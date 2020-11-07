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
# zip file in 04_Hexagons_DataInt/Data. You should have a file named victimas.zip after decompression

# Load data
delitos <- read.csv("04_Hexagons_DataInt/Data/victimas.csv", stringsAsFactors = F)

## 02: Clean data ==============================================================

delitos %>%
    # As date
    mutate(FechaHecho = as.Date(FechaHecho, format = "%d/%m/%Y")) %>%
    mutate(MesHecho = floor_date(FechaHecho, unit = "month")) %>%
    # Select only 3Q data
    filter(MesHecho >= "2020-07-01", MesHecho <= "2020-09-01") %>%
    filter(Categoria != "HECHO NO DELICTIVO") -> delitos_clean

## 03: Download OSM data =======================================================

# Get roads using osmdata
osmData <- opq("Mexico City") %>%
    add_osm_feature(key = 'highway', value = c('motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified')) %>%
    osmdata_sf()

## 04: Map data ================================================================

# # #
# Todos los delitos
# # #
delitos_map <- ggplot() + 
    geom_sf(colour = "#bcbca9", data = osmData$osm_lines) +
    geom_hex(aes(x = longitud, y = latitud), colour = NA, data = delitos_clean, 
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
    coord_sf(xlim = c(min(delitos_clean$longitud), max(delitos_clean$longitud)), ylim = c(min(delitos_clean$latitud), max(delitos_clean$latitud))) +
    labs(title = "Densidad de hechos delictivos en la Ciudad de México",
         fill = "Número de hechos delictivos",
         caption = "#30DayMapChallenge\nDatos: Agencia Digital de Inovación Pública (Gobierno de la CDMX)\nElaboración: Pablo Reyes Moctezuma") +
    theme_30DayMapChallenge_clear()

## 05: Write data ==============================================================

# High res maps
ggsave("04_Hexagons_DataInt/Out/01_todos.png", delitos_map, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5)


# Web friendly maps
ggsave("04_Hexagons_DataInt/Out/02_todos.jpeg", delitos_map, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5, quality = 75)

