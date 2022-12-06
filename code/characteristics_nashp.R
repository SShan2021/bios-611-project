################################################
#setwd()
setwd("~/work")

################################################
#load libraries
library(readxl)
library(tidyverse)
library(usmap)

################################################
#read in filtered NASHP data
nashp_filtered <- read_csv("./derived_data/tidy_nashp_2016_2018.csv")

dim(nashp_filtered)

################################################
#filter out characteristics columns 
nashp_characteristics <- nashp_filtered %>%
  select(ccn, year, facility_type, state, health_system, hospital_ownership_type,
         bed_size) %>%
  mutate(year = as.factor(year),
         facility_type = as.factor(facility_type),
         state = as.factor(state),
         hospital_ownership_type = as.factor(hospital_ownership_type))

#only keep complete cases 
nashp_characteristics <- nashp_characteristics[complete.cases(nashp_characteristics), ]
length(unique(nashp_characteristics$ccn)) 

#distribution of hospitals per year
nashp_characteristics %>%
  select(ccn, year) %>%
  group_by(year) %>%
  tally()
################################################
#check out each of the columns in the dataset

#bed_size
summary(nashp_characteristics$bed_size) #min: -99999 (looks wrong)
nashp_characteristics <- nashp_characteristics %>%
  filter(bed_size >= 0) 

bed_size_plot <- nashp_characteristics %>%
  ggplot(aes(x= bed_size, fill=facility_type)) +
  geom_boxplot()
pdf(file = "figures/nashp_bed_size_plot.pdf")
bed_size_plot
dev.off()

#facility_type 
facility_type <- nashp_characteristics %>% 
  group_by(facility_type, year) %>%
  tally()

#plot of facility_type
facility_type_plot <- ggplot(nashp_characteristics, aes(x=year, fill=facility_type))+
  geom_bar(aes( y=..count../tapply(..count.., ..x.. ,sum)[..x..]), position="dodge" ) +
  geom_text(aes( y=..count../tapply(..count.., ..x.. ,sum)[..x..], label=scales::percent(..count../tapply(..count.., ..x.. ,sum)[..x..]) ),
            stat="count", position=position_dodge(0.9), vjust=-0.5)+
  ylab('Percent of Total Hospitals, %') +
  scale_y_continuous(labels = scales::percent)
pdf(file = "figures/nashp_facility_type_plot.pdf")
facility_type_plot
dev.off()

#state
state <- nashp_characteristics %>% 
  group_by(state, year) %>%
  tally() %>%
  summarise(n = mean(n))
dim(state)

#distribution of hospitals
state_plot <- plot_usmap(data = state, values = "n", color = "black") + 
  scale_fill_continuous(
    low = "white", high = "red", name = "# of Hospitals", label = scales::comma
  ) + 
  theme(legend.position = "right")
pdf(file = "figures/nashp_state_plot.pdf")
state_plot
dev.off()

#health_system
health_system <- nashp_characteristics %>% 
  group_by(health_system, year) %>%
  tally() %>%
  summarise(n = mean(n)) %>%
  arrange(desc(n))
dim(health_system)
  
nashp_characteristics <- nashp_characteristics %>%
  mutate(
    health_system = str_to_lower(health_system) %>% 
      str_trim()) %>%
  mutate(
    health_system = str_replace_all(health_system, "[[:space:],#'$?/()-=]+", "_") %>%
      str_replace_all("[_]+$",""))

#hospital_ownership_type
hospital_ownership_type <- nashp_characteristics %>% 
  group_by(hospital_ownership_type, year) %>%
  tally() 

#plot of hospital_ownership_type
hospital_ownership_type_plot <- ggplot(nashp_characteristics, aes(x=year, fill=hospital_ownership_type))+
  geom_bar(aes( y=..count../tapply(..count.., ..x.. ,sum)[..x..]), position="dodge" ) +
  geom_text(aes( y=..count../tapply(..count.., ..x.. ,sum)[..x..], label=scales::percent(..count../tapply(..count.., ..x.. ,sum)[..x..]) ),
            stat="count", position=position_dodge(0.9), vjust=-0.5)+
  ylab('Percent of Total Hospitals, %') +
  scale_y_continuous(labels = scales::percent)
pdf(file = "figures/nashp_hospital_ownership_type_plot.pdf")
hospital_ownership_type_plot
dev.off()

################################################
#extract characteristics data for 2016

nashp_characteristics_2016 <- nashp_characteristics %>%
  filter(year == 2016) 

################################################
#save the dataset
write_csv(nashp_characteristics_2016,
          "./derived_data/nashp_characteristics_2016.csv")