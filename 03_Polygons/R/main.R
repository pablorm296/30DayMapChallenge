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

# Before running this part of the code, make sure that you have decompressed the
# zip files in 03_Polygons/Data. You should have a directory named SHP and a file
# named sig_IZTAPALAPA.csv after decompression

# Load spatial data
# I downloaded the data from the Open Geographical Information System of Mexico City's government 
# https://sig.cdmx.gob.mx/datos/
# RANT: Why did they separate the actual data from the geospatial vectors!!
iztapalapa_sig_spatial <- readOGR(dsn = "03_Polygons/Data/SHP/", layer = "IZTAPALAPA",
                               stringsAsFactors = F)

# Load data
iztapalapa_sig_data <- read.csv("03_Polygons/Data/sig_IZTAPALAPA.csv", stringsAsFactors = F)

## 02: Clean data ==============================================================

# First remove spatial data from the actual data
iztapalapa_sig_data %>%
    select(!any_of("geo_shape")) -> iztapalapa_sig_data

# Join sig data with spatial vectors
iztapalapa_sig_spatial@data %>%
    # There are two problems:
    # 1. NAs should not be treated as equals
    # 2. The csv file actually contains buildings with more than 1
    # housing units (apartments, studios, etc.)
    # Let's just group by fid and summarise some values
    left_join(iztapalapa_sig_data, by = "fid", na_matches = "never") %>%
    mutate(anio_construccion = ifelse(anio_construccion < 1950, NA, anio_construccion)) %>%
    mutate(uso_construccion = recode(na_if(uso_construccion, ""),
        "Sin Zonificación" = NA_character_
    )) %>%
    group_by(fid) %>%
    summarise(superficie_terreno = mean(superficie_terreno),
              superficie_construccion = mean(superficie_construccion),
              uso_construccion = first(uso_construccion),
              anio_construccion = mean(anio_construccion),
              valor_unitario_suelo = mean(valor_unitario_suelo),
              valor_suelo = mean(as.numeric(valor_suelo))
              ) %>%
    ungroup() %>%
    mutate(id = 0:(n() - 1)) -> tmp.data

# Fortify 
iztapalapa_sig_spatial %>%
    fortify() -> iztapalapa_sig_fortified

# Join with data
tmp.data %>%
    mutate(id = as.character(id)) %>%
    right_join(iztapalapa_sig_fortified, by = "id") -> iztapalapa_sig_fortified_full

# Remove unused objects
rm(iztapalapa_sig_data, iztapalapa_sig_spatialm, old.data, tmp.data); gc()

## 03: Map data ================================================================

# # #
# Antigüedad del predio
# # #
iztapalapa_antiguedad <- ggplot() + 
    geom_polygon(aes(x = long, y = lat, group = group, fill = anio_construccion), 
                 colour = NA, data = iztapalapa_sig_fortified_full) +
    scale_fill_viridis_c(direction = -1, guide = guide_colorbar(
        direction = "horizontal",
        barheight = unit(10, units = "points"),
        barwidth = unit(200, units = "points"),
        draw.ulim = T,
        draw.llim = T,
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5
    )) +
    labs(title = "¿Qué tan antiguos son los edificios en Iztapalapa?",
         fill = "Año de construcción",
         caption = "#30DayMapChallenge\nAño de construcción o última remodelación\nTodos los predios con un año de construcción o última remodelación previo a 1950 fueron reclasificados como NA.\nDatos: Agencia Digital de Innovación Pública (Sistema Abierto de Información Geográfica)\nElaboración: Pablo Reyes Moctezuma") +
    coord_equal() +
    theme_30DayMapChallenge_clear()

# # #
# Valor unitario del suelo
# # #
iztapalapa_valor <- ggplot() + 
    geom_polygon(aes(x = long, y = lat, group = group, fill = valor_unitario_suelo), 
                 colour = NA, data = iztapalapa_sig_fortified_full) +
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
    labs(title = "¿Cuál es el valor de suelo en los predios de Iztapalapa?",
         fill = "Valor unitario del suelo", 
         caption = "#30DayMapChallenge\nDatos: Agencia Digital de Innovación Pública (Sistema Abierto de Información Geográfica)\nElaboración: Pablo Reyes Moctezuma") +
    coord_equal() +
    theme_30DayMapChallenge_clear()

# # #
# Uso del suelo
# # #
iztapalapa_uso <- ggplot() + 
    geom_polygon(aes(x = long, y = lat, group = group, fill = uso_construccion), 
                 colour = NA, data = iztapalapa_sig_fortified_full) +
    scale_color_brewer(type = "qual", guide = guide_legend(
        direction = "horizontal",
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 0.5
    )) +
    labs(title = "¿Cuál es el uso de suelo en los predios de Iztapalapa?",
         fill = "Uso del suelo", 
         caption = "#30DayMapChallenge\nDatos: Agencia Digital de Innovación Pública (Sistema Abierto de Información Geográfica)\nElaboración: Pablo Reyes Moctezuma") +
    coord_equal() +
    theme_30DayMapChallenge_clear()


# High res maps
ggsave("03_Polygons/Out/01_antiguedad.png", iztapalapa_antiguedad, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5)
ggsave("03_Polygons/Out/02_valor.png", iztapalapa_valor, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5)
ggsave("03_Polygons/Out/03_uso.png", iztapalapa_uso, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5)

# Web friendly maps
ggsave("03_Polygons/Out/04_antiguedad.jpeg", iztapalapa_antiguedad, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5, quality = 75)
ggsave("03_Polygons/Out/05_valor.jpeg", iztapalapa_valor, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5, quality = 75)
ggsave("03_Polygons/Out/06_uso.jpeg", iztapalapa_uso, width = 32.51, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#f5f5f2", scale = 1.5, quality = 75)
