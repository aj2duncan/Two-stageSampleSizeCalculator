library(shiny)
library(ggvis)
library(dplyr)
library(xtable)
source("functions_v02.r",local=TRUE)

Herd_sens = c(0.55,0.65,0.75,0.85,0.95)
Tol = c(0.01,0.05,0.10)

`%then%` = shiny:::`%OR%`

# Define server logic 
shinyServer(function(input, output, session) {
#Reactive function to generate results
Results = reactive({
  Results_herd_local = c()
  Results_anim_local = c()
  
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
    
  #Generate results for different tolerances
  for(i in c(1:3)){
    for(j in c(1:length(Herd_sens))){
      Number_herds = num_herds(Conf,Tol[i],Herd_sens[j],Herd_spec,Prev)
      Results_herd_local = rbind(Results_herd_local,c(Conf,Tol[i],Herd_sens[j],Number_herds))
    }
    #update progress bar
    incProgress(1/3)
  }
      
  #Generate results for different herd sensitivities
  for(j in c(1:length(Herd_sens))){
    Number_animals = num_anim(Test_sens,Test_spec,Prev,Herd_size,1-Herd_sens[j],1-Herd_spec)
    Results_anim_local = rbind(Results_anim_local,c(Herd_sens[j],Number_animals))
  }
  
  Results_anim_local = rbind(Results_anim_local,Results_anim_local,Results_anim_local)

  #Bind them together
  Results_local = cbind(Results_herd_local,Results_anim_local)
  Results_local = Results_local[,-c(5)]
    
  #num_herds(C,L,HSENS,HSPEC,HTP)
  colnames(Results_local) = c("Confidence","Tolerance","Herd.Sensitivity","Number.Herds","Number.Animals","Cutpoint","P")
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
  Orange = colorRampPalette(c("darkorange3","orange"))
  Blue = colorRampPalette(c("darkblue","lightblue"))
    if(input$log==FALSE){
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
                    paste("<p>With a tolerance of",df$Tolerance,"and a Herd sensitivity of",df$Sensitivity,"</p>",
                          "<p>- the number of herds to be sampled is",df$Number.Herds,".<p/>",
                          "<p>- the number of animals is",df$Number.Animals,"<p/>")) %>%
                    set_options(duration=0)
    }else{
#Plot results with log scale
      Results()[[1]] %>%
        dplyr::mutate(Sensitivity = factor(Herd.Sensitivity),Tolerance = factor(Tolerance)) %>%
        ggvis(x=~Number.Animals,y=~log10(Number.Herds)) %>% 
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
          paste("<p>With a tolerance of",df$Tolerance,"and a Herd sensitivity of",df$Sensitivity,"</p>",
                "<p>- the number of herds to be sampled is",df$Number.Herds,".<p/>",
                "<p>- the number of animals is",df$Number.Animals,"<p/>")) %>%
        set_options(duration=0)
  #finishing log if statement
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



#Table
output$Results_table = renderDataTable({
  data = Results()[[2]][,c(2,3,4,5)]
  colnames(data)=c("Tolerance","Herd Sensitivity","Number of Herds","Number of Animals")
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
