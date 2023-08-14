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

# Normalize feature values
print("normalize")
train_data <- scale(train_data)
test_data <- scale(test_data)

# Convert labels to one-hot encoding
print("convert")
train_labels_onehot <- keras::to_categorical(train_labels)
test_labels_onehot <- keras::to_categorical(test_labels)

# Build the neural network model
print("build")
model <- keras_model_sequential() %>%
  layer_dense(units = 128, activation = "relu", input_shape = ncol(train_data)) %>%
  layer_dropout(rate = 0.5) %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dropout(rate = 0.5) %>%
  layer_dense(units = num_unique_labels, activation = "softmax")  # Adjust num_unique_labels

# Compile the model
print("compile")
model %>% compile(
  loss = "categorical_crossentropy",
  optimizer = optimizer_adam(),
  metrics = c("accuracy")
)


# Train a NN classifier
print("training")
history <- model %>% fit(
  train_data, train_labels_onehot,
  epochs = 20,
  batch_size = 32,
  validation_split = 0.2
)

saveRDS(history, "nn_model.rds")
# Evaluate the model
evaluation <- model %>% evaluate(test_data, test_labels_onehot)
accuracy <- evaluation$acc

# Print evaluation metric
cat("Accuracy:", accuracy, "\n")
