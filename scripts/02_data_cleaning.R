# ==============================================================================
# 02_data_cleaning.R
# Clean and Merge Hospital Datasets
# ==============================================================================

library(tidyverse)

# ==============================================================================
# Function: Clean Mortality/Complications Data
# ==============================================================================
clean_mortality_data <- function(complications_data) {
  message("Cleaning mortality/complications data...")
  
  if (is.null(complications_data)) {
    return(NULL)
  }
  
  mortality_clean <- complications_data %>%
    filter(grepl("death|mortality|MORT", `Measure Name`, ignore.case = TRUE)) %>%
    group_by(`Facility ID`) %>%
    summarise(
      mortality_rate = mean(Score, na.rm = TRUE),
      mortality_measures = n(),
      .groups = "drop"
    ) %>%
    rename(hospital_id = `Facility ID`)
  
  message(paste("Cleaned mortality data for", nrow(mortality_clean), "hospitals"))
  return(mortality_clean)
}

# ==============================================================================
# Function: Clean Readmissions Data
# ==============================================================================
clean_readmissions_data <- function(readmissions_data) {
  message("Cleaning readmissions data...")
  
  if (is.null(readmissions_data)) {
    return(NULL)
  }
  
  readmissions_clean <- readmissions_data %>%
    group_by(`Facility ID`) %>%
    summarise(
      readmission_rate = mean(Score, na.rm = TRUE),
      readmission_measures = n(),
      .groups = "drop"
    ) %>%
    rename(hospital_id = `Facility ID`)
  
  message(paste("Cleaned readmissions data for", nrow(readmissions_clean), "hospitals"))
  return(readmissions_clean)
}

# ==============================================================================
# Function: Clean Healthcare-Associated Infections Data
# ==============================================================================
clean_infections_data <- function(infections_data) {
  message("Cleaning infections data...")
  
  if (is.null(infections_data)) {
    return(NULL)
  }
  
  infections_clean <- infections_data %>%
    group_by(`Facility ID`) %>%
    summarise(
      infection_rate = mean(Score, na.rm = TRUE),
      infection_measures = n(),
      .groups = "drop"
    ) %>%
    rename(hospital_id = `Facility ID`)
  
  message(paste("Cleaned infections data for", nrow(infections_clean), "hospitals"))
  return(infections_clean)
}

# ==============================================================================
# Function: Clean Patient Experience Data
# ==============================================================================
clean_patient_experience <- function(patient_exp_data) {
  message("Cleaning patient experience data...")
  
  if (is.null(patient_exp_data)) {
    return(NULL)
  }
  
  patient_clean <- patient_exp_data %>%
    group_by(`Facility ID`) %>%
    summarise(
      patient_experience_score = mean(Score, na.rm = TRUE),
      experience_measures = n(),
      .groups = "drop"
    ) %>%
    rename(hospital_id = `Facility ID`)
  
  message(paste("Cleaned patient experience data for", nrow(patient_clean), "hospitals"))
  return(patient_clean)
}

# ==============================================================================
# Function: Handle Missing Values
# ==============================================================================
handle_missing_values <- function(df, method = "median") {
  message("Handling missing values...")
  
  # Count missing values before
  missing_before <- sum(is.na(df))
  
  numeric_cols <- df %>% 
    select(where(is.numeric)) %>% 
    names()
  
  if (method == "median") {
    for (col in numeric_cols) {
      median_val <- median(df[[col]], na.rm = TRUE)
      df[[col]][is.na(df[[col]])] <- median_val
    }
  } else if (method == "mean") {
    for (col in numeric_cols) {
      mean_val <- mean(df[[col]], na.rm = TRUE)
      df[[col]][is.na(df[[col]])] <- mean_val
    }
  }
  
  # Count missing values after
  missing_after <- sum(is.na(df))
  
  message(paste("Imputed", missing_before - missing_after, "missing values"))
  return(df)
}

