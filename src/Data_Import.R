#'mike nugent, jr.
#'data analyst
#'indygo


# description -------------------------------------------------------------
#'run this one first to import the data
#'outputs passenger_count_raw.csv and VMH_raw.csv to data//raw//


# libraries ---------------------------------------------------------------
library(tidyverse)
library(data.table)
library(timeDate)
library(lubridate)

# Connect and Import TMDM --------------------------------------------------
con <- DBI::dbConnect(odbc::odbc(), Driver = "SQL Server", Server = "IPTC-TMDATAMART\\TMDATAMART",
                      Database = "TMDATAMART", 
                      Port = 1433)

# pass count, for a few different time frames, this takes like twenty minutes

PASSENGER_COUNT_query_1 <- tbl(con, sql("SELECT
                                      CALENDAR_ID
                                      ,ROUTE_ID
                                      ,GEO_NODE_ID
                                      ,BOARD
                                      ,ALIGHT
                                      ,VEHICLE_ID
                                      ,TRIP_ID
                                      ,PATTERN_ID
                                      ,RUN_ID
                                      ,BLOCK_ID
                                      ,WORK_PIECE_ID
                                      from PASSENGER_COUNT
                                      WHERE CALENDAR_ID > 120091124.0
                                      and CALENDAR_ID < 120120101.0
                                      and (BOARD > 0.0 OR ALIGHT > 0.0)
                                      and REVENUE_ID = 'R'
                                      and PASSENGER_COUNT.TRIP_ID IS NOT NULL
                                      and PASSENGER_COUNT.VEHICLE_ID IN (SELECT dbo.SCHEDULE.VEHICLE_ID
                                      FROM dbo.SCHEDULE with (nolock)
                                      WHERE PASSENGER_COUNT.CALENDAR_ID = dbo.SCHEDULE.CALENDAR_ID
                                      AND PASSENGER_COUNT.TIME_TABLE_VERSION_ID=dbo.SCHEDULE.TIME_TABLE_VERSION_ID
                                      AND PASSENGER_COUNT.ROUTE_ID = dbo.SCHEDULE.ROUTE_ID
                                      AND PASSENGER_COUNT.ROUTE_DIRECTION_ID = dbo.SCHEDULE.ROUTE_DIRECTION_ID
                                      AND PASSENGER_COUNT.TRIP_ID = dbo.SCHEDULE.TRIP_ID
                                      AND PASSENGER_COUNT.GEO_NODE_ID = dbo.SCHEDULE.GEO_NODE_ID)
                                      "))

PASSENGER_COUNT_query_2 <- tbl(con, sql("SELECT
                                      CALENDAR_ID
                                      ,ROUTE_ID
                                      ,GEO_NODE_ID
                                      ,BOARD
                                      ,ALIGHT
                                      ,VEHICLE_ID
                                      ,TRIP_ID
                                      ,PATTERN_ID
                                      ,RUN_ID
                                      ,BLOCK_ID
                                      ,WORK_PIECE_ID
                                      from PASSENGER_COUNT
                                      WHERE CALENDAR_ID >= 120120101.0
                                      and CALENDAR_ID < 120150101.0
                                      and (BOARD > 0.0 OR ALIGHT > 0.0)
                                      and REVENUE_ID = 'R'
                                      and PASSENGER_COUNT.TRIP_ID IS NOT NULL
                                      and PASSENGER_COUNT.VEHICLE_ID IN (SELECT dbo.SCHEDULE.VEHICLE_ID
                                      FROM dbo.SCHEDULE with (nolock)
                                      WHERE PASSENGER_COUNT.CALENDAR_ID = dbo.SCHEDULE.CALENDAR_ID
                                      AND PASSENGER_COUNT.TIME_TABLE_VERSION_ID=dbo.SCHEDULE.TIME_TABLE_VERSION_ID
                                      AND PASSENGER_COUNT.ROUTE_ID = dbo.SCHEDULE.ROUTE_ID
                                      AND PASSENGER_COUNT.ROUTE_DIRECTION_ID = dbo.SCHEDULE.ROUTE_DIRECTION_ID
                                      AND PASSENGER_COUNT.TRIP_ID = dbo.SCHEDULE.TRIP_ID
                                      AND PASSENGER_COUNT.GEO_NODE_ID = dbo.SCHEDULE.GEO_NODE_ID)
                                      "))

PASSENGER_COUNT_query_3 <- tbl(con, sql("SELECT
                                      CALENDAR_ID
                                      ,ROUTE_ID
                                      ,GEO_NODE_ID
                                      ,BOARD
                                      ,ALIGHT
                                      ,VEHICLE_ID
                                      ,TRIP_ID
                                      ,PATTERN_ID
                                      ,RUN_ID
                                      ,BLOCK_ID
                                      ,WORK_PIECE_ID
                                      from PASSENGER_COUNT
                                      WHERE CALENDAR_ID > 120150101.0
                                      and CALENDAR_ID <= 120170101.0
                                      and (BOARD > 0.0 OR ALIGHT > 0.0)
                                      and REVENUE_ID = 'R'
                                      and PASSENGER_COUNT.TRIP_ID IS NOT NULL
                                      and PASSENGER_COUNT.VEHICLE_ID IN (SELECT dbo.SCHEDULE.VEHICLE_ID
                                      FROM dbo.SCHEDULE with (nolock)
                                      WHERE PASSENGER_COUNT.CALENDAR_ID = dbo.SCHEDULE.CALENDAR_ID
                                      AND PASSENGER_COUNT.TIME_TABLE_VERSION_ID=dbo.SCHEDULE.TIME_TABLE_VERSION_ID
                                      AND PASSENGER_COUNT.ROUTE_ID = dbo.SCHEDULE.ROUTE_ID
                                      AND PASSENGER_COUNT.ROUTE_DIRECTION_ID = dbo.SCHEDULE.ROUTE_DIRECTION_ID
                                      AND PASSENGER_COUNT.TRIP_ID = dbo.SCHEDULE.TRIP_ID
                                      AND PASSENGER_COUNT.GEO_NODE_ID = dbo.SCHEDULE.GEO_NODE_ID)
                                      "))

PASSENGER_COUNT_query_4 <- tbl(con, sql("SELECT
                                      CALENDAR_ID
                                      ,ROUTE_ID
                                      ,GEO_NODE_ID
                                      ,BOARD
                                      ,ALIGHT
                                      ,VEHICLE_ID
                                      ,TRIP_ID
                                      ,PATTERN_ID
                                      ,RUN_ID
                                      ,BLOCK_ID
                                      ,WORK_PIECE_ID
                                      from PASSENGER_COUNT
                                      WHERE CALENDAR_ID > 120170101.0
                                      and CALENDAR_ID <= 120190101.0
                                      and (BOARD > 0.0 OR ALIGHT > 0.0)
                                      and REVENUE_ID = 'R'
                                      and PASSENGER_COUNT.TRIP_ID IS NOT NULL
                                      and PASSENGER_COUNT.VEHICLE_ID IN (SELECT dbo.SCHEDULE.VEHICLE_ID
                                      FROM dbo.SCHEDULE with (nolock)
                                      WHERE PASSENGER_COUNT.CALENDAR_ID = dbo.SCHEDULE.CALENDAR_ID
                                      AND PASSENGER_COUNT.TIME_TABLE_VERSION_ID=dbo.SCHEDULE.TIME_TABLE_VERSION_ID
                                      AND PASSENGER_COUNT.ROUTE_ID = dbo.SCHEDULE.ROUTE_ID
                                      AND PASSENGER_COUNT.ROUTE_DIRECTION_ID = dbo.SCHEDULE.ROUTE_DIRECTION_ID
                                      AND PASSENGER_COUNT.TRIP_ID = dbo.SCHEDULE.TRIP_ID
                                      AND PASSENGER_COUNT.GEO_NODE_ID = dbo.SCHEDULE.GEO_NODE_ID)
                                      "))

PASSENGER_COUNT_query_5 <- tbl(con, sql("SELECT
                                      CALENDAR_ID
                                      ,ROUTE_ID
                                      ,GEO_NODE_ID
                                      ,BOARD
                                      ,ALIGHT
                                      ,VEHICLE_ID
                                      ,TRIP_ID
                                      ,PATTERN_ID
                                      ,RUN_ID
                                      ,BLOCK_ID
                                      ,WORK_PIECE_ID
                                      from PASSENGER_COUNT
                                      WHERE CALENDAR_ID > 120190101.0
                                      and CALENDAR_ID <= 120200603.0 
                                      and (BOARD > 0.0 OR ALIGHT > 0.0)
                                      and REVENUE_ID = 'R'
                                      and PASSENGER_COUNT.TRIP_ID IS NOT NULL
                                      and PASSENGER_COUNT.VEHICLE_ID IN (SELECT dbo.SCHEDULE.VEHICLE_ID
                                      FROM dbo.SCHEDULE with (nolock)
                                      WHERE PASSENGER_COUNT.CALENDAR_ID = dbo.SCHEDULE.CALENDAR_ID
                                      AND PASSENGER_COUNT.TIME_TABLE_VERSION_ID=dbo.SCHEDULE.TIME_TABLE_VERSION_ID
                                      AND PASSENGER_COUNT.ROUTE_ID = dbo.SCHEDULE.ROUTE_ID
                                      AND PASSENGER_COUNT.ROUTE_DIRECTION_ID = dbo.SCHEDULE.ROUTE_DIRECTION_ID
                                      AND PASSENGER_COUNT.TRIP_ID = dbo.SCHEDULE.TRIP_ID
                                      AND PASSENGER_COUNT.GEO_NODE_ID = dbo.SCHEDULE.GEO_NODE_ID)
                                      "))

PASSENGER_COUNT_1 <- PASSENGER_COUNT_query_1 %>% collect() %>% setDT()
PASSENGER_COUNT_2 <- PASSENGER_COUNT_query_2 %>% collect() %>% setDT()
PASSENGER_COUNT_3 <- PASSENGER_COUNT_query_3 %>% collect() %>% setDT()
PASSENGER_COUNT_4 <- PASSENGER_COUNT_query_4 %>% collect() %>% setDT()
PASSENGER_COUNT_5 <- PASSENGER_COUNT_query_5 %>% collect() %>% setDT()

#rbind it so we have one big happy data frame
PASSENGER_COUNT_raw <-rbind(PASSENGER_COUNT_1,PASSENGER_COUNT_2,PASSENGER_COUNT_3,PASSENGER_COUNT_4,PASSENGER_COUNT_5)

# Write TMDM ----------------------------------------------------------
fwrite(PASSENGER_COUNT_raw,"data//raw//Passenger_Count_Raw.csv")


# Clean TMDM ----------------------------------------------------------------
rm(list = paste0("PASSENGER_COUNT_",seq_along(1:5)))
rm(list = paste0("PASSENGER_COUNT_query_",seq_along(1:5)))
rm(list = paste0("PASSENGER_COUNT_raw"))


# Connect and Read VMH--------------------------------------------------------------
con2 <- DBI::dbConnect(odbc::odbc(), Driver = "SQL Server", Server = "REPSQLP01VW", 
                      Database = "TransitAuthority_IndyGo_Reporting", 
                      Port = 1433)


VMH_Query <- tbl(con2,sql("select a.Time
                          ,a.Route
                          ,Boards
                          ,Alights
                          ,Trip
                          ,Vehicle_ID
                          ,Stop_Name
                          ,Stop_Id
                          ,Inbound_Outbound
                          ,Departure_Time
                          ,Latitude
                          ,Longitude
                          ,GPSStatus
                          from avl.Vehicle_Message_History a (nolock)
                          left join avl.Vehicle_Avl_History b
                          on a.Avl_History_Id = b.Avl_History_Id
                          where (Boards > 0 or Alights > 0)
                          and a.Time > '20180101'
                          and a.Time < DATEADD(day,1,'20200601')
                          "
                          )#endsql
              )#end tbl

VMH_Raw <- VMH_Query %>% collect() %>% setDT()

VMH_Raw[, c("ClockTime","Date") := list(str_sub(Time, 12, 19),str_sub(Time, 1, 10))
             ][, DateTest := ifelse(ClockTime<"03:00:00",1,0)
               ][, Transit_Day := ifelse(DateTest ==1
                                         ,as_date(Date)-1
                                         ,as_date(Date))
                 ][,Transit_Day := as_date("1970-01-01")+days(Transit_Day)
                   ]

fwrite(VMH_Raw,"data//raw//VMH_Raw.csv")
rm(VMH_Raw)
