library(rnaturalearth)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(wbstats)

create_map <- function(var_id, title, legend_title, theme, direction){
  
  ne_countries(scale = "medium", returnclass = "sf") |> 
    left_join(
      wb_data(var_id, mrnev = 1), # change variable id
      join_by(iso_a3 == iso3c)
    ) |> 
    filter(name != "Antarctica") |>  
    ggplot() + 
    geom_sf(aes(fill = eval(parse(text=var_id)))) + # remove quotes
    labs(
      title =  title, # change title
      fill = legend_title, # change legend title
      caption = "Source: World Bank Development Indicators"
    ) +
    theme_map() +
    theme(
      plot.title = element_text(face = "bold"),
    ) +
    scale_fill_viridis_c( 
      option = theme, #  chg theme
      direction = direction # change direction of scale
    )
}
