####################
### 07. seagrass ###
####################

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
               odp,
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
### will need to define the geometry field (e.g., wkt_point)
### boundary box for the study region
bbox <- 'geometry within "POLYGON((-4.4454 50.9954, 12.0059 50.9954, 12.0059 61.0170, -4.4454 61.0170, -4.4454 50.9954))"'
odp_data <- "7199f9bc-96ae-49d1-a814-df8c4bcc7552"

#####################################
#####################################

# Set directories
## Define data directory (as this is an R Project, pathnames are simplified)
### Input directories

### Output directories
#### Analysis directories
output_dir <- "data/b_intermediate_data"

#####################################
#####################################

# set up ODP API
## to find the API key or create one, navigate to: https://app.hubocean.earth/account
### Client (API key can come from ODP_API_KEY)
### API key saved in .Renvironment so retrieving through the Sys.getenv()
### this is so the API key is not public
odp_api_key <- Sys.getenv("odp_api_key")
client <- odp::odp_client(api_key = odp_api_key)

#####################################
#####################################

# load in dataset (see https://app.hubocean.earth/) -- seagrass
dataset <- client$dataset(odp_data)

# generate table (defaults to the first table in the dataset)
table <- dataset$table
schema <- table$schema()

# query -- by boundary box
## returns a cursor that streams rows lazily
cursor <- table$select(filter = bbox)

# fetch table into a dataframe that you can use for analysis
df <- cursor$dataframe()

dim(df)
names(df)
View(df)
str(df)

#####################################

# # load in dataset (see https://app.hubocean.earth/) -- seagrass
# dataset_full <- client$dataset(odp_data)
# 
# # generate table (defaults to the first table in the dataset)
# table_full <- dataset_full$table
# schema_full <- table_full$schema()
# 
# # query -- by boundary box
# ## returns a cursor that streams rows lazily
# cursor_full <- table_full$select()
# 
# # fetch table into a dataframe that you can use for analysis
# df_full <- cursor_full$dataframe()
# 
# dim(df_full)
# names(df_full)
# View(df_full)
# str(df_full)
# 
# data_full <- df_full %>%
#   janitor::clean_names() %>%
#   # convert the WKB geometry field to a more user friendly geomtry field
#   dplyr::mutate(geometry = sf::st_as_sfc(structure(as.list(geometry), class = "WKB"))) %>%
#   sf::st_as_sf(crs = 4326)

##############

data <- df %>%
  janitor::clean_names() %>%
  # convert the WKB geometry field to a more user friendly geomtry field
  dplyr::mutate(geometry = sf::st_as_sfc(structure(as.list(geometry), class = "WKB"))) %>%
  # set CRS to WGS84
  sf::st_as_sf(crs = 4326)

View(data)
class(data)

ns <- sf::st_read(dsn = fs::path(output_dir, "study_area.gpkg"), layer = "greater_north_sea")

region_data <- data %>%
  # obtain only seagrass in the study area
  rmapshaper::ms_clip(target = .,
                      clip = ns) %>%
  # create field called "layer" and fill with "seagrass" for summary
  dplyr::mutate(layer = "seagrass") %>%
  dplyr::select(layer, geometry) %>%
  sf::st_make_valid()

##############

hex_dir <- "data/b_intermediate_data/study_area.gpkg"
hex_grid <- sf::st_read(dsn = hex_dir, layer = "ns_hexes_full")

# seagrass hex grids
region_data_hex <- hex_grid[region_data, ] %>%
  # spatially join seagrass values to North Sea hex cells
  sf::st_join(x = .,
              y = region_data,
              join = st_intersects) %>%
  # select fields of importance
  dplyr::select(h3_index, layer)

mapview::mapview(region_data_hex)

##############

# export data
# sf::st_write(obj = data_full, dsn = "data/b_intermediate_data/habitats.gpkg", layer = "seagrass", append = T)
sf::st_write(obj = region_data, dsn = "data/b_intermediate_data/habitats.gpkg", layer = "seagrass_ns", append = T)
sf::st_write(obj = region_data_hex, dsn = "data/c_hex_data/data_ns_hex.gpkg", layer = "seagrass_hex", append = T)

sf::st_layers(dsn = "data/b_intermediate_data/habitats.gpkg")
