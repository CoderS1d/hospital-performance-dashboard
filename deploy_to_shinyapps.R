# Quick Deployment Script for ShinyApps.io
# Run this script after configuring your ShinyApps.io account

# Load required packages
if (!require("rsconnect")) {
  install.packages("rsconnect")
  library(rsconnect)
}

# Instructions
cat("\n====================================\n")
cat("ShinyApps.io Deployment Script\n")
cat("====================================\n\n")

cat("BEFORE RUNNING THIS SCRIPT:\n")
cat("1. Create account at https://www.shinyapps.io/\n")
cat("2. Get your token from: https://www.shinyapps.io/admin/#/tokens\n")
cat("3. Run the rsconnect::setAccountInfo() command they provide\n\n")

cat("Example:\n")
cat("rsconnect::setAccountInfo(\n")
cat("  name='YOUR_USERNAME',\n")
cat("  token='YOUR_TOKEN',\n")
cat("  secret='YOUR_SECRET'\n")
cat(")\n\n")

# Check if account is configured
accounts <- rsconnect::accounts()

if (nrow(accounts) == 0) {
  cat("❌ ERROR: No ShinyApps.io account configured!\n\n")
  cat("Please run:\n")
  cat("1. Go to https://www.shinyapps.io/admin/#/tokens\n")
  cat("2. Copy your token command\n")
  cat("3. Run it in R Console\n")
  cat("4. Then run this script again\n\n")
  stop("Account configuration required")
} else {
  cat("✅ Account configured:", accounts$name[1], "\n\n")
}

# Set working directory
project_dir <- "d:/Project/R/Health"
if (!dir.exists(project_dir)) {
  stop("Project directory not found: ", project_dir)
}
setwd(project_dir)
cat("📁 Working directory:", getwd(), "\n\n")

# Verify required files exist
required_files <- c(
  "app.R",
  "outputs/hospital_ratings.csv",
  "outputs/state_summary.csv"
)

cat("Checking required files...\n")
missing_files <- c()
for (file in required_files) {
  if (file.exists(file)) {
    cat("  ✅", file, "\n")
  } else {
    cat("  ❌", file, "NOT FOUND\n")
    missing_files <- c(missing_files, file)
  }
}

if (length(missing_files) > 0) {
  cat("\n❌ ERROR: Missing required files!\n")
  cat("Please ensure these files exist:\n")
  for (file in missing_files) {
    cat("  -", file, "\n")
  }
  stop("Missing files")
}

cat("\n====================================\n")
cat("Ready to Deploy!\n")
cat("====================================\n\n")

# Ask for confirmation
cat("This will deploy your app to ShinyApps.io\n")
cat("App name: hospital-performance-dashboard\n")
cat("Account:", accounts$name[1], "\n\n")

response <- readline(prompt = "Continue with deployment? (yes/no): ")

if (tolower(response) != "yes") {
  cat("\nDeployment cancelled.\n")
  stop("User cancelled deployment")
}

cat("\n🚀 Starting deployment...\n\n")

# Deploy the app
tryCatch({
  rsconnect::deployApp(
    appName = "hospital-performance-dashboard",
    appTitle = "US Hospital Performance Dashboard",
    appFiles = c(
      "app.R",
      "outputs/hospital_ratings.csv",
      "outputs/state_summary.csv"
    ),
    launch.browser = TRUE,
    forceUpdate = FALSE
  )
  
  cat("\n====================================\n")
  cat("✅ DEPLOYMENT SUCCESSFUL!\n")
  cat("====================================\n\n")
  
  app_url <- paste0("https://", accounts$name[1], ".shinyapps.io/hospital-performance-dashboard/")
  cat("Your app is live at:\n")
  cat(app_url, "\n\n")
  
  cat("Next steps:\n")
  cat("1. Test your app in the browser\n")
  cat("2. Add the URL to your GitHub README\n")
  cat("3. Share on LinkedIn/portfolio\n\n")
  
  cat("To update your app later, run this script again.\n")
  
}, error = function(e) {
  cat("\n❌ DEPLOYMENT FAILED!\n\n")
  cat("Error message:\n")
  cat(conditionMessage(e), "\n\n")
  
  cat("Troubleshooting:\n")
  cat("1. Check your internet connection\n")
  cat("2. Verify account is configured: rsconnect::accounts()\n")
  cat("3. Try manual deployment:\n")
  cat("   rsconnect::deployApp(appName = 'hospital-performance-dashboard')\n")
  cat("4. View logs: rsconnect::showLogs()\n\n")
  
  stop(e)
})
