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

# load in dataset (see https://app.hubocean.earth/) -- protected areas
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

doggerbank <- data %>%
  dplyr::filter(grepl(pattern = "Doggerbank",
                      # field
                      x = sitename,
                      # is not case sensitive
                      ignore.case = T))

sydlige_nordso <- data %>%
  dplyr::filter(grepl(pattern = "Sydlige Nordsø",
                      # field
                      x = sitename,
                      # is not case sensitive
                      ignore.case = T))

mapview::mapview(doggerbank)
mapview::mapview(sydlige_nordso)

#####################################

# Doggerbank
fulmarus_glacialis <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_137195_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = doggerbank,
              # mask the data
              mask = T)
mapview::mapview(fulmarus_glacialis)
terra::minmax(fulmarus_glacialis)
hist(fulmarus_glacialis)
doggerbank_fulmarus_glacialis <- sum(!is.na(values(fulmarus_glacialis)))
probable_mask <- fulmarus_glacialis > 50 & fulmarus_glacialis <= 75
count_probable <- sum(values(probable_mask), na.rm = TRUE)
count_probable / doggerbank_fulmarus_glacialis * 100


larus_fuscus <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_137142_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = doggerbank,
              # mask the data
              mask = T)
mapview::mapview(larus_fuscus)
terra::minmax(larus_fuscus)
hist(larus_fuscus)
doggerbank_larus_fuscus <- sum(!is.na(values(larus_fuscus)))
probable_mask <- larus_fuscus > 50 & larus_fuscus <= 75
count_probable <- sum(values(probable_mask), na.rm = TRUE)
count_probable / doggerbank_larus_fuscus * 100
core_mask <- larus_fuscus > 75
count_core <- sum(values(core_mask), na.rm = TRUE)
count_core / doggerbank_larus_fuscus * 100

morus_bassanus <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_148776_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = doggerbank,
              # mask the data
              mask = T)
mapview::mapview(morus_bassanus)
terra::minmax(morus_bassanus)
hist(morus_bassanus)
doggerbank_morus_bassanus <- sum(!is.na(values(morus_bassanus)))
probable_mask <- morus_bassanus > 50 & morus_bassanus <= 75
count_probable <- sum(values(probable_mask), na.rm = TRUE)
count_probable / doggerbank_morus_bassanus * 100
core_mask <- morus_bassanus > 75
count_core <- sum(values(core_mask), na.rm = TRUE)
count_core / doggerbank_morus_bassanus * 100

rissa_tridactyla <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_137156_ensemble_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = doggerbank,
              # mask the data
              mask = T)
mapview::mapview(rissa_tridactyla[[1]])
terra::minmax(rissa_tridactyla[[1]])
hist(rissa_tridactyla[[1]])
doggerbank_rissa_tridactyla <- sum(!is.na(values(rissa_tridactyla[[1]])))
probable_mask <- rissa_tridactyla[[1]] > 50 & rissa_tridactyla[[1]] <= 75
count_probable <- sum(values(probable_mask), na.rm = TRUE)
count_probable / doggerbank_rissa_tridactyla * 100
core_mask <- rissa_tridactyla[[1]] > 75
count_core <- sum(values(core_mask), na.rm = TRUE)
count_core / doggerbank_rissa_tridactyla * 100


uria_aalge <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_137133_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = doggerbank,
              # mask the data
              mask = T)
mapview::mapview(uria_aalge)
terra::minmax(uria_aalge)
hist(uria_aalge)
doggerbank_uria_aalge <- sum(!is.na(values(uria_aalge)))
probable_mask <- uria_aalge > 50 & uria_aalge <= 75
count_probable <- sum(values(probable_mask), na.rm = TRUE)
count_probable / doggerbank_uria_aalge * 100
core_mask <- uria_aalge > 75
count_core <- sum(values(core_mask), na.rm = TRUE)
count_core / doggerbank_uria_aalge * 100

phoca_vitulina <- terra::rast(x = "data/b_intermediate_data/species/cetaceans/taxonid_137084_ensemble_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = doggerbank,
              # mask the data
              mask = T)
