########################################
### 14. seabirds and protected areas ###
########################################

# Clear environment
rm(list = ls())

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(cowplot,
               dplyr,
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
               rnaturalearth,
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

# protected seas dataset
df <- client$dataset(odp_data)$table$select(filter = bbox)$dataframe()

#####################################

# country data
world <- rnaturalearth::ne_countries(scale="large", type = "countries", returnclass = "sf")
europe <- rnaturalearth::ne_countries(scale = "large", type = "countries", continent = "Europe", returnclass = "sf")

# load North Sea data
ns <- sf::st_read(dsn = fs::path(output_dir, "study_area.gpkg"), layer = "greater_north_sea")

# protected areas
# clean data
protected_areas <- df %>%
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

# ggplot2::ggplot(data = protected_areas) +
#   ggplot2::geom_sf()

doggerbank <- protected_areas %>%
  dplyr::filter(grepl(pattern = "Doggerbank",
                      # field
                      x = sitename,
                      # is not case sensitive
                      ignore.case = T))

sydlige_nordso <- protected_areas %>%
  dplyr::filter(grepl(pattern = "Sydlige Nordsø",
                      # field
                      x = sitename,
                      # is not case sensitive
                      ignore.case = T))

# load hex data
nature <- sf::st_read(dsn = data_dir <- "data/d_final_data/north_sea_nature_index.gpkg",
                      layer = "north_sea_model_4555_mobilesessile")

# mapview::mapView(nature,
#                  # column to map
#                  zcol = "nature_index")

p <- ggplot2::ggplot() +
  # nature index
  ggplot2::geom_sf(data = nature,
                   aes(fill = nature_index),
                   color = NA) +
  # Greater North Sea
  ggplot2::geom_sf(data = ns,
                   fill = NA,
                   color = "grey80",
                   lwd=0.2) +
  # Europe
  ggplot2::geom_sf(data = europe,
                   fill = "grey90",
                   color = "black") +
  # protected areas
  ggplot2::geom_sf(data = protected_areas,
                   fill = NA,
                   color = "grey10",
                   linetype = "dashed",
                   lwd = 0.2) +
  # x-axis limit (focus on the North Sea)
  ggplot2::xlim(-6, 12) +
  # y-axis limit (focus on the North Sea)
  ggplot2::ylim(50, 62) +
  # Legend
  ggplot2::scale_fill_gradientn(name = "Nature Index",
                                # color ramp
                                colors = RColorBrewer::brewer.pal(n=9,
                                                                  name="Blues"),
                                # NA values
                                na.value = "grey70",
                                limits = c(0, 2.5),
                                # legend breaks
                                breaks = seq(0, 2.5, 0.5),
                                # legend labels
                                labels = c("0", "0.5", "1.0", "1.5", "2.0", "2.5")) +
  guides(fill = guide_colourbar(title.position = "top",
                                ticks.colour = "black",
                                frame.colour = "black",
                                title.hjust = 0.5)) +
  theme_bw() +
  theme(axis.text = element_text(size=6),
        axis.title = element_text(size=8),
        axis.text.y = element_text(angle = 90,
                                   hjust = 0.5),
        strip.text = element_text(size = 8),
        # Gridlines
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(), 
        axis.line = element_line(colour = "black"),
        # Legend
        legend.text = element_text(size = 6),
        legend.title = element_text(size = 8),
        legend.position = c(0.2, 0.95),
        legend.key.size = unit(0.5, "cm"),
        legend.direction = "horizontal",
        legend.background = element_rect(fill = NA,
                                         color = NA,
                                         linewidth = 0.5),
        # plot
        plot.margin=grid::unit(c(0,0,0,0), "mm"))
p

ggplot2::ggsave(p, filename = file.path("figure/nature-index_map.png"),
                width = 2048, height = 1736, units = "px", dpi = 300)





inset <- ggplot2::ggplot() +
  # Greater North Sea
  ggplot2::geom_sf(data = ns,
                   fill = NA,
                   color = "grey20",
                   linetype = "dotted",
                   lwd=0.2) +
  # Europe
  ggplot2::geom_sf(data = europe,
                   fill = "grey90",
                   color = "black",
                   alpha = 0.9) +
  # protected areas
  ggplot2::geom_sf(data = protected_areas,
                   fill = NA,
                   color = "grey10",
                   linetype = "dashed",
                   lwd = 0.2) +
  # Doggerbank
  ggplot2::geom_sf(data = doggerbank,
                   fill = NA,
                   color = "#E6FE44",
                   linetype = "solid",
                   lwd = 0.5) +
  # Sydlige Nordso
  ggplot2::geom_sf(data = sydlige_nordso,
                   fill = NA,
                   color = "#D943EE",
                   linetype = "solid",
                   lwd = 0.5) +
  # x-axis limit (focus on the North Sea)
  ggplot2::xlim(-6, 12) +
  # y-axis limit (focus on the North Sea)
  ggplot2::ylim(50, 62) +
  theme_bw() +
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.text.y = element_blank(),
        strip.text = element_blank(),
        axis.ticks = element_blank(),
        # Gridlines
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = 'lightblue'), 
        axis.line = element_line(colour = "black"),
        # Legend
        # legend.text = element_text(size = 6),
        # legend.title = element_text(size = 8),
        # legend.position = c(0.2, 0.95),
        # legend.key.size = unit(0.5, "cm"),
        # legend.direction = "horizontal",
        # legend.background = element_rect(fill = NA,
        #                                  color = NA,
        #                                  linewidth = 0.5),
        # plot
        plot.margin=grid::unit(c(0,0,0,0), "mm"))
