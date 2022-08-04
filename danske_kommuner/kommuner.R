library(leaflet)
library(tidyverse)
library(geojsonio)
library(geojsonsf)
library(sp)
library(raster)
library(rgdal)
library(htmlwidgets)
library(sf)
library(dplyr)

# Imports data as an sf object through the geojsonsf package.
### Data from https://lab.information.dk/ 
kommuner <- geojson_sf("danske_kommuner/data/dagi_ref_kommuner.geojson")

# Data has unneeded Z dimension. Removes this and converts to sp object
kommuner <- st_zm(kommuner)
kommuner <- as(kommuner, Class = "Spatial")

kommuner <- spTransform(kommuner, CRS("+proj=longlat +init=epsg:4326 +ellps=WGS84 +datum=WGS84 +no_defs"))

# Loading data from https://noegletal.dk/noegletal/ntStart.html 
## Download data as txt file to get proper encoding
## Further more the data has been transformed a little
population <- read_csv2("danske_kommuner/data/kommune_indbyggere_2007_2022.csv")
population <- dplyr::select(population, -Kom.nr)

# Number of people pr square kilometers
pop_density <- read_csv2("danske_kommuner/data/kommune_befolkningstæthed_2007_2022.csv")
pop_density <- dplyr::select(pop_density, -Kom.nr)

# Joins data
kommuner@data <- inner_join(kommuner@data, population, by = "KOMNAVN")
kommuner@data <- inner_join(kommuner@data, pop_density, by = "KOMNAVN")

#Color palette for populaion
pal <- colorBin("YlOrRd", domain = indbyg2022$"2022")

# Creating map
m <- leaflet() %>% 
  addProviderTiles("CartoDB.Positron", group = "Kort") %>% # Map background
  addProviderTiles("Esri.WorldImagery", group="Satelit") %>% # Satelitte background
  addPolygons(data = kommuner,
              popup = ~paste0('<b>', KOMNAVN, ' Kommune</b>'),
              fillColor = ~pal(indbyg2022$"2022"),
              weight = 2,
              opacity = 1,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7)
                              
saveWidget(m, file="danske_kommuner/kommuner.html")
