# ==============================================================================
# 06_generate_sample_data.R
# Generate Synthetic CMS Hospital Compare Data for Demonstration
# ==============================================================================

library(tidyverse)

set.seed(42)

# ==============================================================================
# Configuration
# ==============================================================================
N_HOSPITALS <- 500
STATES <- c("CA", "TX", "FL", "NY", "PA", "IL", "OH", "GA", "NC", "MI", 
            "NJ", "VA", "WA", "AZ", "MA", "TN", "IN", "MO", "MD", "WI",
            "CO", "MN", "SC", "AL", "LA", "KY", "OR", "OK", "CT", "UT")

HOSPITAL_TYPES <- c("Acute Care Hospitals", "Critical Access Hospitals", 
                    "Children's Hospitals", "Acute Care - Department of Defense")

OWNERSHIP_TYPES <- c("Government - Federal", "Government - State", 
                     "Government - Local", "Voluntary non-profit - Private",
                     "Voluntary non-profit - Church", 
                     "Proprietary", "Voluntary non-profit - Other")

MEASURES_MORTALITY <- c(
  "Death rate for heart attack patients",
  "Death rate for heart failure patients",
  "Death rate for pneumonia patients",
  "Death rate for COPD patients",
  "Death rate for stroke patients",
  "Death rate for coronary artery bypass graft (CABG) patients"
)

MEASURES_READMISSION <- c(
  "Readmission rate for heart attack patients",
  "Readmission rate for heart failure patients",
  "Readmission rate for pneumonia patients",
  "Readmission rate for COPD patients",
  "Readmission rate for stroke patients",
  "Readmission rate for hip/knee replacement patients"
)

MEASURES_INFECTION <- c(
  "Central line-associated bloodstream infections (CLABSI)",
  "Catheter-associated urinary tract infections (CAUTI)",
  "Surgical site infections (SSI) - Colon surgery",
  "Surgical site infections (SSI) - Abdominal hysterectomy",
  "Methicillin-resistant Staphylococcus aureus (MRSA)",
  "Clostridium difficile (C.diff) infections"
)

# ==============================================================================
# Function: Generate Hospital General Information
# ==============================================================================
generate_hospital_info <- function(n) {
  message(paste("Generating", n, "hospitals..."))
  
  hospital_info <- tibble(
    `Facility ID` = sprintf("%06d", 1:n),
    `Facility Name` = paste(
      sample(c("St.", "Mount", "County", "Memorial", "General", "Regional",
               "University", "Community", "Sacred Heart", "Good Samaritan",
               "Mercy", "Presbyterian", "Methodist"), n, replace = TRUE),
      sample(c("Medical Center", "Hospital", "Healthcare System", 
               "Medical Hospital", "Regional Hospital"), n, replace = TRUE)
    ),
    Address = paste(sample(100:9999, n), 
                   sample(c("Main St", "Oak Ave", "Park Blvd", "Elm St", 
                           "Maple Dr", "Washington Ave"), n, replace = TRUE)),
    City = paste("City", sample(1:200, n, replace = TRUE)),
    State = sample(STATES, n, replace = TRUE),
    `ZIP Code` = sprintf("%05d", sample(10000:99999, n)),
    `Hospital Type` = sample(HOSPITAL_TYPES, n, replace = TRUE, 
                            prob = c(0.7, 0.15, 0.1, 0.05)),
    `Hospital Ownership` = sample(OWNERSHIP_TYPES, n, replace = TRUE,
                                 prob = c(0.05, 0.05, 0.1, 0.35, 0.15, 0.2, 0.1))
  )
  
  message("Hospital information generated")
  return(hospital_info)
}

# ==============================================================================
# Function: Generate Complications and Deaths Data
# ==============================================================================
generate_complications_deaths <- function(hospital_ids) {
  message("Generating complications and deaths data...")
  
  complications <- tibble()
  
  for (hospital_id in hospital_ids) {
    n_measures <- sample(3:6, 1)
    measures <- sample(MEASURES_MORTALITY, n_measures)
    
    # Base mortality rate with some variation
    base_rate <- rnorm(1, mean = 15, sd = 3)
    base_rate <- max(5, min(30, base_rate))  # Clamp between 5-30%
    
    for (measure in measures) {
      score <- base_rate + rnorm(1, mean = 0, sd = 2)
      score <- max(3, min(35, score))  # Realistic range
      
      complications <- bind_rows(
        complications,
        tibble(
          `Facility ID` = hospital_id,
          `Measure Name` = measure,
          Score = round(score, 2),
          `Compared to National` = sample(c("No Different", "Better", "Worse"), 1,
                                         prob = c(0.7, 0.2, 0.1))
        )
      )
    }
  }
  
  message(paste("Generated", nrow(complications), "complication records"))
  return(complications)
}

