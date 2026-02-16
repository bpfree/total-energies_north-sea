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

# read data
## fisheries species richness for present day in North Sea
### data provided by Cesc Gordó-Vilaseca shared the data that came from the paper (https://www.nature.com/articles/s41467-024-49911-9)
data <- terra::rast(fs::path(data_dir, "fish_north-sea_richness_present_day", ext = "tiff"))

study_area <- sf::st_read(dsn = fs::path(output_dir, "study_area.gpkg"), layer = "north_sea") %>%
  sf::st_transform(x = .,
                   crs = crs(data))

mapview::mapview(study_area)
sf::st_layers(dsn = fs::path(output_dir, "study_area.gpkg"))

#####################################
#####################################

mapview::mapview(data)

# limit fish data to 
ns_fish <- data %>%
  terra::crop(x = .,
              y = study_area,
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
  dplyr::mutate("rescale" = ifelse(rescale == 0.00,
                                   rescale + 0.01,
                                   rescale))

View(ns_fish_poly)

mapview::mapview(ns_fish_poly)

hex_dir <- "data/b_intermediate_data/study_area.gpkg"
hex_grid <- sf::st_read(dsn = hex_dir, layer = "ns_hexes_full")

region_data_hex <- hex_grid[ns_fish_poly, ] %>%
  # spatially join fish species richness values to North Sea hex cells
  sf::st_join(x = .,
              y = ns_fish_poly,
              join = st_intersects) %>%
  sf::st_drop_geometry() |>
  # group by H3 index and layer name
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

region_data_hex_join <- hex_grid %>%
  dplyr::inner_join(x = .,
                   y = region_data_hex,
                   by = "h3_index")

mapview::mapview(region_data_hex_join)

#####################################
#####################################

terra::writeRaster(x = ns_fish, filename = fs::path(output_dir, "ns_fish.grd"), overwrite = T)
sf::st_write(obj = region_data_hex_join,
             dsn = "data/c_hex_data/data_ns_hex.gpkg",
             layer = "fish_hex",
             append = F)
