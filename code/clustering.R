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

################################################
#perform PCA

#scaling our data (PCA strongly influenced by variance in each column)
pca_df <- prcomp(df, center = TRUE, scale = TRUE)

#find the proportion of variance explained by each component
std_dev <- pca_df$sdev
pr_var <- std_dev^2
prop_varex <- pr_var/sum(pr_var)

pdf(file = "figures/pca_variance_plot.pdf")
plot(cumsum(prop_varex), xlab = "Principal Component",
     ylab = "Cumulative Proportion of Variance Explained",
     type= "b")
dev.off()

#extract first 500 components
df_transform <- as.data.frame(-pca_df$x[,1:500])
################################################
#k-means clustering

#determine the number of clusters k
pdf(file = "figures/k_means_silhouette_plot.pdf")
fviz_nbclust(df_transform, kmeans, method = 'silhouette')
dev.off()

#kmeans clustering
kmeans_df <- kmeans(df_transform, centers = 2, nstart = 20)
pdf(file = "figures/k_means_plot.pdf")
fviz_cluster(kmeans_df, data=df_transform)
dev.off()
################################################
#spectral clustering 
#citation: https://rpubs.com/nurakawa/spectral-clustering

spectral_clustering <- function(X, # matrix of data points
                                nn = 10, # the k nearest neighbors to consider
                                n_eig = 2) # m number of eignenvectors to keep
{
  mutual_knn_graph <- function(X, nn = 10)
  {
    D <- as.matrix( dist(X) ) # matrix of euclidean distances between data points in X
    
    # intialize the knn matrix
    knn_mat <- matrix(0,
                      nrow = nrow(X),
                      ncol = nrow(X))
    
    # find the 10 nearest neighbors for each point
    for (i in 1: nrow(X)) {
      neighbor_index <- order(D[i,])[2:(nn + 1)]
      knn_mat[i,][neighbor_index] <- 1 
    }
    
    # Now we note that i,j are neighbors iff K[i,j] = 1 or K[j,i] = 1 
    knn_mat <- knn_mat + t(knn_mat) # find mutual knn
    
    knn_mat[ knn_mat == 2 ] = 1
    
    return(knn_mat)
  }
  
  graph_laplacian <- function(W, normalized = TRUE)
  {
    stopifnot(nrow(W) == ncol(W)) 
    
    g = colSums(W) # degrees of vertices
    n = nrow(W)
    
    if(normalized)
    {
      D_half = diag(1 / sqrt(g) )
      return( diag(n) - D_half %*% W %*% D_half )
    }
    else
    {
      return( diag(g) - W )
    }
  }
  
  W = mutual_knn_graph(X) # 1. matrix of similarities
  L = graph_laplacian(W) # 2. compute graph laplacian
  ei = eigen(L, symmetric = TRUE) # 3. Compute the eigenvectors and values of L
  n = nrow(L)
  return(ei$vectors[,(n - n_eig):(n - 1)]) # return the eigenvectors of the n_eig smallest eigenvalues
  
}

# do spectral clustering procedure

X_sc <- spectral_clustering(df)

# run kmeans on the 2 eigenvectors
X_sc_kmeans <- kmeans(X_sc, 2)

pdf(file = "figures/spectral_clustering_plot.pdf")
fviz_cluster(X_sc_kmeans, data=df_transform)
dev.off()

