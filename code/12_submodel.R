#######################
### 12. final model ###
#######################

# Clear environment
rm(list = ls())

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,
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
               stringr,
               terra,
               tidyr)

#####################################
#####################################

# parameters
submodel1 <- 0.45 # mobile species
submodel2 <- 1 - submodel1 # sessile species

# function
## score function
score_function <- function(layer, field_name, score_value){
  # add cost value
  data <- layer %>%
    # create new field to add score value
    dplyr::mutate({{field_name}} := score_value) |>
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

# inspect geopackages
sf::st_layers(dsn = data_dir)

## output directories
output_dir <- "d_final_data"

#####################################
#####################################

# load data
hex_grid <- sf::st_read(dsn = hex_dir, layer = "ns_hexes_full")

# mobile species submodel
## cetaceans
cetaceans <- sf::st_read(dsn = data_dir,
                         layer = "ceta_hex") %>%
  # drop geometry for faster processing
  sf::st_drop_geometry()

## seabirds
seabirds <- sf::st_read(dsn = data_dir,
                        layer = "seabirds_hex") %>%
  # drop geometry for faster processing
  sf::st_drop_geometry()

## fishes
fishes <- sf::st_read(dsn = data_dir, "fish_hex") %>%
  # drop geometry for faster processing
  sf::st_drop_geometry()

# sessile subsets
coral <- sf::st_read(dsn = data_dir, layer = "cold_water_corals_hex") %>%
  # run score function
  score_function(layer = .,
                 # field name
                 field_name = "c_val",
                 # score value
                 score_value = 1)

seagrass <- sf::st_read(dsn = data_dir, layer = "seagrass_hex") %>%
  # run score function
  score_function(layer = .,
                 # field name
                 field_name = "s_val",
                 # score value
                 score_value = 1)

protected_areas <- sf::st_read(dsn = data_dir, layer = "protected_areas_hex") %>%
  # run score function
  score_function(layer = .,
                 # field name
                 field_name = "pa_val",
                 # score value
                 score_value = 1)

imma <- sf::st_read(dsn = data_dir, "imma_hex") %>%
  # run score function
  score_function(layer = .,
                 # field name
                 field_name = "i_val",
                 # score value
                 score_value = 1)

#####################################
#####################################

# create mobile submodel dataset
hex_mobile <- hex_grid %>%
  # join mobile species data to full hex grid
  dplyr::left_join(x = .,
                   y = cetaceans,
                   by = "h3_index") %>%
  dplyr::left_join(x = .,
                   y = seabirds,
                   by = "h3_index") %>%
  dplyr::left_join(x = .,
                   y = fishes,
                   by = "h3_index") %>%
  
  # add value of 0 for datasets when hex cell has value of NA
  dplyr::mutate(across(2:4, ~replace(x = .,
                                     # when NA
                                     list = is.na(.),
                                     # replacement values
                                     values = 0))) %>%
  
  # sum the layers of interest
  dplyr::mutate(mobile_sum = ceta_rich + bird_rich + fish_rich) |>
  
  # move the sessile sum column to end of key fields
  dplyr::relocate(mobile_sum, .before = geom)

#####################################

# create sessile submodel dataset
hex_sessile <- hex_grid %>%
  dplyr::left_join(x = .,
                   y = coral,
                   by = "h3_index") %>%
  dplyr::left_join(x = .,
                   y = seagrass,
                   by = "h3_index") %>%
  dplyr::left_join(x = .,
                   y = protected_areas,
                   by = "h3_index") %>%
  dplyr::left_join(x = .,
                   y = imma,
                   by = "h3_index") %>%
  
  # add value of 0 for datasets when hex cell has value of NA
  dplyr::mutate(across(2:5, ~replace(x = .,
                                     list = is.na(.),
                                     # replacement values
                                     values = 0))) %>%
  
  # sum the layers of interest
  dplyr::mutate(sessile_sum = c_val + s_val + pa_val + i_val) |>
  
  # move the sessile sum column to end of key fields
  dplyr::relocate(sessile_sum, .before = geom)

mapview::mapview(hex_sessile)

#####################################
#####################################

# sessile no geometry
hex_sessile_no_geom <- hex_sessile %>%
  # drop geometry
  sf::st_drop_geometry() %>%
  # remove unneeded fields
  dplyr::select(-h3_index)

#####################################
#####################################

# create final model hexagon grid
model_hex <- hex_mobile %>%
  # bind sessile submodel fields
  cbind(hex_sessile_no_geom) %>%
  # create nature index with respective submodel values
  dplyr::mutate(nature_index = mobile_sum * submodel1 + sessile_sum * submodel2) %>%
  # relocate nature index field
  dplyr::relocate(nature_index, .before = geom)

# create a CSV version of data
model_hex_csv <- model_hex %>%
  # change geometry to appropriate format
  dplyr::mutate(geometry = sf::st_as_text(geom)) %>%
  # drop other geometry field
  sf::st_drop_geometry()

# inspect data
mapview::mapview(model_hex,
                 # column to map
                 zcol = "nature_index",
                 # show legend
                 legend = TRUE)

#####################################
#####################################

# export as geopackage
sf::st_write(obj = model_hex,
             # destination
             dsn = "data/d_final_data/north_sea_nature_index.gpkg",
             # layer
             layer = "north_sea_model_4555_mobilesessile",
             # appending
             append = F)


#####################################

# ODP
## connect to client
client <- odp::odp_client()

## load in dataset (see https://app.hubocean.earth/)
dataset <- client$dataset("47b3ee44-ced3-4d87-ae50-a181b7a31e5c")

## prepare the data for ODP
model_hex_odp <- model_hex %>%
  # change geometry to appropriate format
  dplyr::mutate(geometry = sf::st_as_text(geom)) %>%
  # drop the old geometry
  sf::st_drop_geometry()

# generate table (defaults to the first table in the dataset)
table <- dataset$table

# drop the existing table
table$drop()

# create with the table to repopulate
table$create(model_hex_odp)

#####################################

# write to CSV
readr::write_csv(x = model_hex_csv,
                 # file
                 file = "data/d_final_data/model_hex.csv",
                 # appending
                 append = TRUE,
                 # column names
                 col_names = TRUE)
