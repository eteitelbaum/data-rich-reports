---
title: "Module 5.1"
subtitle: "Your First Shiny App"
format: 
  html:
    code-link: true
highlight-style: atom-one
execute:
  echo: true
  message: false
  warning: false
---


:::{.callout-tip}
## Prework
- Install Shiny (`install.packages("shiny")`)
- Familiarize yourself with some of the materials available for developing Shiny Apps on Posit's [Shiny website](https://shiny.posit.co/)
- Optional: sign up for a free account on [shinyapps.io](https://www.shinyapps.io/)
- Start a new Shiny project for this lesson. Go to File, select New Directory and then Shiny App. Browse to where you want to save the app, give the directory a name and click Create Project.  
:::

## Overview

In this module, we are going to be learning how to make a Shiny app. Shiny is a web application framework that is designed for building interactive web applications. It is available as an open-source package in R that is maintained by the team at Posit. 

Shiny enables you to create interactive web-based visualizations and dashboards directly from your R code. It simplifies the process of developing web applications by providing a higher-level abstraction and handling the underlying web technologies. Shiny apps are especially useful for interactive data analysis and visualization. With Shiny, you can allow your users to explore data, change parameters, and see the results of an analysis dynamically. And you can do all of this without extensive web development skills.

To display a Shiny app you can just render it locally, but you likely want to share it with a broader audience. For this, you will need to host it on a server. There are lots of different to do this, but the easiest thing to use when you are getting started is [shinyapps.io](https://www.shinyapps.io/). In a later module we will learn to deploy our apps, but for this one it is fine to just view them locally. 

Shiny apps consist of three components:1) a *user interface* (UI); 2) a *server function*; and 3) a *call to the Shiny app*. The UI is the part of the app that defines what the user is going to see and interact with. The server function runs all of the computations and produces the visualizations and output that you want to display. And the call to the Shiny app simply tells Shiny to run the app. 

We are going to talk about each of these elements in turn, but first, have a look at this scatter plot app that we are going to but first take a few minutes to familiarize yourself with this scatter plot app that we are going to building in this this module: 

<iframe src="https://emmanuelteitelbaum.shinyapps.io/vdem-scatter-plot/" width="780" height="500" data-external="1"></iframe>

## Setup 

