library(leaflet)
library(tidyverse)
library(geojsonio)
library(sp)
library(raster)
library(rgdal)
library(htmlwidgets)
library(sf)

buildings <- geojson_sp("data/save_buildings.geojson")

buildings <- spTransform(buildings, CRS("+proj=longlat +init=epsg:4326 +ellps=WGS84 +datum=WGS84 +no_defs"))

buildings$save_ <- factor(buildings$save_)

factpal <- colorFactor(palette = c("#DD8D29", "#E2D200", "#46ACC8", "#E58601") , buildings$save_)


m <- leaflet() %>% 
  addProviderTiles("CartoDB.Positron", group = "Kort") %>% 
  addProviderTiles("Esri.WorldImagery", group="Satelit") %>% 
  addPolygons(data = buildings, popup = ~paste0("<b>", adresse, "</b><p>Saveværdi: ", save_, "</p>"), color = ~factpal(save_)) %>% 
  addLegend(pal = factpal, values = buildings$save_, opacity = 1)


saveWidget(m, file="SAVE_buildings_aarhus.html")
