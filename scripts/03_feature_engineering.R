# ==============================================================================
# 03_feature_engineering.R
# Create Healthcare Quality Score and Performance Metrics
# ==============================================================================

library(tidyverse)
library(scales)

# ==============================================================================
# Function: Normalize Scores (Min-Max Scaling to 0-100)
# ==============================================================================
normalize_score <- function(x, inverse = FALSE) {
  # Remove NA values for calculation
  x_clean <- x[!is.na(x)]
  
  if (length(x_clean) == 0) {
    return(rep(NA, length(x)))
  }
  
  min_val <- min(x_clean)
  max_val <- max(x_clean)
  
  if (max_val == min_val) {
    return(rep(50, length(x)))  # Return midpoint if all values are the same
  }
  
  normalized <- (x - min_val) / (max_val - min_val) * 100
  
  # Inverse for metrics where lower is better (mortality, readmission, infection)
  if (inverse) {
    normalized <- 100 - normalized
  }
  
  return(normalized)
}

# ==============================================================================
# Function: Create Individual Performance Scores
# ==============================================================================
create_performance_scores <- function(data) {
  message("Creating normalized performance scores...")
  
  data_scored <- data %>%
    mutate(
      # Lower is better - inverse normalization
      mortality_score = normalize_score(mortality_rate, inverse = TRUE),
      readmission_score = normalize_score(readmission_rate, inverse = TRUE),
      infection_score = normalize_score(infection_rate, inverse = TRUE),
      
      # Higher is better - standard normalization
      patient_exp_score = normalize_score(patient_experience_score, inverse = FALSE)
    )
  
  message("Performance scores created successfully")
  return(data_scored)
}

# ==============================================================================
# Function: Calculate Composite Healthcare Quality Score
# ==============================================================================
calculate_quality_score <- function(data, weights = NULL) {
  message("Calculating composite healthcare quality score...")
  
  # Default weights (can be adjusted based on importance)
  if (is.null(weights)) {
    weights <- list(
      mortality = 0.30,      # 30% - Most critical
      readmission = 0.25,    # 25% - Very important
      infection = 0.25,      # 25% - Very important
      patient_exp = 0.20     # 20% - Important for overall care
    )
  }
  
  # Validate weights sum to 1
  weight_sum <- sum(unlist(weights))
  if (abs(weight_sum - 1.0) > 0.01) {
    warning("Weights do not sum to 1.0. Normalizing...")
    weights <- lapply(weights, function(w) w / weight_sum)
  }
  
  data_with_score <- data %>%
    mutate(
      quality_score = (
        mortality_score * weights$mortality +
        readmission_score * weights$readmission +
        infection_score * weights$infection +
        patient_exp_score * weights$patient_exp
      )
    )
  
  message("Quality score calculation complete")
  return(data_with_score)
}

# ==============================================================================
# Function: Create Hospital Rating Categories
# ==============================================================================
create_rating_categories <- function(data) {
  message("Creating hospital rating categories...")
  
  data_rated <- data %>%
    mutate(
      # 5-Star Rating System
      star_rating = case_when(
        quality_score >= 80 ~ 5,
        quality_score >= 65 ~ 4,
        quality_score >= 50 ~ 3,
        quality_score >= 35 ~ 2,
        TRUE ~ 1
      ),
      
      # Performance Category
      performance_category = case_when(
        quality_score >= 80 ~ "Excellent",
        quality_score >= 65 ~ "Above Average",
        quality_score >= 50 ~ "Average",
        quality_score >= 35 ~ "Below Average",
        TRUE ~ "Poor"
      ),
      
      # Performance Category as ordered factor
      performance_category = factor(
        performance_category,
        levels = c("Poor", "Below Average", "Average", "Above Average", "Excellent"),
        ordered = TRUE
      )
    )
  
  message("Rating categories created successfully")
  return(data_rated)
}

# ==============================================================================
# Function: Create State-Level Rankings
# ==============================================================================
create_state_rankings <- function(data) {
  message("Creating state-level rankings...")
  
  data_ranked <- data %>%
    group_by(state) %>%
    mutate(
      state_rank = rank(-quality_score, ties.method = "min"),
      state_percentile = percent_rank(quality_score) * 100
    ) %>%
    ungroup() %>%
    mutate(
      national_rank = rank(-quality_score, ties.method = "min"),
      national_percentile = percent_rank(quality_score) * 100
    )
  
  message("State rankings created successfully")
  return(data_ranked)
}

