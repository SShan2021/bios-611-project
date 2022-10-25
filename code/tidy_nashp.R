################################################

#load libraries
library(readxl)
library(tidyverse)
library(vistime)
webshot::install_phantomjs()

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
  filter(year == "2019") 

nashp_raw_2019_fiscalyear <- nashp_raw %>%
  filter(year == "2019") %>%
  group_by(ccn) %>% #among one ccn, I would like 
  #to get the smallest fiscal year beginning 
  summarise(fiscal_year_beginning = min(fiscal_year_beginning),
            fiscal_year_ending = max(fiscal_year_ending)) %>% head(20)


f <- vistime(nashp_raw_2019_fiscalyear, col.event = "ccn",
        col.start = "fiscal_year_beginning", col.end = "fiscal_year_ending")
k <- plotly::export(f, file="figures/fiscal_year_2019.png")

