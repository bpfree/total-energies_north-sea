#############################
### 01. Define Study Area ###
#############################

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
dataset <- client$dataset("71ca7b80-a2e0-4721-be6f-cbe820b3c3ef")

# generate table (defaults to the first table in the dataset)
table <- dataset$table
schema <- table$schema()

# query -- by boundary box
## returns a cursor that streams rows lazily
cursor <- table$select(filter = bbox)

# fetch table into a dataframe that you can use for analysis
df <- cursor$dataframe()
View(df)

##############

# get list of Aphia IDs
worms_ids <- unique(df$AphiaID)
worms_ids

list <- data.frame(worms_id = unlist(worms_ids)) %>%
  # get the taxonomic convention
  ## need to set as character as otherwise data will not get exported correctly
  dplyr::mutate(species_name = as.character(worrms::wm_id2name_(id = worms_ids)))
View(list)

##############

genus_species <- df %>%
  dplyr::rename("worms_id" = "AphiaID") %>%
  dplyr::inner_join(x = .,
                    y = list,
                    by = "worms_id")


species <- genus_species %>%
  # detect full taxonomic names
  dplyr::filter(stringr::str_detect(string = species_name,
                                    pattern = " ")) %>%
  sf::st_as_sf(x = .,
               wkt = "wkt_point",
               crs = 4326)
  # # get the common name convention
  # dplyr::mutate(common_name = worrms::wm_common_id_(id = worms_ids))
species

genus <- genus_species %>%
  # return the WoRMS IDs that do not contain species level information
  dplyr::filter(!worms_id %in% species$worms_id) %>%
  # convert to sf to export
  sf::st_as_sf(x = .,
               # set the WKT to the correct geometry column
               wkt = "wkt_point",
               # set as the correct reference system (WGS84: https://epsg.io/4326)
               crs = 4326)
genus

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
             driver = "Parquet",
             append = F)
