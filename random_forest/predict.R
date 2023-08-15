#Load libraries

library(Matrix)
library(data.table)
library("rpart")
library("rpart.plot")
library(caret)

#Load expression matrix and cluster information
load("../exprMatrix.RData")
print("expression matrix")
print(m_n_1000[1:5,1:5])
print(dim(m_n_1000))

data<-as.matrix(m_n_1000)
clusters<-fread("../clusters.tsv")
print("clusters")
head(clusters)
labels <- as.numeric(as.factor(clusters$cls_id))
head(labels)

#Divide training and testing data
tr <- sample(nrow(data), round(nrow(data) * 0.6))
head(tr)
data<-data.frame(as.matrix(m_n_1000))
data[1:5,1:5]
train <- data[tr, ]
test <- data[-tr, ]
train_labels <- labels[tr]
test_labels <- labels[-tr]

m_train<-data.frame(cbind(train, train_labels))
m_test<-data.frame(cbind(test, test_labels))


#Construct model
m <- rpart(train_labels ~ ., data = m_train,method = "class")

#plot tree
png(file="tree.png")
rpart.plot(m)
dev.off()

#predict on test data
p <- predict(m, m_test, type = "class")

#confusion matrix
table(p, m_test$test_labels)

confusionMatrix(factor(p), factor(m_test$test_labels))
