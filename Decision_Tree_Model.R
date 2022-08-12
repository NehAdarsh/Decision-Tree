#Installing libraries
install.packages('rpart')
install.packages('caret')
install.packages('rpart.plot')
install.packages('rattle')
install.packages('readxl')
install.packages("dplyr")
install.packages("ggplot2")
install.packages("descr")
install.packages("psych")

#Loading libraries
library(rpart,quietly = TRUE)
library(caret,quietly = TRUE)
library(rpart.plot,quietly = TRUE)
library(rattle)
library(readxl)
library(dplyr)
library(ggplot2)
library(descr)
library(psych)
library(gridExtra)

#Data Importing and a few basic checks to get to know the data
mushroom_data = read.csv(file.choose(), header = T, na.strings=c("","NA"), strip.white = TRUE)
View(mushroom_data)                                                #View the data in a tabular form in a new tab
nrow(mushroom_data)                                                #total rows
ncol(mushroom_data)                                                #total columns
names(mushroom_data)                                               #variable names
str(mushroom_data)                                                 #Structure of the data
summary(mushroom_data)                                             #Summary of the data
data.frame(sapply(mushroom_data, class))                           #checking data types od the variables
describe(mushroom_data)                                            #basic statistical details about data

#Analyzing the variables
nrow(mushroom_data) - sum(complete.cases(mushroom_data))           #number of rows with missing values
mushroom_data$veil.type <- NULL                                    #deleting redundant variable `veil.type`


################################################################################
################################################################################
names(mushroom_data)                                               

# Converting all variable into factors
library(tidyverse)
mushroom_data2 = mushroom_data %>% map_df(function(.x) as.factor(.x))

#Redefine each of the category for each of the variables
levels(mushroom_data2$class) = c("edible", "poisonous")
levels(mushroom_data2$cap.shape) = c("bell", "conical", "flat", "knobbed", "sunken", "convex")
levels(mushroom_data2$cap.surface) <- c("fibrous", "grooves", "scaly", "smooth")
levels(mushroom_data2$cap.color) <- c("buff", "cinnamon", "red", "gray", "brown", "pink", 
                                "green", "purple", "white", "yellow")
levels(mushroom_data2$bruises) <- c("no", "yes")
levels(mushroom_data2$odor) <- c("almond", "creosote", "foul", "anise", "musty", "none", "pungent", "spicy", "fishy")
levels(mushroom_data2$gill.attachment) <- c("attached", "free")
levels(mushroom_data2$gill.spacing) <- c("close", "crowded")
levels(mushroom_data2$gill.size) <- c("broad", "narrow")
levels(mushroom_data2$gill.color) <- c("buff", "red", "gray", "chocolate", "black", "brown", "orange", 
                                 "pink", "green", "purple", "white", "yellow")
levels(mushroom_data2$stalk.shape) <- c("enlarging", "tapering")
levels(mushroom_data2$stalk.root) <- c("missing", "bulbous", "club", "equal", "rooted")
levels(mushroom_data2$stalk.surface.above.ring) <- c("fibrous", "silky", "smooth", "scaly")
levels(mushroom_data2$stalk.surface.below.ring) <- c("fibrous", "silky", "smooth", "scaly")
levels(mushroom_data2$stalk.color.above.ring) <- c("buff", "cinnamon", "red", "gray", "brown", "pink", 
                                             "green", "purple", "white", "yellow")
levels(mushroom_data2$stalk.color.below.ring) <- c("buff", "cinnamon", "red", "gray", "brown", "pink", 
                                             "green", "purple", "white", "yellow")
levels(mushroom_data2$veil.type) <- "partial"
levels(mushroom_data2$veil.color) <- c("brown", "orange", "white", "yellow")
levels(mushroom_data2$ring.number) <- c("none", "one", "two")
levels(mushroom_data2$ring.type) <- c("evanescent", "flaring", "large", "none", "pendant")
levels(mushroom_data2$spore.print.color) <- c("buff", "chocolate", "black", "brown", "orange", 
                                        "green", "purple", "white", "yellow")
levels(mushroom_data2$population) <- c("abundant", "clustered", "numerous", "scattered", "several", "solitary")
levels(mushroom_data2$habitat) <- c("wood", "grasses", "leaves", "meadows", "paths", "urban", "waste")

