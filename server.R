library(shiny)
library(ggvis)
library(dplyr)
library(xtable)
source("functions_v02.r",local=TRUE)

Herd_sens = c(0.55,0.65,0.75,0.85,0.95)
Tol = c(0.01,0.05,0.10)

`%then%` = shiny:::`%OR%`

# Define server Logic 
shinyServer(function(input, output, session) {
#Reactive function to generate results
Results = reactive({
  Results_local = c()
  Calc_herd_sens = 0
  Calc_herd_spec = 0
  
  #code for progress bar
  withProgress(message = 'Calculating values...', 
               detail = "Please wait...",
               value=0,{
                 Sys.sleep(1)
  
  #validating input
  validate(
      need(isolate(input$Herd_size)!="","Please enter a Herd size") %then%
      need(isolate(input$Herd_size)>0, "Please enter a positive Herd size") %then%
      need(isolate(input$Herd_size)<3000, "Please enter a Herd size of less than 3000.")
  )  
  
  #getting input
  input$goButton  #reactive on pressing of button not on changing of values
                  #values below are isolated
  Test_sens = isolate(input$Test_sens/100)
  Test_spec = isolate(input$Test_spec/100)
  Herd_spec = isolate(input$Herd_spec/100)
  Conf = isolate(input$Conf_slider/100)
  Herd_size = isolate(input$Herd_size)
  Prev = isolate(input$Prev/100)
  Herd_prev = isolate(input$Herd_prev/100)
    
  #Generate results for different tolerances
  #Generate results for different herd sensitivities
  for(j in c(1:length(Herd_sens))){
    Number_animals = num_anim(Test_sens,Test_spec,Prev,Herd_size,1-Herd_sens[j],1-Herd_spec)
    Calc_herd_sens = Number_animals[3]
    Calc_herd_spec = Number_animals[4]
    for(i in c(1:3)){
      Number_herds = num_herds(Conf,Tol[i],Calc_herd_sens,Calc_herd_spec,Herd_prev)
      Results_local = rbind(Results_local,
                            c(Conf,Tol[i],Herd_sens[j],
                            Calc_herd_sens,Calc_herd_spec,
                            Number_herds,Number_animals[1],Number_animals[2])) 
    }
    #update progress bar
    incProgress(1/3)
  }
    
  colnames(Results_local) = c("Confidence","Tolerance","Herd.Sensitivity",
                              "Calc.Herd.Sensitivity","Calc.Herd.Specificity",
                              "Number.Herds","Number.Animals","Cutpoint")
  Results_local = data.frame(Results_local,row.names=NULL)
  Results_with_errors = Results_local
  if(length(which(Results_local$Number.Animals==-1))>0){
    Results_without_errors = Results_local[-which(Results_local$Number.Animals==-1),]
  }else{
    Results_without_errors = Results_local
  }
  Results_with_errors$Number.Animals[which(Results_with_errors$Number.Animals==-1)] = "Not Available"
  return(list(Results_without_errors,Results_with_errors))
  #finishing progress bar
  })
#finishing Results function  
})

#Reactive function to plot results
make_ggvis = reactive({
if(!is.null(Results()[[1]])){
  Orange = colorRampPalette(c("darkorange4","gold"))
  Blue = colorRampPalette(c("darkblue","lightblue"))
    if(input$Log==FALSE){
#Plot results    
      Results()[[1]] %>%
        dplyr::mutate(Sensitivity = factor(Herd.Sensitivity),Tolerance = factor(Tolerance)) %>%
        ggvis(x=~Number.Animals,y=~Number.Herds) %>% 
        group_by(Tolerance) %>%
        layer_paths(stroke=~Tolerance,strokeWidth:=2) %>%
        scale_nominal("stroke",
                      range = Blue(3)) %>%
        add_legend(scales = "stroke", title = "Tolerance",
                   properties = legend_props(
                     title = list(fontSize = 14),
                     labels = list(fontSize = 12, dx = 5),
                     symbol = list(strokeWidth = 2,shape = "square")
                    )) %>%  
        layer_points(fill = ~Sensitivity) %>%
        scale_nominal("fill",
                      range = Orange(5)) %>%
        add_legend(scales = "fill", title = "Herd Sensitivity", 
                   properties = legend_props(
                     title = list(fontSize = 14),
                     labels = list(fontSize = 12, dx = 5),
                     legend = list(y = 75)
                    )) %>%
        add_axis("x",title="Number of animals tested per herd") %>%
        add_axis("y",title="Number of Herds",title_offset = 75) %>%
        add_tooltip(function(df) 
                    paste("<p>With a tolerance of",df$Tolerance,"and a Herd sensitivity of &ge;",df$Sensitivity,"</p>",
                          "<p>- the number of herds to be sampled is",df$Number.Herds,"<p/>",
                          "<p>- the number of animals is",df$Number.Animals,"<p/>")) %>%
                    set_options(duration=0)
    }else{
#Plot results with Log scale
      Results()[[1]] %>%
        dplyr::mutate(Sensitivity = factor(Herd.Sensitivity),Tolerance = factor(Tolerance),Log.Herds = log10(Number.Herds)) %>%
        ggvis(x=~Number.Animals,y=~Log.Herds) %>% 
        group_by(Tolerance) %>%
        layer_paths(stroke=~Tolerance,strokeWidth:=2) %>%
        scale_nominal("stroke",
                      range = Blue(3)) %>%
        add_legend(scales = "stroke", title = "Tolerance",
                   properties = legend_props(
                     title = list(fontSize = 14),
                     labels = list(fontSize = 12, dx = 5),
                     symbol = list(strokeWidth = 2,shape = "square")
                   )) %>%  
        layer_points(fill = ~Sensitivity) %>%
        scale_nominal("fill",
                      range = Orange(5)) %>%
        add_legend(scales = "fill", title = "Herd Sensitivity", 
                   properties = legend_props(
                     title = list(fontSize = 14),
                     labels = list(fontSize = 12, dx = 5),
                     legend = list(y = 75)
                   )) %>%
        add_axis("x",title="Number of animals tested per herd") %>%
        add_axis("y",title="Log(Number of Herds)",title_offset = 75) %>%
        add_tooltip(function(df) 
                    paste("<p>With a tolerance of",df$Tolerance,"and a Herd sensitivity of &ge;",,"</p>",
                          "<p>- the number of animals is",df$Number.Animals,"<p/>")) %>%
                    set_options(duration=0)
  #finishing Log if statement
    }
}
})  

######
##Output
#Plot
make_ggvis %>% bind_shiny("ggvis", "ggvis_ui")

#Plot Title
output$plot_title = renderUI({
  if(nrow(Results()[[1]])!=0){ #only plot title if we actually have results
    HTML('<p style="font-size:20px; font-weight:bold; text-align:center"> 
        Number of Herds Sampled vs Number of Animals Sampled 
        </p>')
  }
})

#Errors
output$error_text = renderUI({
  #if there were values we couldn't calculate output those with errors
  if(nrow(Results()[[1]])==0){ #if we have no results at all
  
    HTML('<p style="font-size:15px; color:red">When the above calculation was attempted the number of animals  
         could not be calculated. The values attempted are shown in the tabulated results.</p>')
  
  }else if(nrow(Results()[[1]])!=15){ #if we don't have all the results
    
    HTML('<p style="font-size:15px; color:red">When the above calculation was attempted the values of the number of animals 
         could not be calculated for certain tolerances and herd sensitivities. All values are shown in the tabulated results.</p>')
  
  } 
})

#Notes - to sit just below the plot for a little more explanation
output$notes = renderUI({
  if(nrow(Results()[[1]])!=0){ #only plot notes if we actually have results
    HTML('<p style="font-size:18px; font-weight:bold; text-align:left"> 
         Notes 
         </p>
         <p style="font-size:15px; text-align:left"> 
          Note that by increasing the number of animals tested within the herd, the herd level sensitivity
          increases and thus fewer herds will be required. How best to optimise this trade-off will depend 
          on the marginal cost of testing an extra animal compared to the marginal cost of testing an extra herd.
         </p>
         <p>The actual achieved herd sensitivity and specificity are higher than the desired herd sensitivity
         and specificity. This is because the number of animals tested can only be increased in units of one.
         The calculated herd sensitivity and specificity represent the sensitivity and specificity achieved
         testing the smallest number of animals and still satisfying the desired herd sensitivity and specificity.
         </p>')
  }
  })

#Table
output$Results_table = renderDataTable({
  data = Results()[[2]][,-c(1,8)]
  data[,c(1,2)] = 100*data[c(1,2)]
  data[,c(3,4)] = 100*round(data[c(3,4)],4)
  colnames(data)=c("Tolerance(%)<br>&nbsp;","Minimum Desired<br>Herd Sensitivity(%)",
                   "Calculated<br>Herd Sensitivity(%)","Calculated<br>Herd Specificity(%)",
                   "Number of<br>Herds","Number of<br>Animals")
  return(data)}, 
  options = list(paging=FALSE,searching=FALSE)
)


#Exporting Results
output$Export_results <- downloadHandler(
  filename = function() {
    paste('SampleSizeCalculations-', Sys.Date(), '.csv', sep='')
  },
  content = function(file) {
    write.csv(Results()[[2]], file, row.names=FALSE)
  }
)

#All finished so complete shiny function
})
