library(shiny)

# Define UI
ui <- fluidPage(
  titlePanel("Loughborough RDM Blog Scraper"),
  sidebarLayout(
    sidebarPanel(
      dateInput("start_date", "Start Date:", value = Sys.Date() - 30),
      dateInput("end_date", "End Date:", value = Sys.Date()),
      actionButton("scrape", "Scrape Blog")
    ),
    mainPanel(
      uiOutput("html_output")
    )
  )
)
