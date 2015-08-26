library(shiny)
library(ggvis)
library(markdown)
library(shinyBS)
library(DT)


# Define UI 
###########################################
# constructing navbar with logo
###########################################
shinyUI(fluidPage(
  list(tags$head(HTML())),
  div(style = "padding: 1px 0px; width: '100%';",
      titlePanel(
        title = "", windowTitle = "Two-stage Sample Size Calculator"
      )
  ),
  navbarPage(
    title = div("Sample Size Calculator"),
############################################
#Background tab
############################################
  tabPanel("Background",
    includeCSS("css/bootstrap.css"),
    includeCSS("css/styles.css"),
    fluidRow(
      column(2),#blank for the moment
      column(8,
        includeMarkdown("background.md")
      ),
      column(2)
    ) 
  #finishing tabPanel         
  ),
############################################
#Main tab with inputs and graph
############################################ 
  tabPanel("Graphical Output",
  fluidRow(
    tags$head(
      tags$style(HTML("
      .shiny-output-error-validation {
        color: green; font-size:20pt;
      }
    "))
    ),
    column(1),
    column(10,
    sidebarLayout(
      #Sidebar with controls 
      sidebarPanel(
        sliderInput("Test_sens", "Test Sensitivity (%)", min = 1, max = 100,
                    value = 65, step = 1, ticks = F),
        sliderInput("Test_spec", "Test Specificity (%)", min = 1, max = 100,
                    value = 80, step = 1, ticks = F),
        sliderInput("Herd_spec", "Minimum Desired Herd Specificity (%)", 
                    min = 55, max = 99, value = 65, step = 1, ticks = F),
        sliderInput("Conf_slider","Confidence (%)", min = 90, max = 99,
                    value = 95, step = 1, ticks = F),
        sliderInput("Prev", "Animal level Prevalence (%)", min = 1, max = 100,
                    value = 20,step = 1,ticks = F),
        sliderInput("Herd_prev", "Herd level Prevalence (%)", min = 1, 
                    max = 50, value = 5, step = 1, ticks = F),
        numericInput("Herd_size", "Herd Size", 200, min = 1, max = 2000, 
                     step = 1),
        checkboxInput("Log","Take Log of Number of Herds", value = FALSE),
        ###Action button
        actionButton("goButton","Calculate Sample Size"),
        uiOutput("ggvis_ui")
      #finish sidebarPanel
      ,width = 3),           
      #Main panel with all the output
      mainPanel(
          uiOutput("Error_text"),
          uiOutput("Plot_title"),
          ggvisOutput("ggvis"),
          uiOutput("Plot_notes")
      #finishing mainPanel
      ,width = 7) 
    #finishing sidebarlayout                 
    ),
    #adding tooltips for all inputs using bsTooltip from shinyBS
    #note that tooltip title cannot contain a line break
    bsTooltip("Test_sens","Select the sensitivity of your test (i.e. individual animal level).","top","hover"),
    bsTooltip("Test_spec","Select the specificity of your test (i.e. individual animal level).","top","hover"),
    bsTooltip("Herd_spec","Select your Herd level specificity.","top","hover"),
    bsTooltip("Conf_slider","Select the confidence you would like for the result.","top","hover"),
    bsTooltip("Prev","Select the minimum within Herd Prevalence for a positive herd.","top","hover"),
    bsTooltip("Herd_prev","Select Your a priori estimate for the Herd Level Prevalence.","top","hover"),
    bsTooltip("Herd_size","Input your typical herd size. The value must be between 1 and 2000.","top","hover"),
    bsTooltip("Log","Reduce the values of the vertical axis by taking base 10 Log of the values. This will make it easier to differentiate between some of the values.","top","hover")
    #finishing column
    ),
    column(1)
    #finishing fluidRow
  )
  #finishing tabPanel  
  ),
############################################
#Table tab
############################################ 
  tabPanel("Tabulated Results",
    fluidRow(
      column(2), #blank for the moment
      column(8,
             downloadButton("Export_results", "Export Results as CSV file"),
             dataTableOutput("Results_table"),
             uiOutput("Table_notes")
      ),
      column(2) #blank for the moment         
    )
  #finishing tabPanel
  )
  #finishing navbarpage
  )
#finishing fluidpage and shiny UI
))