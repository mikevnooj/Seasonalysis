#'mike nugent, jr.
#'data analyst
#'indygo


# description -------------------------------------------------------------

# run prophet analysis of daily ridership by route
# relies on pass_count_all_joined.csv

# libraries ---------------------------------------------------------------

library(data.table)
library(prophet)

# first we'll addall the boardings together into a new row labeled y
# prophet needs a y column that contains the data to be forecast
pass_count_all_joined <- fread("data//processed//pass_count_all_joined.csv",data.table = TRUE,colClasses = c("ds"="Date"))
pass_count_all_joined
pass_count_all_joined[,y:= rowSums(.SD,na.rm = TRUE),.SDcols = paste0("Boardings.",c("x","y"))]


# fit the model, we'll use route 8 since its been around for a long time
# we'll try it first without daily.seasonality, and then again with daily seasonality
# fit the model

m <- prophet(pass_count_all_joined[Route==8])

future <- make_future_dataframe(m,periods = 60)

forecast <- predict(m,future)

prophet_plot_components(m,forecast)
dyplot.prophet(m,forecast)

cross_va <- cross_validation(m,initial = 365, period = 180, horizon = 365, units = 'days')

plot_cross_validation_metric(cross_va,'mape')
# okay so that's not uh... not great.
# let's adjust some things

add_country_holidays
# Round 2 -----------------------------------------------------------------
#let's add holidays!
holidays_names <- c("USNewYearsDay", "USMemorialDay",
                    "USIndependenceDay", "USLaborDay",
                    "USThanksgivingDay", "USChristmasDay",
                    "USMLKingsBirthday")

holidays <- as.Date(holiday(2000:2020, holidays_names))


#transform
m <- prophet(pass_count_all_joined[Route == 4]
             ,changepoint.prior.scale = .8 #greater flexibility
             )

future <- make_future_dataframe(m,periods = 60)

forecast <- predict(m,future)

prophet_plot_components(m,forecast)


dyplot.prophet(m,forecast)  + add_changepoints_to_plot(m)

cross_va <- cross_validation(m,initial = 450, period = 180, horizon = 365, units = 'days')

plot_cross_validation_metric(cross_va,'mape')
performance_metrics(cross_va)


# weekday ridership -------------------------------------------------------
#okay we're going to abandon that for a minute, let's just look at weekdays

# special
# define holidays
holidays_names <- c("USNewYearsDay", "USMemorialDay",
                    "USIndependenceDay", "USLaborDay",
                    "USThanksgivingDay", "USChristmasDay",
                    "USMLKingsBirthday")

NewYears <- data.table(
  holiday = holidays_names[1]
  ,ds =holiday(2000:2020,holidays_names[1])
  ,lower_window = 0
  ,upper_window = 0
  )

d<-map(holidays_names,function(holidays_names){
  data.table(
    holiday = holidays_names
    ,ds = as.Date(holiday(2000:2020,holidays_names))
    ,lower_window = 0
    ,upper_window = 0
 )
})

holidays <- rbindlist(d)


#plug em in

m <- prophet(
  seasonality.mode = 'multiplicative'
  ,holidays = holidays
  )
#add polar vortex

pass_count_all_joined[Route == 8 &
                        year(ds) == 2015 &
                        month(ds)==1,plot(ds,y)]

future <- make_future_dataframe(m,periods = 365) %>%
  filter(wday(ds,week_start = 1)<6)

forecast <- predict(m,future)

prophet_plot_components(m,forecast)

dyplot.prophet(m,forecast)

m.cv <- cross_validation(m,365.25,units = "days")

plot_cross_validation_metric(m.cv, "mae")

