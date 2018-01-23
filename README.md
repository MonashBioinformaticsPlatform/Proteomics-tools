# Proteomics_tools
Repo for scripts for parsing Byonic output 
### Issue
- Typical proteomics experiment produces multiple raw files
- Byonic generates single excel sheet per sample/raw file
- Usually we have more than one sample per condition or experiment
- One solution: Merge different output files manually (VLOOKUP function in excel)
  - Time consuming
  - Protein Parsimony (Blank columns for members of protein groups)
  - Might be error prone
### Solution
- Automatic merging of byonic out using R
  - Reads “Protein” sheet from every byonic subfolders
  - Counts how many proteins per group
  - Populates blank rows with information from other member of protein group
  - Removes “Reverse” sequences
  - Generates summary excel file
- Advantages
  - Time efficient
  - Reduces chances of error
  - Compare multiple samples efficiently
  - Get an idea about protein groups
- Limitations
  - All excel files need to be closed
  - Duplicates if a protein is reported as part of group or individual entry

### How to use
1.  Download the Repo into a folder
2.	Open RStudio (**FOR FIST TIME USE:** Install dependent packages (bindrcpp_0.2; xlsx_0.5.7; xlsxjars_0.6.1; rJava_0.9-9; readxl_1.0.0; data.table_1.10.4; readr_1.1.1; ggplot2_2.2.1; tidyverse_1.1.1)
3.	Click on tab called “Code” 
4.	Click on “Source File.. ”
5.	Open file “byonic_parser.R” from downloaded folder
6.	Prompt will appear asking for choosing the MAIN BYONIC directory where all byonic outputs are located. (BE CAREFUL WITH CHOOSING THE DIRECTORY!) 
7.	Choose the correct folder.
8.	Script will run (Note check if > appears after a while in “Console” panel)
9.	Output file is located in the same MAIN BYONIC directory you choose with the name “Summary_byonic.xlsx”

### Output
1. Summary_byonic.xlsx - File containing merged results
2. Protein_summary.xlsx - File containing protein counts table
