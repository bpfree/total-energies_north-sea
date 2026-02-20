#############################
### 08. cold water corals ###
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
# bbox <- 'geometry within "POLYGON((-4.4454 50.9954, 12.0059 50.9954, 12.0059 61.0170, -4.4454 61.0170, -4.4454 50.9954))"'
odp_data <- "a29029e6-0f60-4488-af33-fb3d86e02d47"

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

# load in dataset (see https://app.hubocean.earth/)
dataset <- client$dataset(odp_data)

# generate table (defaults to the first table in the dataset)
table <- dataset$table
schema <- table$schema()

# query -- by boundary box
## returns a cursor that streams rows lazily
cursor <- table$select(filter = "lat >= 50.9954 AND lat <= 61.0170 AND lon >= -4.4454 AND lon <= 12.0059")

# fetch table into a dataframe that you can use for analysis
df <- cursor$dataframe()

# dim(df)
# names(df)
# View(df)
# str(df)

#####################################

# reclassified coral data
data <- df %>%
  # clean column names
  janitor::clean_names() %>%
  # set CRS to WGS84
  sf::st_as_sf(crs = 4326, coords = c("lon", "lat")) %>%
  # create maximum coral score for species at each location
  dplyr::mutate(coral_max = pmax(aa,
                                 dp,
                                 er,
                                 gd,
                                 mo,
                                 ov,
                                 pa,
                                 pp,
                                 pr,
                                 sv),
                # reclassify based on the maximum score
                # scores come from Tong et al. (2023) [https://www.frontiersin.org/journals/marine-science/articles/10.3389/fmars.2023.1217851/full]
                classification = dplyr::case_when(coral_max < 200 ~ "very low",
                                                  coral_max >= 200 & coral_max < 400 ~ "low",
                                                  coral_max >= 400 & coral_max < 600 ~ "moderate",
                                                  coral_max >= 600 & coral_max < 800 ~ "high",
                                                  coral_max >= 800 ~ "very high"))

#####################################

# remove unneeded objects
rm(df, client, cursor, dataset, table)
# mapview::mapview(data)

# View(data)
# class(data)

#####################################

# load greater North Sea
ns <- sf::st_read(dsn = fs::path(output_dir, "study_area.gpkg"), layer = "greater_north_sea")

# to make easier on memory
data_split <- data %>%
  # create column and populate with the nth-tile for row's location (10 separate bunches)
  dplyr::mutate(split_id = dplyr::ntile(row_number(), 10)) %>%
  # group the data into batches based on the split ID
  dplyr::group_split(split_id)

# clipped data
clipped_list <- purrr::map(
  # applied list
  .x = data_split,
  # function to apply
  ~ rmapshaper::ms_clip(target = .x,
                        # clip object
                        clip = ns)
)

# rebuild coral data in study region
clipped_data <- bind_rows(clipped_list) %>%
  # removed unneeded fields
  dplyr::select(-split_id)

#####################################

# remove unneeded objects
rm(clipped_list, data, data_split, ns)

#####################################

# load hex grid data
hex_dir <- "data/b_intermediate_data/study_area.gpkg"
hex_grid <- sf::st_read(dsn = hex_dir, layer = "ns_hexes_full")

#####################################

# coral hex grids
region_data_hex <- hex_grid[clipped_data, ] %>%
  # spatially join coral values to North Sea hex cells
  sf::st_join(x = .,
              # joined data
              y = clipped_data,
              # join function
              join = st_intersects) %>%
  # select fields of importance
  dplyr::select(h3_index, coral_max, classification)

# coral hex without geometry (make it less data intense)
region_data_hex_no_geo <- region_data_hex %>%
  # drop geometry
  sf::st_drop_geometry()

# Keep only one result per cell
region_data_hex_single <- region_data_hex_no_geo %>%
  # group by key fields to reduce duplicates
  dplyr::group_by(h3_index) %>%
  # return only distinct rows (remove duplicates)
  dplyr::summarize(max = max(coral_max)) %>%
  # create classification field based on coral scores
  dplyr::mutate(classification = case_when(max < 200 ~ "very low",
                                             max >= 200 & max < 400 ~ "low",
                                             max >= 400 & max < 600 ~ "moderate",
                                             max >= 600 & max < 800 ~ "high",
                                             max >= 800 ~ "very high")) %>%
  # filter for only high and very high classifications
  dplyr::filter(grepl(pattern = "high|very high",
                      # within classification field
                      x = classification,
                      # is not case sensitive
                      ignore.case = T))

region_data_hex_join <- hex_grid %>%
  dplyr::left_join(x = .,
                   y = region_data_hex_single,
                   by = "h3_index") %>%
  dplyr::filter(grepl(pattern = "high|very high",
                      # within classification field
                      x = classification,
                      # is not case sensitive
                      ignore.case = T)) %>%
  dplyr::select(h3_index)

mapview::mapview(region_data_hex_join)

##############

# export data
# sf::st_write(obj = region_data_hex_join, dsn = "data/b_intermediate_data/habitats.gpkg", layer = "cold_water_corals_ns", append = F)
sf::st_write(obj = region_data_hex_join, dsn = "data/c_hex_data/data_ns_hex.gpkg", layer = "cold_water_corals_hex", append = F)

# inspect geopackage layers
sf::st_layers(dsn = "data/c_hex_data/coral.gpkg")
