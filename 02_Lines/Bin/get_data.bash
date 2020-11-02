#! /bin/bash

# Author: Pablo Reyes Moctezuma
# Purpose: Donwload INEGI's Red Nacional de Caminos (2019).
# Instructions: Simply run bash 02_Lines/Bin/get_data.bash to download the data, the uncompress it.
#               in order to replicate the maps, you should have a dir named SHP in 02_Lines/Data containing
#               the shape files.

# Download data
wget -nv -O ./02_Lines/Data/SHP.zip http://189.254.204.50:83/recursos/ShapeFiles/Red_vial_shapefiles2019.zip