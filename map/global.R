# load packages
library(tidyverse)
library(leaflet)
#devtools::load_all('~/github/leaflet.extras')
library(leaflet.extras) # devtools::install_github('bbest/leaflet.extras')
library(rmarkdown)
library(shiny)
library(shinydashboard)
library(jsonlite)
library(xts)
library(RColorBrewer)
library(dygraphs)

select = dplyr::select
addLegend = leaflet::addLegend

# debug ----
# https://shiny.rstudio.com/reference/shiny/latest/shiny-options.html
options(
  shiny.sanitize.errors = F, shiny.autoreload=T,
  shiny.fullstacktrace=F, shiny.stacktraceoffset=T,
  shiny.trace=F, shiny.testmode=F, shiny.minified=T,
  shiny.deprecation.messages=T,
  shiny.reactlog=F)

msg = function(txt, debug=F){
  if (debug)
    cat(sprintf('%s ~ %s\n', txt, Sys.time()), file=stderr())
}

# paths ----
# dir_wd = 'map'; if (basename(getwd())!=dir_wd) setwd(dir_wd)

layers = list(
  tcc2015_r = list(
    title = 'Forest Loss',
    url   = 'http://glcfapp07.umd.edu:8080/map/tcc_global_2015_61/{z}/{x}/{y}.png',
    cite  = '© <a href="http://www.terrapulse.com" target="_blank">terraPulse Tree Cover 2015</a>'),
  fcc20102015_r = list(
    title = 'Forest Cover',
    url   = 'http://glcfapp07.umd.edu:8080/map/zforest_loss_2010_2015_v03/{z}/{x}/{y}.png',
    cite  = '© <a href="http://www.terrapulse.com" target="_blank">terraPulse Forest Loss 2010 to 2015</a>'))

# setwd('app')
#shp = 'data/utah_zip.shp'
#shp = 'prep/data/Parcels_Summit/Parcels_Summit.shp'
#zip = read_sf(shp) # plot(zip['ndvi'])

# zip = zip %>%
#   st_transform(leaflet:::epsg4326) %>%
#   mutate(ndvi = runif(nrow(zip)))
# 
# pal_zip = colorNumeric('Greens', domain = zip$ndvi)

# leaflet() %>%
#   addProviderTiles(providers$Stamen.TonerBackground, group = 'B&W') %>%
#   addPolygons(
#     data = zip, group='zip by NDVI',
#     fillColor = ~pal_zip(ndvi), fillOpacity = 0.7,
#     weight = 2, opacity = 0.7, color = 'white')

# x = -108.47892530078518
# y =   41.06222969618248
# txt = fromJSON(sprintf('http://terrapulse.com:8080/_ndvi?x=%g&y=%g', x, y))
# d = tibble(
#   date = as.Date(txt$data[,1]),
#   NDVI  = as.numeric(txt$data[,2]))
# x = xts(select(d, -date), order.by=d$date)
# p = dygraph(x) %>%
#   dyAxis('y', label = 'NDVI') #%>%

