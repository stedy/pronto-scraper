library(dplyr)

original <- rjson::fromJSON(file="my_trips.json")

ul <- unlist(original)
lul <- length(ul)

my_data <- data.frame(date = ul[seq(1, lul, by=4)],
                       start = ul[seq(2, lul, by=4)],
                       end = ul[seq(3, lul, by=4)],
                       tripduration = ul[seq(4, lul, by=4)])
my_data[] <- sapply(my_data, as.character)
my_data$date <- unlist(strsplit(my_data$date, ":[0-9][0-9] [AP]M"))

#for demo lets use Key Arena to 2nd & Pine

my_trip_data <-
  my_data %>% subset(start == "Key Arena / 1st Ave N & Harrison St" & end == "2nd Ave & Pine St") %>%
  rename(starttime = date) %>%
  select(starttime, tripduration) %>%
  mutate(group = "My data")

trip_data <- read.csv("~/pronto-stories/data/2015_trip_data.csv") %>%
  subset(from_station_id == "SLU-19" & to_station_id == "CBD-13") %>%
  select(starttime, tripduration) %>%
  mutate(group = "All Riders")

writeout <- rbind(my_trip_data, trip_data) %>%
  mutate(starttime = as.POSIXct(strptime(starttime, "%m/%d/%Y %H:%M"))) %>%
  arrange(starttime)

write.table(writeout, "d3_demo_data.tsv", sep="\t", row.names=F, quote=F)
