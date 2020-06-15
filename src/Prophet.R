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

pass_count_all_joined[,y:= rowSums(.SD,na.rm = TRUE),.SDcols = paste0("Boardings.",c("x","y"))]