###########################
### 03. North Sea hexes ###
###########################

# Clear environment
rm(list = ls())

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,
               fs,
               h3,
               janitor,
               jsonlite,
               mapview,
               mregions2,
               odp,
               purrr,
               readr,
               rmapshaper,
               sf,
               stringr,
               terra,
               tidyr)

# Commentary on R and code formulation:
## ***Note: If not familiar with dplyr notation
## dplyr is within the tidyverse and can use %>%
## to "pipe" a process, allowing for fluidity
## Can learn more here: https://style.tidyverse.org/pipes.html

## Another  common coding notation used is "::"
## For instance, you may encounter it as dplyr::filter()
## This means use the filter function from the dplyr package
## Notation is used given sometimes different packages have
## the same function name, so it helps code to tell which
## package to use for that particular function.
## The notation is continued even when a function name is
## unique to a particular package so it is obvious which
## package is used

#####################################
#####################################

# Set directories
## Define data directory (as this is an R Project, pathnames are simplified)
### Input directories
data_dir <- "data/b_intermediate_data/study_area.gpkg"

#####################################
#####################################

# load polygon
hexes <- sf::st_read(dsn = data_dir,
                       layer = sf::st_layers(dsn = data_dir)[[1]][[grep(pattern = "grid",
                                                                        x = sf::st_layers(dsn = data_dir)[[1]])]])

# set parameters
# data <- mregions2::gaz_search(x = "North Sea") %>%
#   # only have existing datasets (exclude "deleted" datasets)
#   dplyr::filter(!status == "deleted") %>%
#   # return geometry
#   mregions2::gaz_geometry()

ns <- mregions2::gaz_search(36317) %>%
  # return geometry
  mregions2::gaz_geometry() %>%
  sf::st_make_valid()

mapview::mapview(ns)

#####################################
#####################################

# return the hexes in the water
ns_hex <- hexes %>%
  # intersect the hexes with the North Sea boundary
  sf::st_intersection(x = .,
                      y = ns)

# get list of hex grids in North Sea
ns_hex_list <- ns_hex %>%
  # drop geometry to make faster
  sf::st_drop_geometry() %>%
  # select on the H3 index column
  dplyr::select(h3_index)

# get full hex grid
ns_hexes_full <- hexes %>%
  dplyr::filter(h3_index %in% ns_hex_list$h3_index)

#####################################
#####################################

# export hexagon grid
sf::st_write(obj = ns, dsn = data_dir, layer = stringr::str_glue("greater_north_sea"), append = F)
sf::st_write(obj = ns_hex, dsn = data_dir, layer = "ns_hex", append = F)
sf::st_write(obj = ns_hexes_full, dsn = data_dir, layer = "ns_hexes_full", append = F)

sf::st_layers(dsn = data_dir)