{{< video https://youtu.be/9KfZbOQGnpY title = 'First Shiny app setup'>}}

I said earlier that there are three main components of a Shiny app (UI, server and call to app). However, with most apps, there is usually a bit of setup int the code before you get to this point. So perhaps you could say there are actually four elements of a Shiny app, with the set up being the "0th" element.

There are going to be two components to the setup for this app. First we are going to "pre-wrangle" our data and store it in a .csv file. I will explain why in a minute. Second, we are going to build a setup code chunk that we will include in our `app.R` file. Let's get started. 

### Wrangling and storing the data

For this app, we want users to be able to create scatter plots using selected variables from the V-Dem dataset. Let's say that we want to have a nice mix of variables related to democracy and development so that users can explore how democracy relates to development and vice versa. So we will filter the data for the post-2000 period and select measures relating to democracy, governance and women's empowerment and then four measures related to development.

We will also make sure to code a region variable and include region in the `group_by()` call so that it stays in the data frame. Then we will take the country mean of the measures for the post-2000 period so that we have one set of observations for each each country. 

Finally, let's then save these data in a .csv file to include with the app. Alternatively, we could have our app wrangle the data each time the app is loaded. This would ensure that the data are always up to date, but it would require more resources than is available with the free version of the Shiny server due to the size of the V-Dem dataset. 


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


### Setup code chunk

Now let's build a setup code chunk that we can include in the app.R script. Here we will load the packages we need for the app and read in the data we just wrangled from the .csv file. Finally, let's go ahead and create a list of variable names for our dropdown menus in the app and map these to the variables in our data frame. 


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


## UI

{{< video https://www.youtube.com/embed/wo9vZccmqwc title = 'User interface (UI)'>}}

The **user interface (UI)** defines the layout and appearance of the web application. Here you tell Shiny what elements such as buttons, sliders, text inputs, plots, and other interactive components that you want users to be able to interact with. 

We will start with the `fluidPage()` function as the outermost layer of our UI and then add additional container functions within it. First we will add a `titlePanel()`. You are free to call this app whatever you like but I thought a good title would be "Democracy and Development." 

Then we can add a sidebar panel with dropdown menus to select the variables to display in the scatter plot. For this we call `sidebarLayout()` and then within that `sidebarPanel()`. 
This next step is really important. We are going to use the list variables called `vars` from our setup code chunk to populate the dropdown menus. To do this we are going to call `selectInput()` twice--once for the x-axis variable that the user wants to appear on the scatter plot and once for the y-axis variable. 

The three main arguments for this function are `input`, `label` and `choices`. `input` is the input ID that we will use to access the user selection later on in the server function. `label` refers to the name that we want to appear above the dropdown menu. And `choices` refers to the list of choices to appear in the dropdown (in our case the list of variables called `vars`.)

We can also include the argument `selected` in our `selectInput()` call to determine which variable is selected by default when the app loads. We are going to specify the sixth variable in the list for the y-axis (`vars[[6]]`) to make sure that the same two variables do not appear on both the x and y axes. 

The final piece of our UI is the main panel where we want our scatter plot to appear. Let's go ahead and add `mainPanel()` and then within that call `plotOutput("scatterplot")`. This is going to dynamically retrieve the updated scatter plot as the user changes the variables in the dropdown menu. 


::: {.cell}

```{.r .cell-code}
# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Democracy and Development"),

    # Sidebar with a two dropdown menus
    sidebarLayout(
      sidebarPanel(
        selectInput(input = 'xcol', label = 'X Variable', choices = vars),
        selectInput(input = 'ycol', label = 'Y Variable', 
                    choices = vars, selected = vars[[6]])
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

{{< video https://www.youtube.com/embed/wo9vZccmqwc title = 'Server'>}}

The **server function** is where you are going to put the logic and computations of the application. The server function receives input from the user interface, processes it, and generates the corresponding output. It can perform calculations, query databases, apply statistical models, and produce visualizations.

The server function contains three arguments. Two of them (`input` and `output`) are mandatory. `session` is an optional parameter that controls the behavior of the app during the user session that we won't get into here. But we will keep it in the function call for now just to remind us that it is there. 

Next we are going to define the output of the app with `output$scatterplot <- renderPlot({})`. This bit of code is going to render a plot and then save it to the output in an object called `scatterplot`. Remember that in the UI, we defined our plot output as `plotOutput("scatterplot")`. This is where that object `scatterplot` is going to come from. 
The scatter plot is going to be created in two steps. First we are going to reactively retrieve the data each time the user selects new inputs. To do this we are going to use the inputs (`xcol`, `ycol`) from the UI to subset our data frame `demdata`, e.g. `dem_data[, c(input$xcol, input$ycol, "region")]`. That is going to create a three-column data frame with the user's selected x variable, y variable and the region coding and store it in an object called `selectedData`.  

From there, we take `selectedData` and use it to create a scatter plot with `ggplot2`. This is done in the usual way, except for a couple of things. First, in our `aes()` call we need to use `get()` to specify the x and y variables. `aes()` uses nonstandard evaluation to capture variable names, meaning that the bare column names of the data frame are read directly so that you do not have to explicitly quote the inputs. However, in this case the names of the inputs are being passed as a string from the user. The `get()` function enables us to retrieve the value of an object based on its name. So our `aes()` call will be `aes(x = get(x = input$xcol), y = get(input$ycol)).` 

The other thing we need to do is to add some special code to deal with the x- and y-axis labels because these are going to change every time the user selects a different variable. Here we are going to use the `names()` function to return the names of the the object selected in the `vars` vector of variable names. To make sure we get the right name from the vector, we are going to use the `which()` function. `which()` returns the value that satisfies a given function, in this case the index number of the `vars` vector that matches the user input. So for example, our x label will be defined as `x = names(vars[which(vars == input$xcol)]`. Here the number returned by `[which(vars == input$xcol)]` is going to be used to subset the `vars` list so that x displays the name of the variable selected by the user.


::: {.cell}

```{.r .cell-code}
# Define server logic required to draw a scatter plot
server <- function(input, output, session) {
  
  # Render the plot
  output$scatterplot <- renderPlot({
    
    # ggplot call
    ggplot(dem_data, aes(x = get(input$xcol), y = get(input$ycol))) +
      geom_point(aes(color = region)) +
      geom_smooth(method = "loess") +
      scale_color_viridis_d(option = "plasma") +
      theme_minimal() +
      labs(
        x =  names(vars[which(vars == input$xcol)]), # select names in vars that
        y =  names(vars[which(vars == input$ycol)]), # match input selections
        caption = "Source: V-Dem Institute",
        color = "Region"
      )
  })
}
```
:::


## Displaying your app

At this point it should be relatively simple to view your app. Just add the call to the Shiny app, e.g. `shinyApp(ui = ui, server = server)` and click "Run App" in RStudio. 


::: {.cell}

```{.r .cell-code}
# See above for the definitions of ui and server
ui <- ...

server <- ...

# Run the application 
shinyApp(ui = ui, server = server)
```
:::


Optionally, right now, you can try setting up an account on [shinyapps.io](https://www.shinyapps.io/). Read over the shinyapps.io [user guide](https://docs.posit.co/shinyapps.io/index.html) and see if you can get it to work. For your final project, you will need to be able to deploy your app but but right now it is fine if you only want to view it locally.


