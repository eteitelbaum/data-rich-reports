---
title: "Module 5.2"
subtitle: ""
format: html
highlight-style: atom-one
execute:
  echo: true
  message: false
  warning: false
---


:::{.callout-tip}
- Review the prework for [module 5.1](https://dataviz-gwu.rocks/modules/module-5.1.html) and make sure that you have everything installed
- Install [ecm](https://cran.r-project.org/web/packages/ecm/ecm.pdf), which we will use to build our recession shading helper script
- Install [shinyWidgets](https://dreamrs.github.io/shinyWidgets/) and familiarize yourself with its basic functions
- We will be using [lubridate](https://lubridate.tidyverse.org/), which is part of the Tidyverse. So it should already be installed; but take some time to familiarize yourself with its basic purpose and functions. 
:::

## Overview



## App with a reactive API call and date parameters

<iframe src="https://emmanuelteitelbaum.shinyapps.io/fred_app/" width="780" height="560" data-external="1"></iframe>


## Setup

{{< video https://www.youtube.com/embed/wo9vZccmqwc title = 'View regression results with broom'>}}


::: {.cell}

```{.r .cell-code}
# Load packages
library(shiny)
library(fredr)
library(dplyr)
library(ggplot2)
library(lubridate)

# Set Fred API key 
fredr_set_key("YOUR FRED API KEY") 

# Assign FRED series to objects
cci <- "CSCICP03USM665S" # consumer confidence
bci <- "BSCICP03USM665S" # business confidence
cli <- "USALOLITONOSTSAM" # composite lead indicator
unemp_rate <- "UNRATE" # unemployment rate
growth <- "A191RL1Q225SBEA" # growth rate

# set start and end date
start_date <- as.Date("1970-01-01")
end_date <- as.Date(Sys.Date())

# Create list of named values for the input selection
vars <- c("Consumer Confidence" = cci, 
          "Business Confidence" = bci, 
          "Composite Indicator" = cli, 
          "Unemployment Rate" = unemp_rate,
          "Growth Rate" = growth)

# Load helper script
source("helper.R") # scroll down, code pasted below
```
:::



## ui

{{< video https://www.youtube.com/embed/wo9vZccmqwc title = 'View regression results with broom'>}}

Define UI for application that draws a line chart


::: {.cell}

```{.r .cell-code}
ui <- fluidPage(

    # Application title
    titlePanel("FRED Data App"),
    
    fluidRow(
      
      # 12 columns on one row: this panel will take 1/4 of it
      column(3, wellPanel(
        selectInput("indicator", "Indicator:", vars)
        ),
      helpText("Select an indicator, choose a date range and view the trend. 
               The grey bars represent economic recessions. 
               The data for this app comes from the St. Louis Fed's 
               FRED database. The consumer confidence, business confidence and 
               lead composite indicators are OECD data downloaded through FRED.")
      ), 
      
      # Remaining 3/4 occupied by plot
      column(8,
        plotOutput("lineChart"),     
        sliderInput(
          "range",
          "",
          min = my("01-1970"),
          max = today(), 
          value = c(my("01-1970"), today()), 
          width = "100%"
        )
      )
    )
)
```
:::



## Server

{{< video https://www.youtube.com/embed/wo9vZccmqwc title = 'View regression results with broom'>}}

Define server logic required to draw a histogram.


::: {.cell}

```{.r .cell-code}
server <- function(input, output) {
  
    # Download data from FRED with reactive function. 
    # Only updates when user selects new indicator
    fred_indicator <- reactive({
      fredr(series_id = input$indicator,
        observation_start = start_date,
        observation_end = end_date)
    })
  
    # Filter data according to chosen years 
    # Only updates when user selects new data range
    fred_data <- reactive({
      fred_indicator() |>
      filter(date %in% (input$range[1]:input$range[2]))
   })

    # Render line chart
    output$lineChart <- renderPlot({
      
      # Build plot with ggplot2
      ggplot(fred_data(), aes(x = date, y = value)) + 
        geom_line(color = "navyblue") +
        labs(
          x = "", 
          y =  names(vars[which(vars == input$indicator)])
        ) +
        theme_minimal() +
        # add recession shading
        add_rec_shade(st_date = input$range[1], 
                      ed_date = input$range[2], 
                      shade_color = "darkgrey",
                      y_min = min(fred_data()$value),
                      y_max = max(fred_data()$value))
    })
}
```
:::



## Call to Shiny app


::: {.cell}

```{.r .cell-code}
# See above for the definitions of ui and server
ui <- ...

server <- ...

# Run the application 
shinyApp(ui = ui, server = server)
```
:::



## Helper script

Helper script for shaded recession rectangles. Save in a file called `helper.R` in same folder as your `app.R` file. See [this post](https://rpubs.com/FSl/609471) for more details. 


::: {.cell}

```{.r .cell-code}
# build recession shading function 
library(ecm)

add_rec_shade<-function(st_date,ed_date,shade_color, y_min, y_max) # are st_date and ed_date being used in this function?
{
  
  recession<-fredr(series_id = "USRECD",observation_start = as.Date(st_date),observation_end = as.Date(ed_date))
  
  recession$diff<-recession$value-lagpad(recession$value,k=1) #code 1 for 1st day of recession, -1 for first day after recession ends
  recession<-recession[!is.na(recession$diff),] #drop 1st N.A. value
  recession.start<-recession[recession$diff==1,]$date #create vector of recession start dates
  recession.end<-recession[recession$diff==(-1),]$date #create vector of recession end dates
  
  if(length(recession.start)>length(recession.end)) # if there are more dates listed in recession.start than recession.end
  {recession.end<-c(recession.end,Sys.Date())} # enter system date for last date in recession.end
  if(length(recession.end)>length(recession.start)) # if there are more dates listed in recession.end than recession.start         
  {recession.start<-c(min(recession$date),recession.start)} # enter the earliest date in recession$date as first date in recession.start
  
  recs<-as.data.frame(cbind(recession.start,recession.end)) # make a dataframe out of recession.start and recession.end
  recs$recession.start<-as.Date(as.numeric(recs$recession.start),origin=as.Date("1970-01-01")) # convert recession.start into a date
  recs$recession.end<-as.Date(recs$recession.end,origin=as.Date("1970-01-01")) # convert recession.end into a 
  if(nrow(recs)>0) # if the number of rows in recs > 0
  {
    rec_shade<-geom_rect(data=recs, inherit.aes=F, #inherit.aes=F overrides default aesthetics
                         aes(xmin=recession.start, xmax=recession.end, ymin=y_min, ymax=y_max), 
                         fill=shade_color, alpha=0.5)
    return(rec_shade)
  }
}
```
:::
