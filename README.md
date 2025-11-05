# US Healthcare Hospital Performance Analysis

[![R](https://img.shields.io/badge/R-4.5.1-blue?logo=r)](https://www.r-project.org/)
[![Shiny](https://img.shields.io/badge/Shiny-Interactive%20Dashboard-blue?logo=r)](https://shiny.rstudio.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🌐 Live Interactive Dashboard

**🚀 [Try the Live Demo](https://bog67.shinyapps.io/hospital-performance-dashboard/)**

Explore 500 US hospitals with interactive visualizations, clustering analysis, and performance comparisons.

![Hospital Performance Dashboard](image.png)

## Project Overview
This project evaluates hospital quality metrics and patient outcomes using CMS Hospital Compare data. The analysis includes data cleaning, clustering, performance scoring, and interactive visualizations.

## Goals
- Clean and merge hospital datasets
- Analyze mortality, readmission, and infection rates
- Cluster hospitals by performance (k-means, hierarchical clustering)
- Create comprehensive performance scores
- Build hospital rating visualization dashboard

## Project Structure
```
Health/
├── data/                    # Data files
│   ├── raw/                # Raw CMS Hospital Compare data
│   └── processed/          # Cleaned and processed data
├── scripts/                # R analysis scripts
│   ├── 01_data_loading.R
│   ├── 02_data_cleaning.R
│   ├── 03_feature_engineering.R
│   ├── 04_clustering.R
│   ├── 05_visualization.R
│   └── 06_generate_sample_data.R
├── outputs/                # Analysis outputs
│   ├── plots/             # Visualizations
│   └── hospital_ratings.csv
├── main_analysis.R        # Master script
└── README.md
```

## Key Outputs
1. **Healthcare Quality Score**: Composite score for each hospital
2. **Top vs. Worst Hospitals by State**: Comparative rankings
3. **Performance Cluster Visualization**: Hospital groupings
4. **Interactive Dashboard**: Comprehensive performance metrics

## Skills Demonstrated
✔ Healthcare analytics  
✔ Clustering in R (k-means, hierarchical)  
✔ Data visualization (ggplot2, plotly)  
✔ Feature engineering  
✔ Statistical analysis  

## Dependencies
```r
# Install required packages
install.packages(c("tidyverse", "cluster", "factoextra", "plotly", 
                   "ggcorrplot", "scales", "RColorBrewer", "reshape2"))
```

## Usage

### Option 1: Use Sample Data (Recommended for Demo)
```r
# Generate sample data
source("scripts/06_generate_sample_data.R")

# Run complete analysis
source("main_analysis.R")
```

### Option 2: Use Real CMS Data
1. Download CMS Hospital Compare data from: https://data.cms.gov/provider-data/
2. Place files in `data/raw/` directory
3. Run the analysis:
```r
source("main_analysis.R")
```

## Key Metrics Analyzed
- **Mortality Rates**: 30-day death rates for major conditions
- **Readmission Rates**: 30-day unplanned hospital readmissions
- **Infection Rates**: Hospital-acquired infections (HAI)
- **Patient Experience**: HCAHPS survey scores
- **Timely & Effective Care**: Treatment quality measures

## Analysis Workflow
1. **Data Loading**: Import CMS Hospital Compare datasets
2. **Data Cleaning**: Handle missing values, outliers, standardization
3. **Feature Engineering**: Create composite quality score
4. **Clustering Analysis**: Group hospitals by performance patterns
5. **Visualization**: Generate comprehensive dashboard

## Results
Results are saved to:
- `outputs/hospital_ratings.csv` - Complete hospital ratings
- `outputs/plots/` - All visualization files
