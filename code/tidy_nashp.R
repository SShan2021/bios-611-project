################################################
#setwd()
setwd("~/work")

################################################
#load libraries
library(readxl)
library(tidyverse)
library(vistime)
library(lubridate)
library(plotly)
webshot::install_phantomjs(force = TRUE)

################################################
#read in RAND data
nashp_raw <- read_xlsx("source_data/NASHP_HCT_Data_2022_April.xlsx",
                       sheet = "HCT data")
dim(nashp_raw)

################################################
#make colnames lowercase
colnames(nashp_raw) <- str_to_lower(colnames(nashp_raw)) %>% str_trim();
#replace all whitespace with underscores
colnames(nashp_raw) <- str_replace_all(colnames(nashp_raw), "[[:space:],#'$?/()-=]+", "_") %>%
  str_replace_all("[_]+$","");

################################################
#how many unique hospitals
length(unique(nashp_raw$ccn)) 

################################################
#subsetting to only 2016-2018 first
nashp_raw_2016_2018 <- nashp_raw %>%
  filter(year == 2016 |
           year == 2017 |
           year == 2018)

length(unique(nashp_raw_2016_2018$ccn)) 
################################################
#figuring out fiscal year distribution
#selecting columns of interest
nashp_2016_2018_fiscalyear <- nashp_raw_2016_2018 %>%
  select(year, ccn, fiscal_year_beginning, fiscal_year_ending)

#how many days between start and end of fiscal year?
nashp_2016_2018_fiscalyear <- nashp_2016_2018_fiscalyear %>%
  mutate(difference = as.numeric(difftime(ymd(fiscal_year_ending),
                                          ymd(fiscal_year_beginning),
                                          units = "days"))) 

################################################
#take a look at distribution of fiscal year length 
nashp_2016_2018_fiscalyear %>%
  group_by(difference) %>%
  tally() %>%
  arrange(desc(difference)) 
#there are fiscal years that are much greater than 364 or 365
#there are also fiscal years that mare much smaller than 364 or 365
#notice that the majority of the fiscal years are either 364 or 365

#need to extract all rows with fiscal years < 364 or >365 
nashp_2016_2018_fiscalyear_notnormal <- nashp_2016_2018_fiscalyear %>%
  filter(difference < 364|
           difference > 365) %>%
  select(ccn) %>%
  distinct()

dim(nashp_2016_2018_fiscalyear_notnormal)

#select out those hospitals and take a look at them
nashp_2016_2018_fiscalyear_notnormal_data <- nashp_raw_2016_2018 %>% 
  filter(ccn %in% nashp_2016_2018_fiscalyear_notnormal$ccn) %>%
  arrange(ccn)

length(unique(nashp_2016_2018_fiscalyear_notnormal_data$ccn)) 
dim(nashp_2016_2018_fiscalyear_notnormal_data) 

################################################
#take a look at distribution of days (for strange
#hospitals)
nashp_2016_2018_fiscalyear_notnormal_data_top30 <- nashp_raw_2016_2018 %>%
  filter(ccn %in% nashp_2016_2018_fiscalyear_notnormal_data$ccn) %>%
  select(year, ccn, fiscal_year_beginning, fiscal_year_ending) %>%
  arrange(ccn) %>%
  mutate(difference = as.numeric(difftime(ymd(fiscal_year_ending),
                                          ymd(fiscal_year_beginning),
                                          units = "days"))) %>%
  group_by(ccn) 

f_2 <- vistime(nashp_2016_2018_fiscalyear_notnormal_data_top30[1:20,], col.group = "ccn",
               col.event = "difference", 
               col.start = "fiscal_year_beginning", col.end = "fiscal_year_ending")
plotly::export(f_2, file = "figures/nashp_strangefiscalyear.pdf")

################################################
#extract normal hospitals
nashp_2016_2018_fiscalyear_normal_data <- nashp_raw_2016_2018 %>% 
  filter(!(ccn %in% nashp_2016_2018_fiscalyear_notnormal$ccn)) %>%
  arrange(ccn) %>%
  #exclude hospitals in the District of Columbia
  filter(state != "DC")

length(unique(nashp_2016_2018_fiscalyear_normal_data$ccn)) 

################################################
write_csv(nashp_2016_2018_fiscalyear_normal_data,
                      "./derived_data/tidy_nashp_2016_2018.csv")
