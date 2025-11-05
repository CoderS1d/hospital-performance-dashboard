# ==============================================================================
# 05_visualization.R
# Create Hospital Performance Visualization Dashboard
# ==============================================================================

library(tidyverse)
library(plotly)
library(scales)
library(RColorBrewer)
library(ggcorrplot)
library(patchwork)

# Ensure output directory exists
if (!dir.exists("outputs/plots")) {
  dir.create("outputs/plots", recursive = TRUE)
}

# ==============================================================================
# Function: Create Quality Score Distribution Plot
# ==============================================================================
plot_quality_distribution <- function(data) {
  message("Creating quality score distribution plot...")
  
  p <- ggplot(data, aes(x = quality_score)) +
    geom_histogram(aes(y = ..density..), bins = 30, fill = "steelblue", 
                   alpha = 0.7, color = "black") +
    geom_density(color = "red", size = 1.2) +
    geom_vline(aes(xintercept = mean(quality_score)), 
               color = "darkgreen", linetype = "dashed", size = 1) +
    geom_vline(aes(xintercept = median(quality_score)), 
               color = "orange", linetype = "dashed", size = 1) +
    labs(
      title = "Distribution of Hospital Quality Scores",
      subtitle = paste("Mean:", round(mean(data$quality_score), 2), 
                      "| Median:", round(median(data$quality_score), 2)),
      x = "Quality Score (0-100)",
      y = "Density"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold"),
      plot.subtitle = element_text(size = 12)
    )
  
  ggsave("outputs/plots/quality_score_distribution.png", p, 
         width = 12, height = 8, dpi = 300)
  message("Saved: outputs/plots/quality_score_distribution.png")
  
  return(p)
}

# ==============================================================================
# Function: Create Star Rating Distribution Plot
# ==============================================================================
plot_star_ratings <- function(data) {
  message("Creating star rating distribution plot...")
  
  rating_counts <- data %>%
    count(star_rating) %>%
    mutate(percentage = n / sum(n) * 100)
  
  p <- ggplot(rating_counts, aes(x = factor(star_rating), y = n, fill = factor(star_rating))) +
    geom_bar(stat = "identity", color = "black") +
    geom_text(aes(label = paste0(n, "\n(", round(percentage, 1), "%)")), 
              vjust = -0.5, size = 4, fontface = "bold") +
    scale_fill_manual(
      values = c("1" = "#d73027", "2" = "#fc8d59", "3" = "#fee090", 
                 "4" = "#91bfdb", "5" = "#4575b4")
    ) +
    labs(
      title = "Hospital Star Rating Distribution",
      subtitle = "Based on Composite Quality Score",
      x = "Star Rating",
      y = "Number of Hospitals",
      fill = "Stars"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold"),
      legend.position = "none",
      axis.text.x = element_text(size = 12, face = "bold")
    )
  
  ggsave("outputs/plots/star_rating_distribution.png", p, 
         width = 12, height = 8, dpi = 300)
  message("Saved: outputs/plots/star_rating_distribution.png")
  
  return(p)
}

# ==============================================================================
# Function: Create Performance Category Plot
# ==============================================================================
plot_performance_categories <- function(data) {
  message("Creating performance category plot...")
  
  category_counts <- data %>%
    count(performance_category) %>%
    mutate(percentage = n / sum(n) * 100)
  
  p <- ggplot(category_counts, aes(x = performance_category, y = n, 
                                    fill = performance_category)) +
    geom_bar(stat = "identity", color = "black") +
    geom_text(aes(label = paste0(n, "\n(", round(percentage, 1), "%)")), 
              vjust = -0.5, size = 4, fontface = "bold") +
    scale_fill_brewer(palette = "RdYlGn", direction = 1) +
    labs(
      title = "Hospital Performance Category Distribution",
      x = "Performance Category",
      y = "Number of Hospitals"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold"),
      legend.position = "none",
      axis.text.x = element_text(angle = 45, hjust = 1, size = 11)
    )
  
  ggsave("outputs/plots/performance_categories.png", p, 
         width = 12, height = 8, dpi = 300)
  message("Saved: outputs/plots/performance_categories.png")
  
  return(p)
}

