library(shiny)
library(ggvis)
library(dplyr)

initial_values = tbl_df(read.csv("initial_values.csv", 
                          stringsAsFactors = FALSE))

source("functions_v02.r",local = TRUE)

#Default values for Herd Sensitivity and Tolerance
Herd_sens = c(0.55,0.65,0.75,0.85,0.95)
Tol = c(0.025,0.05,0.10)

#start shiny function
shinyServer(function(input, output, session) {
  
Results = reactiveValues(data_for_plot = initial_values,
                         data_for_table = initial_values, 
                         error_flag = 0,
                         num_problems = 0)
  
# listening to goButton which will let us change the values in the list  
observeEvent(input$goButton, {
  Results_local = c()
  Calc_herd_sens = 0
  Calc_herd_spec = 0
  
  #code for progress bar
  withProgress(message = 'Calculating values...', 
               detail = "Please wait...",
               value = 0,{
                 Sys.sleep(1)

  #getting input
  Test_sens = isolate(input$Test_sens/100)
  Test_spec = isolate(input$Test_spec/100)
  Herd_spec = isolate(input$Herd_spec/100)
  Conf = isolate(input$Conf_slider/100)
  Herd_size = isolate(input$Herd_size)
  Prev = isolate(input$Prev/100)
  Herd_prev = isolate(input$Herd_prev/100)

  if (Test_sens + Test_spec >= 1) { #if test is valid run calculations
    for (j in c(1:length(Herd_sens))) {
      Number_animals = num_anim(Test_sens,Test_spec,Prev,Herd_size,
                                1 - Herd_sens[j], 1 - Herd_spec)
      Calc_herd_sens = Number_animals[3]
      Calc_herd_spec = Number_animals[4]
      for (i in c(1:3)) {
        Number_herds = num_herds(Conf,Tol[i],Calc_herd_sens,Calc_herd_spec,
                                 Herd_prev)
        Results_local = rbind(Results_local,
                              c(Test_sens,Test_spec,Herd_size,Prev,Herd_prev,
                                Conf,Tol[i],Herd_sens[j],Herd_spec,
                                Calc_herd_sens,Calc_herd_spec,
                                Number_herds,Number_animals[1],
                                Number_animals[2])) 
      }#finish i
    #update progress bar
    incProgress(1/3)
    }#finish j
    colnames(Results_local) = c("Test.Sensitivity","Test.Specificity",
                                "Herd.Size","Prevalence","Herd.Prevalence",
                                "Confidence","Tolerance","Herd.Sensitivity",
                                "Herd.Specificity","Calc.Herd.Sensitivity",
                                "Calc.Herd.Specificity","Number.Herds",
                                "Number.Animals","Cutpoint")
    Results_local = data.frame(Results_local,row.names = NULL)
    Results_with_errors = Results_local
    num_problems = length(which(Results_local$Number.Animals == -1))
    if (num_problems > 0) {
      Results_without_errors = Results_local[
        -which(Results_local$Number.Animals == -1),]
    }else{
      Results_without_errors = Results_local
    }
    Results_with_errors$Number.Animals[
      which(Results_with_errors$Number.Animals == -1)] = 
      "Insufficient animals to achieve desired test performance."
    test_flag = 0
    
    # change reactive values
    Results$data_for_plot = Results_without_errors
    Results$data_for_table = Results_with_errors
    Results$error_flag = test_flag
    Results$num_problems = num_problems
  #finishing test if
  } else {#if test isn't valid return blank dataframes with error flag.
    #update progress bar
    incProgress(1)
    
    blank_results = return_blanks()
    # change reactive values
    Results$data_for_plot = blank_results$Results_without_errors
    Results$data_for_table = blank_results$Results_with_errors
    Results$error_flag = 1
    Results$num_problems = 15
  }
  
  #finishing progress bar
  })
#finishing observeEvent
})

#Reactive function to plot results
make_ggvis = reactive({

if (Results$num_problems != 15 && Results$error_flag != 1) {
  Orange = colorRampPalette(c("darkorange4","gold"))
  Blue = colorRampPalette(c("darkblue","lightblue"))
    if (input$Log == FALSE) {
#Plot results    
      Results$data_for_plot %>%
        dplyr::mutate(Sensitivity = factor(Herd.Sensitivity),
                      Tolerance = factor(Tolerance)) %>%
        ggvis(x = ~Number.Animals, y = ~Number.Herds) %>% 
        group_by(Tolerance) %>%
        layer_paths(stroke = ~Tolerance,strokeWidth := 2) %>%
        scale_nominal("stroke",
                      range = Blue(3)) %>%
        add_legend(scales = "stroke", title = "Tolerance",
                   properties = legend_props(
                     title = list(fontSize = 14),
                     labels = list(fontSize = 12, dx = 5),
                     symbols = list(strokeWidth = 2,shape = "square"))) %>% 
        layer_points(fill = ~Sensitivity) %>%
        scale_nominal("fill",
                      range = Orange(5)) %>%
        add_legend(scales = "fill", title = "Herd Sensitivity", 
                   properties = legend_props(
                     title = list(fontSize = 14),
                     labels = list(fontSize = 12, dx = 5),
                     legend = list(y = 75)
                    )) %>%
        add_axis("x", title = "Number of animals tested per herd") %>%
        add_axis("y", title = "Number of Herds",title_offset = 75) %>%
        add_tooltip(function(df) 
                    paste("<p>With a tolerance of",df$Tolerance,
                          "and a Herd sensitivity of &ge;",df$Sensitivity,
                          "</p>","<p>- the number of herds to be sampled is",
                          df$Number.Herds,"<p/>","<p>- the number of animals is"
                          ,df$Number.Animals,"<p/>")) %>%
                    set_options(duration = 0)
    }else{
#Plot results with Log scale
      Results$data_for_plot %>%
        dplyr::mutate(Sensitivity = factor(Herd.Sensitivity),
                      Tolerance = factor(Tolerance),
                      Log.Herds = log10(Number.Herds)) %>%
        ggvis(x = ~Number.Animals, y = ~Log.Herds) %>% 
        group_by(Tolerance) %>%
        layer_paths(stroke = ~Tolerance, strokeWidth := 2) %>%
        scale_nominal("stroke",
                      range = Blue(3)) %>%
        add_legend(scales = "stroke", title = "Tolerance",
                   properties = legend_props(
                     title = list(fontSize = 14),
                     labels = list(fontSize = 12, dx = 5),
                     symbols = list(strokeWidth = 2,shape = "square"))) %>%
        layer_points(fill = ~Sensitivity) %>%
        scale_nominal("fill",
                      range = Orange(5)) %>%
        add_legend(scales = "fill", title = "Herd Sensitivity", 
                   properties = legend_props(
                     title = list(fontSize = 14),
                     labels = list(fontSize = 12, dx = 5),
                     legend = list(y = 75)
                   )) %>%
        add_axis("x", title = "Number of animals tested per herd") %>%
        add_axis("y", title = "Log(Number of Herds)",title_offset = 75) %>%
        set_options(duration = 0)
  #finishing Log if statement
    }
} else {# blank plot for case when sensitivity + specificify < 100
  data.frame(x = 0, y = 0) %>% 
    ggvis(~x, ~y, size := 1) %>%
    layer_points() %>%
    add_axis("x", title = "Number of animals tested per herd") %>%
    add_axis("y", title = "Number of Herds",title_offset = 75)
}
})  

######
##Output
#Plot
make_ggvis %>% bind_shiny("ggvis", "ggvis_ui")

#Plot Title
output$Plot_title = renderUI({
  #only plot title if we actually have results
  if (!is.null(Results$data_for_plot) && Results$error_flag != 1) { 
    HTML('<p style="font-size:20px; font-weight:bold; text-align:center"> 
        Number of Herds Sampled vs Number of Animals Sampled 
        </p>')
  }
})

#Errors
output$Error_text = renderUI({
  #if the test wasn't valid report the error
  if (Results$error_flag == 1) {
     HTML('<p style="font-size:15px; color:red">Please ensure that the test 
          sensitivity and test specificity sum to at least 100%.</p>')
  #if there were values we couldn't calculate output those with errors
  }else if (Results$num_problems == 15) { #if we have no results at all
    HTML('<p style="font-size:15px; color:red">When the above calculation was 
         attempted the number of animals could not be calculated. The values 
         attempted are shown in the tabulated results.</p>')
  
  }else if (Results$num_problems > 0 && Results$num_problems < 15) { 
    #if we don't have all the results
    HTML('<p style="font-size:15px; color:red">When the above calculation was 
         attempted the values of the number of animals could not be calculated 
         for certain tolerances and herd sensitivities. All values are shown in 
         the tabulated results.</p>')
  } 
})

#Notes - to sit just below the plot for a little more explanation
output$Plot_notes = renderUI({
  #only plot notes if we actually have results
  if (Results$num_problems != 15) { 
    HTML('<p style="font-size:18px; font-weight:bold; text-align:left"> 
         Notes 
         </p>
         <p style="font-size:15px; text-align:left"> 
          Note that by increasing the number of animals tested within the herd, 
          the herd level sensitivity increases and thus fewer herds will be 
          required. How best to optimise this trade-off will depend on the 
          marginal cost of testing an extra animal compared to the marginal cost
          of testing an extra herd.
         </p>
         <p>The actual achieved herd sensitivity and specificity are higher than 
          the desired herd sensitivity and specificity. This is because the 
          number of animals tested can only be increased in units of one. The 
          calculated herd sensitivity and specificity represent the sensitivity 
          and specificity achieved testing the smallest number of animals and 
          still satisfying the desired herd sensitivity and specificity.
         </p>')
  }
  })

#constructing table for data
data = function(){
  d1 = Results$data_for_table[,-c(1:6,9,14)]
  d1[,c(1,2)] = 100*d1[c(1,2)]
  d1[,c(3,4)] = 100*round(d1[c(3,4)],4)
  #d1[,6] = as.numeric(d1[,6]) # forcing the number of animals to be numeric.
  return(d1)
}


#Table
output$Results_table = renderDataTable({
  datatable(data(), 
            colnames = c("Tolerance(%)","Minimum Desired Herd Sensitivity(%)",
                           "Calculated Herd Sensitivity(%)",
                           "Calculated Herd Specificity(%)",
                           "Number of Herds","Animals per Herd"),
            rownames = FALSE,
            options = list(paging = FALSE, searching = FALSE), 
            escape = FALSE)
})

#Table notes 
output$Table_notes = renderUI({
  if (Results$error_flag != 1) {
    HTML('<p style="font-size:18px; font-weight:bold; text-align:left"> 
           Notes 
          </p>
          <p style="font-size:15px; text-align:left"> 
          The .csv file ready for download contains all input values in 
          addition to the output values shown above.
          </p>')
  }else{
    HTML('<p style="font-size:15px; color:red">Please ensure that the test 
          sensitivity and test specificity sum to at least 100%.</p>')
  }
})

#Exporting Results
output$Export_results = downloadHandler(
    filename = function() {
      paste('SampleSizeCalculations-', Sys.Date(), '.csv', sep = '')
    },
    content = function(file) {
      write.csv(Results$data_for_table, file, row.names = FALSE)
    }
)

#All finished so complete shiny function
})
