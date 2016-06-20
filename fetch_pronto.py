from splinter import Browser
from bs4 import BeautifulSoup
import re
import json

def str_to_seconds(x):
    minsec = [int(s) for s in x.split() if s.isdigit()]
    minsec[0] = minsec[0] * 60
    return sum(minsec)

with Browser() as browser:
    slug = "https://secure.prontocycleshare.com"
    url = slug + "/profile/login"
    browser.visit(url)
    browser.fill('_username', 'zachstednick@yahoo.com')
    browser.fill('_password', 'LJQ8vuK8zs')
    button = browser.find_by_text('Log in!')
    button.click()
    trips_main = browser.html

    main_soup = BeautifulSoup(trips_main)
    trip_link = main_soup.findAll('a', text=re.compile('Trips'))
    browser.visit(slug + trip_link[0]['href'])
    trip_soup = BeautifulSoup(browser.html)
    page_count = trip_soup.find_all('div', {"class":"ed-paginated-navigation__pages-group\
    ed-paginated-navigation__pages-group_jump-to\
    ed-paginated-navigation__jump-to"})

    date, start, end, duration = [], [], [], []

    trip_slug = main_soup.findAll('a', text=re.compile('Trips'))[0]
    for trip_page in range(1, int(page_count[0].get_text().lstrip("/")) + 1):
        browser.visit(slug + trip_slug['href'] + "?pageNumber=" + str(trip_page))

        trip_soup = BeautifulSoup(browser.html.encode('utf-8'))
        for v in trip_soup.find_all('div', {"class":"ed-table__item__info__sub-info\
            ed-table__item__info__sub-info_1 \
            ed-table__item__info__sub-info_trip-start-date"}):
            date.append({'date':v.get_text()})
        for x in trip_soup.find_all('div', {"class":"ed-table__item__info__sub-info\
            ed-table__item__info__sub-info_2 \
            ed-table__item__info__sub-info_trip-start-station"}):
            start.append({'start':x.get_text()})
        for y in trip_soup.find_all('div', {"class":"ed-table__item__info__sub-info\
            ed-table__item__info__sub-info_2\
            ed-table__item__info__sub-info_trip-end-station"}):
            end.append({'end':y.get_text()})
        for z in trip_soup.find_all('div', {"class":"ed-table__item__info\
            ed-table__item__info_trip-duration ed-table__col\
            ed-table__col_trip-duration "}):
            duration.append({'duration':str_to_seconds(z.get_text().strip())})

results = zip(date, start, end, duration)

with open("my_trips.json", "w") as outfile:
    json.dump(results, outfile, indent=4)