# ==============================================================================
# Function: Create State Comparison Plot
# ==============================================================================
plot_state_comparison <- function(data, top_n = 20) {
  message("Creating state comparison plot...")
  
  state_summary <- data %>%
    group_by(state) %>%
    summarise(
      avg_quality = mean(quality_score, na.rm = TRUE),
      n_hospitals = n(),
      .groups = "drop"
    ) %>%
    arrange(desc(avg_quality)) %>%
    head(top_n)
  
  p <- ggplot(state_summary, aes(x = reorder(state, avg_quality), 
                                  y = avg_quality, fill = avg_quality)) +
    geom_bar(stat = "identity", color = "black") +
    geom_text(aes(label = round(avg_quality, 1)), hjust = -0.2, size = 3) +
    scale_fill_gradient2(
      low = "#d73027", mid = "#fee090", high = "#4575b4",
      midpoint = 50
    ) +
    coord_flip() +
    labs(
      title = paste("Top", top_n, "States by Average Hospital Quality Score"),
      x = "State",
      y = "Average Quality Score",
      fill = "Score"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      legend.position = "right"
    )
  
  ggsave("outputs/plots/state_comparison.png", p, 
         width = 12, height = 10, dpi = 300)
  message("Saved: outputs/plots/state_comparison.png")
  
  return(p)
}

# ==============================================================================
# Function: Create Metric Correlation Heatmap
# ==============================================================================
plot_correlation_heatmap <- function(data) {
  message("Creating metric correlation heatmap...")
  
  cor_data <- data %>%
    select(mortality_score, readmission_score, infection_score, 
           patient_exp_score, quality_score) %>%
    rename(
      `Mortality` = mortality_score,
      `Readmission` = readmission_score,
      `Infection` = infection_score,
      `Patient Exp` = patient_exp_score,
      `Quality` = quality_score
    )
  
  cor_matrix <- cor(cor_data, use = "complete.obs")
  
  p <- ggcorrplot(
    cor_matrix,
    method = "circle",
    type = "lower",
    lab = TRUE,
    lab_size = 4,
    colors = c("#d73027", "white", "#4575b4"),
    title = "Correlation Between Hospital Performance Metrics",
    ggtheme = theme_minimal()
  ) +
    theme(
      plot.title = element_text(size = 14, face = "bold")
    )
  
  ggsave("outputs/plots/correlation_heatmap.png", p, 
         width = 10, height = 8, dpi = 300)
  message("Saved: outputs/plots/correlation_heatmap.png")
  
  return(p)
}

# ==============================================================================
# Function: Create Scatter Plot Matrix
# ==============================================================================
plot_metric_relationships <- function(data) {
  message("Creating metric relationship scatter plots...")
  
  sample_data <- data %>%
    sample_n(min(500, nrow(data))) %>%
    select(mortality_score, readmission_score, infection_score, 
           patient_exp_score, quality_score, performance_category)
  
  p1 <- ggplot(sample_data, aes(x = mortality_score, y = quality_score, 
                                 color = performance_category)) +
    geom_point(alpha = 0.6, size = 2) +
    geom_smooth(method = "lm", se = FALSE, color = "black", linetype = "dashed") +
    scale_color_brewer(palette = "RdYlGn", direction = 1) +
    labs(x = "Mortality Score", y = "Quality Score") +
    theme_minimal()
  
  p2 <- ggplot(sample_data, aes(x = readmission_score, y = quality_score, 
                                 color = performance_category)) +
    geom_point(alpha = 0.6, size = 2) +
    geom_smooth(method = "lm", se = FALSE, color = "black", linetype = "dashed") +
    scale_color_brewer(palette = "RdYlGn", direction = 1) +
    labs(x = "Readmission Score", y = "Quality Score") +
    theme_minimal()
  
  p3 <- ggplot(sample_data, aes(x = infection_score, y = quality_score, 
                                 color = performance_category)) +
    geom_point(alpha = 0.6, size = 2) +
    geom_smooth(method = "lm", se = FALSE, color = "black", linetype = "dashed") +
    scale_color_brewer(palette = "RdYlGn", direction = 1) +
    labs(x = "Infection Score", y = "Quality Score") +
    theme_minimal()
  
  p4 <- ggplot(sample_data, aes(x = patient_exp_score, y = quality_score, 
                                 color = performance_category)) +
    geom_point(alpha = 0.6, size = 2) +
    geom_smooth(method = "lm", se = FALSE, color = "black", linetype = "dashed") +
    scale_color_brewer(palette = "RdYlGn", direction = 1) +
    labs(x = "Patient Experience Score", y = "Quality Score") +
    theme_minimal()
  
  combined <- (p1 + p2) / (p3 + p4) +
    plot_layout(guides = "collect") +
    plot_annotation(
      title = "Relationship Between Individual Metrics and Overall Quality Score",
      theme = theme(plot.title = element_text(size = 16, face = "bold"))
    )
  
  ggsave("outputs/plots/metric_relationships.png", combined, 
         width = 16, height = 12, dpi = 300)
  message("Saved: outputs/plots/metric_relationships.png")
  
  return(combined)
}

