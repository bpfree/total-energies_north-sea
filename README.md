# Advancing nature and biodiversity insights in the North Sea
Habitat sensitivity assessment in North Sea

**Points of contact**
* **Analysis:** [Brian Free](mailto:brian.free@oceandata.earth)
* **Ocean Data Platform:** [Max Romagnoli](mailto:max.romagnoli@oceandata.earth)
* **Project lead:** [Laurence Janssens](mailto:laurence.janssens@oceandata.earth)

* **Total Adviser:** [Phil Wemyss](mailto:phil.wemyss@external.totalenergies.com)
* **Total GIS Analyst:** [Katrina Povidisa-Delefosse](katrina.povidisa-delefosse@totalenergies.com)
* **Total GIS Analyst:** [Ilaria Valentini](ilaria.valentini@totalenergies.com)

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

### **Study region**
The study defined a boundary box for the Greater North Sea with points of: 
* southwest: -4.4454, 50.9954
* northwest: -4.4454 61.0170
* northeast: 12.0059, 61.0170
* southeast: 12.0059, 50.9954

Since the desired resolution for the analysis was at 500m, a hex grid at [resolution 8](https://gist.github.com/colbyn/001064f00385d253b42693c3889f9beb) generated the hex grid using [H3 indexes](https://h3geo.org). Only the hexes that intersected with the Greater North Sea boundary layer provided by [Marine Regions](https://marineregions.org/gazetteer.php) were used in the final analysis.

### **Model configuration**
Habitat designation
- Unlikely habitat: scores below 75
- Probable Habitat: scores between 50 and 75
- Core habitat: scores over 75

### Cold water corals


### Scores
| Layer | Score | Consideration |
|---------------|---------------|---------------|
| Fish | 0 - 1 | Linear normalization with 0.01 added to minimum |
| Cetaceans | | Species list compiled from list provided by Total Energies,
[Waggitt et al. (2020)](https://besjournals.onlinelibrary.wiley.com/doi/pdf/10.1111/1365-2664.13525), along with cetaceans that have at least one observation in the [ICES statistical surveys](https://cetaceans.ices.dk/inventory) for the North Sea |
| Seabirds | | Species list compiled from list provided by Total Energies,
[Waggitt et al. (2020)](https://besjournals.onlinelibrary.wiley.com/doi/pdf/10.1111/1365-2664.13525),
along with data from [ICES statistical surveys](https://esas.ices.dk/inventory) and [MPA EU](https://shiny.obis.org/distmaps/) |
| Protected areas | 0, 1| Absence, Presence |
| Cold water corals | 0, 1| Absence, Presence |
| Important Marine Mammal Areas | 0, 1| Absence, Presence |
| Seagrass | 0, 1| Absence, Presence |

## Methods
### Linear normalization
* Normalized score = (value - minimum) / (maximum - minimum)
If normalized value is minimum value then the returning value equals zero; to avoid these scores
to have zero values, 0.01 got added to those scores. Otherwise keep the normalized value.

### Overlapping features
When a hex grid received more than one value from a linear normalization, due to the shape incongruity, then the maximum value was kept.

### **Data sources**
#### *Generic Data*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|
| Fish | [Cesc Gordó-Vilaseca](https://www.nature.com/articles/s41467-024-49911-9) | Fish species richness | [GitHub repository](https://github.com/CescGV/JSDM-Barents-Norwegian-North/tree/main) |
| Cetaceans | [MPA EU](https://mpa-europe.eu) and provided by Silas C. Principe | Cetaceans species distribution models | | [GitHub](https://github.com/iobis/mpaeu_sdm/tree/main), [Shiny OBIS](https://shiny.obis.org/distmaps/)
| Seabids | [MPA EU](https://mpa-europe.eu) and provided by Silas C. Principe | Seabirds species distribution models | | [GitHub](https://github.com/iobis/mpaeu_sdm/tree/main), [Shiny OBIS](https://shiny.obis.org/distmaps/)
| Conservation areas | [Marine Mammals Protected Areas Task Force](https://www.marinemammalhabitat.org) | Important Marine Mammal Areas | | Need to [request download](https://www.marinemammalhabitat.org/immas/imma-spatial-layer-download/) |
| Protected areas | [Protected Seas](https://protectedseas.net) | Marine protected areas | | [Ocean Data Platform](https://app.hubocean.earth/catalog/dataset/a608f54b-75c7-4df9-a3a8-cedbfa391873/protectedseas-navigator-v2-focused-area-based-protections) | Used the focused dataset
| Corals | [Tong et al. (2023)](https://www.frontiersin.org/journals/marine-science/articles/10.3389/fmars.2023.1217851/full) | Cold water corals | | [Direct data download](https://zenodo.org/records/7896310) |
| Seagrass | WCMC | Seagrass | | |