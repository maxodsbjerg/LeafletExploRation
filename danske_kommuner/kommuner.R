library(leaflet)
library(tidyverse)
library(geojsonio)
library(geojsonsf)
library(sp)
library(raster)
library(rgdal)
library(htmlwidgets)
library(sf)

# Imports data as an sf object through the geojsonsf package.
### Data from https://lab.information.dk/ 
kommuner <- geojson_sf("data/dagi_ref_kommuner.geojson")

# Data has unneeded Z dimension. Removes this and converts to sp object
kommuner <- st_zm(kommuner)
kommuner <- as(kommuner, Class = "Spatial")

kommuner <- spTransform(kommuner, CRS("+proj=longlat +init=epsg:4326 +ellps=WGS84 +datum=WGS84 +no_defs"))

m <- leaflet() %>% 
  addProviderTiles("CartoDB.Positron", group = "Kort") %>% # Map background
  addProviderTiles("Esri.WorldImagery", group="Satelit") %>% # Satelitte background
  addPolygons(data = kommuner)

saveWidget(m, file="danske_kommuner/kommuner.html")