# ==============================================================================
# Function: Create Cluster Visualization
# ==============================================================================
plot_clusters <- function(data, cluster_col = "cluster", method = "kmeans") {
  message(paste("Creating cluster visualization for", method, "..."))
  
  # PCA for dimensionality reduction
  pca_data <- data %>%
    select(mortality_score, readmission_score, infection_score, 
           patient_exp_score, quality_score)
  
  pca_result <- prcomp(pca_data, scale. = TRUE)
  pca_coords <- as.data.frame(pca_result$x[, 1:2])
  pca_coords$cluster <- factor(data[[cluster_col]])
  pca_coords$quality_score <- data$quality_score
  
  # Calculate variance explained
  var_explained <- summary(pca_result)$importance[2, 1:2] * 100
  
  p <- ggplot(pca_coords, aes(x = PC1, y = PC2, color = cluster, size = quality_score)) +
    geom_point(alpha = 0.6) +
    scale_color_brewer(palette = "Set1") +
    scale_size_continuous(range = c(1, 4)) +
    labs(
      title = paste("Hospital Clusters -", tools::toTitleCase(method), "Clustering"),
      subtitle = "PCA Visualization of Performance-Based Clusters",
      x = paste0("PC1 (", round(var_explained[1], 1), "% variance)"),
      y = paste0("PC2 (", round(var_explained[2], 1), "% variance)"),
      color = "Cluster",
      size = "Quality Score"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      legend.position = "right"
    )
  
  ggsave(paste0("outputs/plots/cluster_visualization_", method, ".png"), p, 
         width = 14, height = 10, dpi = 300)
  message(paste("Saved: outputs/plots/cluster_visualization_", method, ".png"))
  
  return(p)
}

# ==============================================================================
# Function: Create Top/Worst Hospitals Plot
# ==============================================================================
plot_top_worst_hospitals <- function(data, n = 15) {
  message("Creating top/worst hospitals comparison plot...")
  
  top_hospitals <- data %>%
    arrange(desc(quality_score)) %>%
    head(n) %>%
    mutate(rank = row_number(),
           category = "Top")
  
  worst_hospitals <- data %>%
    arrange(quality_score) %>%
    head(n) %>%
    mutate(rank = row_number(),
           category = "Worst")
  
  combined <- bind_rows(top_hospitals, worst_hospitals) %>%
    mutate(
      label = paste0(hospital_name, " (", state, ")"),
      label = str_trunc(label, 40)
    )
  
  p <- ggplot(combined, aes(x = reorder(label, quality_score), 
                            y = quality_score, fill = category)) +
    geom_bar(stat = "identity", color = "black") +
    geom_text(aes(label = round(quality_score, 1)), hjust = -0.2, size = 3) +
    scale_fill_manual(values = c("Top" = "#4575b4", "Worst" = "#d73027")) +
    coord_flip() +
    facet_wrap(~ category, scales = "free_y", ncol = 1) +
    labs(
      title = paste("Top", n, "and Worst", n, "Hospitals by Quality Score"),
      x = "Hospital",
      y = "Quality Score"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      legend.position = "none",
      strip.text = element_text(size = 12, face = "bold"),
      axis.text.y = element_text(size = 8)
    )
  
  ggsave("outputs/plots/top_worst_hospitals.png", p, 
         width = 14, height = 16, dpi = 300)
  message("Saved: outputs/plots/top_worst_hospitals.png")
  
  return(p)
}

