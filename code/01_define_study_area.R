#############################
### 01. define study area ###
#############################

# Clear environment
rm(list = ls())

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

# Set directories
## Define data directory (as this is an R Project, pathnames are simplified)
### Input directories

### Output directories
#### Analysis directories
output_dir <- "data/b_intermediate_data"

#####################################
#####################################

# study area
## create points for study area
### add points as they need to be drawn (clockwise or counterclockwise)
study_area <- rbind(c("point", -4.4454, 50.9954),
                    c("point", 12.0059, 50.9954),
                    c("point", 12.0059, 61.0170),
                    c("point", -4.4454, 61.0170),
                    c("point", -4.4454, 50.9954)) %>%
  # convert to data frame
  as.data.frame() %>%
  # rename column names
  dplyr::rename("point" = "V1",
                "lon" = "V2",
                "lat" = "V3") %>%
  # convert to simple feature
  sf::st_as_sf(coords = c("lon", "lat"),
               # set the coordinate reference system to WGS84
               crs = 4326) %>% # EPSG 4326 (https://epsg.io/4326)
  
  ######### convert the points to a polygon
  
  # group by the points field
  dplyr::group_by(point) %>%
  # combine geometries without resolving borders to create multipoint feature
  dplyr::summarise(geometry = st_combine(geometry)) %>%
  # convert back to sf
  sf::st_as_sf() %>%
  # convert to polygon simple feature
  sf::st_cast("POLYGON") %>%
  # convert back to sf
  sf::st_as_sf()

#####################################

# export the data
sf::st_write(obj = study_area,
             # destination as a parquet file
             dsn = file.path(output_dir,
                             "study_area.parquet"),
             # the driver to use
             driver = "Parquet")
