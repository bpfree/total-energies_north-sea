################################################################################
###  0. Setup the environment
################################################################################

if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}
remotes::install_github("C4IROcean/odp-sdkr")

library(odp)
library(h3jsr)

client <- odp_client()


################################################################################
###  1. Create H3 parents (res 6 and 4)
################################################################################

r8_tab <- client$dataset("47b3ee44-ced3-4d87-ae50-a181b7a31e5c")$table

# define aggregations for columns
col_aggrs <- list(
  "mobile_sum" = "sum",
  "sessile_sum" = "sum",
  "c_val" = "sum",
  "s_val" = "sum",
  "pa_val" = "sum",
  "i_val" = "sum", 
  "ceta_rich" = "mean",
  "bird_rich" = "mean",
  "fish_rich" = "mean",
  "nature_index" = "mean"
)

# aggregate to res 6, generate geometry from index
r6_agg <- r8_tab$aggregate(
  group_by = "h3(geometry, 6)",
  aggr = col_aggrs
)
r6_agg <- r6_agg |> dplyr::mutate(geometry = sf::st_as_text(cell_to_polygon(group)))  # index to geo
r6_agg <- r6_agg |> dplyr::rename(h3_index = group) # rename index like r8 table

# aggregate to res 4, generate geometry from index
r4_agg <- r8_tab$aggregate(
  group_by = "h3(geometry, 4)",
  aggr = col_aggrs
)
r4_agg <- r4_agg |> dplyr::mutate(geometry = sf::st_as_text(cell_to_polygon(group)))
r4_agg <- r4_agg |> dplyr::rename(h3_index = group)


################################################################################
###  2. Save aggregations to ODP
################################################################################

r6_tab <- client$dataset("12ef0e09-0303-491b-8c1e-000453a3a7dc")$table
r4_tab <- client$dataset("a7358fa0-6a5a-4583-830a-9de581b96a48")$table

# cleanup tables before creating
r6_tab$drop()
r4_tab$drop()

# create table and insert
r6_tab$create(r6_agg)
r4_tab$create(r4_agg)


################################################################################
###  3. Sync code to ODP
################################################################################

# TODO: