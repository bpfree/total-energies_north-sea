##################################
### 02. ICES cetaceans surveys ###
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

#####################################
#####################################

# Set directories
## Define data directory (as this is an R Project, pathnames are simplified)
### Input directories

### Output directories
#### Analysis directories
output_dir <- "data/b_intermediate_data"

#####################################
#####################################

# set up ODP API
## to find the API key or create one, navigate to: https://app.hubocean.earth/account
### Client (API key can come from ODP_API_KEY)
### API key saved in .Renvironment so retrieving through the Sys.getenv()
### this is so the API key is not public
odp_api_key <- Sys.getenv("odp_api_key")
client <- odp::odp_client(api_key = odp_api_key)

#####################################
#####################################

# load in dataset (see https://app.hubocean.earth/) -- ICES cetaceans surveys
dataset <- client$dataset(odp_data)

# generate table (defaults to the first table in the dataset)
table <- dataset$table
schema <- table$schema()

# query -- by boundary box
## returns a cursor that streams rows lazily
cursor <- table$select(filter = bbox)

# fetch table into a dataframe that you can use for analysis
df <- cursor$dataframe()

dim(df)
names(df)
View(df)
str(df)

df2 <- df %>%
  # filter for only non-duplicated sightings and definite identifications
  # duplication sighting status: http://vocab.ices.dk/?ref=1721
  # identification confidence codes: http://vocab.ices.dk/?ref=1700
  dplyr::filter(DuplicateSightingStatus == "N",
                IdentificationConfidence == "D")
View(df2)

##############

# get list of Aphia IDs
worms_ids <- unique(df$AphiaID)
worms_ids
length(worms_ids)

# fetch the genus and genus species names for each WoRMS code
list <- data.frame(worms_id = unlist(worms_ids)) %>%
  # get the taxonomic convention
  ## need to set as character as otherwise data will not get exported correctly
  dplyr::mutate(species_name = as.character(worrms::wm_id2name_(id = worms_ids)))
print(sort(list$worms_id))

##############

# add the genus species names back to the full dataset
genus_species <- df2 %>%
  # rename the code column
  dplyr::rename("worms_id" = "AphiaID") %>%
  # join with the new genus species names
  dplyr::inner_join(x = .,
                    y = list,
                    by = "worms_id")

table <- df2 %>%
  dplyr::select(AphiaID,
                Latitude, Longitude) %>%
  # rename the code column
  dplyr::rename("worms_id" = "AphiaID",
                "lat" = "Latitude",
                "lon" = "Longitude") %>%
  # join with the new genus species names
  dplyr::inner_join(x = .,
                    y = list,
                    by = "worms_id") %>%
  # dplyr::slice(1, 3:5) %>%
  dplyr::mutate(common_name = dplyr::recode(worms_id,
                                            "2688" = "Cetacea",
                                            # "127405" = "Ocean sunfish",
                                            # "136980" = "Delphinidae", # ocean dolphins
                                            # "136986" = "Ziphiidae", # beaked whales
                                            # "137020" = "Lagenorhynchus",
                                            "137080" = "Grey whale",
                                            "137084" = "Harbor seal",
                                            "137087" = "Minke whale",
                                            "137091" = "Fin whale",
                                            "137094" = "Short-beaked common dolphin",
                                            "137098" = "Risso's dolphin",
                                            "137100" = "Atlantic white-sided dolphin",
                                            "137101" = "White-beaked dolphin",
                                            "137102" = "Orca",
                                            "137111" = "Common bottlenose dolphim",
                                            "137117" = "Harbour porpoise",
                                            # "137121" = "Sowerby's beaked whale",
                                            # "148724" = "Mysticeti", # baleen whales
                                            "148736" = "Pinnipedia", # seals
                                            "343898" = "Burmeister's porpoise",
                                            # "343899" = "Northern bottlenose dolphin",
                                            "368408" = "Selachii")) %>% # sharks
  dplyr::relocate(c(lat, lon),
                  .after = common_name)
View(table)

test <- table %>%
  dplyr::select(worms_id, species_name, common_name)
distinct(test)

# subset for data that have complete taxonomic names
species <- genus_species %>%
  # detect full taxonomic names
  dplyr::filter(stringr::str_detect(string = species_name,
                                    pattern = " ")) %>%
  # to have geometries, set as simple feature in WGS84
  sf::st_as_sf(x = .,
               wkt = "wkt_point",
               crs = 4326) %>%
  # get the common name convention
  dplyr::mutate(common_name = worrms::wm_common_id_(id = worms_ids))

genus <- genus_species %>%
  # return the WoRMS IDs that do not contain species level information
  dplyr::filter(!worms_id %in% species$worms_id) %>%
  # to have geometries, set as simple feature in WGS84
  sf::st_as_sf(x = .,
               # set the WKT to the correct geometry column
               wkt = "wkt_point",
               # set as the correct reference system (WGS84: https://epsg.io/4326)
               crs = 4326)

##############

# export data
sf::st_write(obj = species,
             # destination as a parquet file
             dsn = file.path(output_dir,
                             "ices_species.parquet"),
             # the driver to use
             driver = "Parquet")

sf::st_write(obj = genus,
             # destination as a parquet file
             dsn = file.path(output_dir,
                             "ices_genus.parquet"),
             # the driver to use
             driver = "Parquet")
