#'mike nugent, jr.
#'data analyst
#'indygo


# description -------------------------------------------------------------

# run prophet analysis of daily ridership by route
# relies on pass_count_all_joined.csv

# libraries ---------------------------------------------------------------

library(data.table)
library(prophet)



# read in data ------------------------------------------------------------
# first we'll addall the boardings together into a new row labeled y
# prophet needs a y column that contains the data to be forecast
pass_count_all_joined <- fread("data//processed//pass_count_all_joined.csv",data.table = TRUE,colClasses = c("ds"="Date"))

pass_count_all_joined[,y:= rowSums(.SD,na.rm = TRUE),.SDcols = paste0("Boardings.",c("x","y"))]



# mape function -----------------------------------------------------------

mape <- function(y,yhat){
  paste0(
    round(
      mean((abs(y - yhat)/y)*100)
    ,3)
      ,"%")
    }



# hyperparameters ---------------------------------------------------------
# define holidays
holidays_names <- c("USNewYearsDay", "USMemorialDay",
                    "USIndependenceDay", "USLaborDay",
                    "USThanksgivingDay", "USChristmasDay",
                    "USMLKingsBirthday")

#holiday data frame function
make_holiday_data_frame <- function(holidays_names,start_year,end_year){
  holiday_list <- map(
    holidays_names
    ,function(holidays_names){
      d <- data.table::data.table(
        holiday = holidays_names
        ,ds = as.Date(timeDate::holiday(start_year:end_year,holidays_names))
      ) #end data.table
      
    }#end function(holidays_names)
  )#end map
  
  data.table::rbindlist(holiday_list)
}


holidays <- make_holiday_data_frame(holidays_names,2000,2025)

#create the prophet object
m <- prophet(
  daily.seasonality = FALSE
  ,weekly.seasonality = FALSE
  ,yearly.seasonality = FALSE
  ,holidays = holidays
  ,holidays.prior.scale = 10
  ,growth = 'linear'
  )

#add yearly
m <- add_seasonality(
  m
  ,name = 'yearly'
  ,period = 365.25
  ,fourier.order = 20
)

#add quarterly
m <- add_seasonality(
  m
  ,name = 'quarterly'
  ,period = 365.25/4
  ,fourier.order = 5
)

#add monthly
m <- add_seasonality(
  m
  ,name = 'monthly'
  ,period = 30.5
  ,fourier.order = 3
)

#add weekly
m <- add_seasonality(
  m
  ,name = 'weekly'
  ,period = 7
  ,fourier.order = 15
)

m <- fit.prophet(m,pass_count_all_joined[Route == 8])

future <- make_future_dataframe(m,periods = 365)

forecast <- predict(m,future)

prophet_plot_components(m,forecast)

dyplot.prophet(m,forecast)

m.cv <- cross_validation(m,365.25,units = "days")

plot_cross_validation_metric(m.cv, "mae")


