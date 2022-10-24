################################################

#load libraries
library(readxl)
library(tidyverse)

#set working directory
#"gear" tab in the bottom right pane of rstudio 
#(more -> set current working directory)
#READ.me should say that this is the working directory

#read in RAND data
rand_raw <- read_xlsx("source_data/Supplemental_Material.xlsx",
                      sheet = "Table 1. PF Hospitals",
                      skip = 9)
head(rand_raw)
dim(rand_raw) #3155 rows, 29 columns 

#make colnames lowercase
colnames(rand_raw) <- str_to_lower(colnames(rand_raw)) %>% str_trim();
#replace all whitespace with underscores
colnames(rand_raw) <- str_replace_all(colnames(rand_raw), "[[:space:],$?/()-=]+", "_") %>%
  str_replace_all("[_]+$","");

#are the medicare provider numbers unique? yes 
rand_raw %>% group_by(medicare_provider_number) %>% tally() %>% filter(n!=1)

#are the hospital names unique? 
#in some states the hospital names are the same 
rand_raw %>% 
  group_by(hospital_name, zip_code) %>% 
  tally() %>% 
  filter(n!=1)

#meta-data about hospital
rand_metadata <- rand_raw %>%
  select(medicare_provider_number, hospital_name, street_address, city, state, zip_code,
         hospital_system_or_if_independent_ipps_cah, is_hospital_a_critical_access_hospital_y_n,
         hospital_compare_star_rating_october_na_not_available)

#deleting the meta-data from the RAND file
rand_raw <- rand_raw %>% select(-hospital_name, -street_address, -city, -state, -zip_code,
                                -hospital_system_or_if_independent_ipps_cah,
                                -is_hospital_a_critical_access_hospital_y_n,
                                -hospital_compare_star_rating_october_na_not_available)

#save files to edited_data
write_csv(rand_raw, "./derived_data/rand_raw.csv")
write_csv(rand_metadata, "./derived_data/rand_metadata.csv")

