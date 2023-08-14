# submission

To reproduce the results I downloaded this data
1. https://cf.10xgenomics.com/samples/cell/pbmc68k_rds/pbmc68k_data.rds
2. https://cf.10xgenomics.com/samples/cell/pbmc68k_rds/all_pure_select_11types.rds

#Step1: Ran `extract.R` to get the initial expression matrix (Cells x genes) and clusters (Cells x cell type annotations) 


#Step2: Divided data into 80% training data and 20% test data. Even though we have cell type annotation for each cell, this is an excercise to create the classifier.


#Step3: Ran random forest, neural network, logistic regression classifiers. Only one random forest one ran successfully.

