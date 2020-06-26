# this script is for exploring which data need cleaned and/or removed --------
# pass_count
library(data.table)
library(tidyverse)
library(DBI)

# start here for pass_count_explo -----------------------------------------
#lets pull in from the sandbox
con2 <- DBI::dbConnect(odbc::odbc(), Driver = "SQL Server", Server = "REPSQLP01VW", 
                       Database = "StrategicPlanningSandbox", Port = 1433)

pass_count_raw <- dbReadTable(con2,"pass_count_raw") %>% setDT()

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


pass_count_raw[,sum(BOARD),.(PROPERTY_TAG,CALENDAR_DATE)
               ][order(-V1),ggplot(
                 .SD
                 ,aes(CALENDAR_DATE, V1)
               )+
                 geom_point()+
                 ylim(700,3000)]

# let's check routes
pass_count_raw[,unique(Route_name)]

route_names_to_rm <- c("26SN","1826","90")

# okay so there's a bunch of outliers
pass_count_raw[,sum(BOARD),.(PROPERTY_TAG, CALENDAR_DATE)
               ][order(-V1),head(.SD,80)]

pass_count_raw[!Route_name %in% route_names_to_rm,.(BOARD, PROPERTY_TAG, CALENDAR_DATE)
               ]



pass_count_raw[between(CALENDAR_DATE,as.POSIXct("2016-01-01"),as.POSIXct("2018-01-01"))
               #between(as.numeric(PROPERTY_TAG),1700,2300)
               ][order(-BOARD),head(.SD,10000)
                 ][order(-BOARD),ggplot(
                   .SD
                   ,aes(CALENDAR_DATE,BOARD,color = PROPERTY_TAG)
                 )+
                   geom_point()+
                   ylim(0,425)+
                   theme(axis.text.x = element_text(angle = 90))
                 ]

#okay so 1712 is bad lol oops

# start here for pass_count_explo -----------------------------------------
#lets pull in from the sandbox
con2 <- DBI::dbConnect(odbc::odbc(), Driver = "SQL Server", Server = "REPSQLP01VW", 
                       Database = "StrategicPlanningSandbox", Port = 1433)

pass_count_raw <- dbReadTable(con2,"pass_count_raw") %>% setDT()

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

#this will create a plot that shows 1712 is uh, bad
pass_count_raw[between(CALENDAR_DATE,as.POSIXct("2016-01-01"),as.POSIXct("2018-01-01"))
               #between(as.numeric(PROPERTY_TAG),1700,2300)
               ][order(-BOARD),head(.SD,30000)
                 ][order(-BOARD),ggplot(
                   .SD
                   ,aes(CALENDAR_DATE,BOARD,color = PROPERTY_TAG,shape = as.factor(ifelse(PROPERTY_TAG == 1712,1712,"not ")))
                 )+
                   geom_point()+
                   scale_shape_manual(values = c(6,20))+
                   ylim(0,max(BOARD)+10) + 
                   guides(color = FALSE)+
                   labs(shape = "")
                 ]

pass_count_raw[PROPERTY_TAG == 1712
               ,ggplot(
                 .SD
                 ,aes(PROPERTY_TAG,BOARD)
               )+
                 geom_violin()]


#lets look at boards below 80
pass_count_raw[between(BOARD,10,80)& 
                 PROPERTY_TAG != "1712"
               #][order(-BOARD),head(.SD,10000)
               ]%>%ggplot(aes(x=BOARD))+
  geom_bar(aes(y = ..prop..))


pass_count_raw[PROPERTY_TAG!=1712,.N,BOARD
               ][order(BOARD),
                 ggplot(
                   .SD,
                   aes(x=BOARD,y=N)
                 )+geom_col()
                 +xlim(50,500)
                 ]

pass_count_raw[PROPERTY_TAG != 1712 & 
                 BOARD <= 40,sum(BOARD),CALENDAR_DATE
               ][order(-V1)
                 ,ggplot(
                   .SD
                   ,aes(x=CALENDAR_DATE,y=V1)
                 )+
                   geom_point()
                 ]

pass_count_raw[PROPERTY_TAG != 1712 & 
                 BOARD <= 40,sum(BOARD),CALENDAR_DATE
               ]
pass_count_raw[PROPERTY_TAG != 1712 & 
                 BOARD <= 80,sum(BOARD),CALENDAR_DATE
               ]


var(pass_count_raw$BOARD)
mean(pass_count_raw$BOARD)





1.1/159*100
1.4/267*100
p <- pass_count_raw[between(BOARD,10,100)& 
                      PROPERTY_TAG != "1712"
                    ] %>%
  ggplot(aes(x=CALENDAR_DATE,y=BOARD))
