change_column_names<-function(df,names_vector){
  data.table::setnames(df,names(df)[-2],paste0(names(df)[-2],"_",names_vector))
}

count_protein_groups <- function(df){
 new_df<- df %>% group_by(Protein_Rank) %>%
    mutate(Proteins_in_Group=n())
 return(new_df)
}

proteins_in_each_sample<-function(df,names_vector){
  new_list<-list()
  new_df<- df %>% 
    filter(!grepl("^>Reverse",Description))
  new_list[["Total_proteins"]]<-nrow(new_df)
  new_list[["Sample_name"]]<-names_vector
  ## convert to tidy dataframe
  return(new_list)
}

protein_group_iteration<- function(df){
  updated_sheet<- df %>% group_by(Protein_Rank)%>% 
    mutate(Log_Probability=unique(Log_Probability[!is.na(Log_Probability)]),
           Best_Log_Probability=unique(Best_Log_Probability[!is.na(Best_Log_Probability)]),
           Best_Score=unique(Best_Score[!is.na(Best_Score)]),
           Total_intensity=unique(Total_intensity[!is.na(Total_intensity)]),
           Number_of_Spectra=unique(Number_of_Spectra[!is.na(Number_of_Spectra)]),
           Number_of_Unique_Peptides=unique(Number_of_Unique_Peptides[!is.na(Number_of_Unique_Peptides)]),
           Number_of_Modified_Peptides=unique(Number_of_Modified_Peptides[!is.na(Number_of_Modified_Peptides)]),
           Coverage=unique(Coverage[!is.na(Coverage)]),
           Numbers_of_AA=unique(Numbers_of_AA[!is.na(Numbers_of_AA)]),
           Protein_DB_number=unique(Protein_DB_number[!is.na(Protein_DB_number)]))
  return(updated_sheet)
}
