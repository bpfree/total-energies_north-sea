# combined species richness
rm(list = ls())

# libraries
library(terra)
library(stringr)
library(tidyverse)
library(sf)

# input directory
# fs::dir_create("data/b_intermediate_data/richness")
presence_dir <- "data/b_intermediate_data/presence"
# output_dir <- "data/b_intermediate_data/richness"

cetaceans_species <- c(
  # cetaceans
  137087,
  137091,
  137094,
  137098,
  137080,
  137100,
  137101,
  137102,
  137084,
  137117,
  137119,
  137107,
  137111)

# open species file
for (sp in cetaceans_species) {
  message("Loading data for species ", sp)
  
  # files <- fs::dir_ls(path = presence_dir,
  #                     regexp = stringr::str_glue("{sp}"))[1]
  
  species_files <- fs::dir_ls(
    path = presence_dir,
    regexp = stringr::str_glue("\\.grd$"),
    type = "file")
  
  # Extract taxonid from filenames
  taxon_ids <- str_extract(species_files, "(?<=taxonid_)\\d+")
  
  # Keep only matching species
  matched_files <- species_files[taxon_ids %in% as.character(cetaceans_species)]
  matched_files

  species_list <- lapply(matched_files, terra::rast)
  
  # test <- terra::rast(species_list[2])
  # mapview::mapview(test)
  
  sp1 <- terra::rast(matched_files[1])
  sp2 <- terra::rast(matched_files[2])
  sp3 <- terra::rast(matched_files[3])
  sp4 <- terra::rast(matched_files[4])
  sp5 <- terra::rast(matched_files[5])
  sp6 <- terra::rast(matched_files[6])
  sp7 <- terra::rast(matched_files[7])
  sp8 <- terra::rast(matched_files[8])
  sp9 <- terra::rast(matched_files[9])
  sp10 <- terra::rast(matched_files[10])
  sp11 <- terra::rast(matched_files[11])
  sp12 <- terra::rast(matched_files[12])
  sp13 <- terra::rast(matched_files[13])
  
  mapview::mapview(sp3)
  
  species_list <- list(sp1,
                       sp2,
                       sp3)
  
  species_stack <- terra::rast(species_list)
  mapview::mapview(species_stack)
  terra::nlyr(species_stack)
}



terra::nlyr(species_stack)

species_sum <- terra::app(species_stack,
                    fun = sum,
                    na.rm = TRUE)

mapview::mapview(species_sum)

terra::writeRaster(x = species_sum, filename = fs::path(output_dir, "ns_species_richness", ext = "grd"), overwrite = T)
