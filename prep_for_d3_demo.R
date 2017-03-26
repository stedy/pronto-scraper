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

#lets demo with a common route

my_trip_data <-
  my_data %>% subset(start == "Fred Hutchinson Cancer Research Center / Fairview Ave N & Ward St" & end == "Westlake Ave & 6th Ave") %>%
  rename(starttime = date) %>%
  mutate(tripduration = as.numeric(tripduration)) %>%
  select(starttime, tripduration) %>%
  mutate(group = "My data")

trip_data <- read.csv("2016-12_trip_data.csv") %>%
  subset(from_station_id == "EL-01" & to_station_id == "SLU-15" &
           usertype == "Member") %>%
  select(starttime, tripduration) %>%
  mutate(group = "All Riders")

writeout <- rbind(my_trip_data, trip_data) %>%
  mutate(starttime = as.POSIXct(strptime(starttime, "%m/%d/%Y %H:%M"))) %>%
  mutate(my_besttime = min(my_trip_data$tripduration),
         route_besttime = min(trip_data$tripduration)) %>%
  mutate(drop = ifelse(round(tripduration) %in% my_trip_data$tripduration & group == "All Riders", F, T)) %>%
  subset(drop == T) %>%
  arrange(starttime)

write.table(writeout, "d3_demo_data.tsv", sep="\t", row.names=F, quote=F)
