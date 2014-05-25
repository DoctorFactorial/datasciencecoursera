install.packages("plyr")
library(plyr)

## 1: Merges the training and the test sets to create one data set.
files <- list("./UCI HAR Dataset/test/X_test.txt", "./UCI HAR Dataset/train/X_train.txt")
data <- ldply(files, function(fn) read.table(fn)) 
str(data)
tail(data)
## Testing and training datasets are combined using the ldply package

## 2: Extracts only the measurements on the mean and standard deviation for each measurement. 
measure_mean <- apply(data,2,mean)
measure_sd <- apply(data,2,sd)
measure_m_sd <- rbind(v_mean,v_sd)
## mean and standard deviations for each measurement are calculated using the apply function
## these are combined into a single dataframe using the rbind function

## 3: Uses descriptive activity names to name the activities in the data set
files2 <- list("./UCI HAR Dataset/test/Y_test.txt", "./UCI HAR Dataset/train/Y_train.txt")
data2 <- ldply(files2, function(fn) read.table(fn)) 
act_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")

act_names <- data2
act_names[act_names == 1] <- as.character(act_labels[1,2])
act_names[act_names == 2] <- as.character(act_labels[2,2])
act_names[act_names == 3] <- as.character(act_labels[3,2])
act_names[act_names == 4] <- as.character(act_labels[4,2])
act_names[act_names == 5] <- as.character(act_labels[5,2])
act_names[act_names == 6] <- as.character(act_labels[6,2])

data <- cbind(data,data2,act_names)
## act_labels are used to convert the numeric actions listed in data2 to their name equivalent


## 4: Appropriately labels the data set with descriptive activity names. 
features <- as.vector(read.table("./UCI HAR Dataset/features.txt")[,2])
features <- c(features,"activity.label", "activity")

names(data) <- features
names(data) <- gsub("J", ".j", names(data))
names(data) <- gsub("B", ".b", names(data))
names(data) <- gsub("G", ".g", names(data))
names(data) <- gsub("M", ".m", names(data))
names(data) <- gsub("I", ".i", names(data))
names(data) <- gsub("A", ".a", names(data))
names(data) <- gsub("C", ".c", names(data))
names(data) <- gsub("-", ".", names(data))
names(data) <- gsub("X", "x", names(data))
names(data) <- gsub("Y", "y", names(data))
names(data) <- gsub("Z", "z", names(data))
## dataset names are added and tidied up

## 5: Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
files3 <- list("./UCI HAR Dataset/test/subject_test.txt", "./UCI HAR Dataset/train/subject_train.txt")
data3 <- ldply(files3, function(fn) read.table(fn)) 
data[,ncol(data)+1] <- data3 
features <- c(features, "subject")
names(data) <- features
## subject column is added to the dataset

f <- factor(data$subject)
s <- split(data,f)
subject_mean <- sapply(s, function(data) colMeans(data[ , 1:(ncol(data)-3)]))
for(i in seq_along(colnames(subject_mean))){
        colnames(subject_mean)[i] <- paste0("subject_",i)        
}

f2 <- factor(data$activity)
s2 <- split(data, f2)
activity_mean <- sapply(s2, function(data) colMeans(data[ , 1:(ncol(data)-3)]))
colnames(activity_mean) <- gsub("1", "WALKING", colnames(activity_mean))
colnames(activity_mean) <- gsub("2", "WALKING_UPSTAIRS", colnames(activity_mean))
colnames(activity_mean) <- gsub("3", "WALKING_DOWNSTAIRS", colnames(activity_mean))
colnames(activity_mean) <- gsub("4", "SITTING", colnames(activity_mean))
colnames(activity_mean) <- gsub("5", "STANDING", colnames(activity_mean))
colnames(activity_mean) <- gsub("6", "LAYING", colnames(activity_mean))

## measurement means are calculated for subject and activity splits
## column names are defined for both means specifying "subject" and using the activity_labels, 
## respectively. 

tidy_data <- cbind(activity_mean, subject_mean)
write.table(tidy_data, file = "tidy_data")
# tidy dataset of means created by column binding the two data frames
# writen out to file named tidy_data