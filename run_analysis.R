library(dplyr)
library(reshape2)

# Read in data
setwd("C:/Users/user/My Documents/Samsung")
X_test <- read.table("test/X_test.txt")
Y_test <- read.table("test/y_test.txt")
X_train <- read.table("train/X_train.txt")
Y_train <- read.table("train/y_train.txt")
col_names  <- read.table("features.txt", colClasses = "character")  # Prevent conversion to factors
activities <- read.table("activity_labels.txt")
sub_test   <- read.table("test/subject_test.txt")
sub_train  <- read.table("train/subject_train.txt")

# Combine X, Y, and subject values
test_full  <- cbind(sub_test, Y_test, X_test)
train_full <- cbind(sub_train, Y_train, X_train)
merged <- rbind(test_full, train_full)

# Add column headers
col_names <- col_names[[2]]                           # Extract just the labels as chars
col_names <- c("Subject", "ActivityLabel", col_names) # Insert label for activity
col_names <- make.names(col_names, unique = TRUE)     # Make names unique
colnames(merged) <- col_names

# Extract columns containing mean and std deviation
meanstd <- select(merged, matches("mean|std"))

# "ActivityLabel" already created -- add "ActivityName" column
act_col_names <- c("ActivityLabel", "ActivityName")   # Names for ActivityLabel file
colnames(activities) <- act_col_names                 # Assign names
ma <- full_join(merged, activities)     
ma <- ma[, c(1:2, 564, 3:563)]           # Move "ActivityName" to 3rd column

# Create a second, independent data set with the average of each 
# activity for each activity and subject
final <- ma %>% group_by(Subject, ActivityName) %>% summarise_each(funs(mean))

# Make that data set tidy
final_tidy <- melt(data=final, id=1:3, variable.name = "Parameter", value.name = "Value") 

# Export tidy dataset to a file
write.table(final_tidy, file="final_tidy_dataset.txt")
