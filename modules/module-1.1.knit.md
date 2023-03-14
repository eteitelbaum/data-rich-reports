---
title: "Module 1.1"
subtitle: "Working With Data"
format: html
execute: 
  echo: true
  message: false
  warning: false
---


## Pre-work

At this point you should already have installed R, R Studio the Tidyverse collection of packages (see [getting started](/modules/getting-started.html)). In this module, we will be using the `readr`, `readxl` and `dplyr` from the Tidyverse.

You will also need to install the `vdemdta` package which we will use to interface with the V-Dem Institute's API. Because this package is not on the CRAN Network, you will have to do a couple of extra steps. First, install the devtools package by typing `install.packages("devtools")` in your console. Next, use devtools to install the `vdemdata` package directly from GitHub. Type `devtools::install_github("vdeminstitute/vdemdata")` in your console. 

Now clone [the repo]() for this module. Then open the **module-1.1.qmd** file and load the packages: 


::: {.cell}

```{.r .cell-code}
library(tidyverse)
library(vdemdata)
```
:::


## Reading data from a .csv file


{{< video https://www.youtube.com/embed/wo9vZccmqwc title='Reading Data from a .csv File' >}}


::: {.cell}

```{.r .cell-code}
demdata <- read_csv(data/"demdata.csv")
```
:::


## Reading data from an excel file


{{< video https://www.youtube.com/embed/wo9vZccmqwc title='Reading Data from an Excel File' >}}




## Reading data from an API



## Assignment 
