# Final Project

setwd("C:/Users/boqun.yin/Desktop/Courses/Getting and Cleaning Data/Final Project")

# You should create one R script called run_analysis.R that does the following.
# 
# 1.Merges the training and the test sets to create one data set.
# 2.Extracts only the measurements on the mean and standard deviation for each measurement.
# 3.Uses descriptive activity names to name the activities in the data set
# 4.Appropriately labels the data set with descriptive variable names.
# 5.From the data set in step 4, creates a second, independent tidy data set with the 
#   average of each variable for each activity and each subject.

library(data.table)
library(reshape2)

#Downloaded and unzipped the file manually, and saved them under this directory
link <- file.path(getwd() , "UCI HAR Dataset")
docs<-list.files(link, recursive=TRUE)
docs

#Question 1
#Read the Activity files

dataActivityTest  <- read.table(file.path(link, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(link, "train", "Y_train.txt"),header = FALSE)

#Read the Subject files
dataSubjectTrain <- read.table(file.path(link, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(link, "test" , "subject_test.txt"),header = FALSE)

#Read Fearures files
dataFeaturesTest  <- read.table(file.path(link, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(link, "train", "X_train.txt"),header = FALSE)

#Combine the data by category
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#Reformat the names
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(link, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#Create the total dataset
total<-cbind(dataFeatures,dataSubject,dataActivity)

#Question 2
#Obtain the column number of all the relevant column
grep("mean\\(\\)|std\\(\\)",names(total))
#subset
sub<-total[,c(grep("mean\\(\\)|std\\(\\)",names(total)))]

#Question 3
Labels <- read.table(file.path(link, "activity_labels.txt"),header = FALSE)
total_l<-merge(total,Labels,by.x="activity",by.y="V1",all.x=TRUE)
#Use descriptive number for activity instead of digits
total_l$activity<-total_l$V2
#Remove the orignal column, V2
total_l$V2<-NULL

#Question 4
names(total_l)<-gsub("^t", "time", names(total_l))
names(total_l)<-gsub("^f", "frequency", names(total_l))
names(total_l)<-gsub("Acc", "Accelerometer", names(total_l))
names(total_l)<-gsub("Gyro", "Gyroscope", names(total_l))
names(total_l)<-gsub("Mag", "Magnitude", names(total_l))
names(total_l)<-gsub("BodyBody", "Body", names(total_l))

#Question 5
library(plyr);
total_t<-aggregate(. ~subject + activity, total_l, mean)
total_t<-Data2[order(total_t$subject,total_t$activity),]
write.table(total_t, file = "clean.txt",row.name=FALSE)
