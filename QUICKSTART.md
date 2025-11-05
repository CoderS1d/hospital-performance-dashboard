# US Healthcare Hospital Performance Analysis
## Quick Start Guide

### 🚀 Getting Started in 3 Steps

#### Step 1: Install Required Packages
Open R or RStudio and run:
```r
source("install_packages.R")
```

This will automatically install all required packages:
- tidyverse (data manipulation & visualization)
- cluster (clustering algorithms)
- factoextra (clustering visualization)
- plotly (interactive plots)
- ggcorrplot (correlation heatmaps)
- scales, RColorBrewer, patchwork, htmlwidgets

#### Step 2: Run the Complete Analysis
```r
source("main_analysis.R")
```

This master script will automatically:
1. ✅ Generate sample CMS Hospital Compare data (500 hospitals)
2. ✅ Clean and merge datasets
3. ✅ Calculate healthcare quality scores
4. ✅ Perform clustering analysis (K-means & Hierarchical)
5. ✅ Create comprehensive visualizations
6. ✅ Generate summary reports

**Runtime:** Approximately 2-5 minutes depending on your system

#### Step 3: Explore the Results
Navigate to the `outputs/` folder to find:

**📊 Data Files:**
- `hospital_ratings.csv` - Complete hospital ratings with quality scores
- `top_hospitals_national.csv` - Top 10 hospitals
- `state_summary.csv` - State-level performance metrics
- `cluster_summary_*.csv` - Cluster characteristics

**📈 Visualizations (`outputs/plots/`):**
- `quality_score_distribution.png` - Score distribution histogram
- `star_rating_distribution.png` - 5-star rating breakdown
- `state_comparison.png` - Top states by quality
- `correlation_heatmap.png` - Metric correlations
- `cluster_visualization_*.png` - Hospital clusters
- `interactive_dashboard.html` - **Interactive 3D visualization**

### 📂 Project Structure
```
Health/
├── data/
│   ├── raw/              # Generated sample data
│   └── processed/        # Cleaned datasets
├── scripts/
│   ├── 01_data_loading.R
│   ├── 02_data_cleaning.R
│   ├── 03_feature_engineering.R
│   ├── 04_clustering.R
│   ├── 05_visualization.R
│   └── 06_generate_sample_data.R
├── outputs/
│   ├── plots/            # All visualizations
│   └── *.csv             # Analysis results
├── main_analysis.R       # ⭐ RUN THIS
├── install_packages.R
└── README.md
```

### 🎯 Key Outputs Explained

#### 1. Healthcare Quality Score (0-100)
Composite metric calculated from:
- **Mortality Rate** (30%) - Death rates for major conditions
- **Readmission Rate** (25%) - 30-day unplanned readmissions
- **Infection Rate** (25%) - Hospital-acquired infections
- **Patient Experience** (20%) - HCAHPS survey scores

#### 2. Star Rating (1-5 stars)
- ⭐⭐⭐⭐⭐ (5 stars): Quality Score ≥ 80 (Excellent)
- ⭐⭐⭐⭐ (4 stars): Quality Score 65-79 (Above Average)
- ⭐⭐⭐ (3 stars): Quality Score 50-64 (Average)
- ⭐⭐ (2 stars): Quality Score 35-49 (Below Average)
- ⭐ (1 star): Quality Score < 35 (Poor)

#### 3. Performance Clusters
Hospitals are grouped into 4 clusters based on performance patterns:
- **High Performers** - Consistently excellent across all metrics
- **Above Average** - Good overall performance
- **Below Average** - Room for improvement
- **Needs Improvement** - Significant quality issues

### 🔧 Using Real CMS Data

To analyze real CMS Hospital Compare data:

1. Download data from: https://data.cms.gov/provider-data/
   - Hospital General Information
   - Complications and Deaths
   - Unplanned Hospital Visits
   - Healthcare Associated Infections
   - Patient Experience (HCAHPS)

2. Place CSV files in `data/raw/` directory

3. Open `main_analysis.R` and change:
   ```r
   USE_SAMPLE_DATA <- FALSE  # Line 34
   ```

4. Run the analysis:
   ```r
   source("main_analysis.R")
   ```

### 🛠️ Customization

#### Adjust Clustering Parameters
In `main_analysis.R`:
```r
N_CLUSTERS <- 4  # Change to 3, 5, or 6 clusters
```

#### Modify Quality Score Weights
In `scripts/03_feature_engineering.R`, function `calculate_quality_score()`:
```r
weights <- list(
  mortality = 0.30,      # Adjust these weights
  readmission = 0.25,
  infection = 0.25,
  patient_exp = 0.20
)
```

#### Generate More Hospitals
In `scripts/06_generate_sample_data.R`:
```r
N_HOSPITALS <- 1000  # Generate more sample data
```

### 📊 Sample Analysis Insights

After running the analysis, you'll discover:

✅ **National Rankings**: Which hospitals have the highest quality scores  
✅ **State Comparisons**: Best and worst performing states  
✅ **Metric Correlations**: How mortality, readmissions, and infections relate  
✅ **Cluster Patterns**: Natural groupings of hospitals by performance  
✅ **Performance Distribution**: How hospitals spread across quality categories  

### 🎓 Skills Demonstrated

This project showcases:
- ✔️ **Healthcare Analytics**: CMS data analysis
- ✔️ **Data Wrangling**: Cleaning, merging, handling missing values
- ✔️ **Feature Engineering**: Creating composite scores
- ✔️ **Clustering**: K-means & hierarchical clustering
- ✔️ **Statistical Analysis**: Correlation, normalization, outlier detection
- ✔️ **Data Visualization**: ggplot2, plotly, interactive dashboards
- ✔️ **R Programming**: Modular, well-documented code

### 🐛 Troubleshooting

**Issue: Package installation fails**
```r
# Try installing packages individually
install.packages("tidyverse")
install.packages("cluster")
# ... etc
```

**Issue: "File not found" error**
- Ensure you're running scripts from the project root directory
- Check that `data/raw/` folder exists

**Issue: Out of memory**
- Reduce the number of hospitals in sample data
- Close other applications

### 📧 Support

For questions or issues with this analysis:
1. Check that all packages are installed correctly
2. Verify R version is 4.0 or higher
3. Ensure working directory is set to project root

### 🎉 Success!

If you see this message, you're ready to go:
```
✅ ANALYSIS PIPELINE COMPLETED SUCCESSFULLY!
```

Open `outputs/plots/interactive_dashboard.html` in your browser to explore the results interactively!

---

**Created:** November 2025  
**R Version:** 4.0+  
**Analysis Time:** ~2-5 minutes  
**Output Files:** 18 files (10 visualizations + 8 data files)
