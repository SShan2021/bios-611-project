################################################
#setwd
setwd("~/work")

################################################
#load libraries
library(readxl)
library(tidyverse)

################################################
#read in RAND data
rand_raw <- read_xlsx("source_data/Supplemental_Material.xlsx",
                      sheet = "Table 1. PF Hospitals",
                      skip = 9)
head(rand_raw)
dim(rand_raw) 

################################################
#make colnames lowercase
colnames(rand_raw) <- str_to_lower(colnames(rand_raw)) %>% str_trim();
#replace all whitespace with underscores
colnames(rand_raw) <- str_replace_all(colnames(rand_raw), "[[:space:],$?/()-=]+", "_") %>%
  str_replace_all("[_]+$","");

################################################
#are the medicare provider numbers unique? yes
rand_raw %>% group_by(medicare_provider_number) %>% tally() %>% filter(n!=1)

################################################
#are the hospital names unique?
#in some states the hospital names are the same
rand_raw %>%
  group_by(hospital_name, zip_code) %>%
  tally() %>%
  filter(n!=1)

################################################
#save files to derived_data
write_csv(rand_raw, "./derived_data/tidy_rand.csv")