inset




# get the limits
xlim_dogger <- c(xmin = st_bbox(doggerbank)$xmin - 0.3, xmax = st_bbox(doggerbank)$xmax + 0.3)
ylim_dogger <- c(xmin = st_bbox(doggerbank)$ymin - 0.3, xmax = st_bbox(doggerbank)$ymax + 0.3)

sf::st_crs(doggerbank, parameters = TRUE)$units_gdal
dogger_bb = sf::st_as_sfc(st_bbox(doggerbank)) %>%
  sf::st_buffer(., dist = 0.05)

# mapview::mapView(doggerbank) +
#   mapview::mapView(dogger_bb)

d <- ggplot2::ggplot() +
  # nature index
  ggplot2::geom_sf(data = nature,
                   aes(fill = nature_index),
                   color = NA) +
  # ggplot2::geom_sf(data = ns,
  #                  fill = NA,
  #                  color = "grey80",
  #                  lwd=0.2) +
  # # Europe
  # ggplot2::geom_sf(data = europe,
  #                  fill = "grey90",
  #                  color = "black") +
  # protected areas
  ggplot2::geom_sf(data = protected_areas,
                   fill = NA,
                   color = "grey10",
                   linetype = "dashed",
                   lwd = 0.8) +
  # Doggerbank
  ggplot2::geom_sf(data = doggerbank,
                   fill = NA,
                   color = "#E6FE44",
                   linetype = "solid",
                   lwd = 1) +
  # coordinates to focus plot
  ggplot2::coord_sf(xlim = xlim_dogger,
                    ylim = ylim_dogger) +
  # Legend
  ggplot2::scale_fill_gradientn(name = "Nature Index",
                                # color ramp
                                colors = RColorBrewer::brewer.pal(n=9,
                                                                  name="Blues"),
                                # NA values
                                na.value = "grey70",
                                limits = c(0, 2.5),
                                # legend breaks
                                breaks = seq(0, 2.5, 0.5),
                                # legend labels
                                labels = c("0", "0.5", "1.0", "1.5", "2.0", "2.5")) +
  guides(fill = guide_colourbar(title.position = "top",
                                ticks.colour = "black",
                                frame.colour = "black",
                                title.hjust = 0.5)) +
  theme_bw() +
  theme(axis.text = element_text(size=6),
        axis.title = element_text(size=8),
        axis.text.y = element_text(angle = 90,
                                   hjust = 0.5),
        strip.text = element_text(size = 8),
        # Gridlines
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(), 
        axis.line = element_line(colour = "black"),
        # Legend
        legend.text = element_text(size = 6),
        legend.title = element_text(size = 8),
        legend.position = c(0.2, 0.95),
        legend.key.size = unit(0.5, "cm"),
        legend.direction = "horizontal",
        legend.background = element_rect(fill = NA,
                                         color = NA,
                                         linewidth = 0.5),
        # plot
        plot.margin=grid::unit(c(0,0,0,0), "mm"))
