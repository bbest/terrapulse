library(tidyverse)
library(jsonlite)
library(xts)
library(dygraphs)
library(leaflet)
library(mapview)

x = -108.47892530078518
y =   41.06222969618248
txt = fromJSON(sprintf('http://terrapulse.com:8080/_ndvi?x=%g&y=%g', x, y))

d = tibble(
  date = as.Date(txt$data[,1]),
  NDVI  = as.numeric(txt$data[,2]))
x = xts(select(d, -date), order.by=d$date)

p = dygraph(x) %>%
  dyAxis('y', label = 'NDVI') #%>%

p
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
