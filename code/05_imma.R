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
               ggplot2,
               janitor,
               odp,
               rmapshaper,
               sf,
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
                   crs = "EPSG:4326")

## inspect data
list(unique(sf::st_geometry_type(data)))
sf::st_crs(x = data)
head(data)
names(data)

# ggplot(data = data) +
#   geom_sf()

sr <- sf::st_read(dsn = fs::path(output_dir, "study_area.gpkg"),
                            layer = "north_sea")

sf::st_crs(x = sr)

ggplot(data = sr) +
  geom_sf()

#####################################
#####################################

# reduce IMMAs to study region
## need to change off spherical geometry for the "clip" to work
sf_use_s2(FALSE)

# test <- data %>%
#   rmapshaper::ms_clip(target = .,
#                       clip = sr) %>%
#   sf::st_cast(x =.,
#               to = "MULTIPOLYGON")
# 
# list(unique(sf::st_geometry_type(test)))
# 
# single <- data %>%
#   dplyr::filter(stringr::str_detect(title, "Moray"))
# 
# list(unique(sf::st_geometry_type(single)))

# test <- test %>%
#   rbind(single)

data_sr <- data %>%
  # make data valid to fix topology exception
  sf::st_make_valid() %>%
  # clip to the study region
  sf::st_intersection(x = .,
              y = sr)
View(data_sr)
list(unique(sf::st_geometry_type(data_sr)))

ggplot(data = data_sr) +
  geom_sf()

#####################################
#####################################

# export data
sf::st_write(obj = data_sr,
             # destination as a parquet file
             dsn = fs::path(output_dir,
                            stringr::str_glue("ns_{layer}.gpkg")),
             # define layer name
             layer = stringr::str_glue("ns_{layer}"),
             # the driver to use to export data
             driver = "gpkg",
             # overwrite previously existing layers
             append = F)

# inspect that data got added
sf::st_layers(dsn = fs::path(output_dir, stringr::str_glue("ns_{layer}.gpkg")))







# code from Juan Mayorga (https://github.com/pristine-seas/prj-MPAs-to-30x30/blob/main/scripts/01_MPAs_we_have.qmd)

collections_to_poly <- mWDPA_clean %>%
  filter(st_geometry_type(.) == "GEOMETRYCOLLECTION") |> 
  st_collection_extract(type = "POLYGON") |> 
  group_by(across(-geometry)) %>%  # Group by all columns except geometry
  summarise(geometry = st_union(geometry)) |> 
  ungroup() |> 
  mutate(AREA_KM2 = as.numeric(st_area(geometry)/10^6)) 

mWDPA_clean <- mWDPA_clean %>%
  filter(!st_geometry_type(.) == "GEOMETRYCOLLECTION") |> 
  bind_rows(collections_to_poly)