d

ggplot2::ggsave(d, filename = file.path("figure/nature-index_doggerbank.png"),
                width = 6, height = 6, units = "in", dpi = 600)

dogger_inset <- cowplot::ggdraw() +
  cowplot::draw_plot(d) +
  draw_plot(inset,
            x = 0.75,
            y = 0.75,
            width = 0.2,
            height = 0.2)
dogger_inset

ggplot2::ggsave(dogger_inset, filename = file.path("figure/nature-index_doggerbank-inset.png"),
                width = 6, height = 6, units = "in", dpi = 600)

############################

# get the limits
xlim_sydlige <- c(xmin = st_bbox(sydlige_nordso)$xmin - 0.3, xmax = st_bbox(sydlige_nordso)$xmax + 0.3)
ylim_sydlige <- c(xmin = st_bbox(sydlige_nordso)$ymin - 0.3, xmax = st_bbox(sydlige_nordso)$ymax + 0.3)

sf::st_crs(sydlige_nordso, parameters = TRUE)$units_gdal
sydlige_bb = sf::st_as_sfc(st_bbox(sydlige_nordso)) %>%
  sf::st_buffer(., dist = 0.05)

# Sydlige Nordso
s <- ggplot2::ggplot() +
  # nature index
  ggplot2::geom_sf(data = nature,
                   aes(fill = nature_index),
                   color = NA) +
  # ggplot2::geom_sf(data = ns,
  #                  fill = NA,
  #                  color = "grey80",
  #                  lwd=0.2) +
  # Europe
  ggplot2::geom_sf(data = europe,
                   fill = "grey90",
                   color = "black") +
  # protected areas
  ggplot2::geom_sf(data = protected_areas,
                   fill = NA,
                   color = "grey10",
                   linetype = "dashed",
                   lwd = 0.8) +
  # Sydlige Nordso
  ggplot2::geom_sf(data = sydlige_nordso,
                   fill = NA,
                   color = "#D943EE",
                   linetype = "solid",
                   lwd = 1) +
  # coordinates to focus plot
  ggplot2::coord_sf(xlim = xlim_sydlige,
                    ylim = ylim_sydlige) +
  # Legend
  ggplot2::scale_fill_gradientn(name = "Nature Index",
                                # color ramp
                                colors = RColorBrewer::brewer.pal(n=9,
                                                                  name="Blues"),
                                # NA values
                                na.value = "grey70",
                                limits = c(0, 2.5),
                                # legend breaks
                                breaks = seq(0, 2.5, 0.5),
                                # legend labels
                                labels = c("0", "0.5", "1.0", "1.5", "2.0", "2.5")) +
  guides(fill = guide_colourbar(title.position = "top",
                                ticks.colour = "black",
                                frame.colour = "black",
                                title.hjust = 0.5)) +
  theme_bw() +
  theme(axis.text = element_text(size=6),
        axis.title = element_text(size=8),
        axis.text.y = element_text(angle = 90,
                                   hjust = 0.5),
        strip.text = element_text(size = 8),
        # Gridlines
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(), 
        axis.line = element_line(colour = "black"),
        # Legend
        legend.text = element_text(size = 6),
        legend.title = element_text(size = 8),
        legend.position = c(0.2, 0.95),
        legend.key.size = unit(0.5, "cm"),
        legend.direction = "horizontal",
        legend.background = element_rect(fill = NA,
                                         color = NA,
                                         linewidth = 0.5),
        # plot
        plot.margin=grid::unit(c(0,0,0,0), "mm"))
s

ggplot2::ggsave(s, filename = file.path("figure/nature-index_sydlige-nordso.png"),
                width = 6, height = 6, units = "in", dpi = 600)

sydlige_inset <- cowplot::ggdraw() +
  cowplot::draw_plot(s) +
  draw_plot(inset,
            x = 0.75,
            y = 0.75,
            width = 0.2,
            height = 0.2)
sydlige_inset

ggplot2::ggsave(sydlige_inset, filename = file.path("figure/nature-index_sydlige-nordso_inset.png"),
                width = 6, height = 6, units = "in", dpi = 600)
