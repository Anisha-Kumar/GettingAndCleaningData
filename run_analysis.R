library(dplyr)
library(tidyr)

# download the dataset from the source
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="Dataset.zip")

# unzip the file
unzip(zipfile="Dataset.zip",exdir = "./Dataset")

# set path
path1 <- file.path("./Dataset","UCI HAR Dataset")

# read the feature data for training and test samples
testx <- read.table(file.path(path1,"test","X_test.txt"), header = FALSE) 
trainx <- read.table(file.path(path1,"train","X_train.txt"), header = FALSE)

# combine feature data
combinedfeatures <- rbind(testx,trainx)

# read Activity data for training and test samples
testy <- read.table(file.path(path1,"test","y_test.txt"), header = FALSE)
trainy <- read.table(file.path(path1,"train","y_train.txt"), header = FALSE)

# combine Activity data
combinedActivity <- rbind(testy,trainy)

# read subject data for training and test samples
testsub <- read.table(file.path(path1,"test","subject_test.txt"), header = FALSE)
trainsub <- read.table(file.path(path1,"train","subject_train.txt"), header = FALSE)

# combine subject data
combinedsubject <- rbind(testsub,trainsub)

# remove non utilised tables
rm(testx,trainx,testy,trainy,testsub, trainsub)

# set column names for activity and subject data
names(combinedActivity) = "Activity"
names(combinedsubject)= "Subject"

# read feature names
featureNameFile <- read.table(file.path(path1,"features.txt"), header=FALSE)

# set feature data column names
names(combinedfeatures) <- featureNameFile$V2

# combine all data to create one data set
Combined_Data <- cbind(combinedActivity,combinedsubject, combinedfeatures)


# Assign valid column names
valid_column_names <- make.names(names=names(Combined_Data), unique=TRUE, allow_ = TRUE)
names(Combined_Data) <- valid_column_names

# Extract mean and std measurements
ext_Data <- select (Combined_Data,Activity,Subject, contains("mean"),contains("std"))

# Read activity labels
Names_activity <- read.table(file.path(path1,"activity_labels.txt"), header = FALSE)

# Set descriptive activity names to name the activities in the data set
Combined_Data$Activity <- factor(Combined_Data$Activity, labels = Names_activity[,2] )

# Set descriptive Column names to the data set
names(Combined_Data)<-gsub("^t", "Time", names(Combined_Data))
names(Combined_Data)<-gsub("^f", "Frequency", names(Combined_Data))
names(Combined_Data)<-gsub("Acc", "Accelerometer_", names(Combined_Data))
names(Combined_Data)<-gsub("Gyro", "Gyroscope_", names(Combined_Data))
names(Combined_Data)<-gsub("Mag", "Magnitude", names(Combined_Data))
names(Combined_Data)<-gsub("BodyBody", "Body", names(Combined_Data))
names(Combined_Data)<-gsub("\\.", "", names(Combined_Data))

# Create independent tidy data set with the average of each
#variable for each activity and each subject

finalData <- Combined_Data %>% group_by(Activity,Subject) %>% 
  summarise_each (funs(mean)) %>%
  write.table("TidyDataSet.txt",row.names =FALSE)