mapview::mapview(phoca_vitulina[[1]])
terra::minmax(phoca_vitulina[[1]])
hist(phoca_vitulina[[1]])
doggerbank_phoca_vitulina <- sum(!is.na(values(phoca_vitulina[[1]])))
unlikely_mask <- phoca_vitulina[[1]] < 50
count_unlikely <- sum(values(unlikely_mask), na.rm = TRUE)
count_unlikely / doggerbank_phoca_vitulina * 100
probable_mask <- phoca_vitulina[[1]] >= 50 & phoca_vitulina[[1]] <= 75
count_probable <- sum(values(probable_mask), na.rm = TRUE)
count_probable / doggerbank_phoca_vitulina * 100
core_mask <- phoca_vitulina > 75
count_core <- sum(values(core_mask), na.rm = TRUE)
count_core / doggerbank_phoca_vitulina * 100

phocoena_phocoena <- terra::rast(x = "data/b_intermediate_data/species/cetaceans/taxonid_137117_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = doggerbank,
              # mask the data
              mask = T)
mapview::mapview(phocoena_phocoena[[1]])
terra::minmax(phocoena_phocoena[[1]])
hist(phocoena_phocoena[[1]])
doggerbank_phocoena_phocoena <- sum(!is.na(values(phocoena_phocoena[[1]])))
unlikely_mask <- phocoena_phocoena[[1]] < 50
count_unlikely <- sum(values(unlikely_mask), na.rm = TRUE)
count_unlikely / doggerbank_phocoena_phocoena * 100
probable_mask <- phocoena_phocoena[[1]] >= 50 & phocoena_phocoena[[1]] <= 75
count_probable <- sum(values(probable_mask), na.rm = TRUE)
count_probable / doggerbank_phocoena_phocoena * 100
core_mask <- phocoena_phocoena > 75
count_core <- sum(values(core_mask), na.rm = TRUE)
count_core / doggerbank_phocoena_phocoena * 100

# Sydlige Nordsø
halichoerus_grypus <- terra::rast(x = "data/b_intermediate_data/species/cetaceans/taxonid_137080_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = sydlige_nordso,
              # mask the data
              mask = T)
mapview::mapview(halichoerus_grypus)
terra::minmax(halichoerus_grypus)
hist(halichoerus_grypus)
sydlige_nordso_halichoerus_grypus <- sum(!is.na(values(halichoerus_grypus)))
unlikely_mask <- halichoerus_grypus < 50
count_unlikely <- sum(values(unlikely_mask), na.rm = TRUE)
count_unlikely / sydlige_nordso_halichoerus_grypus * 100
probable_mask <- halichoerus_grypus >= 50 & halichoerus_grypus <= 75
count_probable <- sum(values(probable_mask), na.rm = TRUE)
count_probable / sydlige_nordso_halichoerus_grypus * 100
core_mask <- halichoerus_grypus > 75
count_core <- sum(values(core_mask), na.rm = TRUE)
count_core / sydlige_nordso_halichoerus_grypus * 100

phoca_vitulina <- terra::rast(x = "data/b_intermediate_data/species/cetaceans/taxonid_137084_ensemble_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = sydlige_nordso,
              # mask the data
              mask = T)
mapview::mapview(phoca_vitulina[[1]])
terra::minmax(phoca_vitulina[[1]])
hist(phoca_vitulina[[1]])
sydlige_nordso_phoca_vitulina <- sum(!is.na(values(phoca_vitulina[[1]])))
unlikely_mask <- phoca_vitulina[[1]] < 50
count_unlikely <- sum(values(unlikely_mask), na.rm = TRUE)
count_unlikely / sydlige_nordso_phoca_vitulina * 100
probable_mask <- phoca_vitulina[[1]] >= 50 & phoca_vitulina[[1]] <= 75
count_probable <- sum(values(probable_mask), na.rm = TRUE)
count_probable / sydlige_nordso_phoca_vitulina * 100
core_mask <- phoca_vitulina > 75
count_core <- sum(values(core_mask), na.rm = TRUE)
count_core / sydlige_nordso_phoca_vitulina * 100

phocoena_phocoena <- terra::rast(x = "data/b_intermediate_data/species/cetaceans/taxonid_137117_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = sydlige_nordso,
              # mask the data
              mask = T)
