shinyServer(function(input, output, session) {
  
  # map ----
  output$map <- renderLeaflet({

    leaflet() %>%
      addProviderTiles(providers$Stamen.TonerBackground, group = 'B&W') %>%
      addProviderTiles(providers$Esri.WorldShadedRelief, group = 'Shaded Relief') %>%
      addTiles(
        urlTemplate=layers$tcc2015_r$url, attribution=layers$tcc2015_r$cite, options=tileOptions(tms=T, opacity=0.5), group='Forest Cover') %>%
      addTiles(
        urlTemplate=layers$fcc20102015_r$url, attribution=layers$fcc20102015_r$cite, options=tileOptions(tms=T, opacity=0.8), group='Forest Loss') %>%
      # addPolygons(
      #   data = zip, group='zip by NDVI',
      #   fillColor = ~pal_zip(ndvi), fillOpacity = 0.7,
      #   weight = 2, opacity = 0.7, color = 'white') %>%
        #popup = mapview::popupGraph(p, type='html')) %>%
      addProviderTiles(providers$Stamen.TonerLines, group = 'Lines') %>%
      addProviderTiles(providers$Stamen.TonerLabels, group = 'Labels') %>%
      addLayersControl(
        baseGroups = c('Shaded Relief','B&W'),
        overlayGroups = c('Forest Cover','Forest Loss','zip by NDVI','Lines','Labels'),
        options = layersControlOptions(collapsed = T)) %>%
      hideGroup('zip by NDVI') %>%
      addLegend(
        'bottomright', opacity=0.8, title='Forest Cover',
        values=1:4, labels=c('low',rep('',1),'high','loss <font size="0.7">(2010-2015)</font>'),
        colors=c(colorRampPalette(brewer.pal(9,'Greens'))(4)[2:4], 'red')) %>%
      addScaleBar('bottomleft') %>%
      setView(lng=-111.0937, lat=39.3210, zoom=7) # Utah zoom
    
  })
  
  # meta: info popups ----
  observeEvent(input$meta_forest_cover, { showModal(modalDialog(includeMarkdown('metadata/forest_cover.md'), easyClose=T, title='Forest Cover')) })
  observeEvent(input$meta_forest_loss, { showModal(modalDialog(includeMarkdown('metadata/forest_loss.md'), easyClose=T, title='Forest Loss')) })
  
})
