# ==============================================================================
# 04_clustering.R
# Cluster Hospitals by Performance (K-means and Hierarchical Clustering)
# ==============================================================================

library(tidyverse)
library(cluster)
library(factoextra)

# ==============================================================================
# Function: Prepare Data for Clustering
# ==============================================================================
prepare_clustering_data <- function(data) {
  message("Preparing data for clustering...")
  
  # Select features for clustering
  clustering_features <- data %>%
    select(
      hospital_id,
      mortality_score,
      readmission_score,
      infection_score,
      patient_exp_score,
      quality_score
    )
  
  # Create matrix for clustering (exclude hospital_id)
  cluster_matrix <- clustering_features %>%
    select(-hospital_id) %>%
    as.matrix()
  
  # Standardize features (z-score normalization)
  cluster_matrix_scaled <- scale(cluster_matrix)
  
  # Add row names for identification
  rownames(cluster_matrix_scaled) <- clustering_features$hospital_id
  
  message(paste("Prepared", nrow(cluster_matrix_scaled), "hospitals for clustering"))
  message(paste("Using", ncol(cluster_matrix_scaled), "features"))
  
  return(list(
    scaled_data = cluster_matrix_scaled,
    original_data = clustering_features
  ))
}

# ==============================================================================
# Function: Determine Optimal Number of Clusters (Elbow Method)
# ==============================================================================
find_optimal_clusters <- function(scaled_data, max_k = 10) {
  message("Determining optimal number of clusters using Elbow method...")
  
  # Calculate within-cluster sum of squares for different k values
  wss <- numeric(max_k)
  
  for (k in 1:max_k) {
    kmeans_result <- kmeans(scaled_data, centers = k, nstart = 25, iter.max = 100)
    wss[k] <- kmeans_result$tot.withinss
  }
  
  # Create elbow plot
  elbow_data <- data.frame(
    k = 1:max_k,
    wss = wss
  )
  
  # Save elbow plot
  p <- ggplot(elbow_data, aes(x = k, y = wss)) +
    geom_line(color = "steelblue", size = 1) +
    geom_point(color = "steelblue", size = 3) +
    geom_vline(xintercept = 4, linetype = "dashed", color = "red", alpha = 0.5) +
    labs(
      title = "Elbow Method for Optimal K",
      subtitle = "Within-Cluster Sum of Squares vs Number of Clusters",
      x = "Number of Clusters (k)",
      y = "Total Within-Cluster Sum of Squares"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 10)
    )
  
  ggsave("outputs/plots/elbow_plot.png", p, width = 10, height = 6, dpi = 300)
  message("Elbow plot saved to outputs/plots/elbow_plot.png")
  
  # Calculate silhouette scores
  message("Calculating silhouette scores...")
  silhouette_scores <- numeric(max_k - 1)
  
  for (k in 2:max_k) {
    kmeans_result <- kmeans(scaled_data, centers = k, nstart = 25)
    sil <- silhouette(kmeans_result$cluster, dist(scaled_data))
    silhouette_scores[k - 1] <- mean(sil[, 3])
  }
  
  optimal_k <- which.max(silhouette_scores) + 1
  message(paste("Optimal number of clusters (by silhouette):", optimal_k))
  
  return(optimal_k)
}

# ==============================================================================
# Function: Perform K-means Clustering
# ==============================================================================
perform_kmeans_clustering <- function(scaled_data, k = 4, seed = 123) {
  message(paste("\nPerforming k-means clustering with k =", k))
  
  set.seed(seed)
  
  # Perform k-means
  kmeans_result <- kmeans(
    scaled_data,
    centers = k,
    nstart = 25,
    iter.max = 100
  )
  
  # Calculate cluster statistics
  message("\n=== K-means Clustering Results ===")
  message(paste("Total Sum of Squares:", round(kmeans_result$totss, 2)))
  message(paste("Between-Cluster Sum of Squares:", round(kmeans_result$betweenss, 2)))
  message(paste("Within-Cluster Sum of Squares:", round(kmeans_result$tot.withinss, 2)))
  message(paste("Variance Explained:", 
                round(kmeans_result$betweenss / kmeans_result$totss * 100, 2), "%"))
  
  # Display cluster sizes
  cat("\n=== Cluster Sizes ===\n")
  print(table(kmeans_result$cluster))
  
  # Calculate silhouette score
  sil <- silhouette(kmeans_result$cluster, dist(scaled_data))
  avg_sil <- mean(sil[, 3])
  message(paste("\nAverage Silhouette Score:", round(avg_sil, 3)))
  
  return(list(
    model = kmeans_result,
    silhouette = sil,
    avg_silhouette = avg_sil
  ))
}

