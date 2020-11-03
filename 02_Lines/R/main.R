## 00: Set up ==================================================================
# Load libraries
library(tidyverse)
library(ggrepel)
library(foreign)
library(rgdal)
library(rgeos)
library(osmdata)
library(sf)
library(extrafont)
library(ggpubr)
library(srvyr)

# Clean workspace
rm(list = ls()); gc()

# Source themes
source("Common/ggplot2_theme.R")

## 01: Load data ===============================================================

# Load EOD data
EOD_viajes <- read.dbf("02_Lines/Data/EOD/TVIAJE.DBF", as.is = F)

# Load distric spatial data
EOD_distritos <- readOGR(dsn = "02_Lines/Data/Vectors/", layer = "DIST")

## 02: Clean data ==============================================================

## 02.01: Compute totals =======================================================

# Compute total number of trips using bike
EOD_viajes %>%
    # Make survey design
    as_survey_design(ids = UPM_DIS, strata = EST_DIS, weights = FACTOR) %>%
    # Exclude week end trips
    filter(P5_3 == "1") %>%
    # Only trips inside Mexico City
    filter(P5_7_7 == "09", P5_12_7 == "09") %>%
    # Select only bicycle trips
    filter(across(starts_with("P5_14_") & !contains("P5_14_07"), ~ .x == "2")) %>%
    # Group by origin and destination
    group_by(DTO_ORIGEN, DTO_DEST) %>%
    # Get survey totals
    summarise(TOTAL = survey_total()) -> EOD_bici_totales

# Compute total number of trips using subway
EOD_viajes %>%
    # Make survey design
    as_survey_design(ids = UPM_DIS, strata = EST_DIS, weights = FACTOR) %>%
    # Exclude week end trips
    filter(P5_3 == "1") %>%
    # Only trips inside Mexico City
    filter(P5_7_7 == "09", P5_12_7 == "09") %>%
    # Select only bicycle trips
    filter(across(starts_with("P5_14_") & !contains("P5_14_05"), ~ .x == "2")) %>%
    # Group by origin and destination
    group_by(DTO_ORIGEN, DTO_DEST) %>%
    # Get survey totals
    summarise(TOTAL = survey_total()) -> EOD_metro_totales

# Compute total number of trips using car
EOD_viajes %>%
    # Make survey design
    as_survey_design(ids = UPM_DIS, strata = EST_DIS, weights = FACTOR) %>%
    # Exclude week end trips
    filter(P5_3 == "1") %>%
    # Only trips inside Mexico City
    filter(P5_7_7 == "09", P5_12_7 == "09") %>%
    # Select only bicycle trips
    filter(across(starts_with("P5_14_") & !contains("P5_14_01"), ~ .x == "2")) %>%
    # Group by origin and destination
    group_by(DTO_ORIGEN, DTO_DEST) %>%
    # Get survey totals
    summarise(TOTAL = survey_total()) -> EOD_coche_totales

## 02.02: Compute district centroids ===========================================

# Get district centroids
EOD_distritos %>%
    gCentroid(byid = T, id = EOD_distritos$Distrito) %>%
    # Use OSM crs
    spTransform(CRS("+proj=longlat +datum=WGS84 +no_defs")) -> EOD_distritos_centroids

# Centroids as a dataframes
EOD_distritos_centroids@coords %>%
    as_tibble() %>%
    mutate(id = row.names(.)) %>%
    mutate(id = str_pad(id, width = 3, pad = "0")) -> EOD_distritos_centroids_df  

## 02.03: Join centroids and data ==============================================

# Bike
EOD_bici_totales %>%
    # Remove missing
    filter(DTO_ORIGEN != "888", DTO_DEST != "888", DTO_ORIGEN != "999", DTO_DEST != "999") %>%
    # First, get coords of origin
    left_join(EOD_distritos_centroids_df, by = c("DTO_ORIGEN" = "id"), keep = T) %>%
    select(!any_of("id")) %>%
    rename(ORIGEN_X = x, ORIGEN_Y = y) %>%
    # Now, get coords of destination
    left_join(EOD_distritos_centroids_df, by = c("DTO_DEST" = "id"), keep = T) %>%
    select(!any_of("id")) %>%
    rename(DEST_X = x, DEST_Y = y) -> EOD_bici_totales

# Subway
EOD_metro_totales %>%
    # Remove missing
    filter(DTO_ORIGEN != "888", DTO_DEST != "888", DTO_ORIGEN != "999", DTO_DEST != "999") %>%
    # First, get coords of origin
    left_join(EOD_distritos_centroids_df, by = c("DTO_ORIGEN" = "id"), keep = T) %>%
    select(!any_of("id")) %>%
    rename(ORIGEN_X = x, ORIGEN_Y = y) %>%
    # Now, get coords of destination
    left_join(EOD_distritos_centroids_df, by = c("DTO_DEST" = "id"), keep = T) %>%
    select(!any_of("id")) %>%
    rename(DEST_X = x, DEST_Y = y) -> EOD_metro_totales

