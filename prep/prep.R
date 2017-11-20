# by region, eg east
library(tidyverse)
library(sf)
library(leaflet)
library(jsonlite)
library(rmapshaper)
library(stringr)

# parcels too big ----
#parcels = read_sf('/Users/bbest/github/terrapulse/prep/data/Parcels_SaltLake/Parcels_SaltLake.shp') # n=469K

#parcels %>% st_set_geometry(NULL) %>% View()

#p = parcels[1:100,] %>%
p = parcels %>%
  st_buffer(dist=0) %>%
  st_transform(leaflet:::epsg4326) %>%
  group_by(PARCEL_ZIP) %>%
  summarize(
    n = n()) %>%
  mutate(
    ctr   = st_centroid(geometry),
    ctr_x = st_coordinates(ctr)[,'X'],
    ctr_y = st_coordinates(ctr)[,'Y'])


# poly2ndvi() ----
poly2ndvi = function(poly_id, id_pfx='UT_parcel_Summit_', cache_dir='~/github/terrapulse/map/cache', cache_pfx='ndvi_', cache_zero_pad=5, return_df=T){
  # poly_id = 50; id_pfx='UT_parcel_Summit_'; cache_dir='~/github/terrapulse/map/cache'; cache_pfx='ndvi_'; cache_zero_pad=5
  
  csv_cache = sprintf(paste0('%s/%s%s%0', cache_zero_pad,'d.csv'), cache_dir, cache_pfx, id_pfx, poly_id)
  cat(sprintf('%s - %s\n', basename(csv_cache), Sys.time()))
    
  if (!file.exists(csv_cache)){
    url = sprintf('http://terrapulse.com:8080/_ndvi_poly?id=%s%d', id_pfx, poly_id)
    #browser()
    r = fromJSON(url) %>% as_tibble()
    if (nrow(r)==0)
      r = matrix(rep(NA, 3), ncol=3) %>% as_tibble()
    names(r) = c('date','mean','sd')
    write_csv(r, csv_cache)
  }
  
  if (!return_df) return(NULL)
  
  d = read_csv(csv_cache)
  d
}

# get_last_ndvi() ----
get_last_ndvi = function(...){
  
  #x = zip$ctr_x[49]
  #y = zip$ctr_y[49]
  v = get_ndvi(...) %>% 
    filter(date == last(date))
  
  #browser('get_last_ndvi')
  
  # %>% filter(last(date))
  #.$val %>% last()
  
  i <<- i + 1
  cat(sprintf('%d\n',i))
  if (nrow(v)==0)
    v = NA
  v
}

# fix cache files ----

# for (f in list.files('~/github/terrapulse/map/cache', full.names=T)){ # f = list.files('~/github/terrapulse/map/cache', full.names=T)[4]
#   pfx = str_replace(f, '(.*)_([0-9]+).csv', '\\1')
#   num = str_replace(f, '(.*)_([0-9]+).csv', '\\2')
#   f_new = sprintf('%s_%05d.csv', pfx, as.numeric(num))
#   file.rename(f, f_new)
# }

# Parcels_Summit.shp ----

# in QGIS: added field fid = $id
p_in_shp  = '~/github/terrapulse/prep/data/Parcels_Summit/Parcels_Summit.shp'
p_out_shp = '~/github/terrapulse/map/data/Parcels_Summit_prep.shp'
p = read_sf(p_in_shp) #%>% # nrow(p): 34,873
  #filter(fid < 3800)

p %>% 
  filter(fid > 21471) %>% 
  .$fid %>%
  walk(poly2ndvi, return_df=F)
# ndvi_UT_parcel_Summit_21472.csv - 2017-11-18 17:43:43
# ndvi_UT_parcel_Summit_21524.csv - 2017-11-18 17:45:27



i = 0 # of 34873, start 19:07:25
p = p %>%
  st_transform(leaflet:::epsg4326) %>%
  as_tibble() %>%
  mutate(
    #poly_id   = sprintf('UT_parcel_Summit_%05d', fid),
    ndvi_df   = map(fid, poly2ndvi))

# p$ndvi_df[[51]]
# p$poly_id[[51]]
# d = read_csv('~/github/terrapulse/map/cache/ndvi_UT_parcel_Summit_50.csv')
# as.numeric(d$mean)

p = p %>%
  mutate(
    ndvi_mean = map_dbl(ndvi_df, ~ last(as.numeric(.x$mean))),
    ndvi_sd   = map_dbl(ndvi_df, ~ last(as.numeric(.x$sd))))


#d = poly2ndvi('UT_parcel_Summit_21462')
# TODO: add issue for Min: setup ndvi service to fetch mean+sd for all parcels given date

