# load packages
library(tidyverse)
library(stringr)
library(rgdal)
library(sf)
library(raster)
library(leaflet)
library(mapview)
library(rmarkdown)
#library(leaflet.extras) # devtools::install_github('bhaskarvk/leaflet.extras')
library(shiny)
library(shinydashboard)
library(RColorBrewer)
select = dplyr::select

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
# dir_wd = 'app'; if (basename(getwd())!=dir_wd) setwd(dir_wd)


layers = list(
  tcc2015_r = list(
    title = 'Forest Loss',
    url   = 'http://glcfapp07.umd.edu:8080/map/tcc_global_2015_61/{z}/{x}/{y}.png',
    cite  = '© <a href="http://www.terrapulse.com" target="_blank">terraPulse Tree Cover 2015</a>'),
  fcc20102015_r = list(
    title = 'Forest Cover',
    url   = 'http://glcfapp07.umd.edu:8080/map/zforest_loss_2010_2015_v03/{z}/{x}/{y}.png',
    cite  = '© <a href="http://www.terrapulse.com" target="_blank">terraPulse Forest Loss 2010 to 2015</a>'))

