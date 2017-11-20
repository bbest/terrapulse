library(tidyverse)
library(lubridate)

# ndvi_UT_parcel_Summit_21472.csv - 2017-11-18 17:43:43
# ndvi_UT_parcel_Summit_22020.csv - 2017-11-18 18:01:57 -> 2017-11-18 11:34:57 PST

n_last = 22020
ts_last = '2017-11-18 18:01:57'

t_last = as_datetime(ts_last, tz='America/Los_Angeles')
n_total = 34873; n_first = 21472
dt = as_datetime('2017-11-18 17:45:27', tz='America/Los_Angeles') - t_last
t_last + dt/(n_last - n_first) * (n_total - n_last)