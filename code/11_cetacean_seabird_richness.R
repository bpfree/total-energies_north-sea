##################################################
### 11. cetaceans and seabird species richness ###
##################################################

# clear environment
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

#####################################
#####################################

# input directory
fs::dir_create("data/b_intermediate_data")
cetaceans_dir <- "data/b_intermediate_data/presence/cetaceans"
output_dir <- "data/b_intermediate_data/richness"

# create species list
# List your species here
cetaceans_species <- c(
  # cetaceans
  137087,
  137091,
  137094,
  137098,
  137080,
  137100,
  137101,
  137102, # there are two -- need to remove one
  137084, # there are two -- need to remove one
  137117,
  137119,
  137107,
  137111) # there are two -- need to remove one

#####################################

# get all the cetaceans raster layers
cetaceans_files <- fs::dir_ls(
  # path
  path = cetaceans_dir,
  # return only files that end with .grd
  regexp = stringr::str_glue("\\.grd$"),
  # files
  type = "file"
)

# calculate the number of files that match the .grd in the specified folder
length(cetaceans_files)

# open species presence raster files as a list
cetaceans_list <- lapply(cetaceans_files, terra::rast)

# create a stack of the species raster files
cetaceans_stack <- terra::rast(cetaceans_list)

# inspect data
sources(cetaceans_stack) # will show 13 sources
names(cetaceans_stack) # will show 16 layers (3 with 2 layers)
terra::nlyr(cetaceans_stack) # should show 16 layers

# remove the duplicated layers for the 3 species (using their index location)
cetaceans_select <- cetaceans_stack[[-c(3,11,14)]]

# inspect data
sources(cetaceans_select) # will show 13 sources
names(cetaceans_select) # will show 13 layers (duplicates removed)
terra::nlyr(cetaceans_select) # should show 13 layers

#####################################

# inspect data
mapview::mapview(cetaceans_select)
plot(cetaceans_select)

# create summed raster
cetaceans_sum <- terra::app(cetaceans_select,
                            # apply function (sum)
                          fun = sum,
                          # remove any that meet NAs
                          na.rm = TRUE)

# inspect data
plot(cetaceans_sum)

# export data
terra::writeRaster(x = cetaceans_sum, filename = fs::path(output_dir, "ns_cetaceans_species_richness", ext = "grd"), overwrite = T)

#####################################
#####################################

# convert raster to vector
ns_ceta_poly <- cetaceans_sum |>
  # convert raster to polygons
  terra::as.polygons() |>
  # set as sf
  sf::st_as_sf() |>
  # rename field
  dplyr::rename("richness" = "sum") %>%
  # reclassify species richness
  dplyr::mutate("rescale" = (richness - min(richness)) / (max(richness) - min(richness))) |>
  # change values for reclassification
  dplyr::mutate("rescale" = ifelse(rescale == 0.00,
                                   # when species richness reclassification equals 0 (minimum) add 0.01
                                   rescale + 0.01,
                                   # otherwise keep reclassification value
                                   rescale))

# inspect data
names(ns_ceta_poly)
View(ns_ceta_poly)
mapview::mapview(ns_ceta_poly)

#####################################
#####################################

# load hex grid
hex_dir <- "data/b_intermediate_data/study_area.gpkg"
hex_grid <- sf::st_read(dsn = hex_dir, layer = "ns_hexes_full")

# cetacean species richness hex grid
region_ceta_hex <- hex_grid[ns_ceta_poly, ] %>%
  # spatially join fish species richness values to North Sea hex cells
  sf::st_join(x = .,
              # joned data
              y = ns_ceta_poly,
              # join function
              join = st_intersects) %>%
  # drop geometry -- faster processing
  sf::st_drop_geometry() |>
  # group by H3 index and layer name
  dplyr::group_by(h3_index) |>
  # return only distinct rows (remove duplicates)
  dplyr::summarize(ceta_rich = max(rescale)) %>%
  # ungroup to get each H3 index and its max species value
  dplyr::ungroup()

# check for duplicates -- there don't seem to be any
duplicates <- region_ceta_hex %>%
  # create frequency field based on index
  dplyr::add_count(h3_index) %>%
  # see which ones are duplicates
  dplyr::filter(n>1) %>%
  # show distinct options
  dplyr::distinct()

region_ceta_hex_join <- hex_grid %>%
  # join data to the full hex grid
  dplyr::inner_join(x = .,
                    # joined data
                    y = region_ceta_hex,
                    # joined field
                    by = "h3_index")

# mapview::mapview(region_ceta_hex_join)

#####################################
#####################################

# export data
sf::st_write(obj = region_ceta_hex_join,
             dsn = "data/c_hex_data/data_ns_hex.gpkg",
             layer = "ceta_hex",
             append = F)

