library(shiny)
library(xml2)
library(glue)
library(dplyr)
library(tidyr)  # Load tidyr for unnest function
library(tibble)

# Function to parse the RSS feed with hyperlinks
parse_rss_feed <- function(start_date, end_date) {
  url <- "https://blog.lboro.ac.uk/rdm/feed/"
  feed <- read_xml(url)
  
  # Extract titles, links, dates, and categories
  items <- xml_find_all(feed, ".//item")
  titles <- xml_text(xml_find_all(items, ".//title"))
  links <- xml_text(xml_find_all(items, ".//link"))
  dates <- xml_text(xml_find_all(items, ".//pubDate"))
  
  # Convert dates to Date format
  dates <- as.Date(dates, format = "%a, %d %b %Y %H:%M:%S %z")
  
  # Create a tibble sorted by date in descending order
  data <- tibble(
    title = titles,
    link = links,
    date = dates
  ) %>%
    filter(date >= as.Date(start_date) & date <= as.Date(end_date)) %>%
    arrange(desc(date))
  
  return(data)
}

# Define server logic
server <- function(input, output) {
  
  scraped_data <- eventReactive(input$scrape, {
    parse_rss_feed(input$start_date, input$end_date)
  })
  
  output$html_output <- renderUI({
    req(scraped_data())
    
    if (nrow(scraped_data()) == 0) {
      HTML("<p>No blog posts found for the specified date range.</p>")
    } else {
      # Format HTML with posts arranged by date
      html_content <- paste(
        "<div style='font-family: Arial, sans-serif;'>",
        glue("<h2>Open Research Blog Digest ({input$start_date} to {input$end_date})</h2>"),
        
        # Create list items for each post sorted by date
        "<ul>",
        paste(
          sapply(1:nrow(scraped_data()), function(i) {
            paste0(
              "<li><a href='", scraped_data()$link[i], "' target='_blank'>",
              scraped_data()$title[i], "</a> - ", scraped_data()$date[i], "</li>"
            )
          }),
          collapse = ""
        ),
        "</ul></div>"
      )
      
      HTML(html_content)
    }
  })
}
