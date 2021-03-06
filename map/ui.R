dashboardPage(
  title = 'terraPulse', skin='black',
  dashboardHeader(
    title=tagList(img(src='images/terrapulse_gray_logo.png'), 'terraPulse Map'),
    titleWidth = 250-43),
  dashboardSidebar(
    width = 250,
    
    # menu ----
    sidebarMenu(
      id = 'menu',
      menuItem(
        tagList(h4(icon('tree'), 'Forest')), tabName = 'forest', selected=T, startExpanded=T),
      menuItem(
        tagList(h4(icon('tint'), 'Water')), tabName = 'water'),
      menuItem(
        tagList(h4(icon('building'), 'Urban')), tabName = 'urban')),
    
    # layers -----
    box(
      style = "background-color: #1e282c;", width=12,
      
      conditionalPanel(
        condition = "input.menu == 'forest'",
        h4('Forest layers:'),
        radioButtons(
          'sel_env_var', label=NULL,
          choiceValues = list('forest_cover','forest_loss'),
          choiceNames = list(
            actionLink('meta_forest_cover', h4('Forest Cover')),
            actionLink('meta_forest_loss' , h4('Forest Loss'))))),
      
      conditionalPanel(
        condition = "input.menu == 'water'",
        h4('Water layers:')),
      
      conditionalPanel(
        condition = "input.menu == 'urban'",
        h4('Urban layers:')))),
  
  # body ----
  dashboardBody(
    tags$head(tags$script(src='style_parcels.js')),
    tags$style(type = "text/css", "#map {height: calc(100vh - 140px) !important;}"),
    tabBox(
      id = 'tab_viz', width=12,
      tabPanel(
        'Spatial',
        leafletOutput('map')),
      tabPanel(
        'Temporal',
          dygraphOutput('ts_dygraph'),
        conditionalPanel(
          condition = "input.sel_mvt_poly === undefined",
          p('Please choose a parcel to see NDVI over time.'))))))