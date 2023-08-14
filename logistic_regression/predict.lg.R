
# Load required libraries
library(caret)
library(Matrix)
library(Seurat)
library(data.table)

load("exprMatrix.RData")
print("expression matrix")
print(m_n_1000[1:5,1:5])
print(dim(m_n_1000))
data<-as.matrix(m_n_1000)

# Label the data
clusters<-fread("clusters.tsv")
print("clusters")
head(clusters)
labels <- as.numeric(as.factor(clusters$cls_id))


train_indices <- sample(1:nrow(data), 0.8 * nrow(data))
train_data <- data[train_indices, ]
train_labels <- labels[train_indices]
test_data <- data[-train_indices, ]
test_labels <- labels[-train_indices]
# Train a logistic regression classifier
print("training")
# Train a Logistic Regression model
logreg_model <- glm(train_labels ~ ., data = data.frame(cbind(train_data, train_labels)))


saveRDS(logreg_model, "logreg_model.rds")

# Make predictions
print("predictions")
predictions <- predict(logreg_model, newdata = data.frame(test_data))
print(head(predictions))
predicted_labels <- factor(ifelse(predictions > 0.5, 1, 0), levels = levels(factor(train_labels)))
print("predictions2")
print(head(predictions))

# Evaluate the model
conf_matrix <- confusionMatrix(predictions, test_labels)
accuracy <- conf_matrix$overall["Accuracy"]
precision <- conf_matrix$byClass["Pos Pred Value"]
recall <- conf_matrix$byClass["Sensitivity"]
f1_score <- conf_matrix$byClass["F1"]


# Print evaluation metrics
cat("Accuracy:", accuracy, "\n")
cat("Precision:", precision, "\n")
cat("Recall:", recall, "\n")
cat("F1-Score:", f1_score, "\n")

fwrite(conf_matrix,"conf_matrix.lg.matrix",sep="\t")
