################################################

#load libraries
library(readxl)
library(tidyverse)

#set working directory
#"gear" tab in the bottom right pane of rstudio 
#(more -> set current working directory)
#READ.me should say that this is the working directory

#read in RAND data
nashp_raw <- read_xlsx("source_data/NASHP HCT Data 2022 April.xlsx",
                      sheet = "HCT data")
head(nashp_raw)
dim(nashp_raw) #3155 rows, 29 columns 

columns <- names(nashp_raw);
nr <- nrow(nashp_raw);
for (col in columns) {
  n <- length(unique(nashp_raw[[col]]));
  print(sprintf("%s %f\n", col, n/nr))
}

nashp_raw %>%
  filter(Year == "2016") %>%
  group_by(`CCN#`) %>%
  tally() %>%
  filter(n>1)

nashp_raw %>%
  filter(Year == "2016" &
           `CCN#` == "030074") %>%
  
  select(Year, "CCN#", "Facility Type", "Fiscal Year Beginning", "Fiscal Year Ending",
  "Hospital Name", "Hospital Abbreviated Name", "Address"
  )


nashp_raw %>%
  filter(Year == "2016") %>% 
  select("Fiscal Year Beginning") %>%
  table()

#find the length of time between fiscal year beginning and ending
#take a look at Meg's version of fiscal years 
nashp_raw %>%
  filter(Year == "2016") %>% 
  
  mutate(
    fiscal_year_beg = as.Date("Fiscal Year Beginning"),
    fiscal_year_end = as.Date("Fiscal Year Ending"), 
    length = difftime(fiscal_year_beg, fiscal_year_end, units="days")) %>%
  table()
  
  select("Fiscal Year Ending") %>%
  table()

colnames(nashp_raw)


