#-----Getting and Cleaning Data--Course Project-----#

#Loading the Required Libraries
library("dplyr")
library("plyr")
library("data.table")

#Creating a folder to store my project in
if(!file.exists("CourseProject")) {
  dir.create("CourseProject")
}

#Download the zip folder
zipUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(zipUrl,destfile = "./CourseProject/dataset.zip", method="curl", mode="wb")

#Set the working directory to the Course Project directory
if(file.exists("CourseProject")) {
  setwd("./CourseProject")
}

setwd("./UCI Har Dataset")

#Loading the Raw Datasets
subjectTrain = read.table('./train/subject_train.txt',header=FALSE)
xTrain = read.table('./train/x_train.txt',header=FALSE)
yTrain = read.table('./train/y_train.txt',header=FALSE)

subjectTest = read.table('./test/subject_test.txt',header=FALSE)
xTest = read.table('./test/x_test.txt',header=FALSE)
yTest = read.table('./test/y_test.txt',header=FALSE)


#Organizing and combining raw datasets into a single one
xDataSet <- rbind(xTrain, xTest)
yDataSet <- rbind(yTrain, yTest)
subjectDataSet <- rbind(subjectTrain, subjectTest)
dim(xDataSet)

#Extracting only the measurements on the mean and standard deviation 
#for each measurement
xDataSet_mean_std <- xDataSet[, grep("-(mean|std)\\(\\)", read.table("features.txt")[, 2])]
names(xDataSet_mean_std) <- read.table("features.txt")[grep("-(mean|std)\\(\\)", read.table("features.txt")[, 2]), 2] 
View(xDataSet_mean_std)
dim(xDataSet_mean_std)


#Using descriptive activity names to name the activities in the data set
yDataSet[, 1] <- read.table("activity_labels.txt")[yDataSet[, 1], 2]
names(yDataSet) <- "Activity"
View(yDataSet)


#Appropriately labeling the data set with descriptive activity names
names(subjectDataSet) <- "Subject"
summary(subjectDataSet)

# Organizing and combining all data sets into single one.
singleDataSet <- cbind(xDataSet_mean_std, yDataSet, subjectDataSet)


# Defining descriptive names for all variables.
names(singleDataSet) <- make.names(names(singleDataSet))
names(singleDataSet) <- gsub('Acc',"Acceleration",names(singleDataSet))
names(singleDataSet) <- gsub('GyroJerk',"AngularAcceleration",names(singleDataSet))
names(singleDataSet) <- gsub('Gyro',"AngularSpeed",names(singleDataSet))
names(singleDataSet) <- gsub('Mag',"Magnitude",names(singleDataSet))
names(singleDataSet) <- gsub('^t',"TimeDomain.",names(singleDataSet))
names(singleDataSet) <- gsub('^f',"FrequencyDomain.",names(singleDataSet))
names(singleDataSet) <- gsub('\\.mean',".Mean",names(singleDataSet))
names(singleDataSet) <- gsub('\\.std',".StandardDeviation",names(singleDataSet))
names(singleDataSet) <- gsub('Freq\\.',"Frequency.",names(singleDataSet))
names(singleDataSet) <- gsub('Freq$',"Frequency",names(singleDataSet))

View(singleDataSet)


#Creating a second, independent tidy data set with the average of each variable for each activity and each subject
names(singleDataSet)
Data2<-aggregate(. ~Subject + Activity, singleDataSet, mean)
Data2<-Data2[order(Data2$Subject,Data2$Activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)