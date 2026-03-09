#########################################
### 06. Important marine mammal areas ###
#########################################

# Clear environment
rm(list = ls())

# packages
# install straight from GitHub (requires remotes, pak, or devtools)
# install.packages("remotes")  # skip if already installed
# remotes::install_local("~/dev/odp_sdkr", build = TRUE, build_vignettes = TRUE)
# remotes::install_github("ropensci/worrms")

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

# parameters
layer <- "imma"

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

# input data
## Important marine mammal areas (https://www.marinemammalhabitat.org/immas/)
### these are commercial data
sf::st_layers(dsn = fs::path(data_dir, "imma/iucn-imma/iucn-imma.gpkg"))

data <- sf::st_read(dsn = fs::path(data_dir, "imma/iucn-imma/iucn-imma.gpkg"),
                    layer = "iucn-imma") %>%
  # simplify column names
  janitor::clean_names() %>%
  # remove Z geometry
  sf::st_zm() %>%
  # filter for IMMAs in the Northeast Atlantic
  dplyr::filter(stringr::str_detect(ident_code, "NEATL")) %>%
  # project to WGS84
  sf::st_transform(x = .,
                   # coordinate reference system of interest
                   crs = "EPSG:4326")

## inspect data
list(unique(sf::st_geometry_type(data)))
sf::st_crs(x = data)
head(data)
names(data)

north_sea <- sf::st_read(dsn = fs::path(output_dir, "study_area.gpkg"),
                         layer = "greater_north_sea")

#####################################
#####################################

# reduce IMMAs to study region
## need to change off spherical geometry for the "clip" to work
sf_use_s2(FALSE)

data_sr <- data %>%
  # make data valid to fix topology exception
  sf::st_make_valid() %>%
  # clip to the study region
  sf::st_intersection(x = .,
                      # clip region
                      y = north_sea)

# inspect data
View(data_sr)
list(unique(sf::st_geometry_type(data_sr)))

mapview::mapview(data_sr)

#####################################
#####################################

# solve the problem with the geometry collection data
imma_collection <- data_sr %>%
  # filter for only collection geometry
  dplyr::filter(st_geometry_type(.) == "GEOMETRYCOLLECTION") |>
  # extract the polygons to make the geometry collection
  sf::st_collection_extract(type = "POLYGON") |>
  # group by all the other columns
  dplyr::group_by(across(-geom)) %>%  # Group by all columns except geometry
  # summarise by a unioned geometry
  dplyr::summarise(geom = sf::st_union(geom)) |>
  # ungroup to get the IMMAs again
  dplyr::ungroup()

# inspect the data
mapview::mapview(imma_collection)

# get the clean data
imma_clean <- data_sr %>%
  # get the MULTIPOLYGON objects
  dplyr::filter(!st_geometry_type(.) == "GEOMETRYCOLLECTION") |>
  # add back in the previous collection IMMA objects
  bind_rows(imma_collection) %>%
  # create new column
  dplyr::mutate(layer = "imma")

View(imma_clean)
mapview::mapview(imma_clean)

#####################################
#####################################

hex_dir <- "data/b_intermediate_data/study_area.gpkg"
hex_grid <- sf::st_read(dsn = hex_dir, layer = "ns_hexes_full")

# IMMA hex grids
region_data_hex <- hex_grid[imma_clean, ] %>%
  # spatially join IMMA values to North Sea hex cells
  sf::st_join(x = .,
              # data to join
              y = imma_clean,
              # join function
              join = st_intersects) %>%
  # select fields of importance
  dplyr::select(h3_index) %>%
  # return distinct hexagons
  dplyr::distinct()

mapview::mapview(region_data_hex)

#####################################
#####################################

# export data
sf::st_write(obj = imma_clean,
             # destination as a parquet file
             dsn = fs::path(output_dir,
                            stringr::str_glue("ns_{layer}.gpkg")),
             # define layer name
             layer = stringr::str_glue("ns_{layer}"),
             # the driver to use to export data
             driver = "gpkg",
             # overwrite previously existing layers
             append = F)

sf::st_write(obj = region_data_hex, dsn = "data/c_hex_data/data_ns_hex.gpkg", layer = "imma_hex", append = F)

# inspect that data got added
sf::st_layers(dsn = fs::path(output_dir, stringr::str_glue("ns_{layer}.gpkg")))
