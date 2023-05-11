---
title: "Module 5.1"
subtitle: "Your First Shiny App"
format: html
highlight-style: atom-one
execute:
  echo: true
  message: false
  warning: false
---


:::{.callout-tip}
- Get a [FRED API key](https://fred.stlouisfed.org/docs/api/api_key.html)
- Install [fredr](https://cran.r-project.org/web/packages/fredr/vignettes/fredr.html) and read about its basic usage
- Install [shiny](https://shiny.posit.co/) and read about the 
:::

## Overview



## Scatter plot app

<iframe src="https://emmanuelteitelbaum.shinyapps.io/vdem-scatter-plot/" width="780" height="500" data-external="1"></iframe>


## Setup 

{{< video https://www.youtube.com/embed/wo9vZccmqwc title = 'View regression results with broom'>}}

### Wrangle data and produce .csv file

Say something about how to set up an app.R script. We could include this code in app.R file, but it would require more resources than a free account. So instead we will wrangle the data first and save it in a .csv file. 


::: {.cell}

```{.r .cell-code}
library(vdemdata)
library(dplyr)
library(readr)

dem_data <- vdem |>
  filter(year > 2000) |>
  select(
    country = country_name, 
    polyarchy = v2x_polyarchy,
    clientelism = v2xnp_client,
    corruption = v2xnp_regcorr,
    womens_emp = v2x_gender,
    gdp_pc = e_gdppc,
    inf_mort = e_peinfmor,
    life_exp = e_pelifeex,
    education = e_peaveduc,
    region = e_regionpol_6C 
  ) |>   mutate(
    region = case_match(region, 
                        1 ~ "Eastern Europe", 
                        2 ~ "Latin America",  
                        3 ~ "Middle East",   
                        4 ~ "Africa", 
                        5 ~ "The West", 
                        6 ~ "Asia")
  ) |>
  group_by(country, region) |>
  summarize_all(mean, na.rm = TRUE)

#glimpse(dem_data)

write_csv(dem_data, "dem_data.csv")
```
:::


This chunk we will include in the app.R script. 


::: {.cell}

```{.r .cell-code}
# load packages
library(shiny)
library(readr)
library(ggplot2)

# load the data 
dem_data <- read_csv("dem_data.csv")

# create list of named values for the input selection
vars <- c("Democracy" = "polyarchy",
          "Clientelism" = "clientelism",
          "Corruption" = "corruption",
          "Women's Empowerment" = "womens_emp",
          "Wealth" = "gdp_pc",
          "Infant Mortality" = "inf_mort",
          "Life Expectancy" = "life_exp", 
          "Education" = "education")
```
:::


## ui 

{{< video https://www.youtube.com/embed/wo9vZccmqwc title = 'View regression results with broom'>}}


::: {.cell}

```{.r .cell-code}
# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Democracy and Development"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
      sidebarPanel(
        selectInput('xcol', 'X Variable', vars),
        selectInput('ycol', 'Y Variable', vars, selected = vars[[6]])
      ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("scatterplot")
        )
    )
)
```
:::



## Server

{{< video https://www.youtube.com/embed/wo9vZccmqwc title = 'View regression results with broom'>}}


::: {.cell}

```{.r .cell-code}
# Define server logic required to draw a scatter plot
server <- function(input, output, session) {
  
  # Render the plot
  output$scatterplot <- renderPlot({
    
    # Combine the selected variables into a new data frame
    selectedData <- dem_data[, c(input$xcol, input$ycol, "region")]
    
    # ggplot call
    ggplot(selectedData(), aes_string(x = input$xcol, y = input$ycol)) +
      geom_point(aes(color = region)) +
      geom_smooth(method = "loess") +
      scale_color_viridis_d(option = "plasma") +
      theme_minimal() +
      labs(
        x =  names(vars[which(vars == input$xcol)]),
        y =  names(vars[which(vars == input$ycol)]),
        caption = "Source: V-Dem Institute", # caption
        color = "Region" # legend title
      )
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
