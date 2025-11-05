# ==============================================================================
# interactive_dashboard.R
# Create Interactive Hospital Performance Dashboard with Shiny
# ==============================================================================

# Install Shiny if not already installed
if (!require("shiny", quietly = TRUE)) {
  install.packages("shiny")
}
if (!require("shinydashboard", quietly = TRUE)) {
  install.packages("shinydashboard")
}
if (!require("DT", quietly = TRUE)) {
  install.packages("DT")
}
if (!require("plotly", quietly = TRUE)) {
  install.packages("plotly")
}
if (!require("tidyverse", quietly = TRUE)) {
  install.packages("tidyverse")
}

library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(tidyverse)

# ==============================================================================
# Load Data
# ==============================================================================

cat("Loading hospital data...\n")

# Check if data exists
if (!file.exists("outputs/hospital_ratings.csv")) {
  stop("Data not found! Please run main_analysis.R first to generate the data.")
}

# Load hospital ratings
hospital_data <- read_csv("outputs/hospital_ratings.csv", show_col_types = FALSE)

# Load state summary
state_summary <- read_csv("outputs/state_summary.csv", show_col_types = FALSE)

cat("Data loaded successfully!\n")
cat(paste("Total hospitals:", nrow(hospital_data), "\n"))
cat(paste("Total states:", nrow(state_summary), "\n\n"))

# ==============================================================================
# UI Definition
# ==============================================================================

ui <- dashboardPage(
  skin = "blue",
  
  # Header
  dashboardHeader(
    title = "US Hospital Performance Dashboard",
    titleWidth = 350
  ),
  
  # Sidebar
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Hospital Search", tabName = "search", icon = icon("search")),
      menuItem("State Analysis", tabName = "states", icon = icon("map")),
      menuItem("Clustering", tabName = "clustering", icon = icon("object-group")),
      menuItem("Comparisons", tabName = "compare", icon = icon("balance-scale")),
      menuItem("Data Table", tabName = "data", icon = icon("table"))
    ),
    
    hr(),
    
    # Filters
    h4("Filters", style = "padding-left: 15px;"),
    
    selectInput("state_filter", "State:", 
                choices = c("All States" = "all", sort(unique(hospital_data$state))),
                selected = "all"),
    
    selectInput("rating_filter", "Star Rating:", 
                choices = c("All Ratings" = "all", 1:5),
                selected = "all"),
    
    sliderInput("quality_filter", "Quality Score Range:",
                min = floor(min(hospital_data$quality_score)),
                max = ceiling(max(hospital_data$quality_score)),
                value = c(floor(min(hospital_data$quality_score)), 
                         ceiling(max(hospital_data$quality_score))),
                step = 5)
  ),
  
  # Body
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .small-box {cursor: pointer;}
        .main-header .logo {font-weight: bold;}
        .content-wrapper {background-color: #f4f6f9;}
      "))
    ),
    
    tabItems(
      # Overview Tab
      tabItem(
        tabName = "overview",
        
        fluidRow(
          valueBoxOutput("total_hospitals", width = 3),
          valueBoxOutput("avg_quality", width = 3),
          valueBoxOutput("top_performers", width = 3),
          valueBoxOutput("needs_improvement", width = 3)
        ),
        
        fluidRow(
          box(
            title = "Quality Score Distribution",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("quality_dist_plot", height = 300)
          ),
          
          box(
            title = "Star Rating Distribution",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("star_rating_plot", height = 300)
          )
        ),
        
        fluidRow(
          box(
            title = "Performance Metrics Correlation",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("correlation_plot", height = 300)
          ),
          
          box(
            title = "Top 10 Hospitals",
            status = "success",
            solidHeader = TRUE,
            width = 6,
            DTOutput("top10_table")
          )
        )
      ),
      
      # Hospital Search Tab
      tabItem(
        tabName = "search",
        
        fluidRow(
          box(
            title = "Search Hospitals",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            
            textInput("search_name", "Hospital Name:", ""),
            
            DTOutput("search_results")
          )
        ),
        
        fluidRow(
          box(
            title = "Hospital Details",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            
            uiOutput("hospital_details")
          )
        )
      ),
      
      # State Analysis Tab
      tabItem(
        tabName = "states",
        
        fluidRow(
          box(
            title = "State Performance Rankings",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("state_ranking_plot", height = 500)
          )
        ),
        
        fluidRow(
          box(
            title = "State Summary Table",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            DTOutput("state_summary_table")
          )
        )
      ),
      
      # Clustering Tab
      tabItem(
        tabName = "clustering",
        
        fluidRow(
          box(
            title = "3D Cluster Visualization",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("cluster_3d_plot", height = 600)
          )
        ),
        
        fluidRow(
          box(
            title = "Cluster Statistics",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            DTOutput("cluster_stats_table")
          )
        )
      ),
      
      # Comparisons Tab
      tabItem(
        tabName = "compare",
        
        fluidRow(
          box(
            title = "Metric Relationships",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            
            selectInput("x_metric", "X-Axis Metric:",
                       choices = c("Mortality Score" = "mortality_score",
                                 "Readmission Score" = "readmission_score",
                                 "Infection Score" = "infection_score",
                                 "Patient Experience" = "patient_exp_score",
                                 "Quality Score" = "quality_score"),
                       selected = "mortality_score"),
            
            selectInput("y_metric", "Y-Axis Metric:",
                       choices = c("Mortality Score" = "mortality_score",
                                 "Readmission Score" = "readmission_score",
                                 "Infection Score" = "infection_score",
                                 "Patient Experience" = "patient_exp_score",
                                 "Quality Score" = "quality_score"),
                       selected = "quality_score"),
            
            plotlyOutput("scatter_plot", height = 400)
          ),
          
          box(
            title = "Performance by Category",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("category_boxplot", height = 400)
          )
        ),
        
        fluidRow(
          box(
            title = "Best vs Worst Hospitals",
            status = "warning",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("best_worst_plot", height = 400)
          )
        )
      ),
      
      # Data Table Tab
      tabItem(
        tabName = "data",
        
        fluidRow(
          box(
            title = "Complete Hospital Dataset",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            
            downloadButton("download_data", "Download CSV"),
            hr(),
            DTOutput("full_data_table")
          )
        )
      )
    )
  )
)

