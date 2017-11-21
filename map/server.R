shinyServer(function(input, output, session) {
  
  #session$sendCustomMessage('mvt_data', )
  d = read_csv('data/parcels.csv') %>%
    arrange(fid) %>%
    select(ndvi_mean) #%>%
    #filter(fid < 10)
  
  n_cols = 7
  vals = seq(min(d$ndvi_mean, na.rm=T), ceiling(max(d$ndvi_mean, na.rm=T)*10)/10, length.out=n_cols)
  col_fxn = colorNumeric('Greens', vals)
  cols = col_fxn(vals)
  
  session$sendCustomMessage('handler1', htmlwidgets:::toJSON(d))
  
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
      hideGroup('Forest Cover') %>%
      hideGroup('Forest Loss') %>%
      # addLegend(
      #   'bottomright', opacity=0.8, title='Forest Cover',
      #   values=1:4, labels=c('low',rep('',1),'high','loss <font size="0.7">(2010-2015)</font>'),
      #   colors=c(colorRampPalette(brewer.pal(9,'Greens'))(4)[2:4], 'red')) %>%
      addLegend(
        'bottomright', opacity=0.8, title='NDVI',
        values=vals, pal=col_fxn) %>%
      addScaleBar('bottomleft') %>%
      #setView(lng=-111.0937, lat=39.3210, zoom=7) %>% # Utah zoom
      setView(-111, 41, 10) %>% # Utah Summit zoom
      addMapboxVectorTileLayer(
        'http://mbon.marine.usf.edu:8080/geoserver/gwc/service/tms/1.0.0/vectortiles:Parcels_Summit_epsg4326@EPSG:900913@pbf/{z}/{x}/{y}.pbf', 
        group='Parcels',
        options=tileOptions(
          tms=T,
          debug=F,
          mutexToggle = T,
          getIDForLayerFeature = htmlwidgets::JS('function(feature) { return feature.properties.fid; }'),
          style = htmlwidgets::JS(
            # 0.07705
            paste0("function (feature) {
              getColor = function(v) {
                return ", paste(rev(sprintf("v > %g ? '%s':", vals[-1], cols[-1])), collapse='\n'),
                "v >= 0  ? '", cols[1], "' :
                'gray' ;
              }
            
            //if (feature.properties.fid == 30638){ debugger; }

            var style = {};
            //style.color = getColor(feature.properties.fid);
            style.color = getColor(d.ndvi_mean[feature.properties.fid]);
            style.outline = {
              color: 'lightgray',
              size: 0.5 };
  
            style.selected = {
              color: 'rgba(255,140,0,0.3)',
              outline: {
              color: 'rgba(255,140,0,1)',
                  size: 2}};
  
            return style;
            }")),
          onClick = htmlwidgets::JS(
            "function(evt) {
              //debugger;
              console.log('Click on evt.feature.properties.fid: ' + evt.feature.properties.fid);
              clicked = {
                id: evt.feature.id,
                properties: evt.feature.properties,
                lat: evt.latlng.lat,
                lng: evt.latlng.lng
              }
              Shiny.onInputChange('sel_mvt_poly', clicked)
            }"))) %>%
      addLayersControl(
        baseGroups = c('Parcels','Shaded Relief','B&W'),
        overlayGroups = c('Forest Cover','Forest Loss','Lines','Labels'),
        options = layersControlOptions(collapsed = T))
      # registerPlugin(mvtPlugin) %>%
      # # Add custom JS here. The `this` refers to the Leaflet (JS) map object.
      # onRender("function(el, x) {
      #   var config = {
      #     url: 'http://mbon.marine.usf.edu:8080/geoserver/gwc/service/tms/1.0.0/vectortiles:Parcels_Summit_epsg4326@EPSG:900913@pbf/{z}/{x}/{y}.pbf',
      #     tms: true
      #   };
      #   var mvtSource = new L.TileLayer.MVTSource(config);
      #   this.addLayer(mvtSource);
      # }")
    
  })
  
  # ts ----
  output$ts_dygraph = renderDygraph({
    
    req(input$sel_mvt_poly)
    
    #browser()
    fid = input$sel_mvt_poly$properties$fid
    name = with(input$sel_mvt_poly$properties, sprintf('Parcel %s (%s, %s, FID=%d)', PARCEL_ID, OWN_TYPE, ParcelYear, fid))
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
    
    
    dygraph(x, main=sprintf('NDVI for %s', name)) %>%
      dySeries(c('lwr_sd', 'mean', 'upr_sd')) %>%
      dyAxis('y', label = 'NDVI') %>%
      dyOptions(colors = 'green') %>% 
      dyRangeSelector()  
  })
  
  # meta: info popups ----
  observeEvent(input$meta_forest_cover, { showModal(modalDialog(includeMarkdown('metadata/forest_cover.md'), easyClose=T, title='Forest Cover')) })
  observeEvent(input$meta_forest_loss, { showModal(modalDialog(includeMarkdown('metadata/forest_loss.md'), easyClose=T, title='Forest Loss')) })
  
})
