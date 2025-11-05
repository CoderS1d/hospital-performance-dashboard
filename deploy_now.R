# Deploy Hospital Performance Dashboard to ShinyApps.io
library(rsconnect)

cat("\n====================================\n")
cat("🚀 Deploying Hospital Dashboard\n")
cat("====================================\n\n")

# Set working directory
setwd("d:/Project/R/Health")
cat("📁 Working directory:", getwd(), "\n\n")

# Verify files
cat("Checking required files...\n")
if (file.exists("app.R")) cat("  ✅ app.R\n") else stop("❌ app.R not found")
if (file.exists("outputs/hospital_ratings.csv")) cat("  ✅ outputs/hospital_ratings.csv\n") else stop("❌ Data file not found")
if (file.exists("outputs/state_summary.csv")) cat("  ✅ outputs/state_summary.csv\n") else stop("❌ State summary not found")

cat("\n🚀 Starting deployment to ShinyApps.io...\n")
cat("Account: bog67\n")
cat("App name: hospital-performance-dashboard\n\n")

# Deploy
deployApp(
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

cat("🌐 Your app is live at:\n")
cat("https://bog67.shinyapps.io/hospital-performance-dashboard/\n\n")

cat("Next steps:\n")
cat("1. Test your app in the browser\n")
cat("2. Add the URL to your GitHub README\n")
cat("3. Share on LinkedIn/portfolio\n")
