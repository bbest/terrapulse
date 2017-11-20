dashboardPage(
  title = 'terraPulse', skin='black',
  dashboardHeader(
    title=tagList(img(src='images/terrapulse_gray_logo.png'), 'terraPulse Dashboard'),
    titleWidth = 320-43),
  dashboardSidebar(
    width = 320,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard"),
      menuItem("Raw data", tabName = "rawdata")
    ),
    selectInput('sel_place', 'Pick a place', c('A','B','C','New...')),
    sliderInput("rateThreshold", "Warn when Forest cover score exceeds",
      min = 0, max = 50, value = 3, step = 0.1)),
  dashboardBody(
    tabItems(
      tabItem("dashboard",
        fluidRow(
          valueBoxOutput("rate"),
          valueBoxOutput("count"),
          valueBoxOutput("users")
        ),
        fluidRow(
          box(
            width = 8, status = "info", solidHeader = TRUE,
            title = "Popularity by package (last 5 min)",
            bubblesOutput("packagePlot", width = "100%", height = 600)
          ),
          box(
            width = 4, status = "info",
            title = "Top packages (last 5 min)",
            tableOutput("packageTable")
          )
        )
      ),
      tabItem("rawdata",
        numericInput("maxrows", "Rows to show", 25),
        verbatimTextOutput("rawtable"),
        downloadButton("downloadCsv", "Download as CSV")
      )
    )
  )
)