# ==============================================================================
# Function: Perform Hierarchical Clustering
# ==============================================================================
perform_hierarchical_clustering <- function(scaled_data, k = 4, method = "ward.D2") {
  message(paste("\nPerforming hierarchical clustering with method:", method))
  
  # Calculate distance matrix
  dist_matrix <- dist(scaled_data, method = "euclidean")
  
  # Perform hierarchical clustering
  hclust_result <- hclust(dist_matrix, method = method)
  
  # Cut tree to create clusters
  clusters <- cutree(hclust_result, k = k)
  
  # Calculate silhouette score
  sil <- silhouette(clusters, dist_matrix)
  avg_sil <- mean(sil[, 3])
  
  message("\n=== Hierarchical Clustering Results ===")
  message(paste("Method:", method))
  message(paste("Number of clusters:", k))
  message(paste("Average Silhouette Score:", round(avg_sil, 3)))
  
  # Display cluster sizes
  cat("\n=== Cluster Sizes ===\n")
  print(table(clusters))
  
  return(list(
    model = hclust_result,
    clusters = clusters,
    silhouette = sil,
    avg_silhouette = avg_sil
  ))
}

# ==============================================================================
# Function: Characterize Clusters
# ==============================================================================
characterize_clusters <- function(data, clusters, method = "kmeans") {
  message("\nCharacterizing clusters...")
  
  # Add cluster assignments to data
  if (method == "kmeans") {
    cluster_col <- clusters$model$cluster
  } else {
    cluster_col <- clusters$clusters
  }
  
  data_clustered <- data %>%
    mutate(cluster = cluster_col)
  
  # Calculate cluster characteristics
  cluster_summary <- data_clustered %>%
    group_by(cluster) %>%
    summarise(
      n_hospitals = n(),
      avg_mortality_score = mean(mortality_score, na.rm = TRUE),
      avg_readmission_score = mean(readmission_score, na.rm = TRUE),
      avg_infection_score = mean(infection_score, na.rm = TRUE),
      avg_patient_exp_score = mean(patient_exp_score, na.rm = TRUE),
      avg_quality_score = mean(quality_score, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(avg_quality_score))
  
  # Assign cluster labels based on quality score
  cluster_summary <- cluster_summary %>%
    mutate(
      cluster_label = case_when(
        avg_quality_score >= quantile(avg_quality_score, 0.75) ~ "High Performers",
        avg_quality_score >= quantile(avg_quality_score, 0.50) ~ "Above Average",
        avg_quality_score >= quantile(avg_quality_score, 0.25) ~ "Below Average",
        TRUE ~ "Needs Improvement"
      )
    )
  
  # Display cluster characteristics
  cat("\n=== Cluster Characteristics ===\n")
  print(cluster_summary)
  
  # Save cluster summary
  write_csv(cluster_summary, paste0("outputs/cluster_summary_", method, ".csv"))
  message(paste("\nCluster summary saved to outputs/cluster_summary_", method, ".csv", sep = ""))
  
  return(list(
    data = data_clustered,
    summary = cluster_summary
  ))
}

# ==============================================================================
# Function: Compare Clustering Methods
# ==============================================================================
compare_clustering_methods <- function(kmeans_result, hclust_result) {
  message("\n=== Comparing Clustering Methods ===")
  
  comparison <- data.frame(
    Method = c("K-means", "Hierarchical"),
    Avg_Silhouette = c(
      round(kmeans_result$avg_silhouette, 3),
      round(hclust_result$avg_silhouette, 3)
    )
  )
  
  cat("\n")
  print(comparison)
  
  if (kmeans_result$avg_silhouette > hclust_result$avg_silhouette) {
    message("\nK-means clustering shows better separation")
  } else {
    message("\nHierarchical clustering shows better separation")
  }
  
  return(comparison)
}

# ==============================================================================
# Function: Complete Clustering Pipeline
# ==============================================================================
perform_clustering_analysis <- function(hospital_data, k = 4) {
  message("\n=== Starting Clustering Analysis ===\n")
  
  # Prepare data
  cluster_prep <- prepare_clustering_data(hospital_data)
  
  # Find optimal number of clusters
  optimal_k <- find_optimal_clusters(cluster_prep$scaled_data, max_k = 10)
  
  # Use provided k or optimal k
  final_k <- ifelse(is.null(k), optimal_k, k)
  message(paste("\nUsing k =", final_k, "for clustering"))
  
  # Perform k-means clustering
  kmeans_result <- perform_kmeans_clustering(cluster_prep$scaled_data, k = final_k)
  
  # Perform hierarchical clustering
  hclust_result <- perform_hierarchical_clustering(cluster_prep$scaled_data, k = final_k)
  
  # Characterize clusters for both methods
  kmeans_char <- characterize_clusters(cluster_prep$original_data, kmeans_result, "kmeans")
  hclust_char <- characterize_clusters(cluster_prep$original_data, hclust_result, "hierarchical")
  
  # Compare methods
  comparison <- compare_clustering_methods(kmeans_result, hclust_result)
  
  message("\n=== Clustering Analysis Complete ===\n")
  
  return(list(
    kmeans = list(
      result = kmeans_result,
      characterization = kmeans_char
    ),
    hierarchical = list(
      result = hclust_result,
      characterization = hclust_char
    ),
    comparison = comparison,
    optimal_k = optimal_k
  ))
}

# ==============================================================================
# Main Execution (if run directly)
# ==============================================================================
if (sys.nframe() == 0) {
  # Load hospital ratings data
  hospital_data <- read_csv("outputs/hospital_ratings.csv", show_col_types = FALSE)
  
  # Perform clustering analysis
  clustering_results <- perform_clustering_analysis(hospital_data, k = 4)
  
  cat("\nClustering analysis completed successfully!\n")
}
