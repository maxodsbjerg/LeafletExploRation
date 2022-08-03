library(leaflet)
library(tidyverse)
library(geojsonio)
library(sp)
library(raster)
library(rgdal)
library(htmlwidgets)
library(sf)

# Imports data as an sp object (SpatialPolygonsDataFrame) through the geojsonio package.
buildings <- geojson_sp("data/save_buildings.geojson")

# Transforms data  from one CRS (Cordinate reference system to another)
### The spTransform methods provide transformation between datum(s) and conversion between 
### projections (also known as projection and/or re-projection), from one unambiguously specified 
### coordinate reference system (CRS) to another.
### (https://www.rdocumentation.org/packages/rgdal/versions/1.5-32/topics/spTransform-methods)
buildings <- spTransform(buildings, CRS("+proj=longlat +init=epsg:4326 +ellps=WGS84 +datum=WGS84 +no_defs"))

# Encodes the vector data in buildings$save_ as a factor 
### A factor is a variable used to categorize and store data, having a limited number of different values
buildings$save_ <- factor(buildings$save_)

# Creating the color palette for the SAVE value
### As of now this palette is not in use due to custom label names in the map
factpal <- colorFactor(palette = c("#DD8D29", "#E2D200", "#46ACC8", "#FFC0CB"), 
                       buildings$save_)

title_html <- '<div style="width: 400px;">
                <h1 style="font-size: 16px;">Aarhus Kommunes bevaringsværdige bygninger</h1>
                <p style="font-size: 12px;"><em>Baseret på data fra <a href="https://www.opendata.dk/city-of-aarhus/bevaringsvaerdige-bygninger-i-aarhus-kommune">Aarhus Kommune</a></em></p>
                <p style="font-size: 12px;">Kortet viser hvilke bygninger der er vurderet bevaringsværdige og hvilken værdi disse bygninger har fået på SAVE skalaen.</p></div>'

# Creating leaflet map
m <- leaflet() %>% 
  addProviderTiles("CartoDB.Positron", group = "Kort") %>% # Map background
  addProviderTiles("Esri.WorldImagery", group="Satelit") %>% # Satelitte background
  addPolygons(data = buildings, # Add dataset to leaflet map as polygons 
              popup = ~paste0("<b>", adresse, "</b><p>Saveværdi: ", save_, "</p>"), # Creates popup
              color = ~factpal(save_)) %>% # Add custom color palette to polygons
  addLegend(colors = c("#DD8D29", "#E2D200", "#46ACC8", "#FFC0CB"),
            values = buildings$save_, # Add values to legend
            opacity = 1,
            title = "SAVE Værdi",
            labels = c("1 - Højeste bevaringsværdi", "2 - Høj bevaringsværdi",
                       "3 - Middelhøj bevaringsværdi", "4 - Middel bevaringsværdi")) %>%  
  addControl(title_html, position = "bottomright")


# Saves  leaflet map as html file
saveWidget(m, file="SAVE_buildings_aarhus.html")