# ==============================================================================
# Function: Identify Top and Worst Hospitals
# ==============================================================================
identify_top_worst_hospitals <- function(data, n = 10) {
  message("\nIdentifying top and worst performing hospitals...")
  
  # Overall top hospitals
  top_hospitals <- data %>%
    arrange(desc(quality_score)) %>%
    head(n) %>%
    mutate(category = "Top Overall")
  
  # Overall worst hospitals
  worst_hospitals <- data %>%
    arrange(quality_score) %>%
    head(n) %>%
    mutate(category = "Worst Overall")
  
  # Top by state
  top_by_state <- data %>%
    group_by(state) %>%
    slice_max(quality_score, n = 1) %>%
    ungroup() %>%
    mutate(category = "Top in State")
  
  # Worst by state
  worst_by_state <- data %>%
    group_by(state) %>%
    slice_min(quality_score, n = 1) %>%
    ungroup() %>%
    mutate(category = "Worst in State")
  
  # Display summaries
  cat("\n=== Top 10 Hospitals Nationally ===\n")
  print(top_hospitals %>% 
          select(hospital_name, city, state, quality_score, star_rating))
  
  cat("\n=== Worst 10 Hospitals Nationally ===\n")
  print(worst_hospitals %>% 
          select(hospital_name, city, state, quality_score, star_rating))
  
  # Save to outputs
  if (!dir.exists("outputs")) {
    dir.create("outputs", recursive = TRUE)
  }
  
  write_csv(top_hospitals, "outputs/top_hospitals_national.csv")
  write_csv(worst_hospitals, "outputs/worst_hospitals_national.csv")
  write_csv(top_by_state, "outputs/top_hospitals_by_state.csv")
  write_csv(worst_by_state, "outputs/worst_hospitals_by_state.csv")
  
  message("\nTop/worst hospital lists saved to outputs/")
  
  return(list(
    top = top_hospitals,
    worst = worst_hospitals,
    top_by_state = top_by_state,
    worst_by_state = worst_by_state
  ))
}

# ==============================================================================
# Function: Create State-Level Summary
# ==============================================================================
create_state_summary <- function(data) {
  message("Creating state-level summary statistics...")
  
  state_summary <- data %>%
    group_by(state) %>%
    summarise(
      n_hospitals = n(),
      avg_quality_score = mean(quality_score, na.rm = TRUE),
      median_quality_score = median(quality_score, na.rm = TRUE),
      avg_mortality = mean(mortality_rate, na.rm = TRUE),
      avg_readmission = mean(readmission_rate, na.rm = TRUE),
      avg_infection = mean(infection_rate, na.rm = TRUE),
      avg_patient_exp = mean(patient_experience_score, na.rm = TRUE),
      pct_excellent = sum(performance_category == "Excellent") / n() * 100,
      pct_poor = sum(performance_category == "Poor") / n() * 100,
      .groups = "drop"
    ) %>%
    arrange(desc(avg_quality_score))
  
  # Save state summary
  write_csv(state_summary, "outputs/state_summary.csv")
  message("State summary saved to outputs/state_summary.csv")
  
  return(state_summary)
}

# ==============================================================================
# Function: Complete Feature Engineering Pipeline
# ==============================================================================
engineer_features <- function(clean_data) {
  message("\n=== Starting Feature Engineering Pipeline ===\n")
  
  # Create performance scores
  data <- create_performance_scores(clean_data)
  
  # Calculate composite quality score
  data <- calculate_quality_score(data)
  
  # Create rating categories
  data <- create_rating_categories(data)
  
  # Create rankings
  data <- create_state_rankings(data)
  
  # Identify top/worst hospitals
  top_worst <- identify_top_worst_hospitals(data)
  
  # Create state summary
  state_summary <- create_state_summary(data)
  
  # Save complete dataset with all features
  write_csv(data, "outputs/hospital_ratings.csv")
  message("\nComplete hospital ratings saved to outputs/hospital_ratings.csv")
  
  # Display overall summary
  cat("\n=== Quality Score Distribution ===\n")
  print(summary(data$quality_score))
  
  cat("\n=== Star Rating Distribution ===\n")
  print(table(data$star_rating))
  
  cat("\n=== Performance Category Distribution ===\n")
  print(table(data$performance_category))
  
  message("\n=== Feature Engineering Complete ===\n")
  
  return(list(
    data = data,
    top_worst = top_worst,
    state_summary = state_summary
  ))
}

# ==============================================================================
# Main Execution (if run directly)
# ==============================================================================
if (sys.nframe() == 0) {
  # Load cleaned data
  clean_data <- read_csv("data/processed/hospital_data_clean.csv", show_col_types = FALSE)
  
  # Run feature engineering
  results <- engineer_features(clean_data)
  
  cat("\nFeature engineering pipeline completed successfully!\n")
}
