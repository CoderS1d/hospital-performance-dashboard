# Hospital Performance Analysis Methodology

## Overview
This document details the analytical methodology used in the US Healthcare Hospital Performance Analysis project.

---

## 1. Data Sources

### CMS Hospital Compare Dataset
The Centers for Medicare & Medicaid Services (CMS) Hospital Compare dataset provides publicly available data on hospital quality metrics.

**Key Data Components:**
1. **Hospital General Information**
   - Facility ID, Name, Location
   - Hospital Type, Ownership
   
2. **Complications and Deaths**
   - 30-day mortality rates for major conditions
   - Heart attack, heart failure, pneumonia, COPD, stroke, CABG
   
3. **Readmissions**
   - 30-day unplanned hospital readmissions
   - Various medical conditions and procedures
   
4. **Healthcare-Associated Infections (HAI)**
   - CLABSI, CAUTI, SSI, MRSA, C.diff
   - Standardized Infection Ratios (SIR)
   
5. **Patient Experience (HCAHPS)**
   - Hospital Consumer Assessment of Healthcare Providers and Systems
   - Patient satisfaction scores

---

## 2. Data Cleaning Process

### 2.1 Missing Value Treatment
**Strategy:** Median imputation for numeric variables
- Preserves distribution properties
- Robust to outliers
- Appropriate for healthcare metrics

**Implementation:**
```r
median_val <- median(column, na.rm = TRUE)
column[is.na(column)] <- median_val
```

### 2.2 Outlier Detection and Removal
**Method:** Interquartile Range (IQR)
- Lower Bound = Q1 - 3×IQR
- Upper Bound = Q3 + 3×IQR
- Multiplier of 3 used to retain most data while removing extreme outliers

**Rationale:**
- Healthcare data often has legitimate variation
- Conservative approach preserves true variation
- Removes only extreme measurement errors

### 2.3 Data Standardization
**Approach:** Z-score normalization for clustering
```r
standardized = (x - mean(x)) / sd(x)
```

**Benefits:**
- Equal weight to all features
- Necessary for distance-based clustering
- Facilitates comparison across different scales

---

## 3. Feature Engineering

### 3.1 Score Normalization
**Method:** Min-Max Scaling (0-100)
```r
normalized = (x - min(x)) / (max(x) - min(x)) × 100
```

**Inverse Normalization:** Applied to metrics where lower is better
```r
inverse_normalized = 100 - normalized
```

**Metrics Requiring Inversion:**
- Mortality rates (lower is better)
- Readmission rates (lower is better)
- Infection rates (lower is better)

**Metrics with Standard Normalization:**
- Patient experience scores (higher is better)

### 3.2 Composite Quality Score

**Formula:**
```
Quality Score = (Mortality × 0.30) + (Readmission × 0.25) + 
                (Infection × 0.25) + (Patient Experience × 0.20)
```

**Weight Justification:**

| Metric | Weight | Rationale |
|--------|--------|-----------|
| Mortality | 30% | Most critical outcome measure; direct patient safety impact |
| Readmission | 25% | Indicates quality of care and discharge planning |
| Infection | 25% | Preventable adverse events; reflects safety culture |
| Patient Experience | 20% | Important for overall care quality; patient-centered care |

**Validation:**
- Weights sum to 1.0 (100%)
- Based on healthcare quality literature
- Aligned with CMS priority measures

### 3.3 Star Rating System

**Categories:**
| Stars | Quality Score Range | Label |
|-------|-------------------|-------|
| 5 ⭐⭐⭐⭐⭐ | 80-100 | Excellent |
| 4 ⭐⭐⭐⭐ | 65-79 | Above Average |
| 3 ⭐⭐⭐ | 50-64 | Average |
| 2 ⭐⭐ | 35-49 | Below Average |
| 1 ⭐ | 0-34 | Poor |

**Methodology:**
- Percentile-based thresholds
- Aligned with CMS 5-star rating approach
- Interpretable for stakeholders

### 3.4 Ranking Metrics

**State-Level Rankings:**
- Rank within state (ascending)
- State percentile (0-100)

**National Rankings:**
- Rank nationally (ascending)
- National percentile (0-100)

---

## 4. Clustering Analysis

### 4.1 Algorithm Selection

**K-means Clustering**
- **Type:** Partitional clustering
- **Distance Metric:** Euclidean
- **Initialization:** K-means++ (nstart=25)
- **Convergence:** Maximum 100 iterations

**Advantages:**
- Fast and scalable
- Clear cluster assignments
- Interpretable centroids

**Hierarchical Clustering**
- **Type:** Agglomerative
- **Linkage Method:** Ward's method (ward.D2)
- **Distance Metric:** Euclidean

**Advantages:**
- No need to specify k upfront
- Produces dendrogram
- Captures hierarchical structure

### 4.2 Optimal Cluster Selection

**Elbow Method:**
```r
Within-cluster SS = Σ(distance from point to centroid)²
```
- Plot Total WSS vs k
- Look for "elbow" point where WSS decrease slows

