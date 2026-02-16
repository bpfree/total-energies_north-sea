# combined species richness
rm(list = ls())

# libraries
library(terra)
library(stringr)
library(tidyverse)
library(sf)

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

# # open species file
# for (sp in target_species) {
#   message("Loading data for species ", sp)
#   
#   file <- fs::dir_ls(path = presence_dir,
#                      regexp = stringr::str_glue("{sp}"))
#   
#   # (?<=...) = after
#   # (?=...) = before
#   # [^...] = list excluded characters
#   model <- stringr::str_extract(file, "(?<=mpaeu_method=)[^_]+(?=_scen)")
# }

cetaceans_files <- fs::dir_ls(
  path = cetaceans_dir,
  regexp = stringr::str_glue("\\.grd$"),
  type = "file"
)

length(cetaceans_files)

cetaceans_list <- lapply(cetaceans_files, terra::rast)
cetaceans_stack <- terra::rast(cetaceans_list)
sources(cetaceans_stack) # will show 13 sources
names(cetaceans_stack) # will show 16 layers (3 with 2 layers)
terra::nlyr(cetaceans_stack) # should show 16 layers

# remove the duplicated layers for the 3 species (using their index location)
cetaceans_select <- cetaceans_stack[[-c(3,11,14)]]

sources(cetaceans_select) # will show 13 sources
names(cetaceans_select) # will show 16 layers (3 with 2 layers)
terra::nlyr(cetaceans_select) # should show 16 layers


mapview::mapview(cetaceans_select)
plot(cetaceans_select)

cetaceans_sum <- terra::app(cetaceans_select,
                          fun = sum,
                          na.rm = TRUE)

plot(cetaceans_sum)

terra::writeRaster(x = cetaceans_sum, filename = fs::path(output_dir, "ns_cetaceans_species_richness", ext = "grd"), overwrite = T)

#####################################
#####################################

ns_ceta_poly <- cetaceans_sum |>
  # convert raster to polygons
  terra::as.polygons() |>
  # set as sf
  sf::st_as_sf() |>
  # rename field
  dplyr::rename("richness" = "sum") %>%
  dplyr::mutate("rescale" = (richness - min(richness)) / (max(richness) - min(richness))) |>
  dplyr::mutate("rescale" = ifelse(rescale == 0.00,
                                   rescale + 0.01,
                                   rescale))

names(ns_ceta_poly)

View(ns_ceta_poly)

mapview::mapview(ns_ceta_poly)

hex_dir <- "data/b_intermediate_data/study_area.gpkg"
hex_grid <- sf::st_read(dsn = hex_dir, layer = "ns_hexes_full")

# region_ceta_hex <- hex_grid[ns_ceta_poly, ] %>%
#   # spatially join fish species richness values to North Sea hex cells
#   sf::st_join(x = .,
#               y = ns_ceta_poly,
#               join = st_intersects) %>%
#   sf::st_drop_geometry() |>
#   # group by H3 index and layer name
#   dplyr::group_by(h3_index, rescale) |>
#   # return only distinct rows (remove duplicates)
#   dplyr::summarize(max = max(rescale)) %>%
#   # ungroup to get each H3 index and its max species value
#   dplyr::ungroup()

region_ceta_hex <- hex_grid[ns_ceta_poly, ] %>%
  # spatially join fish species richness values to North Sea hex cells
  sf::st_join(x = .,
              y = ns_ceta_poly,
              join = st_intersects) %>%
  sf::st_drop_geometry() |>
  # group by H3 index and layer name
  dplyr::group_by(h3_index) |>
  # return only distinct rows (remove duplicates)
  dplyr::summarize(ceta_rich = max(rescale)) %>%
  # ungroup to get each H3 index and its max species value
  dplyr::ungroup()

# region_ceta_hex3 <- hex_grid[ns_ceta_poly, ] %>%
#   # spatially join fish species richness values to North Sea hex cells
#   sf::st_join(x = .,
#               y = ns_ceta_poly,
#               join = st_intersects) %>%
#   sf::st_drop_geometry() |>
#   # group by H3 index and layer name
#   dplyr::group_by(h3_index, rescale) |>
#   # return only distinct rows (remove duplicates)
#   dplyr::summarize(max = max(rescale)) |>
#   # ungroup to get each H3 index and its max species value
#   dplyr::distinct()

# test <- region_ceta_hex %>%
#   dplyr::group_by(h3_index) %>%
#   dplyr::summarize(max = max(rescale))

# check for duplicates -- there don't seem to be any
duplicates <- region_ceta_hex %>%
  # create frequency field based on index
  dplyr::add_count(h3_index) %>%
  # see which ones are duplicates
  dplyr::filter(n>1) %>%
  # show distinct options
  dplyr::distinct()

