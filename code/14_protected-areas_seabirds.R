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
odp_data <- "d3a69ed4-75c7-4db9-aef9-db1c39e51296"

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

# load North Sea data
ns <- sf::st_read(dsn = fs::path(output_dir, "study_area.gpkg"), layer = "greater_north_sea")

# clean data
data <- df %>%
  # clean column names
  janitor::clean_names() %>%
  # convert the WKB geometry field to a more user friendly geometry field
  dplyr::mutate(geometry = sf::st_as_sfc(structure(as.list(geometry), class = "WKB"))) %>%
  # set CRS to WGS84
  sf::st_as_sf(crs = 4326) %>%
  # obtain only protected areas in the study area
  rmapshaper::ms_clip(target = .,
                      # clip object
                      clip = ns)

mapview::mapview(data)

protected_areas <- data %>%
  dplyr::filter(grepl(pattern = "Doggerbank|Sydlige Nordsø",
                      # field
                      x = sitename,
                      # is not case sensitive
                      ignore.case = T))

mapview::mapview(protected_areas)

#####################################

# Doggerbank
fulmarus_glacialis <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_137195_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = protected_areas,
              # mask the data
              mask = T)
plot(fulmarus_glacialis)

larus_fuscus <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_137142_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = protected_areas,
              # mask the data
              mask = T)
plot(larus_fuscus)

morus_bassanus <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_148776_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = protected_areas,
              # mask the data
              mask = T)
plot(morus_bassanus)

rissa_tridactyla <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_137156_ensemble_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = protected_areas,
              # mask the data
              mask = T)
plot(rissa_tridactyla[[1]])

uria_aalge <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_137133_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = protected_areas,
              # mask the data
              mask = T)
plot(uria_aalge)

phoca_vitulina <- terra::rast(x = "data/b_intermediate_data/species/cetaceans/taxonid_137084_ensemble_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = protected_areas,
              # mask the data
              mask = T)
plot(phoca_vitulina[[1]])

phocoena_phocoena <- terra::rast(x = "data/b_intermediate_data/species/cetaceans/taxonid_137117_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = protected_areas,
              # mask the data
              mask = T)
plot(phocoena_phocoena)

# Sydlige Nordsø
halichoerus_grypus <- terra::rast(x = "data/b_intermediate_data/species/cetaceans/taxonid_137080_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = protected_areas,
              # mask the data
              mask = T)
plot(halichoerus_grypus)

gavia_arctica <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_137186_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = protected_areas,
              # mask the data
              mask = T)
plot(gavia_arctica)

gavia_stellata <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_137188_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = protected_areas,
              # mask the data
              mask = T)
plot(gavia_stellata)

hydrocoloeus_minutus <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_567449_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = protected_areas,
              # mask the data
              mask = T)
plot(hydrocoloeus_minutus)

melanitta_nigra <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_137073_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = protected_areas,
              # mask the data
              mask = T)
plot(melanitta_nigra)
