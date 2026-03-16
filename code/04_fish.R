########################
### 04. fish species ###
########################

# Clear environment
rm(list = ls())

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,
               flextable,
               fs,
               ggplot2,
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
               skimr,
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
data_dir <- "data/a_raw_data"

### Output directories
#### Analysis directories
output_dir <- "data/b_intermediate_data"

#####################################
#####################################

# read data
## fisheries species richness for present day in North Sea
### data provided by Cesc Gordó-Vilaseca shared the data that came from the paper (https://www.nature.com/articles/s41467-024-49911-9)
data <- terra::rast(fs::path(data_dir, "fish_north-sea_richness_present_day", ext = "tiff"))

study_area <- sf::st_read(dsn = fs::path(output_dir, "study_area.gpkg"), layer = "north_sea") %>%
  # change to match coordinate reference system of data
  sf::st_transform(x = .,
                   # CRS of the other data
                   crs = crs(data))

# inspect the study area
mapview::mapview(study_area)
sf::st_layers(dsn = fs::path(output_dir, "study_area.gpkg"))

#####################################
#####################################

mapview::mapview(data)

# limit fish data to study region
ns_fish <- data %>%
  # crop raster data to study region
  terra::crop(x = .,
              # define study region
              y = study_area,
              # mask the data (so that only the study region is shown)
              mask = T)
mapview::mapview(ns_fish)

ns_fish_poly <- ns_fish |>
  # convert raster to polygons
  terra::as.polygons() |>
  # set as sf
  sf::st_as_sf() |>
  # rename field (based on indexed location)
  dplyr::rename("species_rich" = 1) %>%
  # create new layer
  dplyr::mutate("rescale" = (species_rich - min(species_rich)) / (max(species_rich) - min(species_rich))) |>
  # add a little amount to minimum species to remove possibility of 0 values
  dplyr::mutate("rescale" = ifelse(rescale == 0.00,
                                   # if met, add 0.01 to minimum
                                   rescale + 0.01,
                                   # otherwise keep value
                                   rescale))

# inspect data
View(ns_fish_poly)
mapview::mapview(ns_fish_poly)

#####################################

# load hexagonal grids
hex_dir <- "data/b_intermediate_data/study_area.gpkg"
hex_grid <- sf::st_read(dsn = hex_dir, layer = "ns_hexes_full")

# get fish data for hexagonal grids
region_data_hex <- hex_grid[ns_fish_poly, ] %>%
  # spatially join fish species richness values to North Sea hex cells
  sf::st_join(x = .,
              y = ns_fish_poly,
              join = st_intersects) %>%
  # drop geometry for faster processing
  sf::st_drop_geometry() |>
  # group by H3 index
  dplyr::group_by(h3_index) |>
  # return only distinct rows (remove duplicates)
  dplyr::summarize(fish_rich = max(rescale)) %>%
  # ungroup to get each H3 index and its max species value
  dplyr::ungroup()

# check for duplicates -- there don't seem to be any
duplicates <- region_data_hex %>%
  # create frequency field based on index
  dplyr::add_count(h3_index) %>%
  # see which ones are duplicates
  dplyr::filter(n>1) %>%
  # show distinct options
  dplyr::distinct()

# join the summarized fish data to original hex grid
region_data_hex_join <- hex_grid %>%
  dplyr::inner_join(x = .,
                   y = region_data_hex,
                   by = "h3_index")

mapview::mapview(region_data_hex_join)

#####################################
#####################################

# export data
terra::writeRaster(x = ns_fish,
                   # define filename
                   filename = fs::path(output_dir, "ns_fish.grd"),
                   # overwrite data
                   overwrite = T)

sf::st_write(obj = region_data_hex_join,
             # destination
             dsn = "data/c_hex_data/data_ns_hex.gpkg",
             # layer name
             layer = "fish_hex",
             # append
             append = F)
