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
library(anytime)

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
                                    ,.(ds = as.IDate(CALENDAR_DATE),
                                       Route = Route_name)] #so named for prophet
pass_count_daily[,y:=Boardings] #also for prophet



# read in VMH -------------------------------------------------------------
VMH_Raw <- fread("data//raw//VMH_Raw.csv",data.table = TRUE)


# clean VMH ---------------------------------------------------------------
#fix time and date formats
VMH_Raw[,Time := fasttime::fastPOSIXct(Time,tz = "UTC")
        ][,Transit_Day := as.IDate(Transit_Day)]

routes_to_remove <- c(65535,999,0,1826,32855,4864,32771,12432)

VMH_Raw <- VMH_Raw[!Route %in% routes_to_remove
                   ][!VMH_Vehicles_to_rm,on = c("Vehicle_ID","Transit_Day")]

nrow(VMH_Raw)

VMH_count_daily <- VMH_Raw[,.(Boardings = sum(Boards)
                              ,Alightings = sum(Alights))
                           ,.(ds = Transit_Day
                              ,Route = as.character(Route))]


# join the tables to each other -------------------------------------------

VMH_count_daily[pass_count_daily, on = .(ds,Route)][order(ds)]

pass_count_daily[VMH_count_daily, on = .(ds,Route)][order(ds)]

pass_count_all_joined <- merge.data.table(pass_count_daily,VMH_count_daily,by = c("ds","Route"),all = TRUE)

merge.data.table(pass_count_daily,VMH_count_daily,by = c("ds","Route"))



fwrite(pass_count_raw, "data//processed//pass_count_joined.csv")
fwrite(pass_count_daily, "data//processed//pass_count_daily.csv")
fwrite(VMH_count_daily, "data//processed//VMH_count_daily.csv")
fwrite(pass_count_all_joined,"data//processed//pass_count_all_joined.csv")






# this section is for exploring which data need cleaned and/or removed --------
# start with VMH



VMH_Raw[between(Transit_Day,as.IDate("2019-09-12"),as.IDate("2020-03-01")),sum(Boards),.(Vehicle_ID, Transit_Day)
        ][order(-V1),
          ggplot(
            .SD
            ,aes(Transit_Day,V1,color = as.factor(ifelse(Vehicle_ID %in% c("1988","1986","1993","1994"),Vehicle_ID,0)))
            )+
            geom_point()+
            ylim(500,5000)+
            labs(color = "")+
            theme(axis.text.x = element_text(angle = 90))]

# so there's a lot of super high bangers here, not so good
# we need to clean routes first i think

routes_to_remove <- c(65535,999,0,1826,32855,4864,32771,12432)

VMH_Raw <- VMH_Raw[!Route %in% routes_to_remove]

# alright, now let's look at our vehicles
VMH_Raw[
  #Transit_Day > "2019-09-22" 
  #& Transit_Day < "2020-02-24",
  ,.(Boards, Vehicle_ID, Time)
  ][order(-Boards),head(.SD,10000)
    ][order(-Boards),ggplot(
      .SD,
      aes(Time,Boards,color = as.factor(ifelse(Vehicle_ID %in% c("1988","1986","1993","1994"),"problem","ok")))
      )+
        geom_violin()+
        labs(color = "")
      ]

# better, let's get our top offenders and remove them
VMH_Vehicles_to_rm <- VMH_Raw[,sum(Boards),.(Vehicle_ID,Transit_Day)
                              ][order(-V1),head(.SD,59)][,.(Vehicle_ID,Transit_Day)]

# annnnnd plot
VMH_Raw[!VMH_Vehicles_to_rm,on = c("Vehicle_ID","Transit_Day")
        ][order(-Boards),head(.SD,10000)
          ][order(-Boards),ggplot(
            .SD,
            aes(Time,Boards,color = as.factor(ifelse(Vehicle_ID %in% c("1988","1986","1993","1994"),"problem","ok")))
            )+
              geom_point()+
              labs(color = "")
          ]

# looks much better

VMH_Raw[!VMH_Vehicles_to_rm,on = c("Vehicle_ID","Transit_Day")]



VMH_count_daily <- VMH_Raw[,.(Boardings = sum(Boards)
                              ,Alightings = sum(Alights))
                           ,.(ds = Transit_Day
                              ,Route = as.character(Route))]

pass_count_raw[,unique(Route_name)]

pass_count_raw[,sum(BOARD),.(PROPERTY_TAG,CALENDAR_DATE)
               ][order(-V1),ggplot(
                 .SD
                 ,aes(CALENDAR_DATE, V1)
                 )+
                 geom_point()+
                   ylim(700,3000)]