**Silhouette Analysis:**
```r
Silhouette Score = (b - a) / max(a, b)
```
where:
- a = average distance to points in same cluster
- b = average distance to points in nearest cluster

**Interpretation:**
- Score > 0.7: Strong structure
- Score > 0.5: Reasonable structure
- Score < 0.25: No substantial structure

### 4.3 Cluster Characterization

**Methodology:**
1. Calculate mean values for each metric per cluster
2. Rank clusters by average quality score
3. Assign descriptive labels based on performance

**Cluster Labels:**
- High Performers: Top 25% by quality score
- Above Average: 50-75th percentile
- Below Average: 25-50th percentile
- Needs Improvement: Bottom 25%

---

## 5. Validation and Quality Checks

### 5.1 Data Quality Metrics
- **Completeness:** % of non-missing values
- **Consistency:** Cross-field validation
- **Accuracy:** Range checks and logical constraints

### 5.2 Model Validation
- **Silhouette Score:** Cluster quality
- **Variance Explained:** Between-cluster variance / Total variance
- **Cluster Size:** Ensure balanced clusters (>5% of data each)

### 5.3 Sensitivity Analysis
- **Weight Variation:** Test different quality score weights
- **Cluster Count:** Test k=3 to k=6
- **Outlier Threshold:** Test multipliers 1.5, 2, 3

---

## 6. Visualization Strategy

### 6.1 Univariate Analysis
- **Histograms:** Distribution of quality scores
- **Bar Charts:** Categorical distributions (stars, categories)

### 6.2 Bivariate Analysis
- **Scatter Plots:** Relationships between metrics
- **Box Plots:** Distributions by category
- **Correlation Heatmap:** Linear relationships

### 6.3 Multivariate Analysis
- **PCA Visualization:** 2D projection of high-dimensional data
- **3D Scatter Plots:** Interactive exploration (Plotly)
- **Cluster Plots:** Spatial distribution of clusters

### 6.4 Comparative Analysis
- **State Rankings:** Horizontal bar charts
- **Top/Bottom Hospitals:** Comparative bar charts
- **Temporal Trends:** Line plots (if multiple time periods)

---

## 7. Statistical Considerations

### 7.1 Assumptions
- **Independence:** Hospitals are independent units
- **Measurement Error:** Assumed minimal in CMS data
- **Temporal Stability:** Scores reflect current period

### 7.2 Limitations
- **Sample Bias:** Only hospitals reporting to CMS
- **Risk Adjustment:** Limited patient risk adjustment
- **Composite Scores:** May obscure specific weaknesses
- **Temporal Lag:** Data may be 6-12 months old

### 7.3 Ethical Considerations
- **Transparency:** Methodology fully documented
- **Fairness:** Equal treatment of all hospitals
- **Privacy:** No patient-level data used
- **Interpretation:** Scores should inform, not solely determine decisions

---

## 8. Interpretation Guidelines

### 8.1 Quality Scores
- **Absolute Interpretation:** Compare to national benchmarks
- **Relative Interpretation:** Compare to peer hospitals
- **Trend Analysis:** Monitor changes over time

### 8.2 Cluster Membership
- **Descriptive:** Identifies similar hospitals
- **Not Prescriptive:** Cluster labels are simplified
- **Context Matters:** Consider hospital type, size, location

### 8.3 Rankings
- **Small Differences:** Ranks close together may not be meaningful
- **Confidence Intervals:** Consider uncertainty in measures
- **Multiple Factors:** Rankings based on available metrics only

---

## 9. Reproducibility

### 9.1 Random Seed
```r
set.seed(123)
```
Ensures reproducible results across runs

### 9.2 Package Versions
Document all package versions used:
```r
sessionInfo()
```

### 9.3 Data Versioning
- Date of data download
- Source URL
- File checksums (if available)

---

## 10. Future Enhancements

### 10.1 Potential Improvements
1. **Risk Adjustment:** Incorporate patient case-mix
2. **Temporal Analysis:** Track performance over time
3. **Geographic Clustering:** Spatial analysis
4. **Predictive Modeling:** Forecast future performance
5. **Benchmarking:** Compare to evidence-based targets

### 10.2 Additional Data Sources
- **Cost Data:** Value-based care analysis
- **Volume Data:** Procedure volume relationships
- **Structural Data:** Staffing, technology, facilities
- **Social Determinants:** Community health factors

---

## References

1. Centers for Medicare & Medicaid Services. (2024). Hospital Compare Data.  
   https://data.cms.gov/provider-data/

2. Agency for Healthcare Research and Quality. Quality Indicators.  
   https://www.qualityindicators.ahrq.gov/

3. The Joint Commission. National Quality Measures.  
   https://www.jointcommission.org/measurement/measures/

4. Kaufman, L., & Rousseeuw, P. J. (2009). Finding Groups in Data: An Introduction to Cluster Analysis.

5. James, G., Witten, D., Hastie, T., & Tibshirani, R. (2013). An Introduction to Statistical Learning.

---

**Document Version:** 1.0  
**Last Updated:** November 2025  
**Author:** Healthcare Analytics Team
