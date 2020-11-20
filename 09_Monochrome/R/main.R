## 00: Set up ==================================================================

# Load libraries
library(tidyverse)
library(ggrepel)
library(osmdata)
library(extrafont)
library(ggpubr)

# Clean workspace
rm(list = ls()); gc()

# Source themes
source("Common/ggplot2_theme.R")

## 01: Get osm data ============================================================

# Get roads of Mexico City
osm_mexico <- opq("Mexico City") %>%
    add_osm_feature(key = 'highway', value = c('motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified')) %>%
    osmdata_sf ()

# Get roads of Oaxaca City
osm_arlon <- opq("Arlon") %>%
    add_osm_feature(key = 'highway', value = c('motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified')) %>%
    osmdata_sf ()

# Get roads of Veracruz
osm_moscow <- opq("Moscow") %>%
    add_osm_feature(key = 'highway', value = c('motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified')) %>%
    osmdata_sf ()

# Coords of places where I lived in Mexico City
mexico_points <- data.frame(
    lat = c(19.3481418, 19.2974913, 19.4231204),
    long = c(-99.0979639, -99.2280476, -99.1427634),
    label = c("Citlali, Estrella del Sur, Iztapalapa", "Tulum, Lomas de Padierna, Tlalpan", "Eje Central, Centro, Cuauhtémoc")
)

# Coords of places where I lived in Arlon
arlon_points <- data.frame(
    lat = c(49.6852632),
    long = c(5.8164576),
    label = c("Rue du Bastion")
)

# Coords of places where I lived in Moscow
moscow_points <- data.frame(
    lat = c(55.816793),
    long = c(37.645106),
    label = c("Кибальчича ул., д. 7, Алексеевский")
)

## 02: Map data ================================================================

map_cdmx <- ggplot() + 
    geom_sf(size = 0.25, colour = "#808080", alpha = 0.5, data = osm_mexico$osm_lines) +
    labs(title = "Ciudad de México") +
    coord_sf() +
    theme_30DayMapChallenge_whiter_ultrareduced()

map_arlon <- ggplot() + 
    geom_sf(size = 0.25, colour = "#808080", alpha = 0.5, data = osm_arlon$osm_lines) +
    labs(title = "Arlon") +
    coord_sf() +
    theme_30DayMapChallenge_whiter_ultrareduced()

map_russia <- ggplot() + 
    geom_sf(size = 0.25, colour = "#808080", alpha = 0.5, data = osm_moscow$osm_lines) +
    labs(title = "Moscú") +
    coord_sf() +
    theme_30DayMapChallenge_whiter_ultrareduced()

## 02.01: Map data with points =================================================

map_cdmx_points <- ggplot() + 
    geom_sf(size = 0.25, colour = "#808080", alpha = 0.5, data = osm_mexico$osm_lines) +
    geom_point(aes(x = long, y = lat), colour = "#f04444", alpha = 0.5, size = 1.5,
               data = mexico_points) +
    geom_label_repel(aes(x = long, y = lat, label = label), family = "Montserrat",
               data = mexico_points) +
    labs(title = "Ciudad de México") +
    coord_sf() +
    theme_30DayMapChallenge_whiter_ultrareduced()

map_arlon_points <- ggplot() + 
    geom_sf(size = 0.25, colour = "#808080", alpha = 0.5, data = osm_arlon$osm_lines) +
    geom_point(aes(x = long, y = lat), colour = "#f04444", alpha = 0.5, size = 1.5,
               data = arlon_points) +
    geom_label_repel(aes(x = long, y = lat, label = label), family = "Montserrat",
               data = arlon_points) +
    labs(title = "Arlon") +
    coord_sf() +
    theme_30DayMapChallenge_whiter_ultrareduced()

map_russia_points <- ggplot() + 
    geom_sf(size = 0.25, colour = "#808080", alpha = 0.5, data = osm_moscow$osm_lines) +
    geom_point(aes(x = long, y = lat), colour = "#f04444", alpha = 0.5, size = 1.5,
               data = moscow_points) +
    geom_label_repel(aes(x = long, y = lat, label = label), family = "Montserrat",
               data = moscow_points) +
    labs(title = "Moscú") +
    coord_sf() +
    theme_30DayMapChallenge_whiter_ultrareduced()

## 03: Combine maps ============================================================

map_combined <- ggarrange(map_cdmx, map_arlon, map_russia, ncol = 3, nrow = 1) %>%
    annotate_figure(top = text_grob("Lugares donde he vivido", color = "#404040", size = 24, family = "Keep Calm Med"),
                    bottom = text_grob("#30DayMapChallenge\nDatos: OpenStreetMap\nElaboración: Pablo Reyes Moctezuma",
                                       family = "Montserrat", size = 10, color = "#404040"))

map_combined_points <- ggarrange(map_cdmx_points, map_arlon_points, map_russia_points, ncol = 3, nrow = 1) %>%
    annotate_figure(top = text_grob("Lugares donde he vivido", color = "#404040", size = 24, family = "Keep Calm Med"),
                    bottom = text_grob("#30DayMapChallenge\nDatos: OpenStreetMap\nElaboración: Pablo Reyes Moctezuma",
                                       family = "Montserrat", size = 10, color = "#404040"))

## 04: Save maps ===============================================================

# High res maps
ggsave("09_Monochrome/Out/01_simple.png", map_combined, width = 16.256, height = 9.144, 
       dpi = 600, units = "cm", limitsize = F, bg = "#FFFFFF", scale = 3)
ggsave("09_Monochrome/Out/02_points.png", map_combined_points, width = 16.256, height = 9.144, 
       dpi = 600, units = "cm", limitsize = F, bg = "#FFFFFF", scale = 3)

# Web friendly
ggsave("09_Monochrome/Out/03_simple.jpeg", map_combined, width = 16.256, height = 9.144, 
       dpi = 600, units = "cm", limitsize = F, bg = "#FFFFFF", scale = 3, quality = 75)
ggsave("09_Monochrome/Out/04_points.jpeg", map_combined_points, width = 16.256, height = 9.144, 
       dpi = 600, units = "cm", limitsize = F, bg = "#FFFFFF", scale = 3, quality = 75)