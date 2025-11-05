# Deploy to ShinyApps.io - Complete Guide

## 📦 Deployment Files Created

Your app is ready to deploy with these files:
- `app.R` - Main Shiny app (required for shinyapps.io)
- `outputs/hospital_ratings.csv` - Hospital data
- `outputs/state_summary.csv` - State summary data

---

## 🚀 Step-by-Step Deployment Guide

### Step 1: Create ShinyApps.io Account

1. Go to https://www.shinyapps.io/
2. Click "Sign Up" (free tier available)
3. Choose a username (this will be in your app URL)
4. Verify your email

### Step 2: Install Required Packages in R

```r
# Install rsconnect package
install.packages("rsconnect")

# Install all app dependencies
install.packages(c("shiny", "shinydashboard", "DT", "plotly", "tidyverse"))
```

### Step 3: Configure ShinyApps.io Connection

1. Log into https://www.shinyapps.io/
2. Click your name (top right) → Tokens
3. Click "Show" for your token
4. Copy the command shown (it looks like this):

```r
rsconnect::setAccountInfo(
  name='YOUR_USERNAME',
  token='YOUR_TOKEN',
  secret='YOUR_SECRET'
)
```

5. Run this command in R Console

### Step 4: Deploy Your App

In RStudio or R Console, run:

```r
library(rsconnect)

# Set working directory to your project folder
setwd("d:/Project/R/Health")

# Deploy the app
deployApp(
  appName = "hospital-performance-dashboard",
  appTitle = "US Hospital Performance Dashboard",
  appFiles = c(
    "app.R",
    "outputs/hospital_ratings.csv",
    "outputs/state_summary.csv"
  )
)
```

**Deployment will take 2-5 minutes.**

### Step 5: Access Your Deployed App

Your app will be available at:
```
https://YOUR_USERNAME.shinyapps.io/hospital-performance-dashboard/
```

---

## 🔧 Alternative: Deploy from RStudio

### Method 1: Click-to-Deploy

1. Open `app.R` in RStudio
2. Click the **"Publish"** button (top right of editor)
3. Choose "ShinyApps.io"
4. Select files to include:
   - ✅ app.R
   - ✅ outputs/hospital_ratings.csv
   - ✅ outputs/state_summary.csv
5. Click "Publish"

### Method 2: Using Terminal

```r
# In R Console
source("deployment/deploy_script.R")
```

---

## 📁 File Structure for Deployment

```
Your_App_Folder/
├── app.R                           # Main app file (REQUIRED)
├── outputs/
│   ├── hospital_ratings.csv        # Data file (REQUIRED)
│   └── state_summary.csv           # Data file (REQUIRED)
└── rsconnect/                      # Auto-generated deployment info
```

---

## 🌐 GitHub Integration

### Add to GitHub Repository

1. **Create .gitignore** (to exclude sensitive files):

```gitignore
# R specific
.Rproj.user
.Rhistory
.RData
.Ruserdata

# Deployment
rsconnect/

# Output plots (optional, can be large)
outputs/plots/*.png
outputs/plots/*.html

# Data (optional if you want to keep it private)
# Uncomment if using private data:
# data/raw/*.csv
# data/processed/*.csv
```

2. **Initialize Git Repository**:

```bash
cd "d:/Project/R/Health"
git init
git add .
git commit -m "Initial commit: Hospital Performance Dashboard"
```

3. **Create GitHub Repository**:
   - Go to https://github.com/new
   - Name: `hospital-performance-dashboard`
   - Description: "Interactive R Shiny dashboard analyzing US hospital performance metrics"
   - Make it Public
   - Don't initialize with README (you have one)

4. **Push to GitHub**:

```bash
git remote add origin https://github.com/YOUR_USERNAME/hospital-performance-dashboard.git
git branch -M main
git push -u origin main
```

---

## 📝 Update GitHub README

Add this badge to your README.md to link to the live app:

```markdown
## 🌐 Live Demo

[![ShinyApps.io](https://img.shields.io/badge/Shiny-Live%20Demo-blue?logo=r)](https://YOUR_USERNAME.shinyapps.io/hospital-performance-dashboard/)

**Try the live dashboard:** [https://YOUR_USERNAME.shinyapps.io/hospital-performance-dashboard/](https://YOUR_USERNAME.shinyapps.io/hospital-performance-dashboard/)
```

