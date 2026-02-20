######################################################
### 09. Cetacean and seabird species distributions ###
######################################################

# Clear environment
rm(list = ls())

# Code provided by Silas Principe (https://gist.github.com/silasprincipe/92e98348608615c2bd9304ffbcf982ce)

# Explore also through the STAC catalogue:
# https://radiantearth.github.io/stac-browser/#/external/obis-maps.s3.us-east-1.amazonaws.com/sdm/stac/catalog.json

#####################################
#####################################

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

# parameter
## set model methods of interest
priority_models <- c("maxent", "ensemble") #rf, xgboost, esm

#####################################
#####################################

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

# create and set output directory
fs::dir_create("data/a_raw_data/species")
fs::dir_create("data/a_raw_data/species/cetaceans")
cetaceans_folder <- "data/a_raw_data/species/cetaceans"

for (sp in cetaceans_species) {
    message("Downloading data for species ", sp)

    sp_json <- try(suppressWarnings(jsonlite::read_json(stringr::str_glue(
        "https://obis-maps.s3.us-east-1.amazonaws.com/sdm/stac/species-catalog/species-mpaeu/species-mpaeu-collection/taxonid={sp}/taxonid={sp}.json"
    ))), silent = TRUE)

    if (inherits(sp_json, "try-error")) {
        message("No data for species ", sp)
        next
    }

    # get methods for the species
    met <- unlist(sp_json$properties$methods, use.names = F)

    # return methods that match the ones of interest
    available_met <- intersect(priority_models, met)

    if (length(available_met) < 1) {
        message("No data for species ", sp, " for selected methods")
        next
    }

    # download the species file
    sp_download <- stringr::str_glue("https://obis-maps.s3.us-east-1.amazonaws.com/sdm/species/taxonid={sp}/model=mpaeu/predictions/taxonid={sp}_model=mpaeu_method={available_met[1]}_scen=current_cog.tif")
    download.file(
        url = sp_download,
        destfile = file.path(cetaceans_folder, basename(sp_download))
    )
}

#####################################
#####################################

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

fs::dir_create("data/a_raw_data/species/seabirds")
seabirds_folder <- "data/a_raw_data/species/seabirds"

for (sp in seabirds_species) {
  message("Downloading data for species ", sp)
  
  sp_json <- try(suppressWarnings(jsonlite::read_json(stringr::str_glue(
    "https://obis-maps.s3.us-east-1.amazonaws.com/sdm/stac/species-catalog/species-mpaeu/species-mpaeu-collection/taxonid={sp}/taxonid={sp}.json"
  ))), silent = TRUE)
  
  if (inherits(sp_json, "try-error")) {
    message("No data for species ", sp)
    next
  }
  
  # get methods for the species
  met <- unlist(sp_json$properties$methods, use.names = F)
  
  # return methods that match the ones of interest
  available_met <- intersect(priority_models, met)
  
  if (length(available_met) < 1) {
    message("No data for species ", sp, " for selected methods")
    next
  }
  
  # download the species file
  sp_download <- stringr::str_glue("https://obis-maps.s3.us-east-1.amazonaws.com/sdm/species/taxonid={sp}/model=mpaeu/predictions/taxonid={sp}_model=mpaeu_method={available_met[1]}_scen=current_cog.tif")
  download.file(
    url = sp_download,
    destfile = file.path(seabirds_folder, basename(sp_download))
  )
}
