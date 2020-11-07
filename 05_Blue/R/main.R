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
riesgo_ageb <- readOGR(dsn = "05_Blue/Data/inundaciones.geojson", layer = "inundaciones")

# Load Lago de Texcoco shape
lago_texcoco <- readOGR(dsn = "05_Blue/Data/cuenca.kml")

## 01: Clean data ==============================================================

# Get data from spatial object
riesgo_ageb_data <- riesgo_ageb@data

# Explore
unique(riesgo_ageb_data$intens_num); unique(riesgo_ageb_data$intensidad)

# Fortify
riesgo_ageb_fortify <- fortify(riesgo_ageb, region = "id")

# Join data with fortified
riesgo_ageb_data %>%
    mutate(id = as.character(id)) %>%
    right_join(riesgo_ageb_fortify) -> riesgo_ageb_fortify

# Fortify lago de texcoco
lago_texcoco_fortify <- fortify(lago_texcoco)

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
map_simple <- riesgo_ageb_fortify %>%
    mutate(intens_num = ifelse(intens_num == "0 a 25", NA, intens_num)) %>%
    mutate(intens_num = factor(intens_num, levels = c("0 a 25", "26 a 49", "50 a 72", "73 a 99", "100"))) %>%
    ggplot() +
    geom_polygon(aes(x = long, y = lat, group = group, fill = intens_num), colour = NA, alpha = 1) +
    geom_sf(colour = "#e6e6e6", alpha = 0.5, size = 0.1, data = osmMxData$osm_lines) +
    scale_fill_brewer(type = "seq", na.translate = F, guide = guide_legend(
        direction = "horizontal",
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5, 
    )) +
    coord_sf() +
    labs(title = "Porcentaje de área inundable por AGEB",
         subtitle = "Ciudad de México",
         fill = "Porcentaje de área inundable") +
    theme_30DayMapChallenge_black()

## ## ##
## Map con el lago de texcoco
map_lago <- riesgo_ageb_fortify %>%
    mutate(intens_num = ifelse(intens_num == "0 a 25", NA, intens_num)) %>%
    mutate(intens_num = factor(intens_num, levels = c("0 a 25", "26 a 49", "50 a 72", "73 a 99", "100"))) %>%
    ggplot() +
    geom_polygon(aes(x = long, y = lat, group = group, fill = intens_num), colour = NA, alpha = 1) +
    geom_sf(colour = "#e6e6e6", alpha = 0.5, size = 0.1, data = osmMxData$osm_lines) +
    geom_polygon(aes(x = long, y = lat, group = group, colour = "Lago de Texcoco"), fill = NA, 
                 data = lago_texcoco_fortify) +
    scale_colour_manual(values = c("Lago de Texcoco" = "#08F7FE"), guide = guide_legend(
        direction = "horizontal",
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5, 
    )) +
    scale_fill_brewer(type = "seq", na.translate = F, guide = guide_legend(
        direction = "horizontal",
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5, 
    )) +
    coord_sf(xlim = c(bbox[2], bbox[4]), ylim = c(bbox[1], bbox[3])) +
    labs(title = "Porcentaje de área inundable por AGEB",
         subtitle = "Ciudad de México",
         colour = "Cuencas",
         fill = "Porcentaje de área inundable") +
    theme_30DayMapChallenge_black()

## 05: Save maps ===============================================================

# High res maps
ggsave("05_Blue/Out/01_simple.png", map_simple, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5)
ggsave("05_Blue/Out/02_texcoco.png", map_lago, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5)

# Web friendly
ggsave("05_Blue/Out/03_simple.jpeg", map_simple, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5, quality = 75)
ggsave("05_Blue/Out/04_texcoco.jpeg", map_lago, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5, quality = 75)