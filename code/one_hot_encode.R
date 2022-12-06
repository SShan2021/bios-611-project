################################################
#setwd
setwd("~/work")

################################################
#load libraries
library(readxl)
library(tidyverse)
library(caret)

################################################
#read in the merged characteristics data
merged <- read_csv("./derived_data/merged_characteristics.csv")
merged <- as.data.frame(merged)

################################################
#make the row names the ccn
rownames(merged) <- merged$ccn

#delete the columns ccn and year
merged$ccn <- NULL
merged$year <- NULL

#make the medicare five star rating a categorical variable
merged$medicare_star_rating <- as.factor(merged$medicare_star_rating)
################################################
#define one-hot encoding function
dummy <- dummyVars(" ~ .", data = merged)

#perform one-hot encoding on data frame
merged_dummy <- data.frame(predict(dummy, newdata=merged))

#delete the redundent column for each category
#to get rid of linear dependencies
merged_dummy$facility_typeShort.Term..General.and.Specialty..Hospitals <- NULL
merged_dummy$WY <- NULL
merged_dummy$health_systemyuma_regional_medical_center <- NULL
merged_dummy$hospital_ownership_typeNon.Profit <- NULL
merged_dummy$medicare_star_rating.5 <- NULL
################################################
#save the dataset
write_csv(merged_dummy,
          "./derived_data/merged_dummy.csv")