#####################################
#####################################
#####################################
#####################################

# input directory
seabirds_dir <- "data/b_intermediate_data/presence/seabirds"

# create species list
# List your species here
seabirds_species <- c(
  # seabirds
  137128,
  137129, # there are two -- need to remove one
  159172,
  159179,
  137130,
  137137,
  137071,
  137131,
  137195,
  137185,
  137186,
  137187,
  137188,
  148798,
  1773443, # species data not existing
  137189,
  567449,
  567825,
  137138,
  137141,
  137142,
  137144,
  137145,
  137146,
  137147, # see species 1584284
  1584284,
  232052,
  137149,
  137072,
  137073,
  159097,
  159098,
  148776,
  137178,
  137179,
  137168,
  137169,
  137181,
  137182,
  137183,
  137184,
  137203,
  137156, # there are two -- need to remove one
  137074,
  137075,
  137171,
  137172,
  137173,
  137174,
  137162,
  137165,
  567480,
  413044, # see species 137166
  137166,
  137133
)

#####################################
#####################################

# load data
seabirds_files <- fs::dir_ls(
  # path
  path = seabirds_dir,
  # return on .grd files
  regexp = stringr::str_glue("\\.grd$"),
  # files
  type = "file"
)

# inspect data
length(seabirds_files)

# open seabird species rasters as list
seabirds_list <- lapply(seabirds_files, terra::rast)

# create stack of seabird species rasters
seabirds_stack <- terra::rast(seabirds_list)

# inspect data
sources(seabirds_stack) # will show 52 sources
names(seabirds_stack) # will show 52 layers (2 with 2 layers -- 137129 and 137156)
terra::nlyr(seabirds_stack) # should show 54 layers

seabirds_select <- seabirds_stack[[-c(8, 21)]]

sources(seabirds_select) # will show 52 sources
names(seabirds_select) # will show 52 layers (duplicates removed)
terra::nlyr(seabirds_select) # should show 52 layers

# summarize seabird species richness across the stack
seabirds_sum <- terra::app(seabirds_select,
                           # function for summarizing
                           fun = sum,
                           # remove NAs
                           na.rm = TRUE)

# inspect data
plot(seabirds_sum)

# export data
terra::writeRaster(x = seabirds_sum, filename = fs::path(output_dir, "ns_seabirds_species_richness", ext = "grd"), overwrite = T)

#####################################
#####################################

# convert raster to vector
ns_seabirds_poly <- seabirds_sum |>
  # convert raster to polygons
  terra::as.polygons() |>
  # set as sf
  sf::st_as_sf() |>
  # rename field
  dplyr::rename("richness" = "sum") %>%
  # reclassify species richness (between 0 and 1)
  dplyr::mutate("rescale" = (richness - min(richness)) / (max(richness) - min(richness))) |>
  dplyr::mutate("rescale" = ifelse(rescale == 0.00,
                                   # when species richness reclassification equals 0 (minimum) add 0.01
                                   rescale + 0.01,
                                   # otherwise keep reclassification value
                                   rescale))

# inspect data
names(ns_seabirds_poly)
View(ns_seabirds_poly)
mapview::mapview(ns_seabirds_poly)

# seabird species richness on hex grid
region_seabirds_hex <- hex_grid[ns_seabirds_poly, ] %>%
  # spatially join fish species richness values to North Sea hex cells
  sf::st_join(x = .,
              # joined data
              y = ns_seabirds_poly,
              # joined function
              join = st_intersects) %>%
  # drop geometry -- faster processing
  sf::st_drop_geometry() |>
  # group by H3 index and layer name
  dplyr::group_by(h3_index) |>
  # return only distinct rows (remove duplicates)
  dplyr::summarize(bird_rich = max(rescale)) %>%
  # ungroup to get each H3 index and its max species value
  dplyr::ungroup()

# check for duplicates -- there don't seem to be any
duplicates <- region_seabirds_hex %>%
  # create frequency field based on index
  dplyr::add_count(h3_index) %>%
  # see which ones are duplicates
  dplyr::filter(n>1) %>%
  # show distinct options
  dplyr::distinct()

# join seabirds species richness on full hex grid
region_seabirds_hex_join <- hex_grid %>%
  dplyr::inner_join(x = .,
                    # joined data
                    y = region_seabirds_hex,
                    # joined column
                    by = "h3_index")

# mapview::mapview(region_seabirds_hex_join)

#####################################
#####################################

# export data
sf::st_write(obj = region_seabirds_hex_join,
             # destination
             dsn = "data/c_hex_data/data_ns_hex.gpkg",
             # layer
             layer = "seabirds_hex",
             # appending
             append = F)
