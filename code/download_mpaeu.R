# Code provided by Silas Principe (https://gist.github.com/silasprincipe/92e98348608615c2bd9304ffbcf982ce)

# Explore also through the STAC catalogue:
# https://radiantearth.github.io/stac-browser/#/external/obis-maps.s3.us-east-1.amazonaws.com/sdm/stac/catalog.json

library(jsonlite)
library(stringr)

# List your species here
target_species <- c(
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
  137111,
  
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
  # 1773443,
  137189,
  567449,
  567825,
  137138,
  137141,
  137142,
  137144,
  137145,
  137146,
  # 137147,
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
  # 567840,
  # 413044,
  137133
)

# create and set output directory
fs::dir_create("data/a_raw_data/species")
output_folder <- "data/a_raw_data/species"

# set model methods of interest
priority_models <- c("maxent", "ensemble") #rf, xgboost, esm

for (sp in target_species) {
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
        destfile = file.path(output_folder, basename(sp_download))
    )
}

# # Direct access is also possible
# library(terra)
# 
# sp <- 137087
# r <- rast(
#     paste0("/vsicurl/", glue("https://obis-maps.s3.us-east-1.amazonaws.com/sdm/species/taxonid={sp}/model=mpaeu/predictions/taxonid={sp}_model=mpaeu_method=maxent_scen=current_cog.tif"))
# ) # appending vsicurl makes access faster when working with https based files
