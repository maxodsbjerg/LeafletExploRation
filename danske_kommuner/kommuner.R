library(leaflet)
library(tidyverse)
library(geojsonio)
library(geojsonsf)
library(sp)
library(raster)
library(rgdal)
library(htmlwidgets)
library(sf)
library(lubridate)
library(beepr)

# Loading DigDag shapefiles from Dataforsyningen https://dataforsyningen.dk/data/3967#profile
digdag <- readOGR(dsn = "/Users/vhol/Documents/Code/2022/LeafletExploRation/danske_kommuner/data/KOMMUNAL_SHAPE_UTM32-EUREF89",
                  layer = "Kommune", verbose = FALSE)
digdag <- spTransform(digdag, CRS("+proj=longlat +init=epsg:4326 +ellps=WGS84 +datum=WGS84 +no_defs"))

# Converting date fields to date format
digdag@data$til <- as_date(digdag@data$til)
digdag@data$fra <- as_date(digdag@data$fra)
sapply(digdag@data, class)

# Creating sf object of contemporary municipalities from 2007 and onwards
kommuner2022<-st_as_sf(digdag)
kommuner2022 <-kommuner2022%>%filter(til > "9998-01-01")

# Loading data from https://noegletal.dk/noegletal/ntStart.html 
## Download data as txt file to get proper encoding
## Further more the data has been transformed a little
population <- read_csv2("danske_kommuner/data/kommune_indbyggere_2007_2022.csv")
population <- dplyr::select(population, -Kom.nr)

# Number of people pr square kilometers
pop_density <- read_csv2("danske_kommuner/data/kommune_befolkningstæthed_2007_2022.csv")
pop_density <- dplyr::select(pop_density, -Kom.nr)

# Municipality namechanges
population %>% 
  mutate(navn = str_replace_all(navn, regex("Aarhus", ignore_case = TRUE), "Århus")) %>% 
  mutate(navn = str_replace_all(navn, regex("Vesthimmerlands", ignore_case = TRUE), "Vesthimmerland")) %>% 
  mutate(navn = str_replace_all(navn, regex("Aabenraa", ignore_case = TRUE), "Åbenrå")) %>%
  mutate(navn = str_replace_all(navn, regex("Høje-Taastrup", ignore_case = TRUE), "Høje Tåstrup")) %>%
  mutate(navn = str_replace_all(navn, regex("Lyngby-Taarbæk", ignore_case = TRUE), "Lyngby-Tårbæk")) %>%
  mutate(navn = str_replace_all(navn, regex("Faaborg-Midtfyn", ignore_case = TRUE), "Fåborg-Midtfyn"))-> population

# Joining sf object with extra data
kommuner2022 <- left_join(kommuner2022, population, by = "navn")
kommuner2022 <- left_join(kommuner2022, pop_density, by = "navn")



#Color palette for populaion
pal <- colorNumeric("YlOrRd", domain = kommuner2022$pop_2022)

# Creating map
m <- leaflet() %>% 
  addProviderTiles("CartoDB.Positron", group = "Kort") %>% # Map background
  addProviderTiles("Esri.WorldImagery", group="Satelit") %>% # Satelitte background
  addPolygons(data = kommuner2022,
              popup = ~paste0('<b>', navn, '</b>'),
              fillColor = ~pal(pop_2022), # Color of fill
              weight = 1, # Size of borders
              opacity = 1, # Opacity of borders
              color = "white", # Color of borders
              dashArray = "1", # Type of borders
              fillOpacity = 0.8) # Opacity of fill

saveWidget(n, file="danske_kommuner/kommuner.html")
beep()