library(bcaboot)

att_boot <- function(data, index, outcome, covars, measure = "RR") {
  formula <- as.formula(paste(outcome, "~ TRAUSTREFLG * (", paste(covars, collapse = " + "), ")"))
  
  # Bootstrap sample
  data_boot <- data[index, ]
  
  # Fit the model
  fit <- glm(formula, data = data_boot,
             weights = data_boot$weights,
             family = quasibinomial())
  
  # Subset data for those with TRAUSTREFLG == 1
  boot_data <- subset(data_boot, TRAUSTREFLG == 1)
  
  # Predicted probabilities for the scenario TRAUSTREFLG = 0
  prob0 <- predict(fit, type = "response",
                   newdata = transform(boot_data, TRAUSTREFLG = 0))
  prob_w0 <- weighted.mean(prob0, boot_data$weights)
  
  # Predicted probabilities for the scenario TRAUSTREFLG = 1
  prob1 <- predict(fit, type = "response",
                   newdata = transform(boot_data, TRAUSTREFLG = 1))
  prob_w1 <- weighted.mean(prob1, boot_data$weights)
  
  # Calculate measures based on user input: RR, ARI, NNEH
  # RR: Relative Risk
  # ARI: Absolute Risk Increase
  # NNEH: Number Needed to be Exposed to Harm
  
  if (measure == "RR") {
    result <- prob_w1 / prob_w0
  } else if (measure == "ARI") {
    result <- prob_w1 - prob_w0
  } else if (measure == "NNEH") {
    ARI <- prob_w1 - prob_w0
    result <- ifelse(ARI != 0, 1 / ARI, NA) # Avoid division by zero
  } else {
    stop("Invalid measure specified. Choose 'RR', 'ARI', or 'NNEH'.")
  }
  
  return(result)
}

boot_wrapper <- function(outcome, covars, measure) {
  function(data, index) {
    att_boot(data, index, outcome, covars, measure)
  }
}

estimate_bca <- function(data,outcomes,covars, measure = "RR", B=2000, m = 40) {
  bca <- list()
  for (outcome in outcomes) {
    boot_ <- boot_wrapper(outcome, covars, measure)
    set.seed(1122)
    bca[[outcome]] <- bcajack2(data, boot_, B = B, m = m, verbose = TRUE)
  }
  return(bca)
}

