
library(shiny)
library(shinydashboard)
library(sf)
library(leaflet)
library(tidyverse)
library(scales)
library(highcharter)

# R -------------------------------------------------------------------------------------------

rh_sf <- 
    st_read( 
        dsn = "Regiones_Hidrologicas_2019", 
        layer = "Regiones_Hidrologicas_2019"
    ) %>% 
    st_transform(4326) %>% 
    left_join(read_csv("data/disp2020.csv")) %>% 
    filter(id_rh != 32)

bin_pal <- colorBin('YlGnBu', rh_sf$num_cuen, bins = 5)

labels <- 
    str_glue(
        "<b>{id}. {nom}</b><br>
        Extensión territorial: {comma(exten)} km<sup>2</sup><br>
        Número de cuencas: {num}<br>
        Cuencas con disponibilidad al 2020: {nc}", 
        id = rh_sf$id_rh,
        nom = rh_sf$nom_rh,
        exten = rh_sf$exten_km2,
        num = rh_sf$num_cuen,
        nc = rh_sf$n_disp
    ) %>% 
    map(htmltools::HTML)

preds <- read_csv("data/predicciones.csv")

# Server --------------------------------------------------------------------------------------

shinyServer(function(input, output) {

    output$RH <- renderLeaflet({
        leaflet(
            rh_sf,
            options = leafletOptions(zoomControl = FALSE, minZoom = 4, maxZoom = 6)
        ) %>%
            addProviderTiles(providers$CartoDB.Positron) %>%
            addPolygons(
                layerId = ~id_rh,
                fillColor = ~bin_pal(num_cuen),
                color = "grey",
                weight = 1,
                fillOpacity = 0.4,
                highlightOptions = highlightOptions(weight = 2, color = 'black'),
                label = labels
            ) %>%
            addLegend(
                pal = bin_pal,
                title = "Número de cuencas",
                values = ~(num_cuen),
                position = "topright"
            )
    })
    
    v0 <- reactive({validate(need(!is.null(input$RH_shape_click), "Selecciona una región"))})
    v1 <- reactive({validate(need(!is.null(input$RH_shape_click), ""))})
    
    rh <- reactive({
        input$RH_shape_click[1]
    })
    
    output$rhSelected <- renderText({
        v0()
        
        preds %>%
            filter(id_rh == rh(), !is.na(Nombre_rh)) %>% 
            pull(Nombre_rh) %>% 
            unique()
    })
    
    output$rhDisp <- renderHighchart({
        v1()
        
        preds %>%
            filter(id_rh == rh()) %>%
            mutate(across(dma:p, ~round(., 2))) %>%
            rename(`Disponibilidad Media` = dma, `Disponibilidad Estimada` = p) %>% 
            pivot_longer(5:6) %>% 
            hchart("line", hcaes(x = anio, y = value, group = name)) %>% 
            hc_xAxis(title = list(text = "Año")) %>% 
            hc_yAxis(title = list(text = "Disponibilidad media anual hm<sup>3</sup>", useHTML = T))
    })
    
    output$rhPrecip <- renderHighchart({
        v1()
        
        preds %>%
            filter(id_rh == rh()) %>%
            mutate(across(prec, round, 2)) %>% 
            hchart("line", hcaes(x = anio, y = prec)) %>% 
            hc_title(text = "Estimaciones de la precipitación anual en la región") %>% 
            hc_xAxis(title = list(text = "Año")) %>% 
            hc_yAxis(title = list(text = "Precipitación (mm)"))
    })
    
})

