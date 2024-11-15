library(shiny)

# Define UI
ui <- fluidPage(
  titlePanel("Loughborough RDM Blog Digest Maker"),
  sidebarLayout(
    sidebarPanel(
      dateInput("start_date", "Start Date:", value = Sys.Date() - 30),
      dateInput("end_date", "End Date:", value = Sys.Date()),
      actionButton("scrape", "Get posts")
    ),
    mainPanel(
      uiOutput("html_output"),
      p("You are recieving this email because you have subscribed to the digest. To unsubscribe, simply respond to this email, asking to unsubscribe.")
    )
  )
)

