## 00: Set up ==================================================================
# Load libraries
library(tidyverse)
library(ggrepel)
library(osmdata)
library(extrafont)

# Clean workspace
rm(list = ls()); gc()

## 01: Load data ===============================================================

denue_data <- read.csv("01_Points/Data/denue_inegi_09.csv", encoding = "iso-8859-1", 
                       fileEncoding = "iso-8859-1")

## 02: Clean data ==============================================================

# Keep only act codes 722412 and 722511
denue_data_clean <- denue_data %>%
    filter(codigo_act == "722412" | str_detect(codigo_act, "72251")) %>%
    filter(codigo_act != "722515" | codigo_act != "722516" | codigo_act != "722517" | codigo_act != "722518" | codigo_act != "722519") 

# If code is 722511, name must contain SALÓN|SALON|BAR|CANTINA|PULQUE|CERVE
rows2remove <- if_else((str_detect(denue_data_clean$codigo_act, "72251") & str_detect(denue_data_clean$nom_estab, "SALÓN|SALON|\\bBAR\\b|CANTINA|PULQUE|CERVE")) | denue_data_clean$codigo_act == "722412", 
                       TRUE, FALSE)

# Filter rows
denue_data_clean <- denue_data_clean %>%
    filter(rows2remove) 

# Now, let's pull from the 'uncleaned' dataset some bars that I really like, but INEGI is not very good at classifying their activities
# I mean, they're openly bars but they're classified as restaurants, coffeehouses or malt shops lol.
denue_data %>%
    filter(str_detect(nom_estab, "TAURINO LA FAENA")) -> special_case_LaFaena
denue_data %>%
    filter(str_detect(nom_estab, "BURRA BLANCA")) -> special_case_BurraBlanca
denue_data %>%
    filter(str_detect(nom_estab, "EL GRIFO")) %>%
    add_row(longitud = -99.1736212, latitud = 19.413843, nom_estab = "EL GRIFO") -> special_case_ElGrifo
denue_data %>%
    filter(str_detect(nom_estab, "MEZCALERÍA NECIOS")) %>%
    add_row(longitud = -99.1769494, latitud = 19.4120497, nom_estab = "MEZCALERÍA NECIOS") -> special_case_Necios
denue_data %>%
    filter(str_detect(nom_estab, "MEZCALERÍA GUELAGUETZA")) %>%
    add_row(longitud = -99.1796027, latitud = 19.4123718, nom_estab = "MEZCALERÍA LA GUELAGUETZA") -> special_case_Guelaguetza

# Add them
denue_data_clean <- denue_data_clean %>%
    rbind(special_case_LaFaena) %>%
    rbind(special_case_BurraBlanca) %>%
    rbind(special_case_ElGrifo) %>%
    rbind(special_case_Necios) %>%
    rbind(special_case_Guelaguetza) 

# Clean
rm(list = ls(pattern = "special_case*"))

# Is it Pulquería?
denue_data_clean <- denue_data_clean %>%
    mutate(Pulquería = if_else(str_detect(nom_estab, "PULQU"), "Pulquerías", "Otros bares y cantinas"))

# Is it one of my fav places?

fav_places <- if_else(
    str_detect(denue_data_clean$nom_estab, "LA FAENA") |
    str_detect(denue_data_clean$nom_estab, "BURRA BLANCA") |
    str_detect(denue_data_clean$nom_estab, "GRIFO") |
    str_detect(denue_data_clean$nom_estab, "APACHES") |
    str_detect(denue_data_clean$nom_estab, "TENAMPA") |
    str_detect(denue_data_clean$nom_estab, "COYOACANA") |
    str_detect(denue_data_clean$nom_estab, "PALOMA AZUL") |
    str_detect(denue_data_clean$nom_estab, "MEZCALERÍA NECIOS") |
    str_detect(denue_data_clean$nom_estab, "MEZCALERÍA LA GUELAGUETZA") |
    denue_data_clean$id == 1060479 |
    str_detect(denue_data_clean$nom_estab, "EL MIRADOR"),
    T,
    F
)

denue_data_clean$FAV <- fav_places

# Capitalize name of bars
denue_data_clean <- denue_data_clean %>%
    mutate(nom_estab = str_to_title(nom_estab))

## 03: Get streets of Mexico City ==============================================

# Compute lat long limits, taking into account DENUE data points
max_lat <- denue_data_clean$latitud %>% max()
min_lat <- denue_data_clean$latitud %>% min()
max_lon <- denue_data_clean$longitud %>% max() 
min_lon <- denue_data_clean$longitud %>% min()

