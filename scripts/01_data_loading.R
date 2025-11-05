# ==============================================================================
# 01_data_loading.R
# Load CMS Hospital Compare Data
# ==============================================================================

# Load required libraries
library(tidyverse)

# ==============================================================================
# Function: Load Hospital General Information
# ==============================================================================
load_hospital_info <- function(file_path = "data/raw/hospital_general_info.csv") {
  message("Loading hospital general information...")
  
  if (!file.exists(file_path)) {
    warning(paste("File not found:", file_path))
    return(NULL)
  }
  
  hospital_info <- read_csv(file_path, show_col_types = FALSE) %>%
    select(
      hospital_id = `Facility ID`,
      hospital_name = `Facility Name`,
      address = Address,
      city = City,
      state = State,
      zip_code = `ZIP Code`,
      hospital_type = `Hospital Type`,
      hospital_ownership = `Hospital Ownership`
    ) %>%
    mutate(
      hospital_id = as.character(hospital_id),
      state = as.character(state)
    )
  
  message(paste("Loaded", nrow(hospital_info), "hospitals"))
  return(hospital_info)
}

# ==============================================================================
# Function: Load Complications and Deaths
# ==============================================================================
load_complications_deaths <- function(file_path = "data/raw/complications_deaths.csv") {
  message("Loading complications and deaths data...")
  
  if (!file.exists(file_path)) {
    warning(paste("File not found:", file_path))
    return(NULL)
  }
  
  complications <- read_csv(file_path, show_col_types = FALSE) %>%
    mutate(
      `Facility ID` = as.character(`Facility ID`),
      Score = as.numeric(Score)
    ) %>%
    filter(!is.na(Score))
  
  message(paste("Loaded", nrow(complications), "complication records"))
  return(complications)
}

# ==============================================================================
# Function: Load Readmissions Data
# ==============================================================================
load_readmissions <- function(file_path = "data/raw/readmissions.csv") {
  message("Loading readmissions data...")
  
  if (!file.exists(file_path)) {
    warning(paste("File not found:", file_path))
    return(NULL)
  }
  
  readmissions <- read_csv(file_path, show_col_types = FALSE) %>%
    mutate(
      `Facility ID` = as.character(`Facility ID`),
      Score = as.numeric(Score)
    ) %>%
    filter(!is.na(Score))
  
  message(paste("Loaded", nrow(readmissions), "readmission records"))
  return(readmissions)
}

# ==============================================================================
# Function: Load Healthcare Associated Infections (HAI)
# ==============================================================================
load_infections <- function(file_path = "data/raw/healthcare_infections.csv") {
  message("Loading healthcare-associated infections data...")
  
  if (!file.exists(file_path)) {
    warning(paste("File not found:", file_path))
    return(NULL)
  }
  
  infections <- read_csv(file_path, show_col_types = FALSE) %>%
    mutate(
      `Facility ID` = as.character(`Facility ID`),
      Score = as.numeric(Score)
    ) %>%
    filter(!is.na(Score))
  
  message(paste("Loaded", nrow(infections), "infection records"))
  return(infections)
}

# ==============================================================================
# Function: Load Patient Experience (HCAHPS)
# ==============================================================================
load_patient_experience <- function(file_path = "data/raw/patient_experience.csv") {
  message("Loading patient experience data...")
  
  if (!file.exists(file_path)) {
    warning(paste("File not found:", file_path))
    return(NULL)
  }
  
  patient_exp <- read_csv(file_path, show_col_types = FALSE) %>%
    mutate(
      `Facility ID` = as.character(`Facility ID`),
      Score = as.numeric(gsub("%", "", `Patient Survey Star Rating`))
    ) %>%
    filter(!is.na(Score))
  
  message(paste("Loaded", nrow(patient_exp), "patient experience records"))
  return(patient_exp)
}

# ==============================================================================
# Function: Load All Data
# ==============================================================================
load_all_data <- function(data_dir = "data/raw") {
  message("\n=== Loading All Hospital Data ===\n")
  
  data_list <- list(
    hospital_info = load_hospital_info(file.path(data_dir, "hospital_general_info.csv")),
    complications = load_complications_deaths(file.path(data_dir, "complications_deaths.csv")),
    readmissions = load_readmissions(file.path(data_dir, "readmissions.csv")),
    infections = load_infections(file.path(data_dir, "healthcare_infections.csv")),
    patient_experience = load_patient_experience(file.path(data_dir, "patient_experience.csv"))
  )
  
  message("\n=== Data Loading Complete ===\n")
  return(data_list)
}

# ==============================================================================
# Main Execution (if run directly)
# ==============================================================================
if (sys.nframe() == 0) {
  # Load all data
  hospital_data <- load_all_data()
  
  # Display summary
  cat("\n=== Data Summary ===\n")
  cat("Hospitals:", nrow(hospital_data$hospital_info), "\n")
  cat("Complication Records:", nrow(hospital_data$complications), "\n")
  cat("Readmission Records:", nrow(hospital_data$readmissions), "\n")
  cat("Infection Records:", nrow(hospital_data$infections), "\n")
  cat("Patient Experience Records:", nrow(hospital_data$patient_experience), "\n")
}
