# app

A [Shiny](http://shiny.rstudio.com/) app will be created in this folder that provides an interactive web interface to data layers, particularly for implementing alternative weights and sliders to ocean use layers for identifying areas of conflict.

You can find this app here:

[ecoquants.shiny.io/nrel-uses](https://ecoquants.shinyapps.io/nrel-uses/)

[![](images/app_screen.png)](https://ecoquants.shinyapps.io/nrel-uses/)


Files hosted here can also be directly run from a local desktop instance of the [R]() statistical programming language:

```r
library(shiny) # install.packages('shiny')
runGitHub('ecoquants/nrel-uses', subdir='app')
```
