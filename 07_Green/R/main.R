## 00: Set up ==================================================================

# Load libraries
library(tidyverse)
library(ggrepel)
library(osmdata)
library(rgdal)
library(rgeos)
library(extrafont)

# Clean workspace
rm(list = ls()); gc()

# Source themes
source("Common/ggplot2_theme.R")

## 01: Load data ===============================================================

# You have to decompress the files inundaciones.zip and cuenca.zip. 
# After decompression, you must have a file named inundaciones.geojson and a file named cuenca.kml

# Load data
areas_verdes <- readOGR(dsn = "07_Green/Data/verdes.geojson", layer = "verdes")

## 01: Clean data ==============================================================

# Fortify
areas_verdes_fortify <- fortify(areas_verdes)

## 02: Get osm data ============================================================

# Get roads of Mexico City using osmdata
osmMxData <- opq("Mexico City") %>%
    add_osm_feature(key = 'highway', value = c('motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified')) %>%
    osmdata_sf ()

# Get bbox
bbox <- str_split(osmMxData$bbox, pattern = ",")[[1]] %>%
    as.numeric()

## 04: Map data ================================================================

## ## ##
## Simple map
map_simple <- ggplot() +
    geom_polygon(aes(x = long, y = lat, group = group), colour = "#1a9340", 
                 fill = "#1a9340", alpha = 0.6, data = areas_verdes_fortify) +
    geom_sf(colour = "#65654e", alpha = 0.5, size = 0.1, data = osmMxData$osm_lines) +
    scale_fill_brewer(type = "seq", na.translate = F, guide = guide_legend(
        direction = "horizontal",
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5
    )) +
    coord_sf() +
    labs(title = "Áreas verdes de la Ciudad de México",
         fill = "Porcentaje de área inundable",
         caption = "#30DayMapChallenge\nDatos: ADIP y OpenStreetMap\nElaboración: Pablo Reyes Moctezuma") +
    theme_30DayMapChallenge_clear()

## 05: Save maps ===============================================================

# High res maps
ggsave("07_Green/Out/01_simple.png", map_simple, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5)

# Web friendly
ggsave("07_Green/Out/02_simple.jpeg", map_simple, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5, quality = 75)