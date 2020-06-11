#'mike nugent, jr.
#'data analyst
#'indygo
#'run this one first

library(tidyverse)
library(data.table)

# Connect and Import VMH --------------------------------------------------
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
  setDT()

# get route direction key

ROUTE_DIRECTION <- tbl(con, "ROUTE_DIRECTION") %>%
  collect() %>%
  setDT()

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




PASSENGER_COUNT_raw <-rbind(PASSENGER_COUNT_1,PASSENGER_COUNT_2,PASSENGER_COUNT_3,PASSENGER_COUNT_4,PASSENGER_COUNT_5)

