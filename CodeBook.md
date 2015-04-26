---
title: "CodeBook"
author: "Anisha Kumar"
date: "Thursday, April 23, 2015"

---

# Getting and Cleaning Data Course Project
## Instructions for project
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

You should create one R script called run_analysis.R that does the following.

* 1. Merges the training and the test sets to create one data set.
* 2. Extracts only the measurements on the mean and standard deviation for each measurement.
* 3. Uses descriptive activity names to name the activities in the data set
* 4. Appropriately labels the data set with descriptive variable names.
* 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## initialiaze the packages to be used


```r
library(dplyr)
library(tidyr)
```

## Download the dataset from the source


```r
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
setInternet2(use = TRUE)
download.file(fileUrl,destfile="Dataset.zip" ,method ="internal" , mode="wb")
```
### Unzip the file and set the path
The unzipped files are in the folder UCI HAR Dataset within Dataset folder.
The location to these files is stored in path1 variable

```r
unzip(zipfile="Dataset.zip",exdir = "./Dataset")
```

```r
path1 <- file.path("./Dataset","UCI HAR Dataset")
```
# Read Data
See the README.txt file for the detailed information on the dataset. For the purposes of this project, the files in the Inertial Signals folders are not used. The files that will be used to load data are listed as follows:

* test/subject_test.txt
* test/X_test.txt
* test/y_test.txt
* train/subject_train.txt
* train/X_train.txt
* train/y_train.txt

##Read the feature, Activity, subject data for training and test samples
Feature data is stored in variables testx and trainx
Activity data is stored in variables testy and trainy
Subject data is stored in variables testsub and trainsub

The Feature, Activity and Subject data are combined using the rbind() function and the result stored in variables combinedfeatures, combinedActivity and combinedsubject respectivly


```r
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
```

## Remove unutilised variables
Remove non utilised variables in order not to overload the memory


```r
rm(testx,trainx,testy,trainy,testsub, trainsub)
```

## set column names for activity and subject data


```r
names(combinedActivity) = "Activity"
names(combinedsubject)= "Subject"
```

## read feature names and set feature data column names as provided in the features.txt file.


```r
featureNameFile <- read.table(file.path(path1,"features.txt"), header=FALSE)
names(combinedfeatures) <- featureNameFile$V2
```
## combine all data to create one data set and store it in a variable 

```r
Combined_Data <- cbind(combinedActivity,combinedsubject, combinedfeatures)
```
## Assign valid column names to the combined data set  using  make.names function to ensure that column names does not have invalid characters

```r
valid_column_names <- make.names(names=names(Combined_Data), unique=TRUE, allow_ = TRUE)
names(Combined_Data) <- valid_column_names
```

## Extract mean and std measurements from the combined dataset

```r
ext_Data <- select (Combined_Data,Activity,Subject, contains("mean"),contains("std"))
```
Read activity labels and replace old names with descriptive activity names to name the activities in the data set through factorising the Activity column 

```r
Names_activity <- read.table(file.path(path1,"activity_labels.txt"), header = FALSE)
Combined_Data$Activity <- factor(Combined_Data$Activity, labels = Names_activity[,2] )

# Set descriptive Column names to the data set using names() and gsub()
names(Combined_Data)<-gsub("^t", "Time", names(Combined_Data))
names(Combined_Data)<-gsub("^f", "Frequency", names(Combined_Data))
names(Combined_Data)<-gsub("Acc", "Accelerometer_", names(Combined_Data))
names(Combined_Data)<-gsub("Gyro", "Gyroscope_", names(Combined_Data))
names(Combined_Data)<-gsub("Mag", "Magnitude", names(Combined_Data))
names(Combined_Data)<-gsub("BodyBody", "Body", names(Combined_Data))
names(Combined_Data)<-gsub("\\.", "", names(Combined_Data))
```
## 4. Independent tidy data set 

Create independent tidy data set with the average of each variable for each activity and each subject through pipelining the following functions ( group_by ,sumarrise_each, and finally write the table in TidayDataSet.txt using the function write.table)

```r
finalData <- Combined_Data %>% group_by(Activity,Subject) %>% 
  summarise_each (funs(mean)) %>%
  write.table("TidyDataSet.txt",row.names =FALSE)
```



