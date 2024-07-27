library(MatchIt)
library(quickmatch)
library(cobalt)

perform_matching <- function(data, covars, outcome_var) {
  formula <- as.formula(paste(outcome_var, "~", paste(covars, collapse = " + ")))
  matchit_ <- matchit(formula, data = data, method = "quick")
  return(matchit_)
}

get_matched_data <- function(matchit_obj) {
  match.data(matchit_obj)
}

calculate_balance_stats <- function(matchit_obj) {
  summary(matchit_obj)
}
