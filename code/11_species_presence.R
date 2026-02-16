############################
### 11. species presence ###
############################

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

# input directory
data_dir <- "data/b_intermediate_data/presence"

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
  137102,
  137084,
  137117,
  137119,
  137107,
  137111)

sp <- cetaceans_species[1]

file <- fs::dir_ls(path = data_dir,
                   regexp = stringr::str_glue("{sp}"))[1]

rast <- terra::rast(file)

richness_raster <- 

model <- stringr::str_extract(file, "(?<=taxonid=)[^_]+(?=_scen)")

species <- terra::rast(files[6])
mapview::mapview(species)

sp <- cetaceans_species[1]

file <- fs::dir_ls(path = species_dir,
                   regexp = stringr::str_glue("{sp}"))

# open species file
for (sp in target_species) {
  message("Loading data for species ", sp)
  
  try(file <- fs::dir_ls(path = species_dir,
                         regexp = stringr::str_glue("{sp}")), silent = F)
  
  # (?<=...) = after
  # (?=...) = before
  try(model <- stringr::str_extract(file, "(?<=mpaeu_method=)[^_]+(?=_scen)"), silent = F)
  
  try(species <- terra::rast(x = fs::path(species_dir, stringr::str_glue("taxonid={sp}_model=mpaeu_method={model}_scen=current_cog"), ext = "tif")), silent = F)
  
  message("Cropping and masking data for species ", sp)
  
  # crop and mask species to boundary box
  try(species_ns <- species %>%
        terra::crop(x = .,
                    # boundary box
                    y = bbox,
                    # mask the data
                    mask = T), silent = F)
  try(plot(species_ns, main = stringr::str_glue("{sp} SDM")), silent = F)
  
  message("Exporting species ", sp)
  
  # export data
  try(terra::writeRaster(x = species_ns, filename = fs::path(output_dir, stringr::str_glue("taxonid_{sp}_{model}_scen_current.grd")), overwrite = T), silent = F)
  
  message("Create presence/absence data for species", sp)
  
  # transform data based on probability of occurence
  try(present_values <- ifelse(species_ns[] <= threshold1, 0.3, # very low probability of species exist
                               # probable (0.6)
                               ifelse(species_ns[] > threshold1 & species_ns[] <= threshold2, 0.6,
                                      # core habitat (1.)
                                      ifelse(species_ns[] > threshold2 & species_ns[] <= threshold3, 1, NA))), silent = F)
  
  try(species_ns_present <- terra::setValues(species_ns, present_values), silent = F)
  try(plot(species_ns_present, main = stringr::str_glue("{sp} presence")), silent = F)
  
  # export data
  try(terra::writeRaster(x = species_ns_present, filename = fs::path(presence_dir, stringr::str_glue("taxonid_{sp}_{model}_scen_current_presence.grd")), overwrite = T), silent = F)
}