mapview::mapview(phocoena_phocoena[[1]])
terra::minmax(phocoena_phocoena[[1]])
hist(phocoena_phocoena[[1]])
sydlige_nordso_phocoena_phocoena <- sum(!is.na(values(phocoena_phocoena[[1]])))
unlikely_mask <- phocoena_phocoena[[1]] < 50
count_unlikely <- sum(values(unlikely_mask), na.rm = TRUE)
count_unlikely / sydlige_nordso_phocoena_phocoena * 100
probable_mask <- phocoena_phocoena[[1]] >= 50 & phocoena_phocoena[[1]] <= 75
count_probable <- sum(values(probable_mask), na.rm = TRUE)
count_probable / sydlige_nordso_phocoena_phocoena * 100
core_mask <- phocoena_phocoena > 75
count_core <- sum(values(core_mask), na.rm = TRUE)
count_core / sydlige_nordso_phocoena_phocoena * 100

gavia_arctica <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_137186_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = sydlige_nordso,
              # mask the data
              mask = T)
mapview::mapview(gavia_arctica)
terra::minmax(gavia_arctica)
hist(gavia_arctica)
sydlige_nordso_gavia_arctica <- sum(!is.na(values(gavia_arctica)))
unlikely_mask <- gavia_arctica < 50
count_unlikely <- sum(values(unlikely_mask), na.rm = TRUE)
count_unlikely / sydlige_nordso_gavia_arctica * 100
probable_mask <- gavia_arctica >= 50 & gavia_arctica <= 75
count_probable <- sum(values(probable_mask), na.rm = TRUE)
count_probable / sydlige_nordso_gavia_arctica * 100
core_mask <- gavia_arctica > 75
count_core <- sum(values(core_mask), na.rm = TRUE)
count_core / sydlige_nordso_gavia_arctica * 100

gavia_stellata <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_137188_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = sydlige_nordso,
              # mask the data
              mask = T)
mapview::mapview(gavia_stellata)
terra::minmax(gavia_stellata)
hist(gavia_stellata)
sydlige_nordso_gavia_stellata <- sum(!is.na(values(gavia_stellata)))
unlikely_mask <- gavia_stellata < 50
count_unlikely <- sum(values(unlikely_mask), na.rm = TRUE)
count_unlikely / sydlige_nordso_gavia_stellata * 100
probable_mask <- gavia_stellata >= 50 & gavia_stellata <= 75
count_probable <- sum(values(probable_mask), na.rm = TRUE)
count_probable / sydlige_nordso_gavia_stellata * 100
core_mask <- gavia_stellata > 75
count_core <- sum(values(core_mask), na.rm = TRUE)
count_core / sydlige_nordso_gavia_stellata * 100

hydrocoloeus_minutus <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_567449_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = sydlige_nordso,
              # mask the data
              mask = T)
mapview::mapview(hydrocoloeus_minutus)
terra::minmax(hydrocoloeus_minutus)
hist(hydrocoloeus_minutus)
sydlige_nordso_hydrocoloeus_minutus <- sum(!is.na(values(hydrocoloeus_minutus)))
unlikely_mask <- hydrocoloeus_minutus < 50
count_unlikely <- sum(values(unlikely_mask), na.rm = TRUE)
count_unlikely / sydlige_nordso_hydrocoloeus_minutus * 100
probable_mask <- hydrocoloeus_minutus >= 50 & hydrocoloeus_minutus <= 75
count_probable <- sum(values(probable_mask), na.rm = TRUE)
count_probable / sydlige_nordso_hydrocoloeus_minutus * 100
core_mask <- hydrocoloeus_minutus > 75
count_core <- sum(values(core_mask), na.rm = TRUE)
count_core / sydlige_nordso_hydrocoloeus_minutus * 100

melanitta_nigra <- terra::rast(x = "data/b_intermediate_data/species/seabirds/taxonid_137073_maxent_scen_current.grd") %>%
  # crop species raster
  terra::crop(x = .,
              # boundary box
              y = sydlige_nordso,
              # mask the data
              mask = T)
mapview::mapview(melanitta_nigra)
terra::minmax(melanitta_nigra)
hist(melanitta_nigra)
sydlige_nordso_melanitta_nigra <- sum(!is.na(values(melanitta_nigra)))
unlikely_mask <- melanitta_nigra < 50
count_unlikely <- sum(values(unlikely_mask), na.rm = TRUE)
count_unlikely / sydlige_nordso_melanitta_nigra * 100
probable_mask <- melanitta_nigra >= 50 & melanitta_nigra <= 75
count_probable <- sum(values(probable_mask), na.rm = TRUE)
count_probable / sydlige_nordso_melanitta_nigra * 100
core_mask <- melanitta_nigra > 75
count_core <- sum(values(core_mask), na.rm = TRUE)
count_core / sydlige_nordso_melanitta_nigra * 100