# ==============================================================================
# Function: Create Interactive Dashboard (Plotly)
# ==============================================================================
create_interactive_dashboard <- function(data) {
  message("Creating interactive plotly dashboard...")
  
  # Interactive scatter plot
  plot_data <- data %>%
    mutate(
      hover_text = paste0(
        "<b>", hospital_name, "</b><br>",
        "City: ", city, ", ", state, "<br>",
        "Quality Score: ", round(quality_score, 1), "<br>",
        "Star Rating: ", star_rating, "<br>",
        "Category: ", performance_category
      )
    )
  
  p <- plot_ly(
    data = plot_data,
    x = ~mortality_score,
    y = ~readmission_score,
    z = ~infection_score,
    color = ~quality_score,
    colors = colorRamp(c("#d73027", "#fee090", "#4575b4")),
    text = ~hover_text,
    hoverinfo = "text",
    type = "scatter3d",
    mode = "markers",
    marker = list(size = 5, opacity = 0.7)
  ) %>%
    layout(
      title = "Interactive 3D Hospital Performance Dashboard",
      scene = list(
        xaxis = list(title = "Mortality Score"),
        yaxis = list(title = "Readmission Score"),
        zaxis = list(title = "Infection Score")
      )
    )
  
  # Try to save with selfcontained, fall back if pandoc not available
  tryCatch({
    htmlwidgets::saveWidget(
      p, 
      "outputs/plots/interactive_dashboard.html",
      selfcontained = TRUE
    )
  }, error = function(e) {
    message("Pandoc not available, saving without selfcontained option...")
    htmlwidgets::saveWidget(
      p, 
      "outputs/plots/interactive_dashboard.html",
      selfcontained = FALSE
    )
  })
  message("Saved: outputs/plots/interactive_dashboard.html")
  
  return(p)
}

# ==============================================================================
# Function: Create Complete Visualization Dashboard
# ==============================================================================
create_visualization_dashboard <- function(hospital_data, clustering_results = NULL) {
  message("\n=== Creating Complete Visualization Dashboard ===\n")
  
  # Create all visualizations
  plot_quality_distribution(hospital_data)
  plot_star_ratings(hospital_data)
  plot_performance_categories(hospital_data)
  plot_state_comparison(hospital_data)
  plot_correlation_heatmap(hospital_data)
  plot_metric_relationships(hospital_data)
  plot_top_worst_hospitals(hospital_data)
  
  # Create cluster visualizations if clustering results provided
  if (!is.null(clustering_results)) {
    # Add cluster assignments to data
    data_with_kmeans <- hospital_data %>%
      mutate(cluster = clustering_results$kmeans$result$model$cluster)
    
    data_with_hclust <- hospital_data %>%
      mutate(cluster = clustering_results$hierarchical$result$clusters)
    
    plot_clusters(data_with_kmeans, "cluster", "kmeans")
    plot_clusters(data_with_hclust, "cluster", "hierarchical")
  }
  
  # Create interactive dashboard
  create_interactive_dashboard(hospital_data)
  
  message("\n=== Visualization Dashboard Complete ===")
  message("All plots saved to outputs/plots/")
  
  cat("\n=== Generated Visualizations ===\n")
  cat("1. quality_score_distribution.png\n")
  cat("2. star_rating_distribution.png\n")
  cat("3. performance_categories.png\n")
  cat("4. state_comparison.png\n")
  cat("5. correlation_heatmap.png\n")
  cat("6. metric_relationships.png\n")
  cat("7. top_worst_hospitals.png\n")
  cat("8. cluster_visualization_kmeans.png\n")
  cat("9. cluster_visualization_hierarchical.png\n")
  cat("10. interactive_dashboard.html\n")
}

# ==============================================================================
# Main Execution (if run directly)
# ==============================================================================
if (sys.nframe() == 0) {
  # Load hospital ratings data
  hospital_data <- read_csv("outputs/hospital_ratings.csv", show_col_types = FALSE)
  
  # Create visualization dashboard
  create_visualization_dashboard(hospital_data)
  
  cat("\nVisualization dashboard created successfully!\n")
}
