#'mike nugent, jr.
#'data analyst
#'indygo


# description -------------------------------------------------------------

# this script relies on Passenger_Count_Raw.csv and VMH_Raw.csv in ~data//raw//
# it outputs 4 files to ~data//processed//:
# pass_count_joined.csv
# pass_count_daily.csv
# VMH_count_daily.csv
# pass_count_all_joined.csv


# libraries ---------------------------------------------------------------

library(data.table)
library(tidyverse)

# read in TMDM ------------------------------------------------------------

pass_count_raw <- fread("data//raw//Passenger_Count_Raw.csv",data.table = TRUE)

# read in the dimtables
#connect
con <- DBI::dbConnect(odbc::odbc(), Driver = "SQL Server", Server = "IPTC-TMDATAMART\\TMDATAMART",
                      Database = "TMDATAMART", 
                      Port = 1433)

# get routes

ROUTE_raw <- tbl(con, "ROUTE") %>% 
  select(ROUTE_ID, Route_name = ROUTE_ABBR) %>%
  collect() %>%
  setDT() %>%
  setkey(ROUTE_ID)

# get stops

GEO_NODE_raw <- tbl(con, "GEO_NODE") %>% 
  select(GEO_NODE_ID, Stop_number = GEO_NODE_ABBR, Stop_name = GEO_NODE_NAME,
         Stop_lat = LATITUDE, Stop_lon = LONGITUDE) %>%
  collect() %>%
  setDT() %>%
  setkey(GEO_NODE_ID)

# get calendar

CALENDAR_raw <- tbl(con, "CALENDAR") %>% 
  select(CALENDAR_ID, CALENDAR_DATE) %>%
  collect() %>%
  setDT() %>%
  setkey(CALENDAR_ID)

# get vehicles

VEHICLE_ID_raw <- tbl(con, "VEHICLE") %>% 
  select(VEHICLE_ID, PROPERTY_TAG) %>%
  collect() %>%
  setDT() %>%
  setkey(VEHICLE_ID)

#join it all to pass_count

pass_count_raw[CALENDAR_raw
               ,on = "CALENDAR_ID"
               ,names(CALENDAR_raw) := mget(paste0("i.",names(CALENDAR_raw)))
               ][ROUTE_raw
                 , on = "ROUTE_ID"
                 ,names(ROUTE_raw) := mget(paste0("i.",names(ROUTE_raw)))
                 ][GEO_NODE_raw
                   , on = "GEO_NODE_ID"
                   ,names(GEO_NODE_raw) := mget(paste0("i.",names(GEO_NODE_raw)))
                   ][VEHICLE_ID_raw
                     ,on = "VEHICLE_ID"
                     ,names(VEHICLE_ID_raw) := mget(paste0("i.",names(VEHICLE_ID_raw)))
                     ]


pass_count_daily <- pass_count_raw[,.(Boardings = sum(BOARD)
                                       ,Alightings = sum(ALIGHT))
                                    ,.(ds = CALENDAR_DATE,
                                       Route = Route_name)] #so named for prophet
pass_count_daily[,y:=Boardings] #also for prophet


# read in VMH -------------------------------------------------------------
VMH_Raw <- fread("data//raw//VMH_Raw.csv",data.table = TRUE)

VMH_count_daily <- VMH_Raw[,.(Boardings = sum(Boards)
                              ,Alightings = sum(Alights))
                           ,.(ds = ymd(Transit_Day,tz = "UTC")
                              ,Route = as.character(Route))]


# join the tables to each other -------------------------------------------

VMH_count_daily[pass_count_daily, on = .(ds,Route)][order(ds)]

pass_count_daily[VMH_count_daily, on = .(ds,Route)][order(ds)]

pass_count_all_joined <- merge.data.table(pass_count_daily,VMH_count_daily,by = c("ds","Route"),all = TRUE)

fwrite(pass_count_raw, "data//processed//pass_count_joined.csv")
fwrite(pass_count_daily, "data//processed//pass_count_daily.csv")
fwrite(VMH_count_daily, "data//processed//VMH_count_daily.csv")
fwrite(pass_count_all_joined,"data//processed//pass_count_all_joined.csv")
