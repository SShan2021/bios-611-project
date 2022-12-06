################################################
#setwd
setwd("~/work")

################################################
#load libraries
library(readxl)
library(tidyverse)

################################################
#read in filtered NASHP data
nashp_filtered <- read_csv("./derived_data/tidy_nashp_2016_2018.csv")

dim(nashp_filtered)

nashp_filtered_2016 <- nashp_filtered %>%
  filter(year == 2016)
################################################
#extract charity_care and uninsured_care columns 
charity_uninsured_care_raw <- nashp_filtered_2016 %>%
  select(ccn, charity_care_payer_mix, uninsured_and_bad_debt_payer_mix) %>%
  mutate(charity_care_payer_mix = as.numeric(charity_care_payer_mix),
         uninsured_and_bad_debt_payer_mix = as.numeric(uninsured_and_bad_debt_payer_mix))

#get rid of negative values
charity_uninsured_care_data <- charity_uninsured_care_raw %>%
  filter(charity_care_payer_mix >= 0 &
           uninsured_and_bad_debt_payer_mix >= 0)
  
#remove the NAs 
charity_uninsured_care_data <- charity_uninsured_care_data[complete.cases(charity_uninsured_care_data),]

#how many hospitals we have left
dim(charity_uninsured_care_data)

################################################
#save the dataset
write_csv(charity_uninsured_care_data,
          "./derived_data/charity_uninsured_care_data.csv")
