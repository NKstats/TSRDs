

## Effect of TSRD on Opioid and Alcohol Dependence

This repository contains the code and data for the manuscript "Opioid and alcohol dependence among patients with trauma and stress-related disorders: a population-based retrospective cohort study." (S. Eshun, M.K. Owusu, H. Baffoe, 2024). All estimations were carried out using R version 4.4.1 on macOS. You can replicate all the results presented in the paper, including figures and tables, using the provided scripts and data. The structure and the contents of this repository is defined below:
```r
TSRD_Paper
|
├── data
│   └── Cleaned_Data
│       └── mhcld_clean.csv
|
├── Scripts
│   ├── install_packages.R
│   ├── data_preparation.R
│   ├── propensity_score_matching.R
│   ├── effect_estimations.R
│   ├── odds_ratio_estimation.R
│   ├── visualizations.R
│   └── main.R
|
├── Results
│   ├── BCa_ARI.rds
│   ├── BCa_NNEH.rds
│   ├── BCa_RR.rds
│   ├── BCa.p0.rds
│   └── BCa_p1.rds
|
├── Figures
│   ├── Fig1.tif
│   ├── Fig2.tif
│   ├── Fig3.tf
│   └── S1 Fig.tif
|
├── .gitignore
|
└── Readme.md
```

### Description of .R Scripts

Below is a brief description of each script in the ``./Scripts`` folder.

- ``install_packages.R``: installs all the necessary R packages required for the analysis.

- ``data_preparation.R``: includes the data cleaning and preprocessing steps required to prepare the raw dataset from the source (if you decide to download the raw data, instead of using the cleaned data). Make sure to have a folder `./data/Raw_Data/` in your directory.

- ``propensity_score_matching.R``: This script performs propensity score matching to control for confounding variables in the analysis.

- ``effect_estimations.R``: methods and calculations for estimating the effects.

- ``odds_ratio_estimation.R``: includes the calculations for estimating odds ratios.

- ``visualizations.R``: This script generates visualizations in the work.

- ``main.R``: This is the main script that coordinates the execution of the other scripts and performs the overall analysis.


### Important Information


To work with the data, you have two options:

1. **Use the cleaned data provided in this repository:**

    The cleaned data with CASEIDs is included in the repository. You can load the cleaned data using the following code:

    ```r
    data <- read.csv("./data/Cleaned_Data/mhcld_clean.csv")
    ```

2. **Download and preprocess the raw data from the original source:**

    The raw data files are not included in this repository due to their large size. You can download the necessary data files from the official website: [SAMHSA (MH-CLD)](https://www.samhsa.gov/data/data-we-collect/mh-cld-mental-health-client-level-data). To replicate the data preparation process, follow these steps:

    1. Download the public use files data for the years 2013 to 2022, create a folder ``Raw_Data`` inside the ``data`` folder and save the files in the ``./data/Raw_Data/`` directory. Don't change the file names after downloading them from the website.

    2. After downloading the data files, run the ``data_preparation.R`` script to combine and preprocess the data:
    
        ```r
        # Define file paths for the raw data files
        file_names <- paste0("./data/Raw_Data/mhcld_puf_", 2013:2022, ".csv")
        data_list <- list()
        
        # Load and combine the data files
        for (file in file_names) {
            data <- read.csv(file)
            data_list[[file]] <- data
        }
        
        data <- do.call(rbind, data_list)
        rownames(data) <- NULL
        
        # Source the preprocessing function from the script
        source("data_preparation.R")
        
        # Preprocess the combined data using the function
        data <- preprocess_data(data)
        ```


For the estimation of the 95% Bias-Corrected and Accelerated (BCa) confidence intervals, please note that this process is time-consuming and requires a moderate amount of RAM due to the size of the dataset. To facilitate replication and further analysis, we have saved the bootstrapped results as .RDS files in the ``./Results`` folder. These files can be read directly using the code below if your computational resources are limited.

```r
  #filename: is the named for the specific rds file you want
  bca_file <- readRDS("./Results/filename.rds")
```











