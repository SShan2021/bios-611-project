################################################

#load libraries
library(readxl)
library(tidyverse)

oshpdid_raw <- read_xlsx("source_data/California hospital outcome data.xlsx",
                      sheet = "Sheet 1 - ca-hcai-ahrq-imi-long")
head(oshpdid_raw)
dim(oshpdid_raw) #24368    11
cat(sprintf("Dimensions of original OSHPDID Dataset: %d\n", nrow(oshpdid_raw)), 
    file="derived_data/osphid_cleaning.txt",append=FALSE)

# common format specifiers:
# %d integer
# %f is floating point number
# %s is string
# %0.2f print a floating put number w/ 2 decimals

#filter out statewide rows
oshpdid_raw_v1 <- oshpdid_raw %>%
  filter(OSHPDID != "None")
cat(sprintf("After removing statewide data we had %d rows.\n", nrow(oshpdid_raw_v1)), 
    file="derived_data/osphid_cleaning.txt",append=TRUE);
dim(oshpdid_raw_v1)

oshpdid_raw_v1$`Procedure/Condition`
#retrieve the OSHPDID from the statewid rows 
valid_oshpids <- oshpdid_raw_v1$OSHPDID %>% unique();

#load crosswalk filtering only for OSHPDID 
#where we have them in the oshpdid_raw_v1 dataset 
osphd_cnn_crosswalk <- read_xlsx("source_data/elms-aspen-oshpd-licensed-and-certified-healthcare-facility-crosswalk.xlsx",
                         sheet = "ELMS_ASPEN_OSHPD_CW") %>% 
  filter(OSHPD_ID %in% valid_oshpids)

#keep only parents 
osphd_cnn_crosswalk_v1 <- osphd_cnn_crosswalk %>%
  select(OSHPD_ID, CCN, FAC_FAC_RELATIONSHIP) %>%
  rename(MPN = CCN) %>%
  filter(FAC_FAC_RELATIONSHIP == "Parent")
#take a look 
head(osphd_cnn_crosswalk_v1)

#check if it's a unique mapping
osphd_cnn_crosswalk_v1 %>%
  group_by(OSHPD_ID) %>%
  tally() %>%
  filter(n>1) #yes 


#pick one thing to think about
oshpdid_raw_v1 %>%
  filter(`Procedure/Condition` == "AMI")

oshpdid_raw_v1 %>%
  select(`Procedure/Condition`) %>%
  table()
colnames(oshpdid_raw_v1)
#########################################################

oshpdid_raw_v1 %>% inner_join(osphd_cnn_crosswalk_v1, by=c(OSHPDID="OSHPD_ID")) %>%
  select(YEAR, MPN, `Procedure/Condition`, "Risk Adjuested Mortality Rate",
         "# of Deaths", "# of Cases", )

colnames(osphd_cnn_crosswalk)
