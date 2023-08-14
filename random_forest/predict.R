# Load required libraries
library(randomForest)
library(Matrix)
library(Seurat)
library(data.table)

load("../exprMatrix.RData")
print("expression matrix")
print(m_n_1000[1:5,1:5])
print(dim(m_n_1000))
data<-as.matrix(m_n_1000)

# Label the data
clusters<-fread("../clusters.tsv")
print("clusters")
head(clusters)
labels <- as.numeric(as.factor(clusters$cls_id))


train_indices <- sample(1:nrow(data), 0.8 * nrow(data))
train_data <- data[train_indices, ]
train_labels <- labels[train_indices]
test_data <- data[-train_indices, ]
test_labels <- labels[-train_indices]

# Train a Random Forest classifier
print("training")
rf_model <- randomForest(train_data, train_labels, ntree = 100)
saveRDS(rf_model, "rf_model.rds")
# Make predictions
print("predictions")
predictions <- predict(rf_model, test_data)
# Evaluate the model
accuracy <- sum(predictions == test_labels) / length(test_labels)
conf_matrix <- table(predictions, test_labels)
fwrite(conf_matrix,"conf_matrix.matrix",sep="\t")
precision <- conf_matrix[2, 2] / sum(conf_matrix[, 2])
recall <- conf_matrix[2, 2] / sum(conf_matrix[2, ])
f1_score <- 2 * (precision * recall) / (precision + recall)
# Print evaluation metrics
cat("Accuracy:", accuracy, "\n")
cat("Precision:", precision, "\n")
cat("Recall:", recall, "\n")
cat("F1-Score:", f1_score, "\n")

