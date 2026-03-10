---
output:
  pdf_document: default
---
# Advancing nature and biodiversity insights in the North Sea
Habitat sensitivity assessment in North Sea

**Points of contact**
* **Analysis:** [Brian Free](mailto:brian.free@oceandata.earth)
* **Ocean Data Platform:** [Max Romagnoli](mailto:max.romagnoli@oceandata.earth)
* **Project lead:** [Laurence Janssens](mailto:laurence.janssens@oceandata.earth)

* **Total adviser:** [Phil Wemyss](mailto:phil.wemyss@external.totalenergies.com)
* **Total GIS analyst:** [Katrina Povidisa-Delefosse]((mailto:katrina.povidisa-delefosse@totalenergies.com)
* **Total GIS analyst:** [Ilaria Valentini]((mailto:ilaria.valentini@totalenergies.com)

### **Repository Structure**

```text
├── README.md               : Description of this repository
├── LICENSE                 : Repository license
├── north-sea-analysi.Rproj : RStudio project file
├── .gitignore              : Files and directories to be ignored by git
│
├── data
│   ├── raw                 : Source data obtained from repositories and authors
│   ├── intermediate        : Transformed data
│   ├── model               : Final model data
│
├── code                    : Scripts for cleaning, processing, and analyzing data
│
├── figure                  : All figures
│
├── methodology             : Detailed methodologies for the data and analysis
│
└── literature              : Helpful literature for the project
```

-   **data**
    -   **raw_data:** the raw data integrated in the analysis (**Note:** original data name and structure were kept except when either name was not descriptive or similar data were put in same directory to simplify input directories)
    -   **intermediate_data:** disaggregated processed data
    -   **hex_data:** geopackage 

***Note for PC users:*** The code was written on a Mac so to run the scripts replace "/" in the pathnames for directories with two "\\".

Please contact Brian Free ([brian.free@oceandata.earth](mailto:brian.free@oceandata.earth)) with any questions regarding the code.

## **Overview**
### **Study region**
The study defined a boundary box for the Greater North Sea with points of: 
* southwest: -4.4454, 50.9954
* northwest: -4.4454 61.0170
* northeast: 12.0059, 61.0170
* southeast: 12.0059, 50.9954

Since the desired resolution for the analysis was at 500m, a hex grid at [resolution 8](https://h3geo.org/docs/core-library/restable) generated the hex grid using [H3 indexes](https://h3geo.org) within 
the [Greater North Sea](https://www.marineregions.org/gazetteer.php?p=details&id=36317). [Marine Regions](https://marineregions.org/gazetteer.php) provided the boundary layer of the Greater 
North Sea (as defined by [ICES](http://gis.ices.dk/geonetwork/srv/eng/catalog.search#/metadata/4745e824-a612-4a1f-bc56-b540772166eb)) in the final analysis.

## **Data sources**
### *Generic Data*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|
| Study area | [mregions2](https://docs.ropensci.org/mregions2/) | [Marine Regions](https://marineregions.org/gazetteer.php) | [Greater North Sea](https://www.marineregions.org/gazetteer.php?p=details&id=36317) | Defined by [ICES Ecoregions](http://gis.ices.dk/geonetwork/srv/eng/catalog.search#/metadata/4745e824-a612-4a1f-bc56-b540772166eb) |
| Platforms | Total Energies | | | |
| Species list | [Natura 2000](https://natura2000.eea.europa.eu) | [Doggerbank](https://biodiversity.europa.eu/sites/natura2000/DE1003301) | | 1 habitat, 7 species |
| Species list | [Natura 2000](https://natura2000.eea.europa.eu) | [Sydlige Nordsø](https://biodiversity.europa.eu/sites/natura2000/DK00VD374) | | 0 habitats, 0 species |
| Species list | [Natura 2000](https://natura2000.eea.europa.eu) | [Sydlige Nordsø](https://biodiversity.europa.eu/sites/natura2000/DK00VD375) | | 1 habitat, 3 species |
| Species list | [Natura 2000](https://natura2000.eea.europa.eu) | [Jyske Rev, Lillefiskerbanke](https://biodiversity.europa.eu/sites/natura2000/DK00VA257) | | 1 habitat, 0 species |
| Species list | [Natura 2000](https://natura2000.eea.europa.eu) | [Sandbanker ud for Thyborøn](https://biodiversity.europa.eu/sites/natura2000/DK00VA340) | | 2 habitats, 1 species |
| Species list | [Natura 2000](https://natura2000.eea.europa.eu) | [Sylter Aussenriff](https://biodiversity.europa.eu/sites/natura2000/DE1209301) | | 2 habitat, 17 species |

### *Nature Data*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|
| Fish | [Cesc Gordó-Vilaseca](https://www.nature.com/articles/s41467-024-49911-9) | Fish species richness | [GitHub repository](https://github.com/CescGV/JSDM-Barents-Norwegian-North/tree/main) |
| Cetaceans | [MPA EU](https://mpa-europe.eu) and provided by Silas C. Principe | Cetaceans species distribution models | | [GitHub](https://github.com/iobis/mpaeu_sdm/tree/main), [Shiny OBIS](https://shiny.obis.org/distmaps/) |
| Seabirds | [MPA EU](https://mpa-europe.eu) and provided by Silas C. Principe | Seabirds species distribution models | | [GitHub](https://github.com/iobis/mpaeu_sdm/tree/main), [Shiny OBIS](https://shiny.obis.org/distmaps/) |
| Conservation areas | [Marine Mammals Protected Areas Task Force](https://www.marinemammalhabitat.org) | Important Marine Mammal Areas | | Need to [request download](https://www.marinemammalhabitat.org/immas/imma-spatial-layer-download/) |
| Protected areas | [Protected Seas](https://protectedseas.net) | Marine protected areas | [Ocean Data Platform](https://app.hubocean.earth/catalog/dataset/a608f54b-75c7-4df9-a3a8-cedbfa391873/protectedseas-navigator-v2-focused-area-based-protections) | Used the focused data set |
| Corals | [Tong et al. (2023)](https://www.frontiersin.org/journals/marine-science/articles/10.3389/fmars.2023.1217851/full) | Cold water corals | | [Direct data download](https://zenodo.org/records/7896310) |
| Seagrass | [WCMC](https://data-gis.unep-wcmc.org/portal/home/item.html?id=aaa46cd3d3d640b2916b8f0a0ffe07cb) | Seagrass | [ISO](https://data-gis.unep-wcmc.org/portal/sharing/rest/content/items/aaa46cd3d3d640b2916b8f0a0ffe07cb/info/metadata/metadata.xml?format=default&output=html) | [Ocean Data Platform](https://app.hubocean.earth/catalog/dataset/7199f9bc-96ae-49d1-a814-df8c4bcc7552/unep-wcmc-global-distribution-of-seagrasses-polygons), [WCMC direct data download](https://wcmc.io/WCMC_013_014) |

## Methods
### Geographic constraint
Each nature data set got limited to the [Greater North Sea](https://www.marineregions.org/gazetteer.php?p=details&id=36317) boundary before performing any further data transformations.

### Linear normalization
A linear function normalized species richness values for fish, cetaceans, and seabirds. Normalizing the minimum and maximum species richness to be between 0 and 1 allowed these data to get compared to the data sets that receive
a discrete value for presence and absence (1 or 0).

The linear normalized function is: (value - minimum) / (maximum - minimum) = normalized score.

To avoid returning a zero for the normalized score (when the value is equal to the minimum), when the linear function returns 0.00, then a value of 0.01 got added. By adding value to the minimum value, it ensures that any species
richness never would get treated as absence.

### Overlapping features
When a hex grid received more than one value from a linear normalization, due to the shape incongruity, then the maximum value was kept. Selecting the maximum value ensured the study pursued an 
approach that reflected a precautionary principle (read [here](https://www.ospar.org/convention/principles/precautionary-principle) for further context on the principle) since the nature index would 
represent the best case scenario for nature.

### Habitats
#### Cold water corals
The cold water corals data set contained values that range between 0 and 1000 for 10 species. Suitability classifications on coral presence are separated by steps of 200: very low (<200),
low (200 - 400), moderate (400 - 600), high (600 - 800), and very high (800). This study only considered if a cold water coral was present, not the overall species richness. To determine
if a cold water coral reef was present, the maximum score across the 10 species was returned and only values above 600 were kept.

### Species
#### Cetaceans and seabirds
Cetaceans considered in the analysis either had at least one observation in the [Joint Cetacean Database Programme](https://cetaceans.ices.dk/beta/Inventory?selecteddataset=JCDP&selecteddataset=ESAS) (for more information
about the [JCDP](https://jncc.gov.uk/our-work/joint-cetacean-data-programme) and [ICES statistical surveys](https://www.ices.dk/data/data-portals/Pages/Cetaceans.aspx)) or included in the [Waggitt et al. (2020)](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/1365-2664.13525).
The only species from Waggitt et al. (2020) that did not have at least one observation in the ICES statistical survey was _Physeter macrocephalus_.

These species included:
- _Balaenoptera acutorostrata_
- _Balaenoptera physalus_
- _Delphinus delphis_
- _Grampus griseus_
- _Halichoerus grypus_
- _Lagenorhynchus acutus_
- _Lagenorhynchus albirostris_
- _Orcinus orca_
- _Phoca vitulina_
- _Phocoena phocoena_
- _Physeter macrocephalus_
- _Stenella coeruleoalba_
- _Tursiops truncatus_

Species compiled for seabirds came from Waggitt et al. (2020), ICES's [European Seasbirds at Seas](https://esas.ices.dk/inventory), and a list provided by Total Energies. Species from
the top 50 in ICES's ESAS supplemented the species already included in Waggitt et al. (2020) and the list provided by Total. The species included in the the lists are:

- _Alca torda_
- _Alle alle_
- _Aythya marila_
- _Bucephala clangula_
- _Cepphus grylle_
- _Chlidonias niger_
- _Clangula hyemalis_
- _Fratercula arctica_
- _Fulmarus glacialis_
- _Gavia adamsii_
- _Gavia arctica_
- _Gavia immer_
- _Gavia stellata_
- _Gelochelidon nilotica_
- _Hydrobates leucorhous_
- _Hydrobates pelagicus_
- _Hydrocoloeus minutus_
- _Hydroprogne caspia_
- _Larus argentatus_
- _Larus canus_
- _Larus fuscus_
- _Larus glaucoides_
- _Larus hyperboreus_
- _Larus marinus_
- _Larus melanocephalus_
- _Larus michahellis_
- _Larus ridibundus_
- _Melanitta fusca_
- _Melanitta nigra_
- _Mergus merganser_
- _Mergus serrator_
- _Morus bassanus_
- _Phalacrocorax aristotelis_
- _Phalacrocorax carbo_
- _Phalaropus fulicarius_
- _Phalaropus lobatus_
- _Podiceps auritus_
- _Podiceps cristatus_
- _Podiceps grisegena_
- _Podiceps nigricollis_
- _Puffinus puffinus_
- _Rissa tridactyla_
- _Somateria mollissima_
- _Somateria spectabilis_
- _Stercorarius longicaudus_
- _Stercorarius parasiticus_
- _Stercorarius pomarinus_
- _Stercorarius skua_
- _Sterna hirundo_
- _Sterna paradisaea_
- _Sternula albifrons_
- _Thalasseus sandvicensis_
- _Uria aalge_
- _Xema sabini_

##### Species distribution models
Species distribution models for the interested species came from the [MPA Europe](https://shiny.obis.org/distmaps/) project on modeling ocean biodiversity. The study used species
distribution model data from MPA Europe given they were produced at 5km resolution; comparatively, Waggitt et al. (2020) modeled their species at 10km. To maintain comparability
between species, only species with modeled data by MPA Europe got included. Species were matched by their WoRMS [Aphia identification](https://www.marinespecies.org/about.php#what_is_aphia).
A marine mammal and two seabird species had different accepted species names in [WoRMS](https://www.marinespecies.org/index.php) than those used by ICES, Waggitt et al. (2020), and Total
Energies. The three species were:

- _Lagenorhynchus acutus_ [(137100)](https://www.marinespecies.org/aphia.php?p=taxdetails&id=137100) -- accepted name is _Leucopleurus acutus_ [(1571853)](https://www.marinespecies.org/aphia.php?p=taxdetails&id=1571853)
- _Larus melanocephalus_ [(137147)](https://www.marinespecies.org/aphia.php?p=taxdetails&id=137147) -- accepted name is _Ichthyaetus melanocephalus_ [(1584284)](https://www.marinespecies.org/aphia.php?p=taxdetails&id=1584284)
- _Thalasseus sandvicensis_ [(413044)](https://www.marinespecies.org/aphia.php?p=taxdetails&id=413044) -- accepted name is _Sterna sandvicensis_ [(137166)](https://www.marinespecies.org/aphia.php?p=taxdetails&id=137166)

MPA Europe did not posses a species distribution model for a species on the Total Energies list (_Hydrobates leucorhous_). The study thus did not include _Hydrobates leucorhous_ in the final analysis.

##### Habitat designation
MPA Europe's species distribution models relied on presence-only data. The [best modeled outputs](https://iobis.github.io/mpaeu_docs/methods-testing.html#overview-and-chosen-approach) were LASSO and maxent (maximum entropy).
LASSO results were not available for download, so the priority were maxent along with ensemble outputs when the maxent models did not exist for a particular species. Most species have the maxent models, but five had ensemble
models:

Cetaceans
- _Phoca vitulina_ [(137084)](https://www.marinespecies.org/aphia.php?p=taxdetails&id=137084)
- _Orcinus orca_ [(137102)](https://www.marinespecies.org/aphia.php?p=taxdetails&id=137102)
- _Tursiops truncatus_ [(137111)](https://www.marinespecies.org/aphia.php?p=taxdetails&id=137111)

Seabirds
- _Alle alle_ [137129](https://www.marinespecies.org/aphia.php?p=taxdetails&id=137129)
- _Rissa tridactyla_ [137156](https://www.marinespecies.org/aphia.php?p=taxdetails&id=137156)

Species distribution model (SDM) results were scored to reflect the match to likely habitat. Any location with a species distribution model value under 50 (quantitatively more probable than not)
was classified as unlikely habitat and given a score 0.3. Species distribution model values between 50 and 75 got a score of 0.6 to reflect that these areas are probable habitat. Core habitat
occurred in locations with values over 75 and they received a value of 1.

| SDM value | Classification | Score |
|---------------|---------------|---------------|
| 0 - 50 | Unlikely habitat | 0.3 |
| 50 - 75 | Unlikely habitat | 0.6 |
| 75+ | Unlikely habitat | 1.0 |

#### Normalization
A summarized total species richness layer were created for each cetaceans and seabirds by combining all species values for each. The linear normalization was run on the summarized data
products and any instance where multiple values existed for the same hex, the maximum normalized value was selected.

### Fishes
A summarized fish species data layer came from a paper by [Gordó-Vilaseca et al. (2024)](https://www.nature.com/articles/s41467-024-49911-9) that examined biomass distributions for a
variety of species across the North Sea and Barents Sea. The data shared by Gordó-Vilaseca are the present day species richness data (as seen in the paper's Figure 2(A)).

#### Normalization
The Greater North Sea boundary limited the data to the study region before applying a linear normalization and rescaling the minimum species richness.

### Scores
| Layer | Score | Consideration |
|---------------|---------------|---------------|
| Fish | 0 - 1 | Linear normalization with 0.01 added to minimum |
| Cetaceans | 0 - 1 | Species list compiled from list provided by Total Energies, [Waggitt et al. (2020)](https://besjournals.onlinelibrary.wiley.com/doi/pdf/10.1111/1365-2664.13525), along  with cetaceans that have at least one observation in the [ICES statistical surveys](https://cetaceans.ices.dk/inventory) for the North Sea |
| Seabirds | 0 - 1 | Species list compiled from list provided by Total Energies, [Waggitt et al. (2020)](https://besjournals.onlinelibrary.wiley.com/doi/pdf/10.1111/1365-2664.13525), along  with data from [European Seabirds at Seas](https://esas.ices.dk/inventory) and [MPA EU](https://shiny.obis.org/distmaps/) |
| Protected areas | 0, 1 | Absence, Presence |
| Cold water corals | 0, 1 | Absence, Presence |
| Important Marine Mammal Areas | 0, 1 | Absence, Presence |
| Seagrass | 0, 1 | Absence, Presence |

### Submodel
Two submodels comprised the final nature score index. The fish, cetacean, and seabird data products were summarized in the mobile species submodel. The sessile submodel comprised
of the other four datasets: protected areas, important marine mammal areas, cold water corals, and seagrass. Any "NA" data for a data set got reclassified as a 0 before calculating
submodel scores. These two submodels then were combined to produce a final nature score. More weight was allotted to the sessile submodel since at least two of the layers are immovable,
making them more reliably known. The analysis weighted the sessile submodel with 55% of the score. It did not receive greater share of weight as the seagrass and coral reef data sets
remain to have a level of uncertainty concerning their verified locations.

Below are the three main equations for calculating submodel and final model scores:

[1] mobile_submodel_score = fish_value + cetacean_value + seabird_value

[2] sessile_submodel_score = protected_area_value + imma_value + cold_water_coral_value + seagrass_value

[3] final_model_score = mobile_submodel_score * 0.45 + sessile_submodel_score * 0.55

## Considerations / Limitations / Assumptions
### Data components
The analysis desired to include more data sets within the analysis, but numerous constraints limited what could get used. The cetacean and ICES 

### Analysis components
An assumption was made that the maximum score would get kept to reflect a higher nature score. 

### Future
A major limitation of the study was the inability to integrate more data sets for the nature index. The UNEP-WCMC seagrass is an imperfect data set given that it was created as a global
data set, not to represent localized, high resolution areas. A [seagrass layer](https://emodnet.ec.europa.eu/geonetwork/srv/eng/catalog.search#/metadata/39746d9c-4220-425c-bc26-7cb3056c36a5)
exists that has 250m resolution for the North Sea ([report](https://emodnet.ec.europa.eu/sites/emodnet.ec.europa.eu/files/public/c20190514_generating_eovs.pdf)). The data were only for non-commercial
use only.

Data not permitted for commercial use

Fish, cetaceans, and seabirds data --
Fish -- only species richness, not specific species

Presence-only models -- species distribution models

Resolution of fish, cetaceans, and seabirds

Wanting places even very rare occurrences of data -- hence the inclusion of even low values for species distribution models
Score of 1 for any species is similar to presence of other layer types

Ignoring of other data sets

Evaluations of what to classify as habitat and scores

Maximum score kept 
