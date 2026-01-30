##################################
### XX. ICES seabirds surveys ###
##################################

# Clear environment
rm(list = ls())

# packages
# install straight from GitHub (requires remotes, pak, or devtools)
# install.packages("remotes")  # skip if already installed
# remotes::install_local("~/dev/odp_sdkr", build = TRUE, build_vignettes = TRUE)
# remotes::install_github("ropensci/worrms")

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,
               odp,
               sf,
               tidyr)

# Commentary on R and code formulation:
## ***Note: If not familiar with dplyr notation
## dplyr is within the tidyverse and can use %>%
## to "pipe" a process, allowing for fluidity
## Can learn more here: https://style.tidyverse.org/pipes.html

## Another  common coding notation used is "::"
## For instance, you may encounter it as dplyr::filter()
## This means use the filter function from the dplyr package
## Notation is used given sometimes different packages have
## the same function name, so it helps code to tell which
## package to use for that particular function.
## The notation is continued even when a function name is
## unique to a particular package so it is obvious which
## package is used

#####################################
#####################################

# parameters
### will need to define the geometry field (e.g., wkt_point)
### boundary box for the study region
bbox <- 'wkt_point within "POLYGON((-4.4454 50.9954, 12.0059 50.9954, 12.0059 61.0170, -4.4454 61.0170, -4.4454 50.9954))"'
odp_data <- "71ca7b80-a2e0-4721-be6f-cbe820b3c3ef"

lat1 <- 50.9954
lat2 <- 61.0170

lon1 <- -4.4454
lon2 <- 12.0059

#####################################
#####################################

# Set directories
## Define data directory (as this is an R Project, pathnames are simplified)
### Input directories
observations <- read.csv(file = "data/a_raw_data/ESAS_0115262075/Observations.csv")
positions <- read.csv(file = "data/a_raw_data/ESAS_0115262075/Positions.csv") %>%
  dplyr::rename("lat" = "Latitude",
                "lon" = "Longitude")

### Output directories
#### Analysis directories
output_dir <- "data/b_intermediate_data"

#####################################
#####################################

df <- observations %>%
  dplyr::select(c(1:3, 8:13)) %>%
  dplyr::left_join(x = .,
                   y = positions,
                   by = c("CampaignID", "SampleID", "PositionID")) %>%
  dplyr::filter(lat >= lat1 & lat <= lat2,
                lon >= lon1 & lon <= lon2) %>%
  dplyr::select(1:12) %>%
  dplyr::filter(!stringr::str_detect(SpeciesEnglishName, "unidentified"))
View(df)

# species_list <- list(unique(df$SpeciesEnglishName))
species_list <- df %>%
  dplyr::distinct(.data = .,
                  SpeciesEnglishName, SpeciesScientificName)
species_list

ns_seabirds <- df %>%
  dplyr::select(SpeciesScientificName, SpeciesEnglishName, WormsAphiaID, WormsScientificName) %>%
  # remove non-bird species (seals, dolphins, whales, sharks, porpoises)
  dplyr::filter(!stringr::str_detect(SpeciesEnglishName, "Seal|Dolphin|Shark|Whale|Porpoise")) %>%
  janitor::tabyl(dat = .,
                 var1 = SpeciesEnglishName) %>%
  dplyr::left_join(x = .,
                   y = species_list,
                   by = "SpeciesEnglishName") %>%
  dplyr::relocate("SpeciesScientificName",
                  .after = "SpeciesEnglishName") %>%
  dplyr::arrange(desc(n))
View(ns_seabirds)

top_50 <- ns_seabirds %>%
  dplyr::slice_head(n = 52) %>%
  dplyr::arrange(n)
View(top_50)

seabirds <- df %>%
  dplyr::filter(SpeciesScientificName %in% top_50$SpeciesScientificName) %>%
    # to have geometries, set as simple feature in WGS84
    sf::st_as_sf(x = .,
                 coords = c("lon", "lat"),
                 crs = 4326)
head(seabirds)


##############

# export data
sf::st_write(obj = seabirds,
             # destination as a parquet file
             dsn = fs::path(output_dir,
                             "ices_seabirds.gpkg"),
             append = F)
