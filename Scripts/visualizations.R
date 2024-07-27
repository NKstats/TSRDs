library(ggplot2)
library(ggpubr)
library(cobalt)
library(gridExtra)


custom_labels <- c(
  "DEPRESSFLG" = "Depression",
  "ANXIETYFLG" = "Anxiety",
  "SMI" = "Serious Mental Illness",
  "Hispanic" = "Hispanic/Latino",
  "Race_Other" = "Other Race",
  "White" = "White",
  "Black" = "Black/African American",
  "Never_Married" = "Never Married",
  "Separated" = "Separated",
  "Married" = "Married",
  "Age_60" = "Age 60+",
  "Age_50_59" = "Age 50-59",
  "Age_40_49" = "Age 40-49",
  "Age_30_39" = "Age 30-39",
  "Age_18_29" = "Age 18-29",
  "female" = "Female",
  "Homeless" = "Homeless",
  "TRAUSTREFLG" = "Trauma & Stressor-Related Disorder"
)

plot_balance_stats <- function(balance_stats) {
  std_mean_diff <- data.frame(
    Variable = rownames(balance_stats$sum.all),
    Before = balance_stats$sum.all[, "Std. Mean Diff."],
    After = balance_stats$sum.matched[, "Std. Mean Diff."]
  )
  
  std_mean_diff %<>% pivot_longer(cols = c("Before", "After"),
                                  names_to = "Time",
                                  values_to = "Std_Mean_Diff")
  
  std_mean_diff %<>% mutate(
    Variable = recode(Variable, !!!custom_labels),
    Time = recode(Time,
                  'Before' = 'Before Matching',
                  'After' = 'After Matching')
  )
  
  std_mean_diff %<>% mutate(
    Variable = factor(Variable, levels = rev(unique(std_mean_diff$Variable))),
    Time = factor(Time, levels = c('Before Matching', 'After Matching'))
  )
  
  ggplot(std_mean_diff, aes(x = Std_Mean_Diff, y = Variable,
                            color = Time, shape = Time)) +
    geom_point(size = 4, stroke = 1.5, fill = NA) +
    scale_color_manual(values = c("red", "blue")) +
    scale_shape_manual(values = c(2, 1)) +
    geom_vline(xintercept = 0.1, color = 'green', linetype = 'dashed',
               linewidth = 0.7, alpha = 0.7) +
    geom_vline(xintercept = -0.1, color = 'green', linetype = 'dashed',
               linewidth = 0.7, alpha = 0.7) +
    geom_vline(xintercept = 0, color = 'black', linewidth = 0.3) +
    labs(x = 'Standardized Mean Difference (SMD)', y = '') +
    theme_classic() +
    theme(
      legend.text = element_text(size = 14),
      legend.title = element_blank(),
      plot.margin = margin(20, 20, 20, 20),
      axis.text.x = element_text(size = 15),
      axis.text.y = element_text(size = 15),
      axis.title.x = element_text(size = 15,margin = margin(t = 15)),
      panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5),
      legend.position = c(0.91, 0.05), strip.text = element_text(size = 15)
    ) +
    guides(color = guide_legend(override.aes = list(size = 5)))
}


plot_ps_distribution <- function(matchit_obj) {
  p1 <- bal.plot(matchit_obj,
                 var.name = "distance",
                 which = "both",
                 type = "histogram", mirror = TRUE, plot = FALSE)
  
  p1 + labs(title = NULL, fill = "Group", color = "Group") +
    scale_fill_discrete(labels = c("No TSRD", "TSRD")) +
    scale_color_discrete(labels = c("No TSRD", "TSRD")) +
    labs(x = 'Propensity Score')+
    theme(
      axis.title.x = element_text(size = 15, margin = margin(t = 15)),
      axis.title.y = element_text(size = 15, margin = margin(t = 15)),
      axis.text.x = element_text(size = 15),
      axis.text.y = element_text(size = 15),
      legend.text = element_text(size = 15),
      legend.title = element_blank(),
      legend.position = c(0.06, 0.94), strip.text = element_text(size = 15),
      strip.background = element_blank()
    ) +
    facet_wrap(~factor(which,
                       levels = c("Unadjusted Sample", "Adjusted Sample"),
                       labels = c("Before Matching", "After Matching")))
}

plot_odds_ratios <- function(odds_ratios) {
  plot_data <- bind_rows(odds_ratios, .id = "outcome")
  
  plot_data <- plot_data %>% filter(term != "(Intercept)")
  
  plot_data$term <- factor(plot_data$term, levels = names(custom_labels))
  
  base_plot <- ggplot(plot_data,
                      aes(x = odds_ratio, y = term, color = outcome)) +
    geom_point(color = "black") +
    geom_errorbarh(aes(xmin = conf.low, xmax = conf.high),
                   height = 0.2, color = "black") +
    geom_vline(xintercept = 1, linetype = "dashed", color = "grey") +
    labs(x = "Odds Ratio", y = " ") + theme_classic() +
    theme(
      strip.background = element_blank(),
      strip.placement = "outside",
      legend.position = "none",
      panel.spacing = unit(2, "lines"),
      axis.text.x = element_text(size = 14),
      axis.text.y = element_text(size = 14),
      strip.text.x = element_text(size = 12),
      axis.title.x = element_text(size = 14,margin = margin(t = 15)),
      axis.title.y = element_text(size = 12)
    )
  
  plot_data_alcohol <- subset(plot_data, outcome == "Alcohol")
  plot_data_opioid <- subset(plot_data, outcome == "Opioid")
  
  plot_alcohol <- base_plot %+% plot_data_alcohol +
    ggtitle("Alcohol Dependence") +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      axis.title.y = element_blank(),
      axis.line.y = element_blank(),
      plot.title = element_text(hjust = 0.085, size = 12) 
    )
  
  plot_opioid <- base_plot %+% plot_data_opioid +
    ggtitle("Opioid Dependence") +
    theme(
      plot.title = element_text(hjust = 0.55, size = 12)
    ) +
    scale_y_discrete(labels = custom_labels)
  
  add_annotations <- function(plot) {
    plot +
      annotate("segment", x = 0.9, xend = 1.3, y = Inf, yend = Inf,
               arrow = arrow(type = "closed", length = unit(0.1, "inches")),
               linetype = "solid", color = "black") +
      annotate("text", x = 1.1, y = Inf, label = "Increased Risk",#1.25
               vjust = 1.5, hjust = 0, color="red") +
      annotate("segment", x = 1, xend = 0.7, y = Inf, yend = Inf,
               color = "black", linetype = "solid",
               arrow = arrow(type = "closed", length = unit(0.1, "inches"))) +
      annotate("text", x = 0.9, y = Inf,
               label = "Reduced Risk", vjust = 1.5, hjust = 1, color="blue")
  }
  
  plot_alcohol <- add_annotations(plot_alcohol)
  plot_opioid <- add_annotations(plot_opioid)
  
  grid.arrange(plot_opioid, plot_alcohol, ncol = 2)
}

