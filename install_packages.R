# ==============================================================================
# install_packages.R
# Install Required Packages for Hospital Performance Analysis
# ==============================================================================

cat("=======================================================================\n")
cat("  INSTALLING REQUIRED PACKAGES\n")
cat("=======================================================================\n\n")

# List of required packages
required_packages <- c(
  "tidyverse",      # Data manipulation and visualization (includes ggplot2, dplyr, tidyr, etc.)
  "cluster",        # Clustering algorithms
  "factoextra",     # Enhanced clustering visualization
  "plotly",         # Interactive plots
  "ggcorrplot",     # Correlation heatmaps
  "scales",         # Scale functions for visualization
  "RColorBrewer",   # Color palettes
  "patchwork",      # Combine ggplot2 plots
  "htmlwidgets"     # Save interactive plots
)

cat("Packages to be installed:\n")
for (pkg in required_packages) {
  cat(paste("  -", pkg, "\n"))
}
cat("\n")

# Check which packages are already installed
installed <- installed.packages()[, "Package"]
new_packages <- required_packages[!(required_packages %in% installed)]

if (length(new_packages) == 0) {
  cat("✓ All required packages are already installed!\n\n")
} else {
  cat(paste("Installing", length(new_packages), "new packages...\n\n"))
  
  # Install missing packages
  for (pkg in new_packages) {
    cat(paste("Installing", pkg, "..."))
    tryCatch({
      install.packages(pkg, repos = "http://cran.us.r-project.org", dependencies = TRUE)
      cat(" ✓\n")
    }, error = function(e) {
      cat(" ✗ FAILED\n")
      cat(paste("  Error:", e$message, "\n"))
    })
  }
}

cat("\n=======================================================================\n")
cat("  VERIFYING INSTALLATION\n")
cat("=======================================================================\n\n")

# Verify all packages can be loaded
all_success <- TRUE
for (pkg in required_packages) {
  cat(paste("Checking", pkg, "..."))
  result <- tryCatch({
    library(pkg, character.only = TRUE, quietly = TRUE)
    cat(" ✓\n")
    TRUE
  }, error = function(e) {
    cat(" ✗ FAILED\n")
    FALSE
  })
  all_success <- all_success && result
}

cat("\n=======================================================================\n")
if (all_success) {
  cat("✅ ALL PACKAGES INSTALLED AND VERIFIED SUCCESSFULLY!\n")
  cat("=======================================================================\n\n")
  cat("You can now run the analysis:\n")
  cat("  source('main_analysis.R')\n\n")
} else {
  cat("⚠️  SOME PACKAGES FAILED TO INSTALL\n")
  cat("=======================================================================\n\n")
  cat("Please install failed packages manually:\n")
  cat("  install.packages('package_name')\n\n")
}

# Display R and package versions
cat("\n=======================================================================\n")
cat("  SYSTEM INFORMATION\n")
cat("=======================================================================\n\n")
cat(paste("R Version:", R.version.string, "\n"))
cat(paste("Platform:", R.version$platform, "\n"))
cat("\nInstalled Package Versions:\n")
for (pkg in required_packages) {
  if (pkg %in% installed) {
    version <- packageVersion(pkg)
    cat(paste("  ", pkg, ":", version, "\n"))
  }
}
cat("\n")