# Compute lat long limits, taking into account only my fav places data points
max_lat_fav <- denue_data_clean[denue_data_clean$FAV,]$latitud %>% max()
min_lat_fav <- denue_data_clean[denue_data_clean$FAV,]$latitud %>% min()
max_lon_fav <- denue_data_clean[denue_data_clean$FAV,]$longitud %>% max() 
min_lon_fav <- denue_data_clean[denue_data_clean$FAV,]$longitud %>% min()

# Get roads of Mexico City using osmdata
osmMxData <- opq(bbox = c(min_lon, min_lat, max_lon, max_lat)) %>%
    add_osm_feature(key = 'highway', value = c('motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified')) %>%
    osmdata_sf ()

# Get roads of Mexico City using osmdata
osmMxDataFav <- opq(bbox = c(-99.2685, 19.3330, -99.0114, 19.4779)) %>%
    add_osm_feature(key = 'highway', value = c('motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified')) %>%
    osmdata_sf ()

## 04: Map data ================================================================

# # # #
# Plot all points
# # # #
map <- ggplot() +
    geom_sf(colour = "#4a4a4a", alpha = 0.5, size = 0.5, data = osmMxData$osm_lines) +
    geom_point(aes(x = longitud, y = latitud), colour = "#08F7FE", alpha = 0.5, size = 0.5, data = denue_data_clean) +
    coord_sf(xlim = c(min_lon, max_lon), ylim = c(min_lat, max_lat)) + 
    labs(title = "Bares, cantinas y pulquerías de la Ciudad de México",
         caption = "#30DayMapChallenge\nDatos: INEGI (Directorio Estadístico Nacional de Unidades Económicas) y OpenStreetMap\nElaboración: Pablo Reyes Moctezuma (@_egbg_)") +
    theme_30DayMapChallenge_black() 

# # # #
# Plot pulquerías 
# # # #
mapPulque <- ggplot() +
    geom_sf(colour = "#4a4a4a", alpha = 0.5, size = 0.5, data = osmMxData$osm_lines) +
    geom_point(aes(x = longitud, y = latitud, colour = Pulquería), alpha = 0.5, size = 0.75, 
               data = denue_data_clean) +
    scale_colour_manual(values = c("Pulquerías" = "#09FBD3", "Otros bares y cantinas" = "#FFFFFF"),
                        guide = guide_legend(title.position = "top",
                                             keywidth = unit(1, units = "cm"),
                                             keyheight = unit(1, units = "cm"),
                                             override.aes = list(size = 3))) +
    coord_sf(xlim = c(min_lon, max_lon), ylim = c(min_lat, max_lat)) + 
    labs(title = "Bares, cantinas y pulquerías de la Ciudad de México",
         colour = "Tipo de establecimiento",
         caption = "#30DayMapChallenge\nDatos: INEGI (Directorio Estadístico Nacional de Unidades Económicas) y OpenStreetMap\nElaboración: Pablo Reyes Moctezuma (@_egbg_)") +
    theme_30DayMapChallenge_black() 

# # # #
# Plot fav places
# # # #
mapFav <- ggplot() +
    geom_sf(colour = "#4a4a4a", alpha = 0.5, size = 0.5, data = osmMxDataFav$osm_lines) +
   
    geom_point(aes(x = longitud, y = latitud), colour = "#FE53BB", alpha = 0.5, size = 0.75, 
               data = denue_data_clean %>% filter(FAV)) +
    geom_text_repel(aes(x = longitud, y = latitud, label = nom_estab), colour = "#FFFFFF", 
                    family = "Montserrat", size = 3.5,
                    data = denue_data_clean %>% filter(FAV)) +
    labs(title = "Bares, cantinas y pulquerías de la Ciudad de México",
         subtitle = "Lugares que solía frecuentar",
         caption = "#30DayMapChallenge\nDatos: INEGI (Directorio Estadístico Nacional de Unidades Económicas) y OpenStreetMap\nElaboración: Pablo Reyes Moctezuma (@_egbg_)") +
    theme_30DayMapChallenge_black() 

## 05: Save maps ===============================================================

ggsave("01_Points/Out/01_todos.png", map, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5)
ggsave("01_Points/Out/02_pulquerías.png", mapPulque, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5)
ggsave("01_Points/Out/03_favoritos.png", mapFav, width = 16.255, height = 18.29, 
       dpi = 600, units = "cm", limitsize = F, bg = "#2d2d2d", scale = 1.5)
