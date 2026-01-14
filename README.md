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
├── codes                   : Scripts for cleaning, processing, and analyzing data
│
├── figures                 : All figures
│
├── methodology             : Detailed methodologies for the data and analysis
│
└── literature              : Helpful literature for the project
```

-   **data**
    -   **raw_data:** the raw data integrated in the analysis (**Note:** original data name and structure were kept except when either name was not descriptive or similar data were put in same directory to simplify input directories)
    -   **intermediate_data:** disaggregated processed data

***Note for PC users:*** The code was written on a Mac so to run the scripts replace "/" in the pathnames for directories with two "\\".

Please contact Brian Free ([brian.free@oceandata.earth](mailto:brian.free@oceandata.earth)) with any questions regarding the code.

### **Study region**
Greater North Sea -- boundary box of bbox <- 'geometry within "POLYGON((-4.4454 50.9954, 12.0059 50.9954, 12.0059 61.0170, -4.4454 61.0170, -4.4454 50.9954))"'

### **Data sources**
#### *Generic Data*
| Layer | Data Source | Data Name | Metadata  | Notes |
|---------------|---------------|---------------|---------------|---------------|