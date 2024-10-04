

## Effect of TSRD on Opioid and Alcohol Dependence

This repository contains the code and data for our work "Opioid and alcohol dependence among patients with trauma and stressor-related disorders: a population-based retrospective cohort study." (S. Eshun, M.K. Owusu, H. Baffoe, 2024). All estimations were carried out using R version 4.4.1 on macOS. You can replicate all the results presented in the paper, including figures and tables, using the provided scripts and data. The structure and the contents of this repository is defined below:
```r
TSRDs
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
├── BCa_Results
│   ├── BCa_ARI.rds
│   ├── BCa_NNEH.rds
│   └── BCa_RR.rds
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

    The raw data files are not included in this repository due to their large size. You can download the necessary data files from the official website: [SAMHSA (MH-CLD)](https://www.samhsa.gov/data/data-we-collect/mh-cld/datafiles). To replicate the data preparation process, follow these steps:

    1. Download the public use files data for the years 2013 to 2022. Create a folder named ``Raw_Data`` within the ``data`` directory, and save the downloaded files in the ``./data/Raw_Data/`` path without altering their original filenames.

    2. Once the data files have been downloaded, uncomment the codes below in the main.R script and execute. Make sure to comment ``data <- read.csv("./data/Cleaned_Data/mhcld_clean.csv")`` out if you decide to do the preprocessing from scratch.
    
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
        
        # Preprocess the combined data using the function
        data <- preprocess_data(data)
        
        # Load clean data (Comment out if you preprocess the raw data yourself)
        # data <- read.csv("./data/Cleaned_Data/mhcld_clean.csv")
        ```


For the estimation of the 95% Bias-Corrected and Accelerated (BCa) confidence intervals, please note that this process is time-consuming and requires a moderate amount of RAM due to the size of the dataset. To facilitate replication and further analysis, we have saved the bootstrapped results as .RDS files in the ``./BCa_Results`` folder. These files can be read directly using the code below if your computational resources are limited.

```r
  #filename: is the named for the specific rds file you want
  bca_file <- readRDS("./BCa_Results/filename.rds")
```











