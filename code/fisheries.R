# ICES survey data

# Clear environment
rm(list = ls())

if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,
               fasterize,
               ggplot2,
               icesDatras,
               lubridate,
               mregions2,
               pak,
               plyr,
               prioritizr,
               purrr,
               remotes,
               reshape2,
               rmapshaper,
               rnaturalearth,
               sf,
               stringr,
               terra,
               tibble,
               tidyr,
               tidyverse,
               usethis,
               worrms,
               taxize)

## install packages from GitHub
pacman::p_load_gh("GlobalFishingWatch/gfwr",
                  "data-mermaid/mermaidr",
                  install = T,
                  dependencies = T)


remotes::install_github("crazycapivara/h3-r")

test <- gfwr::gfw_vessel_info(query = 224224000,
                              search_type = "search")

surveys <- icesDatras::getSurveyList() # North Sea surveys are NS-IBTS and NSSS
# NS-IBTS years are 1965 - 2025 (survey design: https://ices-library.figshare.com/articles/report/SISP_10_Manual_for_the_North_Sea_International_Bottom_Trawl_Surveys/19051361?file=33873755)
# NSSS years are 2008 - 2024

survey <- "NS-IBTS"
survey <- "NSSS" # (North Sea sandeel survey)

years <- icesDatras::getSurveyYearList(survey = "NS-IBTS")
quarters <- icesDatras::getSurveyYearQuarterList(survey = survey,
                                                 year = years[length(years)])

## NS-IBTS: North Sea International Bottom Trawl Survey (https://datras.ices.dk/Data_products/Download/Download_Data_public.aspx)
### HH = haul data, HL = length-based data, CA = aged-based data
### Years: 1965 - 2025
data_hl <- icesDatras::getDATRAS(record = "HL",
                              survey = "NS-IBTS",
                              years = years[length(years)-5]:years[length(years)],
                              quarters = 1:4)

data_hh <- icesDatras::getDATRAS(record = "HH",
                                 survey = "NS-IBTS",
                                 years = years[length(years)-5]:years[length(years)],
                                 quarters = 1:4)

data_ca <- icesDatras::getDATRAS(record = "CA",
                                 survey = "NS-IBTS",
                                 years = years[length(years)-5]:years[length(years)],
                                 quarters = 1:4)

