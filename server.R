library(shiny)
library(xml2)
library(glue)
library(tidyverse)

server <- function(input, output, session) {

parse_rss_feed <- function(start_date, end_date) {
  url <- "https://blog.lboro.ac.uk/rdm/feed/"
  feed <- read_xml(url)
  
  items <- xml_find_all(feed, ".//item")
  titles <- xml_text(xml_find_all(items, ".//title"))
  links <- xml_text(xml_find_all(items, ".//link"))
  dates <- xml_text(xml_find_all(items, ".//pubDate"))
  categories <- sapply(items, function(item) {
    cats <- xml_text(xml_find_all(item, ".//category"))
    paste(cats, collapse = ", ")
  })
  
  dates <- as.Date(dates, format = "%a, %d %b %Y %H:%M:%S %z")
  
  tibble(
    title = titles,
    link = links,
    date = dates,
    categories = categories
  ) %>%
    filter(date >= as.Date(start_date) & date <= as.Date(end_date)) %>%
    arrange(desc(date))
}

  html_content <- reactiveVal("")
  
  scraped_data <- eventReactive(input$scrape, {
    parse_rss_feed(input$start_date, input$end_date)
  })
  
  output$html_output <- renderUI({
    req(scraped_data())
    
    if (nrow(scraped_data()) == 0) {
      HTML("<p style='font-family: Arial, sans-serif; color: #666;'>No blog posts found for the specified date range.</p>")
    } else {
      
      posts <- paste(
        sapply(1:nrow(scraped_data()), function(i) {
          post <- scraped_data()[i, ]
          glue("
          <p style='margin: 0 0 16px 0;'>
            <a href='{post$link}' target='_blank' style='font-size:15px; font-weight:500; color:#8d9c27; text-decoration:none;'>{post$title}</a><br>
            <span style='font-size:12px; color:#1a1a1a;'>{post$categories}</span>
            <span style='font-size:12px; color:#aaa; margin-left:10px;'>{format(post$date, '%d %B %Y')}</span>
          </p>
        ")
        }),
        collapse = ""
      )
      
      HTML(glue("
      <div style='font-family: Arial, sans-serif; max-width: 680px;'>
        <h2 style='font-size:18px; font-weight:500; margin-bottom:4px; color:#1a1a1a;'>Open Research Blog Digest {input$start_date} to {input$end_date} </h2>
        <br>
        {posts}
      </div>
    "))
    }
  })
}