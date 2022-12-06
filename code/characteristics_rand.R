################################################
#setwd()
setwd("~/work")

################################################
#load libraries
library(readxl)
library(tidyverse)
library(usmap)

################################################
#read in filtered RAND data
rand_filtered <- read_csv("./derived_data/tidy_rand.csv")

dim(rand_filtered)

################################################
#filter out characteristics columns 
rand_characteristics <- rand_filtered %>%
  select(medicare_provider_number, hospital_compare_star_rating_october_na_not_available) %>%
  mutate(hospital_compare_star_rating_october_na_not_available = as.factor(hospital_compare_star_rating_october_na_not_available))

#rename columns
colnames(rand_characteristics) <- c("ccn", "medicare_star_rating")

#keep only hospitals where they have medicare_star_rating
rand_characteristics <- rand_characteristics[complete.cases(rand_characteristics),]
dim(rand_characteristics)

################################################
#take a look at medicare star rating distribution 
medicare_star_rating <- rand_characteristics %>%
  group_by(medicare_star_rating) %>%
  tally() %>%
  mutate(percentage = round(n/sum(n),4)*100)

#plot 
medicare_star_rating_plot <- medicare_star_rating %>%
  ggplot(aes(x=medicare_star_rating, y=percentage, fill = medicare_star_rating)) +
  geom_bar(stat='identity') +
  geom_text(aes(label=percentage), position=position_dodge(width=0.9), vjust=-0.25) + 
  ylab('Percent of Total Hospitals, %') 

pdf(file = "figures/rand_medicare_star_rating_plot.pdf")
medicare_star_rating_plot
dev.off()

################################################
#save the dataset
write_csv(rand_characteristics,
          "./derived_data/rand_characteristics.csv")
 