# ==============================================================================
# Function: Generate Readmissions Data
# ==============================================================================
generate_readmissions <- function(hospital_ids) {
  message("Generating readmissions data...")
  
  readmissions <- tibble()
  
  for (hospital_id in hospital_ids) {
    n_measures <- sample(3:6, 1)
    measures <- sample(MEASURES_READMISSION, n_measures)
    
    # Base readmission rate
    base_rate <- rnorm(1, mean = 16, sd = 3)
    base_rate <- max(10, min(25, base_rate))
    
    for (measure in measures) {
      score <- base_rate + rnorm(1, mean = 0, sd = 2)
      score <- max(8, min(30, score))
      
      readmissions <- bind_rows(
        readmissions,
        tibble(
          `Facility ID` = hospital_id,
          `Measure Name` = measure,
          Score = round(score, 2),
          `Compared to National` = sample(c("No Different", "Better", "Worse"), 1,
                                         prob = c(0.7, 0.2, 0.1))
        )
      )
    }
  }
  
  message(paste("Generated", nrow(readmissions), "readmission records"))
  return(readmissions)
}

# ==============================================================================
# Function: Generate Healthcare-Associated Infections Data
# ==============================================================================
generate_infections <- function(hospital_ids) {
  message("Generating healthcare-associated infections data...")
  
  infections <- tibble()
  
  for (hospital_id in hospital_ids) {
    n_measures <- sample(3:6, 1)
    measures <- sample(MEASURES_INFECTION, n_measures)
    
    # Base infection rate (SIR - Standardized Infection Ratio)
    base_rate <- rnorm(1, mean = 1.0, sd = 0.3)
    base_rate <- max(0.2, min(2.5, base_rate))
    
    for (measure in measures) {
      score <- base_rate + rnorm(1, mean = 0, sd = 0.2)
      score <- max(0.1, min(3.0, score))
      
      infections <- bind_rows(
        infections,
        tibble(
          `Facility ID` = hospital_id,
          `Measure Name` = measure,
          Score = round(score, 3),
          `Compared to National` = sample(c("No Different", "Better", "Worse"), 1,
                                         prob = c(0.7, 0.2, 0.1))
        )
      )
    }
  }
  
  message(paste("Generated", nrow(infections), "infection records"))
  return(infections)
}

# ==============================================================================
# Function: Generate Patient Experience Data
# ==============================================================================
generate_patient_experience <- function(hospital_ids) {
  message("Generating patient experience data...")
  
  patient_exp <- tibble()
  
  for (hospital_id in hospital_ids) {
    # Patient survey star rating (1-5)
    star_rating <- sample(1:5, 1, prob = c(0.05, 0.15, 0.40, 0.30, 0.10))
    
    # Convert to percentage score
    score <- (star_rating - 1) * 25 + rnorm(1, mean = 10, sd = 5)
    score <- max(0, min(100, score))
    
    patient_exp <- bind_rows(
      patient_exp,
      tibble(
        `Facility ID` = hospital_id,
        `Measure Name` = "Patient Survey Star Rating",
        `Patient Survey Star Rating` = star_rating,
        Score = round(score, 1)
      )
    )
  }
  
  message(paste("Generated", nrow(patient_exp), "patient experience records"))
  return(patient_exp)
}

# ==============================================================================
# Function: Generate All Sample Data
# ==============================================================================
generate_all_sample_data <- function(n_hospitals = N_HOSPITALS) {
  message("\n=== Generating Sample CMS Hospital Data ===\n")
  
  # Create directories
  if (!dir.exists("data/raw")) {
    dir.create("data/raw", recursive = TRUE)
  }
  
  # Generate hospital information
  hospital_info <- generate_hospital_info(n_hospitals)
  hospital_ids <- hospital_info$`Facility ID`
  
  # Generate quality measures
  complications <- generate_complications_deaths(hospital_ids)
  readmissions <- generate_readmissions(hospital_ids)
  infections <- generate_infections(hospital_ids)
  patient_exp <- generate_patient_experience(hospital_ids)
  
  # Save to CSV files
  message("\nSaving data files...")
  write_csv(hospital_info, "data/raw/hospital_general_info.csv")
  write_csv(complications, "data/raw/complications_deaths.csv")
  write_csv(readmissions, "data/raw/readmissions.csv")
  write_csv(infections, "data/raw/healthcare_infections.csv")
  write_csv(patient_exp, "data/raw/patient_experience.csv")
  
  message("\n=== Sample Data Generation Complete ===")
  message(paste("Generated data for", n_hospitals, "hospitals"))
  message("Files saved to data/raw/")
  
  cat("\n=== Generated Files ===\n")
  cat("1. hospital_general_info.csv -", nrow(hospital_info), "hospitals\n")
  cat("2. complications_deaths.csv -", nrow(complications), "records\n")
  cat("3. readmissions.csv -", nrow(readmissions), "records\n")
  cat("4. healthcare_infections.csv -", nrow(infections), "records\n")
  cat("5. patient_experience.csv -", nrow(patient_exp), "records\n")
  
  return(list(
    hospital_info = hospital_info,
    complications = complications,
    readmissions = readmissions,
    infections = infections,
    patient_experience = patient_exp
  ))
}

# ==============================================================================
# Main Execution
# ==============================================================================
if (sys.nframe() == 0) {
  sample_data <- generate_all_sample_data(N_HOSPITALS)
  cat("\nSample data generation completed successfully!\n")
  cat("You can now run main_analysis.R to analyze the data.\n")
}
