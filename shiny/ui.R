
library(shiny)
library(shinydashboard)
library(leaflet)
library(highcharter)

dashboardPage(
    dashboardHeader(
        title = "Agua: Disponiblidad"
    ),
    dashboardSidebar(
        collapsed = TRUE,
        sidebarMenu(
            menuItem("Nacional", tabName = "nacional")
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(
                tabName = "nacional",
                fluidRow(
                    valueBox(37, "Regiones Hidrológicas", icon = icon("water"), color = "blue"),
                    valueBox(757, "Cuencas", icon = icon("tint"), color = "aqua"),
                    valueBox(104, "Cuencas con déficit de disponibilidad media anual en 2020", icon = icon("tint-slash"), color = "teal"),
                ),
                fluidRow(
                    box(
                        title = "Regiones hidrológicas",
                        solidHeader = T,
                        leafletOutput(
                            outputId = "RH"
                        ),
                        footer = "Fuente: CONAGUA. Subdirección General Técnica."
                    ),
                    tabBox(
                        title = textOutput("rhSelected"),
                        id = "rhTab", 
                        tabPanel(
                            title = "Disponibilidad",  
                            value = "disp",
                            highchartOutput("rhDisp"),
                        ),
                        tabPanel(
                            title = "Precipitación", 
                            value = "precip",
                            highchartOutput("rhPrecip")
                        )
                    )
                )
            )
        )
    )
)

