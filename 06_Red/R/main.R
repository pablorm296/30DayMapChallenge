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

# Load fire data
central_america_fires <- readOGR(dsn = "06_Red/Data/FireData/", layer = "SUOMI_VIIRS_C2_Central_America_7d") %>%
    spTransform(CRS("+proj=longlat +datum=WGS84"))

# Load mexico admin data
mexico_admin <- readOGR(dsn = "06_Red/Data/MexAdmin/", layer = "MEX_adm0") %>%
    spTransform(CRS("+proj=longlat +datum=WGS84"))

## 02: Clean data ==============================================================

# Foritfy mexico administrative map
mexico_admin_fortify <- fortify(mexico_admin)

# Get data from spatial object
central_america_fires_data <- central_america_fires@data

# Keep points only in polygon
outside_mexico <- over(central_america_fires, mexico_admin) %>%
    pull(ID_0) %>%
    is.na()

points_in_mexico <- central_america_fires_data[!outside_mexico,]

## 03: Map data ================================================================

## ## ##
## Simple map
map_simple <- ggplot() +
    geom_polygon(aes(x = long, y = lat, group = group), data = mexico_admin_fortify, fill = "#808080") +
    geom_point(aes(x = LONGITUDE, y = LATITUDE, size = FRP), data = points_in_mexico,
               alpha = 0.5, colour = "#FF6666") +
    scale_size(range = c(0.5, 5), guide = guide_legend(
        direction = "horizontal",
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5
    )) +
    labs(title = "Incendios registrados en México durante los úlitmos 7 días",
         size = "Fire Radiative Power",
         caption = "#30DayMapChallenge\nDatos del 1 al 7 de noviembre de 2020\nDatos: NASA (VIIRS I-Band 375 m Active Fire Data) e INEGI\nElaboración: Pablo Reyes Moctezuma") +
    coord_equal() +
    theme_30DayMapChallenge_clear()


## ## ##
## Simple map simple caption
map_simple_no_caption <- ggplot() +
    geom_polygon(aes(x = long, y = lat, group = group), data = mexico_admin_fortify, fill = "#808080") +
    geom_point(aes(x = LONGITUDE, y = LATITUDE, size = FRP), data = points_in_mexico,
               alpha = 0.5, colour = "#FF6666") +
    scale_size(range = c(0.5, 5), guide = guide_legend(
        direction = "horizontal",
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5
    )) +
    labs(title = "Incendios registrados en México durante los úlitmos 7 días",
         size = "Fire Radiative Power",
         caption = "Datos del 1 al 7 de noviembre de 2020\nDatos: NASA (VIIRS I-Band 375 m Active Fire Data)") +
    coord_equal() +
    theme_30DayMapChallenge_clear()


## 04: Save maps ===============================================================

# High res maps
ggsave("06_Red/Out/01_simple.png", map_simple, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5)
ggsave("06_Red/Out/01_simple_no_caption.png", map_simple_no_caption, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5)

# Web friendly
ggsave("06_Red/Out/02_simple.jpeg", map_simple, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5, quality = 75)
