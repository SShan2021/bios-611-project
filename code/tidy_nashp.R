################################################

#load libraries
library(readxl)
library(tidyverse)
library(vistime)

#set working directory
#"gear" tab in the bottom right pane of rstudio 
#(more -> set current working directory)
#READ.me should say that this is the working directory

#read in RAND data
nashp_raw <- read_xlsx("source_data/NASHP_HCT_Data_2022_April.xlsx",
                      sheet = "HCT data")
head(nashp_raw)
dim(nashp_raw) #42709 rows, 65 columns 

#make colnames lowercase
colnames(nashp_raw) <- str_to_lower(colnames(nashp_raw)) %>% str_trim();
#replace all whitespace with underscores
colnames(nashp_raw) <- str_replace_all(colnames(nashp_raw), "[[:space:],#'$?/()-=]+", "_") %>%
  str_replace_all("[_]+$","");

#check out the most recent year 
nashp_raw_2019 <- nashp_raw %>%
  filter(year == "2019") %>%
  head(50)

#make a graph of the fiscal_year_beginning and fiscal_year_ending 
png('figures/fiscal_year_2019.png')
vistime(nashp_raw_2019, col.event = "ccn",
        col.start = "fiscal_year_beginning", col.end = "fiscal_year_ending")
dev.off()