# Car
EOD_coche_totales %>%
    # Remove missing
    filter(DTO_ORIGEN != "888", DTO_DEST != "888", DTO_ORIGEN != "999", DTO_DEST != "999") %>%
    # First, get coords of origin
    left_join(EOD_distritos_centroids_df, by = c("DTO_ORIGEN" = "id"), keep = T) %>%
    select(!any_of("id")) %>%
    rename(ORIGEN_X = x, ORIGEN_Y = y) %>%
    # Now, get coords of destination
    left_join(EOD_distritos_centroids_df, by = c("DTO_DEST" = "id"), keep = T) %>%
    select(!any_of("id")) %>%
    rename(DEST_X = x, DEST_Y = y) -> EOD_coche_totales

## 02.04: Remove trips on same district ========================================

# Bike
EOD_bici_totales %>%
    mutate(SAME_AS_ORIGIN = if_else(DTO_ORIGEN == DTO_DEST, T, F)) %>%
    filter(!SAME_AS_ORIGIN) -> EOD_bici_totales

# Subway
EOD_metro_totales %>%
    mutate(SAME_AS_ORIGIN = if_else(DTO_ORIGEN == DTO_DEST, T, F)) %>%
    filter(!SAME_AS_ORIGIN) -> EOD_metro_totales

# Car
EOD_coche_totales %>%
    mutate(SAME_AS_ORIGIN = if_else(DTO_ORIGEN == DTO_DEST, T, F)) %>%
    filter(!SAME_AS_ORIGIN) -> EOD_coche_totales

## 02.05: Compute limits =======================================================

total_min <- min(c(EOD_bici_totales$TOTAL, EOD_metro_totales$TOTAL, EOD_coche_totales$TOTAL))
total_max <- max(c(EOD_bici_totales$TOTAL, EOD_metro_totales$TOTAL, EOD_coche_totales$TOTAL))

## 03: Download OSM data =======================================================

# Get roads using osmdata
osmData <- opq("Mexico City") %>%
    add_osm_feature(key = 'highway', value = c('motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified')) %>%
    osmdata_sf()

## 04: Plot data ===============================================================

# # # 
# Bike trips
# # #
viajes_bici <- ggplot() +
    geom_sf(alpha = 0.5, colour = "#4a4a4a",
            data = osmData$osm_lines) + 
    geom_curve(aes(x = ORIGEN_X, y = ORIGEN_Y, xend = DEST_X, yend = DEST_Y, alpha = TOTAL),
               colour = "#01FFC3",
               curvature = 0.05,
               data = EOD_bici_totales_unique) + 
    scale_alpha(limits = c(total_min, total_max), range = c(0.1, 0.75), guide = F) + 
    coord_sf() +
    labs(title = "Bicicleta") +
    theme_30DayMapChallenge_black_reduced()

# # # 
# Subway trips
# # #
viajes_metro <- ggplot() +
    geom_sf(alpha = 0.5, colour = "#4a4a4a",
            data = osmData$osm_lines) + 
    geom_curve(aes(x = ORIGEN_X, y = ORIGEN_Y, xend = DEST_X, yend = DEST_Y, alpha = TOTAL),
               colour = "#01FFFF",
               curvature = 0.05,
               data = EOD_metro_totales) + 
    scale_alpha(limits = c(total_min, total_max), range = c(0.1, 0.75), guide = F) +  
    coord_sf() +
    labs(title = "Metro") +
    theme_30DayMapChallenge_black_reduced()

# # # 
# Car trips
# # #
viajes_coche <- ggplot() +
    geom_sf(alpha = 0.5, colour = "#4a4a4a",
            data = osmData$osm_lines) + 
    geom_curve(aes(x = ORIGEN_X, y = ORIGEN_Y, xend = DEST_X, yend = DEST_Y, alpha = TOTAL),
               colour = "#FFB3FD",
               curvature = 0.05,
               data = EOD_coche_totales) + 
    scale_alpha(limits = c(total_min, total_max), range = c(0.01, 0.75), guide = F) + 
    coord_sf() +
    labs(title = "Automóvil") +
    theme_30DayMapChallenge_black_reduced()

combined <- ggarrange(viajes_bici, viajes_metro, viajes_coche, nrow = 1, ncol = 3) %>%
    annotate_figure(top = text_grob("Viajes en la CDMX en distintos medios de transporte", 
                                    color = "white", family = "Keep Calm Med", size = 25),
                    bottom = text_grob("#30DayMapChallenge\nSólo se muestran viajes realizados exclusivamente en el medio de transporte señalado\nDatos: INEGI (Encuesta de Origen Destino 2017) y OpenStreetMap\nElaboración: Pablo Reyes Moctezuma (@_egbg_)", 
                                      color = "white", family = "Montserrat", size = 10))

# High res maps
ggsave("02_Lines/Out/01_bici.png", viajes_bici, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5)
ggsave("02_Lines/Out/02_metro.png", viajes_metro, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5)
ggsave("02_Lines/Out/03_coche.png", viajes_coche, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5)
ggsave("02_Lines/Out/04_combinado.png", combined, width = 48.765, height = 27.435, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1)

# Web friendly maps
ggsave("02_Lines/Out/05_bici.jpeg", viajes_bici, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5, quality = 75)
ggsave("02_Lines/Out/06_metro.jpeg", viajes_metro, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5, quality = 75)
ggsave("02_Lines/Out/07_coche.jpeg", viajes_coche, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5, quality = 75)
ggsave("02_Lines/Out/08_combinado.jpeg", combined, width = 48.765, height = 27.435, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1, quality = 75)
