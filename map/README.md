# app

A [Shiny](http://shiny.rstudio.com/) app that provides an interactive map interface to data layers.

You can find this app here:

[bdbest.shinyapps.io/terrapulse-gui](https://bdbest.shinyapps.io/terrapulse-gui/) 

OR

[mbon.marine.usf.edu:3838/terrapulse/map/](http://mbon.marine.usf.edu:3838/terrapulse/map/)

Files hosted here can also be directly run from a local desktop instance of the [R](https://www.r-project.org) statistical programming language:

You'll need to have all the R packages listed in [`global.R`](https://github.com/bbest/terrapulse/blob/master/map/global.R) installed first, including the custom `leaflet.extras` package installable with `devtools::install_github('bbest/leaflet.extras')` after `install.packages('devtools')`.

```r
library(shiny) # install.packages('shiny')
runGitHub('bbest/terrapulse', subdir='map')
```
