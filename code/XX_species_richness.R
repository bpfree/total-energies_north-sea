# combined species richness
rm(list = ls())

# libraries
library(terra)
library(stringr)
library(tidyverse)
library(sf)

# input directory
fs::dir_create("data/b_intermediate_data/richness")
presence_dir <- "data/b_intermediate_data/presence"
output_dir <- "data/b_intermediate_data/richness"


# open species file
for (sp in target_species) {
  message("Loading data for species ", sp)
  
  file <- fs::dir_ls(path = presence_dir,
                      regexp = stringr::str_glue("{sp}"))
  
  # (?<=...) = after
  # (?=...) = before
  # [^...] = list excluded characters
  model <- stringr::str_extract(file, "(?<=mpaeu_method=)[^_]+(?=_scen)")
}

species_files <- fs::dir_ls(
  path = presence_dir,
  regexp = stringr::str_glue("\\.grd$"),
  type = "file"
)

species_list <- lapply(species_files, terra::rast)
species_stack <- terra::rast(species_list)
terra::nlyr(species_stack)

species_sum <- terra::app(species_stack,
                    fun = sum,
                    na.rm = TRUE)

plot(species_sum)

terra::writeRaster(x = species_sum, filename = fs::path(output_dir, "ns_species_richness", ext = "grd"), overwrite = T)
