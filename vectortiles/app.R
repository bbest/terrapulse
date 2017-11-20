# Using arbitrary Leaflet plugins with Leaflet for R
# https://gist.github.com/jcheng5/c084a59717f18e947a17955007dc5f92

library(shiny)
library(leaflet)
library(htmltools)
library(htmlwidgets)

ui <- fluidPage(
  leafletOutput('map')) #, tags$head(tags$script(src='Leaflet.MapboxVectorTile.js')))

server <- function(input, output) {
  
  mvtPlugin <- htmlDependency(
    "Leaflet.MapboxVectorTile", "0.1.7",
    src = file.path(getwd(), 'js'),
    script = 'Leaflet.MapboxVectorTile.js')

  registerPlugin <- function(map, plugin) {
    map$dependencies <- c(map$dependencies, list(plugin))
    map
  }
  
  output$map <- renderLeaflet({
    
    leaflet() %>%
      addProviderTiles(providers$OpenStreetMap.BlackAndWhite, group = 'B&W') %>%
      setView(-110, 41, 8) %>%
      registerPlugin(mvtPlugin) %>%
      # Add custom JS here. The `this` refers to the Leaflet (JS) map object.
      onRender("function(el, x) {
        var config = {
          url: 'http://mbon.marine.usf.edu:8080/geoserver/gwc/service/tms/1.0.0/vectortiles:Parcels_Summit_epsg4326@EPSG:900913@pbf/{z}/{x}/{y}.pbf',
          tms: true
        };
        var mvtSource = new L.TileLayer.MVTSource(config);
        this.addLayer(mvtSource);
      }")
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

