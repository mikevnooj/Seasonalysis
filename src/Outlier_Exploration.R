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



#lets look at boards below 80
pass_count_raw[between(BOARD,7,80)& 
                 PROPERTY_TAG != "1712"
               #][order(-BOARD),head(.SD,10000)
               ]%>%ggplot(aes(x=BOARD))+
  geom_bar(aes(y = ..prop..))


pass_count_raw[PROPERTY_TAG!=1712,.N,BOARD
               ][BOARD > 40,
                 ggplot(
                   .SD,
                   aes(x=BOARD,y=N)
                 )+geom_col()
                 #+xlim(0,500)
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


names(pass_count_raw)


1.1/159*100
1.4/267*100
p <- pass_count_raw[between(BOARD,10,100)& 
                      PROPERTY_TAG != "1712"
                    ] %>%
  ggplot(aes(x=PROPERTY_TAG,y=BOARD))

#to make pass count a ts object we first must find out if there are any gaps in the date data
daily_sum_one <- pass_count_raw[VEHICLE_ID != 1712 &
                              between(BOARD,0,50),.(boardings = sum(BOARD)),.(date = as.Date(CALENDAR_DATE))
                            ][order(date)]

daily_sum_two <- pass_count_raw[,.(boardings = sum(BOARD)),.(date = as.Date(CALENDAR_DATE))
                                ][order(date)]

weekly_average_one <- daily_sum[,.(boardings = mean(boardings)),.(year(date),isoweek(date))][order(year,isoweek)]
weekly_average_two <- daily_sum_two[,.(boardings = mean(boardings)),.(year(date),isoweek(date))][order(year,isoweek)]

start_date <- as.Date(pass_count_raw[,min(CALENDAR_DATE)])
end_date  <- as.Date(pass_count_raw[,max(CALENDAR_DATE)])

to_convert_one <- merge(daily_sum_one,data.table(date=seq(start_date,end_date,"days")),all = TRUE)
to_convert_two <- merge(daily_sum_two,data.table(date=seq(start_date,end_date,"days")),all=TRUE)

daily_ts_one <- ts(to_convert_one[,boardings],frequency = 365,start = c(year(start_date), as.numeric(format(start_date, "%j"))))
daily_ts_one <- ts(to_convert_two[,boardings],frequency = 365,start = c(year(start_date), as.numeric(format(start_date, "%j"))))

weekly_ts_one <- ts(weekly_average_one$boardings,frequency = 52,start = c(as.numeric(year(start_date)),as.numeric(isoweek(start_date))))
weekly_ts_two <- ts(weekly_average_two$boardings,frequency = 52,start = c(as.numeric(year(start_date)),as.numeric(isoweek(start_date))))


plot(weekly_ts_one)
plot(weekly_ts_two)
ggAcf(weekly_ts)


