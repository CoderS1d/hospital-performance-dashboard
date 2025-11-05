# ==============================================================================
# main_analysis.R
# US Healthcare Hospital Performance Analysis - Master Script
# ==============================================================================
# This script orchestrates the complete hospital performance analysis workflow:
# 1. Generate/Load Data
# 2. Clean and Merge Datasets
# 3. Feature Engineering and Quality Scoring
# 4. Clustering Analysis (K-means & Hierarchical)
# 5. Visualization Dashboard
# ==============================================================================

# Clear environment
rm(list = ls())
gc()

# ==============================================================================
# Load Required Libraries
# ==============================================================================
cat("=======================================================================\n")
cat("  US HEALTHCARE HOSPITAL PERFORMANCE ANALYSIS\n")
cat("=======================================================================\n\n")

message("Loading required packages...")

required_packages <- c(
  "tidyverse",      # Data manipulation and visualization
  "cluster",        # Clustering algorithms
  "factoextra",     # Clustering visualization
  "plotly",         # Interactive plots
  "ggcorrplot",     # Correlation heatmaps
  "scales",         # Scale functions for visualization
  "RColorBrewer",   # Color palettes
  "patchwork"       # Combine ggplot2 plots
)

# Check and install missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages) > 0) {
  message(paste("Installing missing packages:", paste(new_packages, collapse = ", ")))
  install.packages(new_packages, repos = "http://cran.us.r-project.org")
}

# Load all packages
invisible(lapply(required_packages, library, character.only = TRUE, quietly = TRUE))

message("All packages loaded successfully!\n")

# ==============================================================================
# Configuration
# ==============================================================================
USE_SAMPLE_DATA <- TRUE  # Set to FALSE if using real CMS data
N_CLUSTERS <- 4           # Number of clusters for analysis
RANDOM_SEED <- 123        # For reproducibility

set.seed(RANDOM_SEED)

# ==============================================================================
# Source Analysis Scripts
# ==============================================================================
message("Loading analysis scripts...")

source("scripts/01_data_loading.R")
source("scripts/02_data_cleaning.R")
source("scripts/03_feature_engineering.R")
source("scripts/04_clustering.R")
source("scripts/05_visualization.R")

message("Analysis scripts loaded successfully!\n")

# ==============================================================================
# STEP 1: Data Generation/Loading
# ==============================================================================
cat("\n")
cat("=======================================================================\n")
cat("STEP 1: DATA GENERATION/LOADING\n")
cat("=======================================================================\n\n")

if (USE_SAMPLE_DATA) {
  message("Generating sample CMS Hospital Compare data...")
  source("scripts/06_generate_sample_data.R")
  sample_data <- generate_all_sample_data(n_hospitals = 500)
  message("Sample data generated successfully!")
} else {
  message("Loading real CMS Hospital Compare data...")
  message("Please ensure data files are in data/raw/ directory")
}

# Load all hospital data
raw_data <- load_all_data(data_dir = "data/raw")

cat("\n✓ Data loading complete\n")

# ==============================================================================
# STEP 2: Data Cleaning and Merging
# ==============================================================================
cat("\n")
cat("=======================================================================\n")
cat("STEP 2: DATA CLEANING AND MERGING\n")
cat("=======================================================================\n\n")

clean_data <- clean_complete_dataset(raw_data)

cat("\n✓ Data cleaning complete\n")
cat(paste("  - Total hospitals:", nrow(clean_data), "\n"))
cat(paste("  - Total features:", ncol(clean_data), "\n"))

# ==============================================================================
# STEP 3: Feature Engineering and Quality Scoring
# ==============================================================================
cat("\n")
cat("=======================================================================\n")
cat("STEP 3: FEATURE ENGINEERING AND QUALITY SCORING\n")
cat("=======================================================================\n\n")

feature_results <- engineer_features(clean_data)
hospital_data <- feature_results$data
top_worst <- feature_results$top_worst
state_summary <- feature_results$state_summary

