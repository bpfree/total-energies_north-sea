############################
### 10. species presence ###
############################

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

# create export directory
fs::dir_create(path = "data/b_intermediate_data/species/cetaceans")
fs::dir_create(path = "data/b_intermediate_data/species/seabirds")
fs::dir_create(path = "data/b_intermediate_data/presence/cetaceans")
fs::dir_create(path = "data/b_intermediate_data/presence/seabirds")

# input directory
cetaceans_dir <- "data/a_raw_data/species/cetaceans"
seabirds_dir <- "data/a_raw_data/species/seabirds"
data_dir <- "data/b_intermediate_data/study_area.gpkg"

# set directory
## cetaceans
ceta_sp_dir <- "data/b_intermediate_data/species/cetaceans"
ceta_pres_dir <- "data/b_intermediate_data/presence/cetaceans"

## cetaceans
seabirds_sp_dir <- "data/b_intermediate_data/species/seabirds"
seabirds_pres_dir <- "data/b_intermediate_data/presence/seabirds"

#####################################
#####################################

# load boundary box
bbox <- sf::st_read(dsn = data_dir, layer = "ns_boundary")

# set parameter
threshold1 <- 50 # unlikely to be there (<50)
threshold2 <- 75 # more probable than not (50 - 74)
threshold3 <- 100 # core habitat (75 - 100)

#####################################
#####################################

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

# open species file
for (sp in cetaceans_species) {
  message("Loading data for cetacean species ", sp)
  
  # get list of files
  try(file <- fs::dir_ls(path = cetaceans_dir,
                         regexp = stringr::str_glue("{sp}")), silent = F)
  
  # retrieve model name
  ## (?<=...) = after
  ## (?=...) = before
  try(model <- stringr::str_extract(file, "(?<=mpaeu_method=)[^_]+(?=_scen)"), silent = F)
  
  # open species raster
  try(species <- terra::rast(x = fs::path(cetaceans_dir, stringr::str_glue("taxonid={sp}_model=mpaeu_method={model}_scen=current_cog"), ext = "tif")), silent = F)
  
  message("Cropping and masking data for cetacean species ", sp)
  
  # crop and mask species to boundary box
  try(species_ns <- species %>%
        # crop species raster
        terra::crop(x = .,
                    # boundary box
                    y = bbox,
                    # mask the data
                    mask = T), silent = F)
  
  # plot the copped raster data
  try(plot(species_ns, main = stringr::str_glue("{sp} SDM")), silent = F)
  
  message("Exporting species ", sp)
  
  # export data
  try(terra::writeRaster(x = species_ns, filename = fs::path(ceta_sp_dir, stringr::str_glue("taxonid_{sp}_{model}_scen_current.grd")), overwrite = T), silent = F)

  message("Create presence/absence data for species", sp)
  
  # transform data based on probability of occurrence
  try(present_values <- ifelse(species_ns[] <= threshold1, 0.3, # very low probability of species exist
                               # probable (0.6) -- if greater than threshold 1 and equal or under threshold 2
                               ifelse(species_ns[] > threshold1 & species_ns[] <= threshold2, 0.6,
                                      # core habitat (1.0) -- if greater than threshold 2 and equal to or under threshold 3
                                      ifelse(species_ns[] > threshold2 & species_ns[] <= threshold3, 1, NA))), silent = F)
  
  # set new values to raster
  try(species_ns_present <- terra::setValues(species_ns, present_values), silent = F)
  
  # plot the new reclassified raster
  try(plot(species_ns_present,
           # title (change the species {sp} for each presence raster)
           main = stringr::str_glue("{sp} presence")), silent = F)
  
  # export data
  try(terra::writeRaster(x = species_ns_present, filename = fs::path(ceta_pres_dir, stringr::str_glue("taxonid_{sp}_{model}_scen_current_presence.grd")), overwrite = T), silent = F)
}

#####################################
#####################################

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
  137133,
  137167
)

#####################################

# open species file
for (sp in seabirds_species) {
  message("Loading data for seabird species ", sp)
  
  # list files
  try(file <- fs::dir_ls(path = seabirds_dir,
                         regexp = stringr::str_glue("{sp}")), silent = F)
  
  # retrieve model name
  ## (?<=...) = after
  ## (?=...) = before
  try(model <- stringr::str_extract(file, "(?<=mpaeu_method=)[^_]+(?=_scen)"), silent = F)
  
  # load species raster
  try(species <- terra::rast(x = fs::path(seabirds_dir, stringr::str_glue("taxonid={sp}_model=mpaeu_method={model}_scen=current_cog"), ext = "tif")), silent = F)
  
  message("Cropping and masking data for seabird species ", sp)
  
  # crop and mask species to boundary box
  try(species_ns <- species %>%
        # crop species raster
        terra::crop(x = .,
                    # boundary box
                    y = bbox,
                    # mask the data
                    mask = T), silent = F)
  
  # plot raster
  try(plot(species_ns, main = stringr::str_glue("{sp} SDM")), silent = F)
  
  message("Exporting species ", sp)
  
  # export data
  try(terra::writeRaster(x = species_ns, filename = fs::path(seabirds_sp_dir, stringr::str_glue("taxonid_{sp}_{model}_scen_current.grd")), overwrite = T), silent = F)
  
  message("Create presence/absence data for species", sp)
  
  # transform data based on probability of occurrence
  try(present_values <- ifelse(species_ns[] <= threshold1, 0.3, # very low probability of species exist
                               # probable (0.6) -- if greater than threshold 1 and equal or under threshold 2
                               ifelse(species_ns[] > threshold1 & species_ns[] <= threshold2, 0.6,
                                      # core habitat (1.0) -- if greater than threshold 2 and equal or under threshold 3
                                      ifelse(species_ns[] > threshold2 & species_ns[] <= threshold3, 1, NA))), silent = F)
  
  # set new values to raster
  try(species_ns_present <- terra::setValues(species_ns, present_values), silent = F)
  
  # plot the new reclassified raster
  try(plot(species_ns_present,
           # title (change the species {sp} for each presence raster)
           main = stringr::str_glue("{sp} presence")), silent = F)
  
  # export data
  try(terra::writeRaster(x = species_ns_present, filename = fs::path(seabirds_pres_dir, stringr::str_glue("taxonid_{sp}_{model}_scen_current_presence.grd")), overwrite = T), silent = F)
}
