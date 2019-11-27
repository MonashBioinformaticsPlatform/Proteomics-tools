#Define server logic to read selected file ----
server <- function(input, output, session) {
  options(shiny.maxRequestSize=100*1024^2)## Set maximum upload size to 100MB

#    ####======= Render Functions
#   
  observeEvent(input$merge,{ 
  shinyjs::show("downloadbox")
   output$downloadButton <- renderUI({
     downloadButton('downloadData', 'Download File')
   })
  })

  
## ========= make reactive elements ==================

    qvalue_input<-eventReactive(input$merge,{
      inFile<-input$file1
      if(is.null(inFile))
        return(NULL)
      temp_data<-read.table(inFile$datapath,
                 header = TRUE,
                 fill= TRUE, 
                 sep = "\t",
                 quote = "",
                 stringsAsFactors = FALSE
      )
      return(temp_data)
    })
  
 qvalue_sparse_input<-eventReactive(input$merge,{
    inFile<-input$file2
    if (is.null(inFile))
      return(NULL)
    temp_df<-read.table(inFile$datapath,
                        header = TRUE,
                        sep="\t",
                        quote = "",
                        stringsAsFactors = FALSE)
    
    return(temp_df)
  })
 
 
### Reactive components
  merged_data<- reactive({
     ## check which dataset
     if(!is.null (qvalue_input() )){
       qvalue_data <- reactive({qvalue_input()})
     }
    
     if(!is.null (qvalue_sparse_input() )){
       qvalue_sparse_data<-reactive({qvalue_sparse_input()})
     }
  
     q_sparse<- qvalue_sparse_data() %>% data.frame(.) %>% 
       dplyr::filter(!grepl("^CON__|^REV__", PG.ProteinAccessions)) ## looks like the same
     
     intensity_columns<- grep("PG.Quantity", colnames(q_sparse))
    # print(intensity_columns)
     colnames(q_sparse)<-gsub(".htrms.PG.Quantity","", colnames(q_sparse))
     colnames(q_sparse)<-sub(".*?_","", colnames(q_sparse))
     
     q_value<- qvalue_data() %>% data.frame(.) %>% 
       dplyr::filter(!grepl("^CON__|^REV__", PG.ProteinAccessions)) ## looks like the same
     
     intensity_cols_qvalue<- grep("PG.Quantity", colnames(q_value))
   
      colnames(q_value)<-gsub(".htrms.PG.Quantity","", colnames(q_value))
     colnames(q_value)<-sub(".*?_","", colnames(q_value))
     
    q_value<-q_value %>% mutate_all(., na_if, "Filtered") %>%
         mutate_all(., tidyr::replace_na, 0)
     q_value_intensities<- q_value[,intensity_cols_qvalue]
   
    imputed_df<-q_value_intensities %>% mutate_all(funs(.==0))
    imputed_df$num_NA<-rowSums(imputed_df)
    imputed_df$PG.ProteinAccessions<-q_value$PG.ProteinAccessions

     merged_data1<- left_join(q_sparse, imputed_df,
                           suffix=c("", "_imputed"), by="PG.ProteinAccessions")
     return(merged_data1)

   })
  
   
###### ========== DOWNLOAD HANDLER ============ #####
  output$downloadData <- downloadHandler(
    filename = function() { paste("merged_spectronaught", ".csv", sep = "") }, ## use = instead of <-
    content = function(file) {
      write.table(merged_data(),
                  file,
                  col.names = TRUE,
                  row.names = FALSE,
                  sep =",") }
  )
 
  
}
