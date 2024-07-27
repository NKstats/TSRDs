library(geepack)
library(dplyr)
library(broom)
library(magrittr)
library(FDRestimation)
library(gt)

odds_ratio_estimation <- function(matched_data, covars) {
  models <- list()
  
  covars <- setdiff(covars, c("Age_18_29", "Never_Married", "White"))
  
  for (outcome in c("Opioid", "Alcohol")) {
    form_ <- as.formula(paste(outcome, "~",
                              paste(c("TRAUSTREFLG",covars), collapse = " + ")))
    models[[outcome]] <- glm(form_, data = matched_data, family = binomial)
  }
  
  
  # Extract odds ratios and confidence intervals
  model_results <- lapply(models, function(model) {
    tidy(model, conf.int = TRUE) %>%
      mutate(odds_ratio = exp(estimate),
             conf.low = exp(conf.low),
             conf.high = exp(conf.high))
  })
  
  
  model_results$Alcohol %<>% select(term,
                                    odds_ratio,
                                    conf.low,
                                    conf.high,
                                    p.value)
  
  model_results$Opioid %<>% select(term,
                                   odds_ratio,
                                   conf.low,
                                   conf.high,
                                   p.value)
  
  
  # Control FDRs for multiple testing
  adj_alcohol = p.fdr(p=model_results$Alcohol$p.value,
                      threshold=0.05, adjust.method="BH")
  
  adj_opioid = p.fdr(p=model_results$Opioid$p.value,
                     threshold=0.05, adjust.method="BH")
  
  # Add adjusted p-values to the model results
  model_results$Alcohol <- model_results$Alcohol %>%
    mutate(adj.p.value = adj_alcohol$`Results Matrix`$`Adjusted p-values`)
  
  model_results$Opioid <- model_results$Opioid %>%
    mutate(adj.p.value = adj_opioid$`Results Matrix`$`Adjusted p-values`)
  
  combined_results <- bind_rows(model_results, .id = "Model")
  
  reshaped_results <- combined_results %>%
    dplyr::select(Model, term, odds_ratio, conf.low,
                  conf.high, p.value, adj.p.value) %>%
    pivot_wider(
      names_from = Model,
      values_from = c(odds_ratio, conf.low, conf.high, p.value, adj.p.value),
      names_sep = "_"
    )
  
  gt_table <- reshaped_results %>%
    gt(rowname_col = "term") %>%
    fmt_number(
      columns = matches("odds_ratio|conf.low|conf.high|p.value|adj.p.value"),
      decimals = 4
    ) %>%
    tab_header(
      title = "Logistic Regression Model Results",
      subtitle = "Odds ratios, confidence intervals, and adjusted p-values"
    ) %>%
    cols_label(
      term = "Variable",
      odds_ratio_Alcohol = "OR",
      conf.low_Alcohol = "Lower CI",
      conf.high_Alcohol = "Upper CI",
      p.value_Alcohol = "P-value",
      adj.p.value_Alcohol = "Adjusted P-value",
      odds_ratio_Opioid = "OR",
      conf.low_Opioid = "Lower CI",
      conf.high_Opioid = "Upper CI",
      p.value_Opioid = "P-value",
      adj.p.value_Opioid = "Adjusted P-value"
      
    ) %>%
    tab_spanner(
      label = md("**Alcohol**"),
      columns = c(odds_ratio_Alcohol, conf.low_Alcohol, conf.high_Alcohol,
                  p.value_Alcohol, adj.p.value_Alcohol)
    ) %>%
    tab_spanner(
      label = md("**Opioid**"),
      columns = c(odds_ratio_Opioid, conf.low_Opioid, conf.high_Opioid,
                  p.value_Opioid, adj.p.value_Opioid)
    ) %>%
    tab_style(
      style = cell_text(align = "center"),
      locations = cells_column_labels()
    ) %>%
    tab_style(
      style = cell_text(align = "center"),
      locations = cells_body(columns = everything())
    )
  
  # Display the table
  print(gt_table)
  
  
  return(list(Opioid = model_results$Opioid, Alcohol = model_results$Alcohol))
}