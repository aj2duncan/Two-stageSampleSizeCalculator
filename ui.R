library(shiny)
library(ggvis)
library(markdown)
library(shinyBS)


# Define UI 
shinyUI(navbarPage("Sample Size Calculator",
  tabPanel("Background",
    fluidRow(
      column(2),#blank for the moment
      column(8,
        includeMarkdown("background.md")
      ),
      column(2)
    ) 
  #finishing tabPanel         
  ),
  
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
        sliderInput("Test_sens", "Test Sensitivity (%):", min=55,max=100,value=65,step=1),
        sliderInput("Test_spec", "Test Specificity (%):", min=55,max=100,value=80,step=1),
        sliderInput("Herd_spec", "Herd Specificity (%):", min=55,max=99,value=65,step=1),
        sliderInput("Conf_slider","Confidence (%)", min=90,max=99,value=95,step=1),
        sliderInput("Prev", "Animal level (within herd) Prevalence (%)", min=1,max=50,value=20,step=1),
        numericInput("Herd_size", "Herd Size:", 200, min=1, max=2000, step=1),
        checkboxInput("log","Take Log of Number of Herds",value=FALSE),
        ###Action button
        actionButton("goButton","Calculate Sample Size"),
        uiOutput("ggvis_ui")
      #finish sidebarPanel
      ,width=3),           
      #Main panel with all the output
      mainPanel(
          uiOutput("error_text"),
          uiOutput("plot_title"),
          ggvisOutput("ggvis")
      #finishing mainPanel
      ,width=7) 
    #finishing sidebarlayout                 
    ),
    bsTooltip("Test_sens","Select the sensitivity of your test","right","hover"),
    bsTooltip("Test_spec","Select the specificity of your test","right","hover"),
    bsTooltip("Herd_spec","Select your Herd specificity","right","hover"),
    bsTooltip("Conf_slider","Select the confidence you would like for the result","right","hover"),
    bsTooltip("Prev","Select the Herd Prevalence for the disease that you are interested in","right","hover"),
    bsTooltip("Herd_size","Input your herd size. The value must be between 1 and 2000.","right","hover"),
    bsTooltip("log","Reduce the values of the vertical axis by taking base 10 log of the values","right","hover")
    #finishing column
    ),
    column(1)
    #finishing fluidRow
  )
  #finishing tabPanel  
  ),
  
  tabPanel("Tabulated Results",
    fluidRow(
      column(2), #blank for the moment
      column(8,
             downloadButton("Export_results", "Export Results as CSV file"),
             dataTableOutput("Results_table")  
      ),
      column(2) #blank for the moment         
    )
  #finishing tabPanel
  )
#finishing shinyUI                   
))

