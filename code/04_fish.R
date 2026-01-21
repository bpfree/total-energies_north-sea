########################
### 04. fish species ###
########################

# Clear environment
rm(list = ls())

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,
               odp,
               sf,
               tidyr,
               terra)

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
data_dir <- "data/a_raw_data"

### Output directories
#### Analysis directories
output_dir <- "data/b_intermediate_data"

#####################################
#####################################

data <- terra::rast(fs::path(data_dir, "fish_north-sea_richness_present_day", ext = "tiff"))

study_area <- sf::st_read(dsn = file.path(output_dir, "study_area.gpkg"), layer = "north_sea") %>%
  sf::st_transform(x = .,
                   crs = crs(data))

plot(study_area)
sf::st_layers(dsn = file.path(output_dir, "study_area.gpkg"))

#####################################
#####################################

plot(data)

ns_fish <- data %>%
  terra::crop(x = .,
              y = study_area,
              mask = T)
plot(ns_fish)

#####################################
#####################################

terra::writeRaster(x = ns_fish, filename = file.path(output_dir, "ns_fish.grd"), overwrite = T)
