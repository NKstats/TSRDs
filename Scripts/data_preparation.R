library(dplyr)
library(magrittr)

preprocess_data <- function(data) {
  
  # Extracting columns for the current work
  cols <- c("CASEID",
            "AGE",
            "ETHNIC",
            "RACE",
            "GENDER",
            "SUB",
            "LIVARAG",
            "MARSTAT",
            "SMISED",
            "TRAUSTREFLG",
            "ANXIETYFLG",
            "DEPRESSFLG",
            "SAP",
            "NUMMHS")
  
  data <- data[, (names(data) %in% cols)]
  
  # Select those with substance use problems
  data %<>% filter((SAP %in% c(1))) 
  
  #Select participants aged >= 18 years
  data %<>% filter((AGE %in% c(4:14))) 
  
  #Select participants with 3 valid mental health diagnoses
  data %<>% filter((NUMMHS %in% c(3))) 
  
  # Drop rows where any column has the value -9 (missing)
  data %<>% filter_all(all_vars(. != -9))
  
  data <- data %>%
    # Recode Age groups
    mutate(
      Age_18_29 = ifelse(AGE %in% c(4,5,6), 1, 0),
      Age_30_39 = ifelse(AGE %in% c(7,8), 1, 0),
      Age_40_49 = ifelse(AGE %in% c(9,10), 1, 0),
      Age_50_59 = ifelse(AGE %in% c(11,12), 1, 0),
      Age_60 = ifelse(AGE %in% c(13,14), 1, 0)
    ) %>%
    select(-AGE) %>%
    
    # Recode Homeless
    mutate(Homeless = ifelse(LIVARAG == 1, 1, 0)) %>%
    select(-LIVARAG) %>%
    
    # Recode Marital Status
    mutate(
      Never_Married = ifelse(MARSTAT %in% c(1), 1, 0),
      Married = ifelse(MARSTAT %in% c(2), 1, 0),
      Separated = ifelse(MARSTAT %in% c(3,4), 1, 0)
    ) %>%
    select(-MARSTAT) %>%
    
    # Recode Ethnicity
    mutate(Hispanic = ifelse(ETHNIC %in% c(1,2,3), 1, 0)) %>%
    select(-ETHNIC) %>%
    
    # Recode RACE
    mutate(
      White = ifelse(RACE %in% c(5), 1, 0),
      Black = ifelse(RACE %in% c(3), 1, 0),
      Race_Other = ifelse(RACE %in% c(1,2,4,6), 1, 0)
    ) %>%
    select(-RACE) %>%
    
    # Recode Gender
    mutate(female = ifelse(GENDER == 2, 1, 0)) %>%
    select(-GENDER) %>%
    
    # Recode SMISED
    mutate(SMI = ifelse(SMISED %in% c(1,2), 1, 0)) %>%
    select(-SMISED) %>%
    
    # Recode SUB to extract the outcomes for the current work
    mutate(
      Alcohol = ifelse(SUB == 4, 1, 0), #Alcohol Dependence
      Opioid = ifelse(SUB == 7, 1, 0) #Opioid Dependence
    ) %>%
    select(-SUB) %>%
    
    mutate(CASEID = as.character(CASEID)) %>%
    
    # Reorder columns
    select(CASEID, Homeless, female, Age_18_29, Age_30_39, Age_40_49, Age_50_59,
           Age_60, Never_Married, Married, Separated, Hispanic, White, Black,
           Race_Other, SMI, ANXIETYFLG, DEPRESSFLG, TRAUSTREFLG, Alcohol, Opioid)
  
  return(data)
}