# ==============================================================================
# Server Logic
# ==============================================================================

server <- function(input, output, session) {
  
  # Reactive filtered data
  filtered_data <- reactive({
    data <- hospital_data
    
    # Filter by state
    if (input$state_filter != "all") {
      data <- data %>% filter(state == input$state_filter)
    }
    
    # Filter by rating
    if (input$rating_filter != "all") {
      data <- data %>% filter(star_rating == as.numeric(input$rating_filter))
    }
    
    # Filter by quality score
    data <- data %>%
      filter(quality_score >= input$quality_filter[1] & 
             quality_score <= input$quality_filter[2])
    
    return(data)
  })
  
  # Value Boxes
  output$total_hospitals <- renderValueBox({
    valueBox(
      value = nrow(filtered_data()),
      subtitle = "Total Hospitals",
      icon = icon("hospital"),
      color = "blue"
    )
  })
  
  output$avg_quality <- renderValueBox({
    valueBox(
      value = round(mean(filtered_data()$quality_score, na.rm = TRUE), 1),
      subtitle = "Average Quality Score",
      icon = icon("star"),
      color = "yellow"
    )
  })
  
  output$top_performers <- renderValueBox({
    count <- sum(filtered_data()$star_rating >= 4, na.rm = TRUE)
    valueBox(
      value = count,
      subtitle = "Top Performers (4-5★)",
      icon = icon("trophy"),
      color = "green"
    )
  })
  
  output$needs_improvement <- renderValueBox({
    count <- sum(filtered_data()$star_rating <= 2, na.rm = TRUE)
    valueBox(
      value = count,
      subtitle = "Needs Improvement (1-2★)",
      icon = icon("exclamation-triangle"),
      color = "red"
    )
  })
  
  # Quality Distribution Plot
  output$quality_dist_plot <- renderPlotly({
    p <- ggplot(filtered_data(), aes(x = quality_score)) +
      geom_histogram(aes(y = after_stat(density)), bins = 30, 
                     fill = "steelblue", alpha = 0.7, color = "black") +
      geom_density(color = "red", size = 1.2) +
      labs(x = "Quality Score", y = "Density") +
      theme_minimal()
    
    ggplotly(p) %>%
      layout(showlegend = FALSE)
  })
  
  # Star Rating Plot
  output$star_rating_plot <- renderPlotly({
    rating_counts <- filtered_data() %>%
      count(star_rating) %>%
      mutate(percentage = n / sum(n) * 100)
    
    plot_ly(rating_counts, x = ~factor(star_rating), y = ~n, type = "bar",
            text = ~paste0(n, " (", round(percentage, 1), "%)"),
            textposition = "outside",
            marker = list(color = ~star_rating,
                         colorscale = list(c(0, "red"), c(0.5, "yellow"), c(1, "green")))) %>%
      layout(xaxis = list(title = "Star Rating"),
             yaxis = list(title = "Number of Hospitals"),
             showlegend = FALSE)
  })
  
  # Correlation Plot
  output$correlation_plot <- renderPlotly({
    cor_data <- filtered_data() %>%
      select(mortality_score, readmission_score, infection_score, 
             patient_exp_score, quality_score)
    
    cor_matrix <- cor(cor_data, use = "complete.obs")
    
    plot_ly(z = cor_matrix, x = colnames(cor_matrix), y = colnames(cor_matrix),
            type = "heatmap", colorscale = "RdBu", zmid = 0) %>%
      layout(xaxis = list(tickangle = -45))
  })
  
  # Top 10 Table
  output$top10_table <- renderDT({
    filtered_data() %>%
      arrange(desc(quality_score)) %>%
      head(10) %>%
      select(hospital_name, city, state, quality_score, star_rating) %>%
      datatable(
        options = list(pageLength = 10, dom = 't'),
        rownames = FALSE,
        colnames = c("Hospital", "City", "State", "Quality Score", "Stars")
      ) %>%
      formatRound("quality_score", 1)
  })
  
  # Search Results
  output$search_results <- renderDT({
    search_term <- input$search_name
    
    if (search_term == "") {
      data <- filtered_data() %>% head(50)
    } else {
      data <- filtered_data() %>%
        filter(grepl(search_term, hospital_name, ignore.case = TRUE))
    }
    
    data %>%
      select(hospital_name, city, state, quality_score, star_rating) %>%
      datatable(
        options = list(pageLength = 10),
        selection = "single",
        rownames = FALSE,
        colnames = c("Hospital", "City", "State", "Quality Score", "Stars")
      ) %>%
      formatRound("quality_score", 1)
  })
  
  # Hospital Details
  output$hospital_details <- renderUI({
    s <- input$search_results_rows_selected
    
    if (length(s)) {
      search_term <- input$search_name
      
      if (search_term == "") {
        selected_hospital <- filtered_data() %>% head(50) %>% slice(s)
      } else {
        selected_hospital <- filtered_data() %>%
          filter(grepl(search_term, hospital_name, ignore.case = TRUE)) %>%
          slice(s)
      }
      
      tagList(
        h3(selected_hospital$hospital_name),
        p(strong("Location: "), paste(selected_hospital$city, selected_hospital$state, sep = ", ")),
        p(strong("Hospital Type: "), selected_hospital$hospital_type),
        hr(),
        h4("Performance Metrics"),
        fluidRow(
          column(3, 
                 h4(round(selected_hospital$quality_score, 1), style = "color: #3c8dbc;"),
                 p("Quality Score")),
          column(3,
                 h4(paste(rep("⭐", selected_hospital$star_rating), collapse = "")),
                 p("Star Rating")),
          column(3,
                 h4(paste("#", selected_hospital$national_rank)),
                 p("National Rank")),
          column(3,
                 h4(paste("#", selected_hospital$state_rank)),
                 p("State Rank"))
        ),
        hr(),
        h4("Individual Scores"),
        fluidRow(
          column(6,
                 p(strong("Mortality Score: "), round(selected_hospital$mortality_score, 1)),
                 p(strong("Readmission Score: "), round(selected_hospital$readmission_score, 1))),
          column(6,
                 p(strong("Infection Score: "), round(selected_hospital$infection_score, 1)),
                 p(strong("Patient Experience: "), round(selected_hospital$patient_exp_score, 1)))
        )
      )
    } else {
      p("Select a hospital from the table above to see details.")
    }
  })
  
  # State Ranking Plot
  output$state_ranking_plot <- renderPlotly({
    state_data <- state_summary %>%
      arrange(desc(avg_quality_score)) %>%
      head(25)
    
    plot_ly(state_data, x = ~avg_quality_score, y = ~reorder(state, avg_quality_score),
            type = "bar", orientation = "h",
            text = ~paste("Score:", round(avg_quality_score, 1), 
                         "<br>Hospitals:", n_hospitals),
            hoverinfo = "text",
            marker = list(color = ~avg_quality_score,
                         colorscale = list(c(0, "red"), c(0.5, "yellow"), c(1, "green")))) %>%
      layout(xaxis = list(title = "Average Quality Score"),
             yaxis = list(title = ""),
             showlegend = FALSE)
  })
  
  # State Summary Table
  output$state_summary_table <- renderDT({
    state_summary %>%
      arrange(desc(avg_quality_score)) %>%
      datatable(
        options = list(pageLength = 15),
        rownames = FALSE
      ) %>%
      formatRound(c("avg_quality_score", "median_quality_score", "avg_mortality",
                   "avg_readmission", "avg_infection", "avg_patient_exp",
                   "pct_excellent", "pct_poor"), 1)
  })
  
  # 3D Cluster Plot
  output$cluster_3d_plot <- renderPlotly({
    # Get filtered data
    data <- filtered_data()
    
    # Create 3D scatter plot colored by performance category
    plot_ly(data, 
            x = ~mortality_score, 
            y = ~readmission_score, 
            z = ~infection_score,
            color = ~performance_category,
            colors = c("red", "orange", "yellow", "lightgreen", "green"),
            text = ~paste("Hospital:", hospital_name,
                         "<br>Quality:", round(quality_score, 1),
                         "<br>Stars:", star_rating,
                         "<br>State:", state,
                         "<br>Category:", performance_category),
            hoverinfo = "text",
            type = "scatter3d", 
            mode = "markers",
            marker = list(size = 5, opacity = 0.7)) %>%
      layout(
        title = "Hospital Performance in 3D Space",
        scene = list(
          xaxis = list(title = "Mortality Score"),
          yaxis = list(title = "Readmission Score"),
          zaxis = list(title = "Infection Score")
        )
      )
  })
  
  # Cluster Stats Table
  output$cluster_stats_table <- renderDT({
    filtered_data() %>%
      group_by(performance_category) %>%
      summarise(
        Count = n(),
        Avg_Quality = round(mean(quality_score), 1),
        Avg_Mortality = round(mean(mortality_score), 1),
        Avg_Readmission = round(mean(readmission_score), 1),
        Avg_Infection = round(mean(infection_score), 1),
        .groups = "drop"
      ) %>%
      datatable(
        options = list(pageLength = 10, dom = 't'),
        rownames = FALSE
      )
  })
  
  # Scatter Plot
  output$scatter_plot <- renderPlotly({
    plot_ly(filtered_data(), 
            x = ~get(input$x_metric), 
            y = ~get(input$y_metric),
            color = ~factor(star_rating),
            colors = c("red", "orange", "yellow", "lightgreen", "green"),
            text = ~paste("Hospital:", hospital_name,
                         "<br>State:", state),
            hoverinfo = "text",
            type = "scatter", 
            mode = "markers") %>%
      layout(xaxis = list(title = gsub("_", " ", tools::toTitleCase(input$x_metric))),
             yaxis = list(title = gsub("_", " ", tools::toTitleCase(input$y_metric))))
  })
  
  # Category Boxplot
  output$category_boxplot <- renderPlotly({
    plot_ly(filtered_data(), y = ~quality_score, color = ~performance_category,
            colors = c("red", "orange", "yellow", "lightgreen", "green"),
            type = "box") %>%
      layout(yaxis = list(title = "Quality Score"),
             xaxis = list(title = ""))
  })
  
  # Best vs Worst Plot
  output$best_worst_plot <- renderPlotly({
    top10 <- filtered_data() %>%
      arrange(desc(quality_score)) %>%
      head(10) %>%
      mutate(category = "Top 10")
    
    bottom10 <- filtered_data() %>%
      arrange(quality_score) %>%
      head(10) %>%
      mutate(category = "Bottom 10")
    
    combined <- bind_rows(top10, bottom10) %>%
      mutate(label = paste0(hospital_name, " (", state, ")"))
    
    plot_ly(combined, y = ~reorder(label, quality_score), x = ~quality_score,
            color = ~category, colors = c("green", "red"),
            type = "bar", orientation = "h") %>%
      layout(yaxis = list(title = ""),
             xaxis = list(title = "Quality Score"))
  })
  
  # Full Data Table
  output$full_data_table <- renderDT({
    filtered_data() %>%
      select(hospital_name, city, state, hospital_type, quality_score, star_rating,
             mortality_score, readmission_score, infection_score, patient_exp_score,
             national_rank, state_rank, performance_category) %>%
      datatable(
        options = list(pageLength = 25, scrollX = TRUE),
        rownames = FALSE,
        filter = "top"
      ) %>%
      formatRound(c("quality_score", "mortality_score", "readmission_score",
                   "infection_score", "patient_exp_score"), 1)
  })
  
  # Download Handler
  output$download_data <- downloadHandler(
    filename = function() {
      paste0("hospital_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(filtered_data(), file, row.names = FALSE)
    }
  )
}

# ==============================================================================
# Run Application
# ==============================================================================

cat("\n=======================================================================\n")
cat("  LAUNCHING INTERACTIVE HOSPITAL PERFORMANCE DASHBOARD\n")
cat("=======================================================================\n\n")
cat("Dashboard will open in your default web browser.\n")
cat("Press Ctrl+C or Esc in the R console to stop the server.\n\n")

shinyApp(ui = ui, server = server)
