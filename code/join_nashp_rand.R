################################################
#setwd
setwd("~/work")

################################################
#load libraries
library(readxl)
library(tidyverse)

################################################
#read in the characteristics data from nashp and rand
nashp <- read_csv("./derived_data/nashp_characteristics_2016.csv")
rand <- read_csv("./derived_data/rand_characteristics.csv")

################################################
#read in the characteristics data from nashp and rand
merged_characteristics <- nashp %>%
  inner_join(rand, by=c("ccn"="ccn")) %>%
  select(ccn, facility_type, state, health_system, hospital_ownership_type,
         bed_size, medicare_star_rating)
dim(merged_characteristics)

#check if there are any NAs
apply(merged_characteristics, 2, function(x) any(is.na(x)))

################################################
#make some plots
colnames(merged_characteristics)

#facility_type split by medicare_star_rating 
facility_type_medicare_star_rating_plot <- ggplot(merged_characteristics, aes(x=medicare_star_rating, fill=facility_type))+
  geom_bar(aes( y=..count../tapply(..count.., ..x.. ,sum)[..x..]), position="dodge" ) +
  geom_text(aes( y=..count../tapply(..count.., ..x.. ,sum)[..x..], label=scales::percent(..count../tapply(..count.., ..x.. ,sum)[..x..]) ),
            stat="count", position=position_dodge(0.9), vjust=-0.5)+
  ylab('Percent of Total Hospitals, %') +
  scale_y_continuous(labels = scales::percent)
pdf(file = "figures/facility_type_medicare_star_rating_plot.pdf")
facility_type_medicare_star_rating_plot
dev.off()


#hospital_ownership_type split by medicare_star_rating 
hospital_ownership_type_medicare_star_rating_plot <- ggplot(merged_characteristics, aes(x=medicare_star_rating, fill=hospital_ownership_type))+
  geom_bar(aes( y=..count../tapply(..count.., ..x.. ,sum)[..x..]), position="dodge" ) +
  geom_text(aes( y=..count../tapply(..count.., ..x.. ,sum)[..x..], label=scales::percent(..count../tapply(..count.., ..x.. ,sum)[..x..]) ),
            stat="count", position=position_dodge(0.9), vjust=-0.5, size = 2)+
  ylab('Percent of Total Hospitals, %') +
  scale_y_continuous(labels = scales::percent)

pdf(file = "figures/hospital_ownership_type_medicare_star_rating_plot.pdf")
hospital_ownership_type_medicare_star_rating_plot
dev.off()

################################################
#save the dataset
write_csv(merged_characteristics,
          "./derived_data/merged_characteristics.csv")