# ==============================================================================
# Function: Remove Outliers (IQR method)
# ==============================================================================
remove_outliers <- function(df, columns, multiplier = 1.5) {
  message("Removing outliers using IQR method...")
  
  n_before <- nrow(df)
  
  for (col in columns) {
    if (col %in% names(df) && is.numeric(df[[col]])) {
      Q1 <- quantile(df[[col]], 0.25, na.rm = TRUE)
      Q3 <- quantile(df[[col]], 0.75, na.rm = TRUE)
      IQR_val <- Q3 - Q1
      
      lower_bound <- Q1 - multiplier * IQR_val
      upper_bound <- Q3 + multiplier * IQR_val
      
      df <- df %>%
        filter(df[[col]] >= lower_bound & df[[col]] <= upper_bound)
    }
  }
  
  n_after <- nrow(df)
  message(paste("Removed", n_before - n_after, "outlier records"))
  
  return(df)
}

# ==============================================================================
# Function: Merge All Hospital Data
# ==============================================================================
merge_hospital_data <- function(hospital_info, mortality, readmissions, 
                                infections, patient_exp) {
  message("\nMerging all hospital datasets...")
  
  # Start with hospital info
  merged_data <- hospital_info
  
  # Merge mortality data
  if (!is.null(mortality)) {
    merged_data <- merged_data %>%
      left_join(mortality, by = "hospital_id")
  }
  
  # Merge readmissions data
  if (!is.null(readmissions)) {
    merged_data <- merged_data %>%
      left_join(readmissions, by = "hospital_id")
  }
  
  # Merge infections data
  if (!is.null(infections)) {
    merged_data <- merged_data %>%
      left_join(infections, by = "hospital_id")
  }
  
  # Merge patient experience data
  if (!is.null(patient_exp)) {
    merged_data <- merged_data %>%
      left_join(patient_exp, by = "hospital_id")
  }
  
  message(paste("Merged data contains", nrow(merged_data), "hospitals"))
  message(paste("with", ncol(merged_data), "columns"))
  
  return(merged_data)
}

# ==============================================================================
# Function: Clean Complete Dataset
# ==============================================================================
clean_complete_dataset <- function(raw_data_list) {
  message("\n=== Starting Data Cleaning Process ===\n")
  
  # Clean individual datasets
  mortality_clean <- clean_mortality_data(raw_data_list$complications)
  readmissions_clean <- clean_readmissions_data(raw_data_list$readmissions)
  infections_clean <- clean_infections_data(raw_data_list$infections)
  patient_exp_clean <- clean_patient_experience(raw_data_list$patient_experience)
  
  # Merge all data
  merged_data <- merge_hospital_data(
    raw_data_list$hospital_info,
    mortality_clean,
    readmissions_clean,
    infections_clean,
    patient_exp_clean
  )
  
  # Handle missing values
  merged_data <- handle_missing_values(merged_data, method = "median")
  
  # Remove outliers from key metrics
  outlier_columns <- c("mortality_rate", "readmission_rate", 
                       "infection_rate", "patient_experience_score")
  merged_data <- remove_outliers(merged_data, outlier_columns, multiplier = 3)
  
  # Remove rows with too many missing values
  complete_cases <- complete.cases(merged_data[, outlier_columns])
  merged_data <- merged_data[complete_cases, ]
  
  message("\n=== Data Cleaning Complete ===")
  message(paste("Final dataset contains", nrow(merged_data), "hospitals"))
  
  # Save cleaned data
  if (!dir.exists("data/processed")) {
    dir.create("data/processed", recursive = TRUE)
  }
  write_csv(merged_data, "data/processed/hospital_data_clean.csv")
  message("Saved cleaned data to data/processed/hospital_data_clean.csv")
  
  return(merged_data)
}

# ==============================================================================
# Main Execution (if run directly)
# ==============================================================================
if (sys.nframe() == 0) {
  source("scripts/01_data_loading.R")
  
  # Load raw data
  raw_data <- load_all_data()
  
  # Clean and merge data
  clean_data <- clean_complete_dataset(raw_data)
  
  # Display summary statistics
  cat("\n=== Cleaned Data Summary ===\n")
  print(summary(clean_data))
}