cat("\n✓ Feature engineering complete\n")
cat(paste("  - Quality scores calculated for", nrow(hospital_data), "hospitals\n"))
cat(paste("  - Mean quality score:", round(mean(hospital_data$quality_score), 2), "\n"))
cat(paste("  - Median quality score:", round(median(hospital_data$quality_score), 2), "\n"))

# ==============================================================================
# STEP 4: Clustering Analysis
# ==============================================================================
cat("\n")
cat("=======================================================================\n")
cat("STEP 4: CLUSTERING ANALYSIS\n")
cat("=======================================================================\n\n")

clustering_results <- perform_clustering_analysis(hospital_data, k = N_CLUSTERS)

cat("\n✓ Clustering analysis complete\n")
cat(paste("  - K-means silhouette score:", 
          round(clustering_results$kmeans$result$avg_silhouette, 3), "\n"))
cat(paste("  - Hierarchical silhouette score:", 
          round(clustering_results$hierarchical$result$avg_silhouette, 3), "\n"))

# ==============================================================================
# STEP 5: Visualization Dashboard
# ==============================================================================
cat("\n")
cat("=======================================================================\n")
cat("STEP 5: VISUALIZATION DASHBOARD\n")
cat("=======================================================================\n\n")

create_visualization_dashboard(hospital_data, clustering_results)

cat("\n✓ Visualization dashboard complete\n")

# ==============================================================================
# STEP 6: Generate Summary Report
# ==============================================================================
cat("\n")
cat("=======================================================================\n")
cat("STEP 6: SUMMARY REPORT\n")
cat("=======================================================================\n\n")

# Create summary report
summary_report <- list(
  analysis_date = Sys.Date(),
  n_hospitals = nrow(hospital_data),
  n_states = length(unique(hospital_data$state)),
  
  # Quality Score Statistics
  quality_stats = list(
    mean = round(mean(hospital_data$quality_score), 2),
    median = round(median(hospital_data$quality_score), 2),
    sd = round(sd(hospital_data$quality_score), 2),
    min = round(min(hospital_data$quality_score), 2),
    max = round(max(hospital_data$quality_score), 2)
  ),
  
  # Star Rating Distribution
  star_distribution = as.data.frame(table(hospital_data$star_rating)),
  
  # Performance Category Distribution
  category_distribution = as.data.frame(table(hospital_data$performance_category)),
  
  # Top 10 Hospitals
  top_10_hospitals = hospital_data %>%
    arrange(desc(quality_score)) %>%
    head(10) %>%
    select(hospital_name, city, state, quality_score, star_rating),
  
  # Worst 10 Hospitals
  worst_10_hospitals = hospital_data %>%
    arrange(quality_score) %>%
    head(10) %>%
    select(hospital_name, city, state, quality_score, star_rating),
  
  # Best Performing States
  best_states = state_summary %>%
    arrange(desc(avg_quality_score)) %>%
    head(10),
  
  # Clustering Results
  clustering_summary = list(
    n_clusters = N_CLUSTERS,
    kmeans_silhouette = round(clustering_results$kmeans$result$avg_silhouette, 3),
    hclust_silhouette = round(clustering_results$hierarchical$result$avg_silhouette, 3),
    variance_explained = round(
      clustering_results$kmeans$result$model$betweenss / 
      clustering_results$kmeans$result$model$totss * 100, 2
    )
  )
)

# Save summary report
saveRDS(summary_report, "outputs/summary_report.rds")
cat("Summary report saved to outputs/summary_report.rds\n")

# ==============================================================================
# Display Final Summary
# ==============================================================================
cat("\n")
cat("=======================================================================\n")
cat("ANALYSIS COMPLETE - FINAL SUMMARY\n")
cat("=======================================================================\n\n")

cat("📊 DATASET OVERVIEW\n")
cat("-------------------------------------------------------------------\n")
cat(paste("Total Hospitals Analyzed:", summary_report$n_hospitals, "\n"))
cat(paste("Number of States:", summary_report$n_states, "\n"))
cat(paste("Analysis Date:", summary_report$analysis_date, "\n\n"))

