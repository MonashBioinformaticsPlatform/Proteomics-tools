# Define UI for data upload app ----
ui <- function(request){shinyUI(
  dashboardPage(
    skin = "purple",
    dashboardHeader(title = "Spectromerge"),
    # disable = TRUE),# Disable title bar
    dashboardSidebar(
      sidebarMenu(
        menuItem("Upload Files",  tabName="spectro_files"))
      ),
               
    
 ################################################################ 
    ## DASHBOARD BODY
 ################################################################ 
    
    dashboardBody(
      useShinyjs(), #imp to use shinyjs functions
     
      tabItems(
      tabItem(tabName = "spectro_files",
              fileInput('file1',
                        'Upload Spectronaut Qvalue file',
                        accept=c('text/csv/tsv/xls',
                                 'text/comma-separated-values,text/plain',
                                 '.csv', '.xls')
              ),
              
              
              fileInput('file2',
                        'Upload Spectronaut Qvalue Sparse file',
                        accept=c('text/csv/tsv/xls',
                        'text/comma-separated-values,text/plain',
                        '.csv', '.xls')
                        ),
              actionButton("merge", "Merge Files"), 
              shinyjs::hidden(div(id="downloadbox",
                                  fluidRow(
                                    box(
                                      column(4,uiOutput("downloadButton")), 
                                      width = 4)
                                  )    
                       ))
      )#, #close tab
        )#, #spectro_file tab close
        ) # Dasbboardbody close
    ) #Dashboard page close
  )#Shiny U Close
}
