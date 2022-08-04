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

# Loading data from https://noegletal.dk/noegletal/ntStart.html 
## Download data as txt file to get proper encoding
## Further more the data has been transformed a little
indbyg2022 <- read_csv2("danske_kommuner/data/kommune_indbyggere_2007_2022.csv")
# Number of people pr square kilometers
mnskr_pr_kvd_km <- read_csv2("danske_kommuner/data/kommune_befolkningstæthed_2007_2022.csv")

# Joins data
kommuner@data <- inner_join(kommuner@data, indbyg2022, by = "KOMNAVN")

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
