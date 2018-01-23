## ==== Script to parse byonic excel output
## Intput the main directory
## The r script should run through the parent directory
directory<- choose.dir()

library("rstudioapi")
library("tidyverse")
library("data.table")
library("readxl")
library("xlsx")

setwd(directory)
getwd()
### Set working directory
#current_path <- getActiveDocumentContext()$path 
# The next line set the working directory to the relevant one:
#setwd(dirname(current_path ))

source("D:/Applications/Scripts/Byonic/functions_byonic_parser.R", chdir = TRUE)



#sanity check
getwd()
# Get all file names with byonic output
file_names<-list.files(getwd(),pattern = "*.xlsx",recursive = T)
## clean up file names
sheet_names<- file_names %>% gsub(".*[/]","",.) %>% gsub("[.]raw.*","",.) %>% sub("^[^_]*_","",.)

#fiile_names[1]

# Read a sheet named "Protein" from byonic output file
## Use other library "readxl" as others (openxl and tidyverse function gave error
## Need to store column headers as byonic output headers are messy
column_headers<-c("Protein_Rank","Description","Log_Probability","Best_Log_Probability","Best_Score","Total_intensity",
                  "Number_of_Spectra", "Number_of_Unique_Peptides", "Number_of_Modified_Peptides",
                  "Coverage","Numbers_of_AA", 
                  "Protein_DB_number")

## Recursively read all files
file_list<-lapply(file_names,read_excel,sheet = "Proteins",col_names = TRUE)
# Improtant step
new_list<-lapply(file_list,setNames,column_headers)
#str(new_list)
## Copy protein attributes to the blank row below for proteins in group (sharing same protein Rank)
## use protein_group interation function and apply over list of dataframes

modified_files<- lapply(new_list,function(x) protein_group_iteration(x))


###==== Count proteins per sample
#### Count number of proteins after removing reverse sequence in each sample
protein_count_table_list<-map2(modified_files, sheet_names, proteins_in_each_sample)

protein_count_table<-as.data.frame(do.call(cbind,protein_count_table_list), 
                                   stringsAsFactors = FALSE)
protein_count_table_new<-as.data.frame(t(protein_count_table))

## Reorder columns
protein_count_table_new<- select(order(colnames(.)))

### Count how many proteins per group and store it in "Proteins_in_group" column
## Use function count_protein_groups

sheets_with_protein_group<-lapply(modified_files,count_protein_groups)


# Rename columns based on experiment structure
## Add suffix to each column (each dataframe) and exlude "Description" column as it is required for merging
## Use function "change_column_name"

modified_sheets<-map2(sheets_with_protein_group,sheet_names,change_column_names)

## Main merging function
combined_results<- modified_sheets %>% reduce(merge,by="Description",all.x=TRUE,all.y=TRUE)
# requires all.x and all.y to be true

## clean the output
## remove reverse sequences
## get three main set of columns (Description, Number of spectra and how many number of proteins in Group


clean_output<-combined_results %>% 
  filter(!grepl("^>Reverse",Description)) %>% #worked
  select(.,"Description",starts_with("Number_of_Spectra"),starts_with("Proteins_in_Group")) %>%
  arrange(desc(.[[2]])) # sort by second column (Important syntax)
## Reorder columns alphabetically
clean_output %>% select(order(colnames(.)))
write.xlsx(clean_output,"Summary_byonic.xlsx",sheetName = "combined_results",showNA = FALSE, row.names = FALSE)
write.xlsx(protein_count_table_new,"Protein_summary.xlsx", sheetName= "protein_summary", row.names=FLASE)

## Session
sessionInfo()
