###################
### X. submodel ###
###################

# Clear environment
rm(list = ls())

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,
               fs,
               jsonlite,
               odp,
               sf,
               stringr,
               terra,
               tidyr,
               tidyverse)

# create export directory
fs::dir_create(path = "data/b_intermediate_data/species")
fs::dir_create(path = "data/b_intermediate_data/presence")

# input directory
species_dir <- "data/a_raw_data/species"
data_dir <- "data/b_intermediate_data/study_area.gpkg"

# set directory
output_dir <- "data/b_intermediate_data/species"
presence_dir <- "data/b_intermediate_data/presence"

#####################################
#####################################

# parameters
submodel1 <- 0.45
submodel2 <- 1 - submodel1

# function
## score function
score_function <- function(layer, field_name, score_value){
  # add cost value
  data <- layer %>%
    # create new field to add score value
    dplyr::mutate({{field_name}} := score_value) %>%
    # remove geometry so it is simplified data frame
    sf::st_drop_geometry() %>%
    # select fields of interest
    dplyr::select(h3_index, {{field_name}}) %>%
    # due to different types leading to the same score, need to remove duplicates
    ## group by unique indexes and values
    ### using column position (1 = index, 2 = cost value for type)
    dplyr::group_by_at(1:2) %>%
    ## summarise to remove duplicates
    dplyr::summarise()
}

#####################################
#####################################

# directories
## input directories
data_dir <- "data/c_hex_data/data_ns_hex.gpkg"
hex_dir <- "data/b_intermediate_data/study_area.gpkg"

sf::st_layers(dsn = data_dir)

## output directories
output_dir

#####################################
#####################################

# load data
hex_grid <- sf::st_read(dsn = hex_dir, layer = "ns_hexes_full")

# mobile species submodel
cetaceans
seabirds
fishes <- sf::st_read(dsn = data_dir, "fish_hex") %>%
  sf::st_drop_geometry()

# sessile subsets
coral <- sf::st_read(dsn = data_dir, layer = "cold_water_corals_hex") %>%
  score_function(layer = .,
                field_name = "coral",
                score_value = 1)
seagrass <- sf::st_read(dsn = data_dir, layer = "seagrass_hex") %>%
  sf::st_drop_geometry()
protected_areas <- sf::st_read(dsn = data_dir, layer = "protected_areas_hex") %>%
  sf::st_drop_geometry()
imma <- sf::st_read(dsn = data_dir, "imma_hex") %>%
  sf::st_drop_geometry()

#####################################
#####################################

hex_sessile <- hex_grid %>%
  dplyr::left_join(x = .,
                   y = coral,
                   by = "h3_index") %>%
  dplyr::left_join(x = .,
                   y = seagrass,
                   by = "h3_index")
  
  # add value of 1 for datasets when hex cell has value of NA
  ## for hex cells not impacted by a particular dataset, that cell gets a value of 1
  ### this indicates  suitability with wind energy development
  dplyr::mutate(across(2, ~replace(x = .,
                                   list = is.na(.),
                                   # replacement values
                                   values = 1))) %>%
  
  ## geometric mean = nth root of the product of the variable values
  dplyr::mutate(!!stringr::str_glue("{submodel_code}_geom_mean") := .data[[stringr::str_glue("{layer_name}_max")]] ^ gm_wt) %>%
  
  # relocate the industry and operations geometric mean field
  dplyr::relocate(stringr::str_glue("{submodel_code}_geom_mean"),
                  .after = stringr::str_glue("{layer_name}_max"))
