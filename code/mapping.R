coords <- h3::road_safety_greater_manchester[1:2, ]

# Binning
h3_index <- h3::geo_to_h3(h3::road_safety_greater_manchester)
tbl <- table(h3_index) %>%
  tibble::as_tibble()
hexagons <- h3::h3_to_geo_boundary_sf(tbl$h3_index) %>%
  dplyr::mutate(index = tbl$h3_index, accidents = tbl$n)
head(hexagons)

library(leaflet)

pal <- leaflet::colorBin("YlOrRd", domain = hexagons$accidents)

map <- leaflet(data = hexagons, width = "100%") %>%
  # leaflet::addProviderTiles("Stamen.Toner") %>%
  leaflet::addPolygons(
    weight = 2,
    color = "white",
    fillColor = ~ pal(accidents),
    fillOpacity = 0.8,
    label = ~ sprintf("%i accidents (%s)", accidents, index)
  )

map
