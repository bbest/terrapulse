library(tidyverse)
library(jsonlite)
library(xts)
#library(lubridate)
library(dygraphs)
library(leaflet)
library(mapview)

#x = -108.47892530078518
#y =   41.06222969618248
#txt = fromJSON(sprintf('http://terrapulse.com:8080/_ndvi?x=%g&y=%g', x, y))

fid = 27312
url = sprintf('http://terrapulse.com:8080/_ndvi_poly?id=UT_parcel_Summit_%d', fid)
d = fromJSON(url) %>% as_tibble()
if (nrow(d)==0)
  d = matrix(rep(NA, 3), ncol=3) %>% as_tibble()
d = d %>%
  select(date=1, mean=2, sd=3) %>%
  mutate(
    date = as.Date(date),
    mean = as.numeric(mean),
    sd   = as.numeric(sd),
    lwr_sd = mean - sd,
    upr_sd = mean + sd) %>%
  select(-sd)

x = xts(select(d, -date), order.by=d$date)

dygraph(x, main=sprintf('NDVI for Parcel (%d)', fid)) %>%
  dySeries(c('lwr_sd', 'mean', 'upr_sd')) %>%
  dyAxis('y', label = 'NDVI') %>%
  dyOptions(colors = 'green') %>% 
  dyRangeSelector()

  #dyRangeSelector()

leaflet() %>%
  addProviderTiles(providers$Stamen.TonerBackground, group = 'B&W') %>%
  addPolygons(
    data = zip, group='zip by NDVI',
    fillColor = ~pal_zip(ndvi), fillOpacity = 0.7,
    weight = 2, opacity = 0.7, color = 'white',
    popup = mapview::popupGraph(p))

#mapview::popupGraph()
# leaflet() %>%
#   addPolygons()
