library(shiny)
library(dplyr)
library(tibble)
library(tidytext)
library(visNetwork)
library(tidyr)
library(shinydashboard)
# Define UI for application that draws a histogram
ui <- fluidPage(
  # Application title
  titlePanel("Phrasenet"),
  
  # Sidebar with a file input, textinput and slizer
  sidebarLayout(
    sidebarPanel(
      fileInput(inputId = "file", label = "Choose a text file"),
      textInput(inputId = "connector_words", label = "Enter connector word"),
      sliderInput("bins",
                  "Number of nodes",
                  min = 1,
                  max = 200,
                  value = 30)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      visNetworkOutput("PhrasenetPlot"),
      uiOutput("test")
    )
  )
)

ui <- dashboardPage(
  dashboardHeader(title = "Phrasenet"),
  dashboardSidebar(
    fileInput(inputId = "file", label = "Choose a text file"),
    textInput(inputId = "connector_words", label = "Enter connector word"),
    sliderInput("bins",
                "Number of nodes",
                min = 1,
                max = 200,
                value = 30)
  ),
  dashboardBody(
    box(visNetworkOutput("PhrasenetPlot"), width = 15))
)


# Define server logic required to draw a histogram
server <- function(input, output) {
  
  input_string <- reactive({
    file1 <- input$file
    if(is.null(file1)){return()}
    readr::read_file(file = file1$datapath)
  })
  
  connector_words <- reactive({
    connector_words <- input$connector_words
  })
  # Preprocess function
  preprocess_data <- function(string, connect_words){
    # Set up df
    string_df <- tibble::tibble(words = string) %>%
      tidytext::unnest_tokens(word_col, words)
    # Check if connector
    string_df <- string_df %>%
      mutate(is_connector_word = word_col %in% connect_words,
             before_word = lag(word_col),
             after_word = lead(word_col))%>% 
      group_by(word_col) %>% mutate(word_frequency = n())
    # Remove non connectors and NA
    string_df <- string_df %>%
      drop_na() %>%
      filter(is_connector_word == TRUE)
    # Count occurance of words together
    string_df <- count(string_df, before_word, after_word,
                       name = "together_n")
    # Before word frequency
    string_df <- string_df %>% group_by(before_word) %>%
      mutate(before_word_frequency = n())
    # After word frequency
    string_df <- string_df %>% group_by(after_word) %>%
      mutate(after_word_frequency = n())
    
    edges <- data.frame("from"=string_df$before_word, "to" = string_df$after_word, "value" = string_df$together_n)
    
    nodes <- append(string_df$before_word, string_df$after_word)
    
    node_n <- append(string_df$before_word_frequency, string_df$after_word_frequency)
    
    node_df <- data.frame(nodes, node_n)
    node_df$nodes <- as.character(node_df$nodes)
    
    node_df <- node_df %>% group_by(nodes) %>% distinct()
    node_df <- node_df[!duplicated(node_df$nodes),]
    node <- data.frame("id" = node_df$nodes, "label" = node_df$nodes, "value" = node_df$node_n)
    node1 <- node %>% arrange(desc(value)) %>%
      head(input$bins)
    output <- list("node_df" = node1, "edge_df" = edges)
    return(output)
  }
  output$PhrasenetPlot <- renderVisNetwork({
    if(is.null(input_string())){return()}
    processed <- preprocess_data(string = input_string(), connect_words =  connector_words())
    node <- processed[["node_df"]]
    edges <- processed[["edge_df"]]
    
    visNetwork(node, edges, main = "Phrasenet") %>% visPhysics(solver="repulsion") %>% visOptions(highlightNearest = TRUE) %>%
      visEdges(shadow = TRUE,
               arrows =list(to = list(enabled = TRUE, scaleFactor = 2)),
               color = list(color = "lightblue", highlight = "red"))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