---

## ⚙️ ShinyApps.io Settings

### Free Tier Limits:
- 5 applications
- 25 active hours per month
- 1 GB RAM per app
- 1 concurrent user per app

### Upgrade Options:
If you need more resources, consider:
- **Starter** ($9/month): 500 hours, 2 concurrent users
- **Basic** ($39/month): Unlimited hours, 5 concurrent users
- **Standard** ($99/month): Professional features

---

## 🔒 Security Best Practices

### 1. Don't Commit Secrets
Never commit your ShinyApps.io tokens to GitHub:

```r
# ❌ DON'T do this in public repos
rsconnect::setAccountInfo(name='myname', token='12345', secret='abc')

# ✅ DO keep tokens in .Renviron or local scripts
```

### 2. Data Privacy
If using real patient data:
- Use synthetic/anonymized data for public deployment
- Keep sensitive data local
- Add data files to .gitignore

---

## 🐛 Troubleshooting

### Error: "Package not found"
**Solution:** Ensure all packages are listed in your deployment

```r
deployApp(
  appName = "hospital-performance-dashboard",
  appFiles = c("app.R", "outputs/hospital_ratings.csv", "outputs/state_summary.csv"),
  launch.browser = FALSE
)
```

### Error: "Data file not found"
**Solution:** Check file paths are relative, not absolute

```r
# ✅ CORRECT
read_csv("outputs/hospital_ratings.csv")

# ❌ WRONG
read_csv("d:/Project/R/Health/outputs/hospital_ratings.csv")
```

### Error: "App disconnects"
**Solution:** App may be exceeding free tier limits
- Optimize data size
- Reduce plot complexity
- Consider upgrading plan

### Error: "Deployment failed"
**Solution:** Check logs

```r
# View deployment logs
rsconnect::showLogs()
```

---

## 📊 Monitor Your App

### View App Analytics:
1. Go to https://www.shinyapps.io/admin/#/dashboard
2. Click on your app
3. View:
   - Active hours used
   - Number of visitors
   - Memory usage
   - Logs

### Update Your App:

```r
# After making changes to app.R
rsconnect::deployApp(appName = "hospital-performance-dashboard")
```

---

## 🎯 Quick Deployment Checklist

- [ ] ShinyApps.io account created
- [ ] `rsconnect` package installed
- [ ] Account configured with token
- [ ] `app.R` file created
- [ ] Data files in `outputs/` folder
- [ ] All required packages installed
- [ ] Tested app locally
- [ ] Deployed using `deployApp()`
- [ ] Verified app works online
- [ ] Added live demo link to GitHub
- [ ] Updated README with deployment info

---

## 🌟 Next Steps After Deployment

1. **Share your app:**
   - Add link to your resume/portfolio
   - Share on LinkedIn
   - Include in job applications

2. **Customize domain (paid plans):**
   - Use custom domain instead of shinyapps.io
   - Example: `dashboard.yourname.com`

3. **Add Google Analytics:**
   - Track visitor statistics
   - Monitor usage patterns

4. **Set up monitoring:**
   - Get email alerts if app goes down
   - Monitor performance metrics

---

## 💡 Pro Tips

1. **Test locally first:**
   ```r
   shiny::runApp("app.R")
   ```

2. **Keep app lightweight:**
   - Use sample data for demo
   - Optimize large datasets
   - Cache expensive computations

3. **Use meaningful app name:**
   - Lowercase, hyphens only
   - Descriptive and professional
   - Example: `hospital-quality-dashboard`

4. **Document well:**
   - Add "About" tab in app
   - Clear instructions
   - Data source citations

---

## 📧 Support

- **ShinyApps.io Docs:** https://docs.rstudio.com/shinyapps.io/
- **Shiny Tutorial:** https://shiny.rstudio.com/tutorial/
- **Community Forum:** https://community.rstudio.com/

---

**Your app is ready to deploy! 🚀**

Run this command to deploy:

```r
library(rsconnect)
setwd("d:/Project/R/Health")
deployApp(appName = "hospital-performance-dashboard")
```
