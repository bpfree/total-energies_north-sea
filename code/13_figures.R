###################
### 13. figures ###
###################

# Clear environment
rm(list = ls())

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,
               flextable,
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
               skimr,
               stringr,
               terra,
               tidyr)

#####################################
#####################################

# directories
## input directories
# data_dir <- "data/d_final_data/north_sea_nature_index.gpkg"

# inspect geopackages
# sf::st_layers(dsn = data_dir)

#####################################
#####################################

# data <- sf::st_read(dsn = data_dir,
#                     layer = "north_sea_model_4555_mobilesessile")

table <- readr::read_csv(file = "figure/table/model_table.csv")
names(table)
head(table, 5)

data_clean <- function(data, field){
  data %>%
    # create the table based on the field of interest
    janitor::tabyl({{field}}) %>%
    dplyr::rename("Count" = "n",
                  "Percent" = "percent") %>%
    # create the percentages with 1 digit
    janitor::adorn_pct_formatting(digits = 1) %>%
    # create a totals row
    janitor::adorn_totals(where = "row") %>%
    # convert to dataframe
    as.data.frame()
}

figure_clean <- function(data) {
  # convert to flextable
  flextable::flextable(data) %>%
    # color
    flextable::color(.,
      # row
      i = 1,
      # column
      j = NULL,
      # color
      color = "black",
      # section
      part = "header") %>%
    # bold the column names
    flextable::bold(.,
                    part = "header",
                    bold = TRUE) %>%
    # make column names centered
    flextable::align(.,
      # row
      i = 1,
      # column
      j = NULL,
      # align
      align = "center",
      # section
      part = "header") %>%
    # make "-" in the middle
    flextable::align(.,
      # row
      i = .$body$content$nrow,
      # column
      j = .$body$content$ncol,
      # align
      align = "center",
      # section
      part = "body")
}

#####################################
#####################################

# # Theme
# base_theme <- theme(axis.text=element_text(size=7),
#                     axis.title=element_text(size=9),
#                     legend.text=element_text(size=7),
#                     legend.title=element_text(size=8),
#                     strip.text=element_text(size=7),
#                     plot.title=element_blank(),
#                     plot.tag=element_text(size=10, face="bold"),
#                     panel.grid.major = element_blank(),
#                     panel.grid.minor = element_blank(),
#                     panel.background = element_blank(),
#                     axis.line = element_line(colour = "black"),
#                     legend.background = element_rect(fill=alpha('blue', 0)))
# 
# mobile_hist <- ggplot2::ggplot() +
#   ggplot2::geom_histogram(data = data,
#                           aes(x = mobile_sum)) + 
#   # themes
#   theme_bw() + base_theme
# mobile_hist
# 
# ceta_hist <- ggplot2::ggplot() +
#   ggplot2::geom_histogram(data = data,
#                           aes(x = ceta_rich)) + 
#   # themes
#   theme_bw() + base_theme
# ceta_hist
# 
# bird_hist <- ggplot2::ggplot() +
#   ggplot2::geom_histogram(data = data,
#                           aes(x = bird_rich)) + 
#   # themes
#   theme_bw() + base_theme
# bird_hist
# 
# fish_hist <- ggplot2::ggplot() +
#   ggplot2::geom_histogram(data = data,
#                           aes(x = fish_rich)) + 
#   # themes
#   theme_bw() + base_theme
# fish_hist
# 
# sessile_hist <- ggplot2::ggplot() +
#   ggplot2::geom_histogram(data = data,
#                           aes(x = sessile_sum)) + 
#   # themes
#   theme_bw() + base_theme
# sessile_hist
# 
# nature_hist <- ggplot2::ggplot() +
#   ggplot2::geom_histogram(data = data,
#                           aes(x = nature_index)) + 
#   # themes
#   theme_bw() + base_theme
# nature_hist

# mapview::mapview(data,
#                  # column to map
#                  zcol = "nature_index",
#                  # show legend
#                  legend = TRUE)

#####################################
#####################################

# summary statistics table
statistics_table <- skimr::skim(table) %>%
  # return the numeric table
  skimr::yank("numeric") %>%
  # convert to dataframe
  as.data.frame() %>%
  # export as csv
  readr::write_csv("figure/table/skim_table.csv") %>%
  # convert to flextable
  flextable::flextable() %>%
  # update header labels
  set_header_labels(.,
                    skim_variable = "Variable", 
                    n_missing = "NAs",
                    complete_rate = "Completion rate",
                    mean = "Mean",
                    sd = "Standard deviation",
                    p0 = "Minimum",
                    p25 = "1st Quartile",
                    p50 = "Median",
                    p75 = "3rd Quartile",
                    p100 = "Maximum",
                    hist = "Histogram") %>%
  flextable::color(.,
                   # row
                   i = 1,
                   # column
                   j = NULL,
                   # color
                   color = "black",
                  # section
                   part = "header") %>%
  # bold the column names
  flextable::bold(part = "header", bold = TRUE) %>%
  # make column names centered
  flextable::align(.,
                   # top row
                   i = 1,
                   # all columns
                   j = NULL,
                   # align
                   align = "center",
                   # section
                   part = "header") %>%
  # export as image
  flextable::save_as_image(path = "figure/summary_statistics_table.png")

