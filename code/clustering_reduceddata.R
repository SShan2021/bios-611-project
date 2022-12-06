################################################
#setwd
setwd("~/work")

################################################
#load libraries
library(readxl)
library(tidyverse)
library(factoextra)

################################################
#read in the merged characteristics data
df <- read_csv("./derived_data/merged_dummy.csv")
df_characteristics <- read_csv("./derived_data/merged_characteristics.csv")
charity_uninsured_care_data <- read_csv("./derived_data/charity_uninsured_care_data.csv")

colnames(df)
################################################
#keep only facility_type, bed_size, medicare_star_rating
df_1 <- df %>%
  select(facility_typeCritical.Access.Hospitals, 
         hospital_ownership_typeFor.Profit,
         hospital_ownership_typeGovernmental,
         bed_size, 
         medicare_star_rating.1,
         medicare_star_rating.2,
         medicare_star_rating.3,
         medicare_star_rating.4)

################################################
#perform PCA

#scaling our data (PCA strongly influenced by variance in each column)
pca_df <- prcomp(df_1, center = TRUE, scale = TRUE)

#find the proportion of variance explained by each component
std_dev <- pca_df$sdev
pr_var <- std_dev^2
prop_varex <- pr_var/sum(pr_var)
round(prop_varex, 2)
plot(cumsum(prop_varex), xlab = "Principal Component",
     ylab = "Cumulative Proportion of Variance Explained",
     type= "b")


#extract first 500 components
df_transform <- as.data.frame(-pca_df$x[,1:7])
################################################
#k-means clustering

#determine the number of clusters k
fviz_nbclust(df_transform, kmeans, method = 'silhouette')

#kmeans clustering
kmeans_df <- kmeans(df_transform, centers = 9, nstart = 50)
pdf(file = "figures/k_means_plot_reduceddata.pdf")
fviz_cluster(kmeans_df, data=df_transform)
dev.off()

################################################
#understanding the clusters
clusters <- kmeans_df$cluster
df_characteristics$cluster <- clusters

#making the variables factor
df_characteristics$facility_type <- as.factor(df_characteristics$facility_type)
df_characteristics$state <- as.factor(df_characteristics$state)
df_characteristics$health_system <- as.factor(df_characteristics$health_system)
df_characteristics$hospital_ownership_type <- as.factor(df_characteristics$hospital_ownership_type)
df_characteristics$medicare_star_rating <- as.factor(df_characteristics$medicare_star_rating)
df_characteristics$cluster <- as.factor(df_characteristics$cluster)

#hospital_ownership_type
pdf(file = "figures/hospital_ownership_type_cluster_plot.pdf")
df_characteristics %>%
  ggplot(aes(x=cluster, group=hospital_ownership_type, fill=hospital_ownership_type)) +
  geom_bar()
dev.off()

#medicare_star_rating
pdf(file = "figures/medicare_star_rating_cluster_plot.pdf")
df_characteristics %>%
  ggplot(aes(x=cluster, group=medicare_star_rating, fill=medicare_star_rating)) +
  geom_bar()
dev.off()

#facility_type
pdf(file = "figures/facility_type_cluster_plot.pdf")
df_characteristics %>%
  ggplot(aes(x=cluster, group=facility_type, fill=facility_type)) +
  geom_bar()
dev.off()

#bed_size
pdf(file = "figures/bed_size_cluster_plot.pdf")
df_characteristics %>%
  ggplot(aes(x=bed_size, group=cluster, fill=cluster)) +
  geom_boxplot()
dev.off()

#calculate median of bed_size
df_characteristics %>%
  group_by(cluster) %>%
  summarise(median = median(bed_size))

################################################
#mapping on uninsured and charity care payer mix

#merge in uninsured and charity care
merged <- df_characteristics %>%
  inner_join(charity_uninsured_care_data, by=c("ccn"="ccn")) 
colnames(merged)

#uninsured payer mix
pdf(file = "figures/uninsured_payer_mix_plot.pdf")
merged %>%
  ggplot(aes(x=uninsured_and_bad_debt_payer_mix, group=cluster,fill=cluster)) +
  geom_boxplot()
dev.off()

#median
merged %>%
  group_by(cluster) %>%
  summarize(median = round(median(uninsured_and_bad_debt_payer_mix),2))

#charity_care_payer_mix
pdf(file = "figures/charity_care_payer_mix_plot.pdf")
merged %>%
  ggplot(aes(x=charity_care_payer_mix, group=cluster,fill=cluster)) +
  geom_boxplot()

#median
merged %>%
  group_by(cluster) %>%
  summarize(median = round(median(charity_care_payer_mix),2))