region_ceta_hex_join <- hex_grid %>%
  dplyr::inner_join(x = .,
                    y = region_ceta_hex,
                    by = "h3_index")

# mapview::mapview(region_ceta_hex_join)

#####################################
#####################################

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
  137129,
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
  137156,
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

seabirds_files <- fs::dir_ls(
  path = seabirds_dir,
  regexp = stringr::str_glue("\\.grd$"),
  type = "file"
)

length(seabirds_files)

seabirds_list <- lapply(seabirds_files, terra::rast)
seabirds_stack <- terra::rast(seabirds_list)
sources(seabirds_stack) # will show 13 sources
names(seabirds_stack) # will show 16 layers (3 with 2 layers)
terra::nlyr(seabirds_stack) # should show 16 layers

seabirds_select <- seabirds_stack[[-c(3,11,14)]]

sources(seabirds_select) # will show 13 sources
names(seabirds_select) # will show 16 layers (3 with 2 layers)
terra::nlyr(seabirds_select) # should show 16 layers

seabirds_sum <- terra::app(seabirds_select,
                            fun = sum,
                            na.rm = TRUE)

plot(seabirds_sum)

terra::writeRaster(x = seabirds_sum, filename = fs::path(output_dir, "ns_seabirds_species_richness", ext = "grd"), overwrite = T)

#####################################
#####################################

ns_seabirds_poly <- seabirds_sum |>
  # convert raster to polygons
  terra::as.polygons() |>
  # set as sf
  sf::st_as_sf() |>
  # rename field
  dplyr::rename("richness" = "sum") %>%
  dplyr::mutate("rescale" = (richness - min(richness)) / (max(richness) - min(richness))) |>
  dplyr::mutate("rescale" = ifelse(rescale == 0.00,
                                   rescale + 0.01,
                                   rescale))

names(ns_seabirds_poly)

View(ns_seabirds_poly)

mapview::mapview(ns_seabirds_poly)

# region_seabirds_hex <- hex_grid[ns_seabirds_poly, ] %>%
#   # spatially join fish species richness values to North Sea hex cells
#   sf::st_join(x = .,
#               y = ns_seabirds_poly,
#               join = st_intersects) %>%
#   sf::st_drop_geometry() |>
#   # group by H3 index and layer name
#   dplyr::group_by(h3_index, rescale) |>
#   # return only distinct rows (remove duplicates)
#   dplyr::summarize(max = max(rescale)) %>%
#   # ungroup to get each H3 index and its max species value
#   dplyr::ungroup()

region_seabirds_hex <- hex_grid[ns_seabirds_poly, ] %>%
  # spatially join fish species richness values to North Sea hex cells
  sf::st_join(x = .,
              y = ns_seabirds_poly,
              join = st_intersects) %>%
  sf::st_drop_geometry() |>
  # group by H3 index and layer name
  dplyr::group_by(h3_index) |>
  # return only distinct rows (remove duplicates)
  dplyr::summarize(bird_rich = max(rescale)) %>%
  # ungroup to get each H3 index and its max species value
  dplyr::ungroup()

# region_seabirds_hex3 <- hex_grid[ns_seabirds_poly, ] %>%
#   # spatially join fish species richness values to North Sea hex cells
#   sf::st_join(x = .,
#               y = ns_seabirds_poly,
#               join = st_intersects) %>%
#   sf::st_drop_geometry() |>
#   # group by H3 index and layer name
#   dplyr::group_by(h3_index, rescale) |>
#   # return only distinct rows (remove duplicates)
#   dplyr::summarize(max = max(rescale)) |>
#   # ungroup to get each H3 index and its max species value
#   dplyr::distinct()

# test <- region_seabirds_hex %>%
#   dplyr::group_by(h3_index) %>%
#   dplyr::summarize(max = max(rescale))

# check for duplicates -- there don't seem to be any
duplicates <- region_seabirds_hex %>%
  # create frequency field based on index
  dplyr::add_count(h3_index) %>%
  # see which ones are duplicates
  dplyr::filter(n>1) %>%
  # show distinct options
  dplyr::distinct()

region_seabirds_hex_join <- hex_grid %>%
  dplyr::inner_join(x = .,
                    y = region_seabirds_hex,
                    by = "h3_index")

# mapview::mapview(region_seabirds_hex_join)

#####################################
#####################################

sf::st_write(obj = region_seabirds_hex_join,
             dsn = "data/c_hex_data/data_ns_hex.gpkg",
             layer = "seabirds_hex",
             append = F)