#####################################

# create count tables
## mobile submodel
cetacean_table <- table %>%
  # clean data
  data_clean(data = .,
             # data set
             field = Cetacean) %>%
  # export as CSV
  readr::write_csv("figure/table/cetacean_table.csv") %>%
  # clean figure
  figure_clean(.) %>%
  # export as image
  flextable::save_as_image(path = "figure/cetacean_table.png")

seabird_table <- table %>%
  # clean data
  data_clean(data = .,
             # data set
             field = Seabird) %>%
  # export as CSV
  readr::write_csv("figure/table/seabird_table.csv") %>%
  # clean figure
  figure_clean(.) %>%
  # export as image
  flextable::save_as_image(path = "figure/seabird_table.png")

fish_table <- table %>%
  # clean data
  data_clean(data = .,
             # data set
             field = Fish) %>%
  # export as CSV
  readr::write_csv("figure/table/fish_table.csv") %>%
  # clean figure
  figure_clean(.) %>%
  # export as image
  flextable::save_as_image(path = "figure/fish_table.png")

mobile_table <- table %>%
  # clean data
  data_clean(data = .,
             # data set
             field = `Mobile submodel`) %>%
  # export as CSV
  readr::write_csv("figure/table/mobile_table.csv") %>%
  # clean figure
  figure_clean(.) %>%
  # export as image
  flextable::save_as_image(path = "figure/mobile_table.png")

## sessile submodel
coral_table <- table %>%
  # clean data
  data_clean(data = .,
             # data set
             field = Coral) %>%
  # export as CSV
  readr::write_csv("figure/table/coral_table.csv") %>%
  # clean figure
  figure_clean(.) %>%
  # export as image
  flextable::save_as_image(path = "figure/coral_table.png")

seagrass_table <- table %>%
  # clean data
  data_clean(data = .,
             # data set
             field = Seagrass) %>%
  # export as CSV
  readr::write_csv("figure/table/seagrass_table.csv") %>%
  # clean figure
  figure_clean(.) %>%
  # export as image
  flextable::save_as_image(path = "figure/seagrass_table.png")

imma_table <- table %>%
  # clean data
  data_clean(data = .,
             # data set
             field = IMMA) %>%
  # export as CSV
  readr::write_csv("figure/table/imma_table.csv") %>%
  # clean figure
  figure_clean(.) %>%
  # export as image
  flextable::save_as_image(path = "figure/imma_table.png")

protected_area_table <- table %>%
  # clean data
  data_clean(data = .,
             # data set
             field = `Protected area`) %>%
  # export as CSV
  readr::write_csv("figure/table/protected_area_table.csv") %>%
  # clean figure
  figure_clean(.) %>%
  # export as image
  flextable::save_as_image(path = "figure/protected_area_table.png")

sessile_table <- table %>%
  # clean data
  data_clean(data = .,
             # data set
             field = `Sessile submodel`) %>%
  # export as CSV
  readr::write_csv("figure/table/sessile_table.csv") %>%
  # clean figure
  figure_clean(.) %>%
  # export as image
  flextable::save_as_image(path = "figure/sessile_table.png")

nature_table <- table %>%
  # clean data
  data_clean(data = .,
             # data set
             field = `Nature index`) %>%
  # export as CSV
  readr::write_csv("figure/table/nature_table.csv") %>%
  # clean figure
  figure_clean(.) %>%
  # export as image
  flextable::save_as_image(path = "figure/nature_table.png")

#####################################

# Convert only your 10 target columns to 'long' format
hist <- tidyr::pivot_longer(table[, 2:11], cols = everything()) %>%
  dplyr::mutate(name = factor(name, levels = c("Cetacean",
                                               "Seabird",
                                               "Fish",
                                               "Mobile submodel",
                                               "Coral",
                                               "Seagrass",
                                               "Protected area",
                                               "IMMA",
                                               "Sessile submodel",
                                               "Nature index")))

my_theme <-  theme(axis.text=element_text(size=6),
                   axis.title=element_text(size=8),
                   axis.text.y = element_text(angle = 90, hjust = 0.5),
                   legend.text=element_text(size=6),
                   legend.title=element_text(size=8),
                   strip.text=element_text(size=8),
                   # Gridlines
                   panel.grid.major = element_blank(), 
                   panel.grid.minor = element_blank(),
                   panel.background = element_blank(), 
                   axis.line = element_line(colour = "black"),
                   # Legend
                   legend.position="bottom")


# Create the faceted histograms
options(scipen = 999)
p <- ggplot(hist, aes(x = value)) +
  geom_histogram(bins = 30,
                 # bar fill color
                 fill = "steelblue",
                 # bar border color
                 color = "white") +
  facet_wrap(~name,
             # axis scales (free = each is unique)
             scales = "free") +
  theme_bw() +
  my_theme

p

ggplot2::ggsave(p, filename = file.path("figure/histograms.png"),
                width = 12, height = 8, units = "in", dpi = 600)

## summary statistics table
# vtable::sumtable(table)
