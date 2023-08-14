library(Matrix)
library(ggplot2)
library(Rtsne)
library(svd)
library(dplyr)
library(plyr)
library(data.table)

DATA_DIR <-"../data/"
PROG_DIR <- "./"
RES_DIR  <- "../results/"
source(file.path(PROG_DIR,'util.R'))

#Reading data downloaded from following url
#https://cf.10xgenomics.com/samples/cell/pbmc68k_rds/pbmc68k_data.rds
#https://cf.10xgenomics.com/samples/cell/pbmc68k_rds/all_pure_select_11types.rds

pbmc_68k <- readRDS(file.path(DATA_DIR,'pbmc68k_data.rds'))
all_data <- pbmc_68k$all_data
pure_11 <- readRDS(file.path(DATA_DIR,'all_pure_select_11types.rds'))
purified_ref_11 <- load_purified_pbmc_types(pure_11,pbmc_68k$ens_genes)

#normalize by RNA content (umi counts) and select the top 1000 most variable genes

m<-all_data[[1]]$hg19$mat
l<-.normalize_by_umi(m)   
m_n<-l$m
df<-.get_variable_gene(m_n) 
disp_cut_off<-sort(df$dispersion_norm,decreasing=T)[1000]
df$used<-df$dispersion_norm >= disp_cut_off

#use top 1000 variable genes for PCA 
set.seed(0)
m_n_1000<-m_n[,head(order(-df$dispersion_norm),1000)]
pca_n_1000<-.do_propack(m_n_1000,50)

#generate 2-D tSNE embedding
tsne_n_1000<-Rtsne(pca_n_1000$pca,pca=F)
tdf_n_1000<-data.frame(tsne_n_1000$Y)

# assign IDs by comparing the transcriptome profile of each cell to the reference profile from purified PBMC populations
m_filt<-m_n_1000
use_genes_n<-order(-df$dispersion_norm)
use_genes_n_id<-all_data[[1]]$hg19$gene_symbols[l$use_genes][order(-df$dispersion_norm)]
use_genes_n_ens<-all_data[[1]]$hg19$genes[l$use_genes][order(-df$dispersion_norm)]
z_1000_11<-.compare_by_cor(m_filt,use_genes_n_ens[1:1000],purified_ref_11) 
# reassign IDs, as there're some overlaps in the purified pbmc populations
test<-.reassign_pbmc_11(z_1000_11)
cls_id<-factor(colnames(z_1000_11)[test])
tdf_n_1000$cls_id<-cls_id

# use k-means clustering to specify populations
set.seed(0)
k_n_1000<-kmeans(pca_n_1000$pca,10,iter.max=150,algorithm="MacQueen")
tdf_n_1000$k<-k_n_1000$cluster

#Assign colnames and rownames
barcodes<-all_data[[1]]$hg19$barcodes
colnames(m_n_1000)<-use_genes_n_id[1:1000]
rownames(m_n_1000)<-barcodes
rownames(tdf_n_1000)<-barcodes

save(m_n_1000, file="exprMatrix.RData")

write.table(tdf_n_1000,, file = "clusters.tsv", row.names=TRUE, sep="\t")

