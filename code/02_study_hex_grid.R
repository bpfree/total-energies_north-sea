####################
### 02. H3 hexes ###
####################

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

# set parameters
## useful guide on H3: https://h3geo.org/docs/core-library/restable/
### cell area: 0.737327598 km2 (on average)
### cell side length: 0.531414010 km (= 531,41401 m)
res <- 8

# Set directories
## Define data directory (as this is an R Project, pathnames are simplified)
### Input directories
data_dir <- "data/b_intermediate_data/study_area.gpkg"

#####################################
#####################################

# load polygon
polygon <- sf::st_read(dsn = data_dir,
                       layer = sf::st_layers(dsn = data_dir)[[1]][[grep(pattern = "north",
                                                                       x = sf::st_layers(dsn = data_dir)[[1]])]])

#####################################
#####################################

# fill the polygon boundary with all the hexes at the particular resolution of interest
poly_res <- h3::polyfill(polygon = polygon,
                         res = res)
poly_res

# get the boundaries of the h3 indices
hex_grid <- poly_res %>%
  h3::h3_to_geo_boundary_sf()

#####################################
#####################################

# export hexagon grid
sf::st_write(obj = hex_grid, dsn = data_dir, layer = stringr::str_glue("hex_grid_h3res{res}"), append = F)

sf::st_layers(dsn = data_dir)
