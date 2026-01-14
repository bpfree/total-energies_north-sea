data <- read.csv(file = "data/a_raw_data/CetaceansData_0112573557/Sightings_0112573557.csv") %>%
  # filter for only non-duplicated sightings and definite identifications
  # duplication sighting status: http://vocab.ices.dk/?ref=1721
  # identification confidence codes: http://vocab.ices.dk/?ref=1700
  dplyr::filter(DuplicateSightingStatus == "N",
                IdentificationConfidence == "D")

worms_ids <- unique(data$AphiaID)
worms_ids
length(worms_ids)

list <- data.frame(worms_id = unlist(worms_ids)) %>%
  # get the taxonomic convention
  ## need to set as character as otherwise data will not get exported correctly
  dplyr::mutate(species_name = as.character(worrms::wm_id2name_(id = worms_ids)))

table <- data %>%
  dplyr::select(AphiaID,
                Latitude, Longitude) %>%
  # rename the code column
  dplyr::rename("worms_id" = "AphiaID",
                "lat" = "Latitude",
                "lon" = "Longitude") %>%
  dplyr::filter(lat >= 50.9954 & lat <= 61.0170,
                lon >= -4.4454 & lon <= 12.0059) %>%
  # join with the new genus species names
  dplyr::inner_join(x = .,
                    y = list,
                    by = "worms_id") %>%
  dplyr::mutate(common_name = dplyr::recode(worms_id,
                                            "2688" = "Cetacea",
                                            # "127405" = "Ocean sunfish",
                                            # "136980" = "Delphinidae", # ocean dolphins
                                            # "136986" = "Ziphiidae", # beaked whales
                                            # "137020" = "Lagenorhynchus",
                                            "137080" = "Grey whale",
                                            "137084" = "Harbor seal",
                                            "137087" = "Minke whale",
                                            "137091" = "Fin whale",
                                            "137094" = "Short-beaked common dolphin",
                                            "137098" = "Risso's dolphin",
                                            "137100" = "Atlantic white-sided dolphin",
                                            "137101" = "White-beaked dolphin",
                                            "137102" = "Orca",
                                            "137111" = "Common bottlenose dolphim",
                                            "137117" = "Harbour porpoise",
                                            # "137121" = "Sowerby's beaked whale",
                                            # "148724" = "Mysticeti", # baleen whales
                                            "148736" = "Pinnipedia", # seals
                                            "343898" = "Burmeister's porpoise",
                                            # "343899" = "Northern bottlenose dolphin",
                                            "368408" = "Selachii")) %>% # sharks
  dplyr::relocate(c(lat, lon),
                  .after = common_name)
View(table)

# inspect data to determine how often species have been observed
inspection <- table %>%
  dplyr::select(worms_id, species_name, common_name) %>%
  janitor::tabyl(worms_id)
View(inspection)

# further inspection on particular species (e.g., 137111, 148736, and 343989) -- how old are they? where are they?
particular_species <- df2 %>%
  dplyr::filter(AphiaID %in% c("13711", "148736", "343989"))
View(particular_species)
