########################################
### 14. seabirds and protected areas ###
########################################

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

# directories
## input directories
data_dir <- "data/d_final_data/north_sea_nature_index.gpkg"
output_dir <- "data/b_intermediate_data"

# inspect geopackages
sf::st_layers(dsn = data_dir)

#####################################
#####################################

bbox <- 'geometry within "POLYGON((-4.4454 50.9954, 12.0059 50.9954, 12.0059 61.0170, -4.4454 61.0170, -4.4454 50.9954))"'
odp_data <- "6fdd5db8-4866-4634-9011-d7591ae7ddc4"

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

# inspect dataframe
dim(df)
names(df)
View(df)
str(df)

#####################################

# clean data
data <- df %>%
  # clean column names
  janitor::clean_names() %>%
  # convert the WKB geometry field to a more user friendly geometry field
  dplyr::mutate(geometry = sf::st_as_sfc(structure(as.list(geometry), class = "WKB"))) %>%
  # set CRS to WGS84
  sf::st_as_sf(crs = 4326)

mapview::mapview(data)

#####################################

# load North Sea data
ns <- sf::st_read(dsn = fs::path(output_dir, "study_area.gpkg"), layer = "greater_north_sea")

# greater North Sea protected areas
region_data <- data %>%
  # obtain only protected areas in the study area
  rmapshaper::ms_clip(target = .,
                      # clip object
                      clip = ns)

# inspect data
list(unique(region_data$category_name))
mapview::mapview(region_data)

#####################################
#####################################

protected_areas <- region_data %>%
  dplyr::filter(grepl(pattern = "Doggerbank|Sydlige Nordsø|",
                      # field
                      x = site_name,
                      # is not case sensitive
                      ignore.case = T))

mapview::mapview(doggerbank)

sydlige_nordso <- region_data %>%
  dplyr::filter(site_name == "Sydlige Nordsø")
mapview::mapview(sydlige_nordso)
