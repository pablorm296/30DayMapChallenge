## 00: Set up ==================================================================

# Load libraries
library(tidyverse)
library(ggrepel)
library(rgdal)
library(rgeos)
library(extrafont)

# Clean workspace
rm(list = ls()); gc()

# Source themes
source("Common/ggplot2_theme.R")

## 01: Load data ===============================================================

# You have to decompress the file SHP.zip. 
# After decompression, you should have a dir named SHP with all data

# Load data
centrales <- readOGR(dsn = "08_Yellow/Data/SHP/", layer = "CentralesEléctricas")

# Load administrative shape
MEX_shp <- readOGR(dsn = "08_Yellow/Data/Admin/", layer = "MEX")
USA_shp <- readOGR(dsn =  "08_Yellow/Data/Admin/", layer = "USA")
CAN_shp <- readOGR(dsn = "08_Yellow/Data/Admin/", layer = "CAN")


## 02: Clean data ==============================================================

# Reproject data using INEGI's conical lambert
# Power plant data
centrales %>%
    spTransform(CRS("+proj=lcc +lat_1=17.5 +lat_2=29.5 +lat_0=12 +lon_0=-102 +x_0=2500000 +y_0=0 +datum=WGS84 +units=m +no_defs")) -> centrales

# Administrative boundaries
MEX_shp %>%
    spTransform(CRS("+proj=lcc +lat_1=17.5 +lat_2=29.5 +lat_0=12 +lon_0=-102 +x_0=2500000 +y_0=0 +datum=WGS84 +units=m +no_defs")) -> MEX_shp
USA_shp %>%
    spTransform(CRS("+proj=lcc +lat_1=17.5 +lat_2=29.5 +lat_0=12 +lon_0=-102 +x_0=2500000 +y_0=0 +datum=WGS84 +units=m +no_defs")) -> USA_shp
CAN_shp %>%
    spTransform(CRS("+proj=lcc +lat_1=17.5 +lat_2=29.5 +lat_0=12 +lon_0=-102 +x_0=2500000 +y_0=0 +datum=WGS84 +units=m +no_defs")) -> CAN_shp

# Extract data from power plants database
centrales_data <- centrales@data

# Extract coords
centrales_data$Latitud <- centrales@coords[,2]
centrales_data$Longitud <- centrales@coords[,1]

# Fortify admin boundaries
MEX_fortify <- MEX_shp %>% fortify()
USA_fortify <- USA_shp %>% fortify()
CAN_fortify <- CAN_shp %>% fortify()

# Create a data frame with only Mexico
centrales_data %>%
    filter(Pais == "México") -> centrales_data_mex

## 03: Map data ================================================================

simple_map <- ggplot() +
    geom_polygon(aes(x = long, y = lat, group = group), 
                 colour = NA, fill = "#454545", data = MEX_fortify) +
    geom_polygon(aes(x = long, y = lat, group = group), 
                 colour = NA, fill = "#454545",data = USA_fortify) +
    geom_polygon(aes(x = long, y = lat, group = group), 
                 colour = NA, fill = "#454545",data = CAN_fortify) +
    geom_point(aes(x = Longitud, y = Latitud, size = Total_MW),
               alpha = 0.5,
               colour = "#F5D300", data = centrales_data) +
    scale_size(range = c(0.5, 5), guide = guide_legend(
        direction = "horizontal",
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5
    )) +
    coord_equal() +
    labs(title = "Centrales Eléctricas de América del Norte",
         subtitle = "Capacidad igual o mayor a 100 MW",
         size = "Capacidad en MW",
         caption = "#30DayMapChallenge\nDatos: North American Cooperation on Energy Information (NACEI)\nElaboración: Pablo Reyes Moctezuma") +
    theme_30DayMapChallenge_black()

map_mexico <- ggplot() +
    geom_polygon(aes(x = long, y = lat, group = group), 
                 colour = NA, fill = "#454545", data = MEX_fortify) +
    geom_point(aes(x = Longitud, y = Latitud, size = Total_MW),
               alpha = 0.5,
               colour = "#F5D300", data = centrales_data_mex) +
    scale_size(range = c(0.5, 5), guide = guide_legend(
        direction = "horizontal",
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5
    )) +
    coord_equal() +
    labs(title = "Centrales Eléctricas de México",
         subtitle = "Capacidad igual o mayor a 100 MW",
         size = "Capacidad en MW",
         caption = "#30DayMapChallenge\nDatos: North American Cooperation on Energy Information (NACEI)\nElaboración: Pablo Reyes Moctezuma") +
    theme_30DayMapChallenge_black()

## 04: Save maps ===============================================================

# High res maps
ggsave("08_Yellow/Out/01_simple.png", simple_map, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5)
ggsave("08_Yellow/Out/02_mexico.png", map_mexico, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5)

# Web friendly
ggsave("08_Yellow/Out/03_simple.jpeg", simple_map, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5, quality = 75)
ggsave("08_Yellow/Out/04_mexico.jpeg", map_mexico, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5, quality = 75)

