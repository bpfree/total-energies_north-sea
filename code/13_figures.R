###################
### 13. figures ###
###################

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

# inspect geopackages
sf::st_layers(dsn = data_dir)

#####################################
#####################################

data <- sf::st_read(dsn = data_dir,
                    layer = "north_sea_model_4555_mobilesessile")

#####################################
#####################################

# Theme
base_theme <- theme(axis.text=element_text(size=7),
                    axis.title=element_text(size=9),
                    legend.text=element_text(size=7),
                    legend.title=element_text(size=8),
                    strip.text=element_text(size=7),
                    plot.title=element_blank(),
                    plot.tag=element_text(size=10, face="bold"),
                    panel.grid.major = element_blank(), 
                    panel.grid.minor = element_blank(),
                    panel.background = element_blank(), 
                    axis.line = element_line(colour = "black"),
                    legend.background = element_rect(fill=alpha('blue', 0)))

mobile_hist <- ggplot2::ggplot() +
  ggplot2::geom_histogram(data = data,
                          aes(x = mobile_sum)) + 
  # themes
  theme_bw() + base_theme
mobile_hist

ceta_hist <- ggplot2::ggplot() +
  ggplot2::geom_histogram(data = data,
                          aes(x = ceta_rich)) + 
  # themes
  theme_bw() + base_theme
ceta_hist

bird_hist <- ggplot2::ggplot() +
  ggplot2::geom_histogram(data = data,
                          aes(x = bird_rich)) + 
  # themes
  theme_bw() + base_theme
bird_hist

fish_hist <- ggplot2::ggplot() +
  ggplot2::geom_histogram(data = data,
                          aes(x = fish_rich)) + 
  # themes
  theme_bw() + base_theme
fish_hist

sessile_hist <- ggplot2::ggplot() +
  ggplot2::geom_histogram(data = data,
                          aes(x = sessile_sum)) + 
  # themes
  theme_bw() + base_theme
sessile_hist

nature_hist <- ggplot2::ggplot() +
  ggplot2::geom_histogram(data = data,
                          aes(x = nature_index)) + 
  # themes
  theme_bw() + base_theme
nature_hist

mapview::mapview(data,
                 # column to map
                 zcol = "nature_index",
                 # show legend
                 legend = TRUE)

