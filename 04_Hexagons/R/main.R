## 00: Set up ==================================================================

# Load libraries
library(tidyverse)
library(ggrepel)
library(osmdata)
library(lubridate)
library(extrafont)

# Clean workspace
rm(list = ls()); gc()

# Source themes
source("Common/ggplot2_theme.R")

## 01: Load data ===============================================================

# Before running this part of the code, make sure that you have decompressed the
# zip file in 04_Hexagons/Data. You should have a file named listings.csv after decompression

# Load data
listings <- read.csv("04_Hexagons/Data/listings.csv", stringsAsFactors = F)

## 02: Clean data ==============================================================

# Get only private rooms
listings_private <- listings %>%
    filter(room_type == "Private room") 

# Get only full home/apts
listings_entire <- listings %>%
    filter(room_type == "Entire home/apt") 

# Get only Shared room
listings_shared <- listings %>%
    filter(room_type == "Shared room") 


## 03: Download OSM data =======================================================

# Get roads using osmdata
osmData <- opq("Mexico City") %>%
    add_osm_feature(key = 'highway', value = c('motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified')) %>%
    osmdata_sf()

## 04: Map data ================================================================

# # #
# All units
# # #
airbnb_map <- ggplot() + 
    geom_sf(colour = "#bcbca9", data = osmData$osm_lines) +
    geom_hex(aes(x = longitude, y = latitude), colour = NA, data = listings, 
             bins = 60, alpha = 0.8) +
    scale_fill_viridis_c(guide = guide_colorbar(
        direction = "horizontal",
        barheight = unit(10, units = "points"),
        barwidth = unit(200, units = "points"),
        draw.ulim = T,
        draw.llim = T,
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5
    )) +
    labs(title = "Densidad de Airbnbs en la Ciudad de México",
         fill = "Número de Airbnbs",
         caption = "#30DayMapChallenge\nDatos: Inside Airbnb\nElaboración: Pablo Reyes Moctezuma") +
    theme_30DayMapChallenge_clear()

# # #
# Entire apts/homes
# # #
airbnb_entire_map <- ggplot() + 
    geom_sf(colour = "#bcbca9", data = osmData$osm_lines) +
    geom_hex(aes(x = longitude, y = latitude), colour = NA, data = listings_entire, 
             bins = 60, alpha = 0.8) +
    scale_fill_viridis_c(guide = guide_colorbar(
        direction = "horizontal",
        barheight = unit(10, units = "points"),
        barwidth = unit(200, units = "points"),
        draw.ulim = T,
        draw.llim = T,
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5
    )) +
    labs(title = "Densidad de Airbnbs en la Ciudad de México",
         subtitle = "Sólo alojamientos que ofrecen depto./casa completa",
         fill = "Número de Airbnbs",
         caption = "#30DayMapChallenge\nDatos: Inside Airbnb\nElaboración: Pablo Reyes Moctezuma") +
    theme_30DayMapChallenge_clear()

# # #
# Private rooms
# # #
airbnb_private_map <- ggplot() + 
    geom_sf(colour = "#bcbca9", data = osmData$osm_lines) +
    geom_hex(aes(x = longitude, y = latitude), colour = NA, data = listings_private, 
             bins = 60, alpha = 0.8) +
    scale_fill_viridis_c(guide = guide_colorbar(
        direction = "horizontal",
        barheight = unit(10, units = "points"),
        barwidth = unit(200, units = "points"),
        draw.ulim = T,
        draw.llim = T,
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5
    )) +
    labs(title = "Densidad de Airbnbs en la Ciudad de México",
         subtitle = "Sólo alojamientos que ofrecen cuartos privados",
         fill = "Número de Airbnbs",
         caption = "#30DayMapChallenge\nDatos: Inside Airbnb\nElaboración: Pablo Reyes Moctezuma") +
    theme_30DayMapChallenge_clear()

# # #
# Shared rooms
# # #
airbnb_shared_map <- ggplot() + 
    geom_sf(colour = "#bcbca9", data = osmData$osm_lines) +
    geom_hex(aes(x = longitude, y = latitude), colour = NA, data = listings_shared, 
             bins = 60, alpha = 0.8) +
    scale_fill_viridis_c(guide = guide_colorbar(
        direction = "horizontal",
        barheight = unit(10, units = "points"),
        barwidth = unit(200, units = "points"),
        draw.ulim = T,
        draw.llim = T,
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5
    )) +
    labs(title = "Densidad de Airbnbs en la Ciudad de México",
         subtitle = "Sólo alojamientos que ofrecen cuartos compartidos",
         fill = "Número de Airbnbs",
         caption = "#30DayMapChallenge\nDatos: Inside Airbnb\nElaboración: Pablo Reyes Moctezuma") +
    theme_30DayMapChallenge_clear()

## 05: Write data ==============================================================

# High res maps
ggsave("04_Hexagons/Out/01_todos.png", airbnb_map, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5)
ggsave("04_Hexagons/Out/02_enteros.png", airbnb_entire_map, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5)
ggsave("04_Hexagons/Out/03_privado.png", airbnb_private_map, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5)
ggsave("04_Hexagons/Out/04_compartido.png", airbnb_shared_map, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5)

# Web friendly maps
ggsave("04_Hexagons/Out/05_todos.jpeg", airbnb_map, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5, quality = 75)
ggsave("04_Hexagons/Out/06_enteros.jpeg", airbnb_entire_map, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5, quality = 75)
ggsave("04_Hexagons/Out/07_privado.jpeg", airbnb_private_map, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5, quality = 75)
ggsave("04_Hexagons/Out/08_compartido.jpeg", airbnb_shared_map, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5, quality = 75)

