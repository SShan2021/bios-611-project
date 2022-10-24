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

#
length(unique(rand_raw$medicare_provider_number))

#are the medicare provider numbers unique? 
rand_raw %>% group_by(medicare_provider_number) %>% tally() %>% filter(n!=1)

#are the hospital names unique? 
#in some states the hospital names are the same 
rand_raw %>% 
  group_by(hospital_name, zip_code) %>% 
  tally() %>% 
  filter(n!=1)

#
rand_raw %>%
  summary()

#meta-data about hospital
rand_metadata <- rand_raw %>%
  select(medicare_provider_number, hospital_name, street_address, city, state, zip_code,
         hospital_system_or_if_independent_ipps_cah, is_hospital_a_critical_access_hospital_y_n,
         hospital_compare_star_rating_october_na_not_available)

rand_raw <- rand_raw %>% select(-hospital_name, -street_address, -city, -state, -zip_code,
                                -hospital_system_or_if_independent_ipps_cah,
                                -is_hospital_a_critical_access_hospital_y_n,
                                -hospital_compare_star_rating_october_na_not_available);

rand_long <- rbind(
  rand_raw %>% transmute(medicare_provider_number,
                         service_category="outpatient",
                         number_of_services=number_of_outpatient_services,
                         total_private_allowed_millions=total_private_allowed_amount_for_outpatient_services_millions,
                         simulated_medicare_allowed_amount_millions=simulated_medicare_allowed_amount_for_outpatient_services_millions,
                         relative_price=relative_price_for_outpatient_services,
                         standardized_price=standardized_price_per_outpatient_service),
  
  rand_raw %>% transmute(medicare_provider_number,
                         service_category="inpatient",
                         number_of_services=number_of_inpatient_stays,
                         total_private_allowed_millions=total_private_allowed_amount_for_inpatient_services_millions,
                         simulated_medicare_allowed_amount_millions=simulated_medicare_allowed_amount_for_inpatient_services_millions,
                         relative_price=relative_price_for_inpatient_services,
                         standardized_price=standardized_price_per_inpatient_stay),
  
  rand_raw %>% transmute(medicare_provider_number,
                         service_category="inpatient_and_outpatient",
                         number_of_services=NA,
                         total_private_allowed_millions=total_private_allowed_amount_for_inpatient_and_outpatient_services_millions,
                         simulated_medicare_allowed_amount_millions=simulated_medicare_allowed_amount_for_inpatient_and_outpatient_services_millions,
                         relative_price=relative_price_for_inpatient_and_outpatient_services,
                         standardized_price=NA),
  rand_raw %>% transmute(medicare_provider_number,
                         service_category="professional_inpatient_and_outpatient",
                         number_of_services=NA,
                         total_private_allowed_millions=NA,
                         simulated_medicare_allowed_amount_millions=simulated_medicare_allowed_amount_for_professional_inpatient_and_outpatient_services_millions,
                         relative_price=relative_price_for_professional_inpatient_and_outpatient_services,
                         standardized_price=NA), 
  
  rand_raw %>% transmute(medicare_provider_number,
                         service_category="inpatient_facility",
                         number_of_services=NA,
                         total_private_allowed_millions=NA,
                         simulated_medicare_allowed_amount_millions=NA,
                         relative_price=relative_price_for_inpatient_facility_services,
                         standardized_price=NA), 
  
  rand_raw %>% transmute(medicare_provider_number,
                         service_category="outpatient_facility",
                         number_of_services=NA,
                         total_private_allowed_millions=NA,
                         simulated_medicare_allowed_amount_millions=NA,
                         relative_price=relative_price_for_outpatient_facility_services,
                         standardized_price=NA), 
  
  rand_raw %>% transmute(medicare_provider_number,
                         service_category="facility_inpatient_and_outpatient_services",
                         number_of_services=NA,
                         total_private_allowed_millions=total_private_allowed_amount_for_facility_inpatient_and_outpatient_services_millions,
                         simulated_medicare_allowed_amount_millions=simulated_medicare_allowed_amount_for_facility_inpatient_and_outpatient_services_millions,
                         relative_price=relative_price_for_outpatient_facility_services,
                         standardized_price=NA)
) %>% arrange(medicare_provider_number)

head(rand_long)

head(rand_raw)
# put this in utils.R or something
`%not-in%` <- function(a,b){
  !(a %in% b)
}

#pull out meta-data in the original dataset
rand_raw <- rand_raw %>%
  select(!(colnames(rand_metadata)))
dim(rand_raw) #3155 rows, 24 columns 

#check binary columns: 
#1) is_hospital_a_critical_access_hospital_y_n,
rand_raw %>%
  group_by(is_hospital_a_critical_access_hospital_y_n) %>%
  tally()
#2) hospital_compare_star_rating_october_na_not_available
rand_raw %>%
  group_by(hospital_compare_star_rating_october_na_not_available) %>%
  tally()
#3) figure out whether NA in hospital_compare_star_rating_october_na_not_available
#is a string
rand_raw %>%
  group_by(is.na(hospital_compare_star_rating_october_na_not_available)) %>%
  tally() #it's the string NA
#4) replace string NA in hospital_compare_star_rating_october_na_not_available
#and convert ratings to numeric (if considered ordinal - NA doesn't really
#have any "order" to them)
rand_raw <- rand_raw %>%
  mutate(hospital_compare_star_rating_october_na_not_available = 
           as.numeric(hospital_compare_star_rating_october_na_not_available))
#5) check if strings are NA now
#is a string
rand_raw %>%
  group_by(is.na(hospital_compare_star_rating_october_na_not_available)) %>%
  tally() #it is!! 

rand_prices <- rand_raw()
#do this for other columns and try to understand how are these things incoded?
#missing data?

#save files to edited_data
#write_csv(rand_raw, "./derived_data/rand_tidied.csv")
write_csv(rand_metadata, "./derived_data/rand_metadata.csv")
write_csv(rand_long, "./derived_data/rand_long.csv")