cat("📈 QUALITY SCORE STATISTICS\n")
cat("-------------------------------------------------------------------\n")
cat(paste("Mean Quality Score:", summary_report$quality_stats$mean, "\n"))
cat(paste("Median Quality Score:", summary_report$quality_stats$median, "\n"))
cat(paste("Standard Deviation:", summary_report$quality_stats$sd, "\n"))
cat(paste("Range:", summary_report$quality_stats$min, "-", 
          summary_report$quality_stats$max, "\n\n"))

cat("⭐ STAR RATING DISTRIBUTION\n")
cat("-------------------------------------------------------------------\n")
print(summary_report$star_distribution)
cat("\n")

cat("🏆 TOP 5 HOSPITALS NATIONALLY\n")
cat("-------------------------------------------------------------------\n")
print(head(summary_report$top_10_hospitals, 5), row.names = FALSE)
cat("\n")

cat("🔍 CLUSTERING RESULTS\n")
cat("-------------------------------------------------------------------\n")
cat(paste("Number of Clusters:", summary_report$clustering_summary$n_clusters, "\n"))
cat(paste("K-means Silhouette Score:", 
          summary_report$clustering_summary$kmeans_silhouette, "\n"))
cat(paste("Variance Explained:", 
          summary_report$clustering_summary$variance_explained, "%\n\n"))

cat("📁 OUTPUT FILES GENERATED\n")
cat("-------------------------------------------------------------------\n")
cat("Data Files:\n")
cat("  ✓ data/processed/hospital_data_clean.csv\n")
cat("  ✓ outputs/hospital_ratings.csv\n")
cat("  ✓ outputs/top_hospitals_national.csv\n")
cat("  ✓ outputs/worst_hospitals_national.csv\n")
cat("  ✓ outputs/top_hospitals_by_state.csv\n")
cat("  ✓ outputs/state_summary.csv\n")
cat("  ✓ outputs/cluster_summary_kmeans.csv\n")
cat("  ✓ outputs/cluster_summary_hierarchical.csv\n\n")

cat("Visualizations:\n")
cat("  ✓ outputs/plots/quality_score_distribution.png\n")
cat("  ✓ outputs/plots/star_rating_distribution.png\n")
cat("  ✓ outputs/plots/performance_categories.png\n")
cat("  ✓ outputs/plots/state_comparison.png\n")
cat("  ✓ outputs/plots/correlation_heatmap.png\n")
cat("  ✓ outputs/plots/metric_relationships.png\n")
cat("  ✓ outputs/plots/top_worst_hospitals.png\n")
cat("  ✓ outputs/plots/cluster_visualization_kmeans.png\n")
cat("  ✓ outputs/plots/cluster_visualization_hierarchical.png\n")
cat("  ✓ outputs/plots/elbow_plot.png\n")
cat("  ✓ outputs/plots/interactive_dashboard.html\n\n")

cat("=======================================================================\n")
cat("✅ ANALYSIS PIPELINE COMPLETED SUCCESSFULLY!\n")
cat("=======================================================================\n\n")

cat("📌 NEXT STEPS:\n")
cat("  1. Review outputs/hospital_ratings.csv for complete ratings\n")
cat("  2. Explore visualizations in outputs/plots/\n")
cat("  3. Open outputs/plots/interactive_dashboard.html for interactive analysis\n")
cat("  4. Review state_summary.csv for state-level insights\n")
cat("  5. Examine cluster_summary files for hospital groupings\n\n")

cat("💡 SKILLS DEMONSTRATED:\n")
cat("  ✓ Healthcare analytics with CMS data\n")
cat("  ✓ Data cleaning and merging\n")
cat("  ✓ Feature engineering\n")
cat("  ✓ K-means and hierarchical clustering\n")
cat("  ✓ Advanced data visualization\n")
cat("  ✓ Performance scoring methodology\n")
cat("  ✓ Statistical analysis in R\n\n")

# ==============================================================================
# Clean up
# ==============================================================================
message("Analysis complete! Check the outputs/ directory for all results.")