# TODO: issue for: NDVI raster layer?

library(lubridate)
dt = as_datetime('2017-11-11 19:09:45') - as_datetime('2017-11-11 19:07:25')
as_datetime('2017-11-11 19:30:00') + dt/72 * 34873 # '2017-11-12 22:20:08'

#res = map_df(p$poly_id, ~ get_ndvi(poly_id = .x), .id='poly_id')

# zip ----
zip = read_sf('/Users/bbest/github/terrapulse/prep/data/ZipCodes/ZipCodes.shp')

zip = ms_simplify(zip) %>%
  st_transform(leaflet:::epsg4326) %>%
  mutate(
    ctr   = st_centroid(geometry),
    ctr_x = st_coordinates(ctr)[,'X'],
    ctr_y = st_coordinates(ctr)[,'Y'],
    ndvi  = map2_dbl(ctr_x, ctr_y, get_last_ndvi)) %>% 
  st_set_geometry(zip$geometry) %>%
  select(-ctr) %>% select(-ctr)

zip = zip %>%
  select(-ctr) %>% select(-ctr)
zip$ndvi = unlist(zip$ndvi)

zip
write_sf(zip %>% select(NAME,ndvi), 'app/data/utah_zip.shp')

plot(zip['ndvi'])


#zip0 = zip # zip = zip0

pal = colorNumeric('Greens', domain = zip$ndvi)

leaflet() %>%
  addTiles() %>%
  addPolygons(
    data = zip,
    fillColor = ~pal(ndvi), fillOpacity = 0.9,
    weight = 2, opacity = 1, color = 'white')


library(tidyverse)
library(xts)
library(dygraphs)
library(leaflet)
library(mapview)

x = -108.47892530078518
y =   41.06222969618248


a = 
a %>% dplyr::last(x=.$val)
  filter()

dplyr::last()

x = xts(select(d, -date), order.by=d$date)

dygraph(x, main='Time Series') %>%
  dyAxis('y', label = 'NDVI') %>%
  dyRangeSelector()

#mapview::popupGraph()
# leaflet() %>%
#   addPolygons()


# prep parcels for Min summary service ----
library(sf)
shp = read_sf('/Users/bbest/github/terrapulse/prep/data/Parcels_Summit/Parcels_Summit.shp')
shp = shp %>%
  mutate(
    id_num = row_number(FIPS),
    id_str = sprintf('UT_parcel_Summit_%d', id_num))

write_sf(shp, '/Users/bbest/github/terrapulse/prep/data/Parcels_Summit_id/Parcels_Summit_id.shp')

# prep parcels for mapbox ----
library(sf)
library(geojsonio)

shp = '~/github/terrapulse/prep/data/Parcels_Summit/Parcels_Summit.shp'
geo = '~/github/terrapulse/prep/data/Parcels_Summit/Parcels_Summit.geojson'
mbt = '~/github/terrapulse/prep/data/Parcels_Summit/Parcels_Summit.mbtiles'

# shapefile to geojson, project to geographic 
read_sf(shp) %>%
  st_transform(leaflet:::epsg4326) %>%
  geojson_write(file=geo)

p = read_sf(geo)
  
# https://www.mapbox.com/help/large-data-tippecanoe/
# brew install tippecanoe
if (file.exists(mbt)) unlink(mbt)
cmd = sprintf('tippecanoe -o %s %s', mbt, geo)
system(cmd)

library(httr)

mb_token = 'pk.eyJ1IjoiYmRiZXN0IiwiYSI6ImNqOG91a2pwYjA4ZjIycW1ra3V1a285cXkifQ.gpK5u1-Ak3fK7wrVsEGnwA'
mb_user  = 'bdbest'

# https://www.mapbox.com/api-documentation/?language=cURL#uploads

r = POST(sprintf('https://api.mapbox.com/uploads/v1/%s/credentials?access_token=%s', mb_user, mb_token))
r = GET(sprintf('https://api.mapbox.com/datasets/v1/%s?access_token=%s', mb_user, mb_token))
content(r)

# on mbon.marine.usf.edu

wget https://drive.google.com/uc?export=download&id=0ByStJjVZ7c7mZXpnU0J5a0I5SWc

library(leaflet.mapbox) # devtools::install_github('bhaskarvk/leaflet.mapbox')
mb_token = 'pk.eyJ1IjoiYmRiZXN0IiwiYSI6ImNqOG91a2pwYjA4ZjIycW1ra3V1a285cXkifQ.gpK5u1-Ak3fK7wrVsEGnwA'

leafletMapbox(access_token=mb_token) %>%
  addMapboxTileLayer(mapbox.classicStyleIds$dark)