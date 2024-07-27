source("./Scripts/install_packages.R")
source("./Scripts/data_preparation.R")
source("./Scripts/propensity_score_matching.R")
source("./Scripts/effect_estimations.R")
source("./Scripts/visualizations.R")
source("./Scripts/odds_ratio_estimation.R")


library(pacman)
p_load(tableone)
require(tableone)

# file_names <- paste0("./data/Raw_Data/mhcld_puf_", 2013:2022, ".csv")
# data_list <- list()
# 
# for (file in file_names) {
#   data <- read.csv(file)
#   data_list[[file]] <- data
# }
# 
# data <- do.call(rbind, data_list)
# rownames(data) <- NULL
# 
# data <- preprocess_data(data)

# Load clean data (Comment out if you preprocess the raw data yourself)
data <- read.csv("./data/Cleaned_Data/mhcld_clean.csv")

# Define covariates and exposure
covars <- setdiff(colnames(data), c("CASEID","TRAUSTREFLG","Alcohol","Opioid"))

exposure <- "TRAUSTREFLG"


# Descriptive of covariates stratified by the exposure
table = CreateTableOne(vars = covars,
                       data = data,
                       factorVars = covars,
                       strata = exposure, smd = T)

print(table, test = FALSE)



# PROPENSITY SCORE ESTIMATION & MATCHING

matchit_obj <- perform_matching(data, covars, exposure)
matched_data <- get_matched_data(matchit_obj)
balance_stats <- calculate_balance_stats(matchit_obj)


# Balance diagnostics pre- & post-matching
print(balance_stats)
plot_balance_stats(balance_stats)
plot_ps_distribution(matchit_obj)



# EFFECT ESTIMATIONS & BOOTSTRAPPED CONFIDENCE INTERVALS

# RR: Relative Risk
# ARI: Absolute Risk Increase
# NNEH: Number Needed to be Exposed to Harm

# For the measure, Choose 'RR', 'ARI', or 'NNEH' 

outcomes <- c("Opioid", "Alcohol")
bca_results <- estimate_bca(matched_data, outcomes, covars, measure = "NNEH")
print(bca_results)

#bca = readRDS("./BCa_Results/BCa_NNEH.rds")


# ODDS RATIO ESTIMATION

odds_ratios <- odds_ratio_estimation(matched_data, covars)
#Forest plot
plot_odds_ratios(odds_ratios)

