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

# You have to decompress the file 2020_10_victimas.zip in 10/Grid/Data
# Load data
victimas_octubre <- read_csv("10_Grid/Data/2020_10_victimas.csv")

# Keep only crimes and offences
victimas_octubre %>%
    filter(Categoria != "HECHO NO DELICTIVO") -> victimas_octubre_clean

# Get bbox from data
bbox <- c(
    max(victimas_octubre$latitud, na.rm = T),
    min(victimas_octubre$longitud, na.rm = T),
    min(victimas_octubre$latitud, na.rm = T),
    max(victimas_octubre$longitud, na.rm = T)
)

## 02: Get OSM data ============================================================

# Get OSM road layout of Mexico City (using only bbox defined by datapoints)
cdmx_osm <- opq(c(bbox[2], bbox[3], bbox[4], bbox[1])) %>%
    add_osm_feature(key = 'highway', value = c('motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified')) %>%
    osmdata_sf ()

## 03: Map data ================================================================

map_cdmx_bin_streets <- ggplot() +
    geom_sf(colour = "#65654e", alpha = 0.5, size = 0.1, data = cdmx_osm$osm_lines) +
    geom_bin2d(aes(x = longitud, y = latitud), binwidth = 0.0075, 
               alpha = 0.75,
               data = victimas_octubre_clean) +
    scale_fill_viridis_c(breaks = seq(0, 200, 40), guide = guide_colourbar(
        direction = "horizontal",
        barheight = unit(10, units = "points"),
        barwidth = unit(200, units = "points"),
        draw.ulim = T,
        draw.llim = T,
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5
    )) +
    coord_sf() +
    labs(title = "Víctimas de delitos en la CDMX",
         subtitle = bquote("Octubre de 2020. Cuadrantes de ~1"~km^2),
         fill = "Número de víctimas",
         caption = "#30DayMapChallenge\nDatos: FGJ-CDMX, ADIP, OpenStreetMap\nElaboración: Pablo Reyes Moctezuma") +
    theme_30DayMapChallenge_clear()

map_cdmx_bin <- ggplot() +
    geom_bin2d(aes(x = longitud, y = latitud), binwidth = 0.0075,
               data = victimas_octubre_clean) +
    scale_fill_viridis_c(breaks = seq(0, 200, 40), guide = guide_colourbar(
        direction = "horizontal",
        barheight = unit(10, units = "points"),
        barwidth = unit(200, units = "points"),
        draw.ulim = T,
        draw.llim = T,
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5
    )) +
    coord_sf() +
    labs(title = "Víctimas de delitos en la CDMX",
         subtitle = bquote("Octubre de 2020. Cuadrantes de ~1"~km^2),
         fill = "Número de víctimas",
         caption = "#30DayMapChallenge\nDatos: FGJ-CDMX, ADIP, OpenStreetMap\nElaboración: Pablo Reyes Moctezuma") +
    theme_30DayMapChallenge_clear()

## 04: Save maps ===============================================================

# High res maps
ggsave("10_Grid/Out/01_simple.png", map_cdmx_bin, width = 16.256, height = 9.144, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 3)
ggsave("10_Grid/Out/02_roads.png", map_cdmx_bin_streets, width = 16.256, height = 9.144, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 3)

# Web friendly
ggsave("10_Grid/Out/03_simple.jpeg", map_cdmx_bin, width = 16.256, height = 9.144, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 3, quality = 75)
ggsave("10_Grid/Out/04_roads.jpeg", map_cdmx_bin_streets, width = 16.256, height = 9.144, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 3, quality = 75)