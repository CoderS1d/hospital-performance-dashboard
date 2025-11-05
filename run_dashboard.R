# ==============================================================================
# run_dashboard.R
# Quick script to launch the interactive dashboard
# ==============================================================================

cat("\n")
cat("========================================================================\n")
cat("  HOSPITAL PERFORMANCE DASHBOARD - QUICK LAUNCHER\n")
cat("========================================================================\n\n")

# Check if data exists
if (!file.exists("outputs/hospital_ratings.csv")) {
  cat("❌ ERROR: Data not found!\n\n")
  cat("Please run the main analysis first:\n")
  cat("  source('main_analysis.R')\n\n")
  stop("Data files not found. Run main_analysis.R first.")
}

cat("✓ Data files found\n")
cat("✓ Launching interactive dashboard...\n\n")

# Run the dashboard
source("interactive_dashboard.R")