#Checking the variables after converting into factors
glimpse(mushroom_data2)

#Checking for missing data
any(is.na(mushroom_data2))

#Visualizing the data for variables
ggplot(mushroom_data2, aes(x = cap.surface, y = cap.color, col = class)) + 
  geom_jitter(alpha = 0.5) + 
  scale_color_manual(breaks = c("edible", "poisonous"), 
                     values = c("blue", "green"))

ggplot(mushroom_data2, aes(x = cap.shape, y = cap.color, col = class)) + 
  geom_jitter(alpha = 0.5) + 
  scale_color_manual(breaks = c("edible", "poisonous"), 
                     values = c("blue", "green"))

p1 = ggplot(aes(x = cap.shape), data = mushroom_data2) +
  geom_histogram(stat = "count") +
  facet_wrap(~class) +
  xlab("Cap Shape")

p2 = ggplot(aes(x = cap.surface), data = mushroom_data2) +
  geom_histogram(stat = "count") +
  facet_wrap(~class) +
  xlab("Cap Surface")

p3 = ggplot(aes(x = cap.color), data = mushroom_data2) +
  geom_histogram(stat = "count") +
  facet_wrap(~class) +
  xlab("Cap Color")

grid.arrange(p1, p2, p3, ncol = 2)

ggplot(mushroom_data2, aes(x = gill.color, y = cap.color, col = class)) + 
  geom_jitter(alpha = 0.5) + 
  scale_color_manual(breaks = c("edible", "poisonous"), 
                     values = c("blue", "green"))

ggplot(mushroom_data2, aes(x = class, y = odor, col = class)) + 
  geom_jitter(alpha = 0.5) + 
  scale_color_manual(breaks = c("edible", "poisonous"), 
                     values = c("blue", "green"))

p4 = ggplot(aes(x = bruises), data = mushroom_data2) +
  geom_histogram(stat = "count") +
  facet_wrap(~class) +
  xlab("Bruises")

p5 = ggplot(aes(x = odor), data = mushroom_data2) +
  geom_histogram(stat = "count") +
  facet_wrap(~class) +
  xlab("Odor")

grid.arrange(p4, p5, ncol = 2)

##############################################################################
##############################################################################

## Modelling
#Training and testing set conversion of data
set.seed(1810)
mush1 = caret::createDataPartition(y = mushroom_data2$class, times = 1, p = 0.8, list = FALSE)
train_mushroom = mushroom_data2[mush1, ]
test_mushroom = mushroom_data2[-mush1, ]

#Checking the quality of the splits
round(prop.table(table(mushroom_data2$class)), 2)


#Regression Tree
set.seed(1810)
mush_tree = rpart(class ~ ., data = train_mushroom, method = "class")
mush_tree

#Confusion Matrix
caret::confusionMatrix(data=predict(mush_tree, type = "class"), 
                       reference = train_mushroom$class, 
                       positive="edible")
#Penalty matrix
pen_matrix = matrix(c(0, 1, 10, 0), byrow = TRUE, nrow = 2)
penalty_mush = rpart(class ~ ., data = train_mushroom, method = "class", 
                            parms = list(loss = pen_matrix))
caret::confusionMatrix(data=predict(penalty_mush, type = "class"), 
                       reference = train_mushroom$class, 
                       positive="edible")

#Model tree - Pruning
model_tree = rpart(class ~ ., data = train_mushroom, 
                    method = "class", cp = 0.00001)
printcp(model_tree)
plotcp(model_tree)

# choosing the best complexity parameter "cp" to prune the tree
cp.optim <- model_tree$cptable[which.min(model_tree$cptable[,"xerror"]),"CP"]

# tree prunning using the best complexity parameter. For more in
tree <- prune(model_tree, cp=cp.optim)

rpart.plot(model_tree1, extra = 104, box.palette = "GnBu", 
           branch.lty = 3, shadow.col = "gray", nn = TRUE)

#Checking how are model is performing on training data
#Testing the model
pred <- predict(object=tree,test_mushroom[-1],type="class")

#Calculating accuracy
t <- table(test_mushroom$class,pred) 
confusionMatrix(t) 


##############################################################################
##############################################################################








