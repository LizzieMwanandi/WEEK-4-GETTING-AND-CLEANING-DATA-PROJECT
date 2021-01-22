## 1.MERGING DATA

##1.1 Create a folder in which the data will downloaded

if(!file.exists("WeekFourProject")) { dir.create("WeekFourProject")}

##1.1.1 Downloading the file

DataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(DataUrl, destfile ="./WeekFourProject/UCD_Dataset.zip" ); 

##1.1.2 Unzip files and list files

unzip("UCD_Dataset.zip",exdir = "WeekFourProject")

list.files(path="./WeekFourProject/UCD_Dataset/UCI HAR Dataset")

##1.2 Read features files


FeaturesTest <- read.table("./WeekFourProject/UCD_Dataset/UCI HAR Dataset/test/X_test.txt", header = F)

FeaturesTrain <- read.table("./WeekFourProject/UCD_Dataset/UCI HAR Dataset/train/X_train.txt", header = F)

## 1.3 Read Subject files
SubjectTest<- read.table("./WeekFourProject/UCD_Dataset/UCI HAR Dataset/test/subject_test.txt", header = F)

SubjectTrain<- read.table("./WeekFourProject/UCD_Dataset/UCI HAR Dataset/train/subject_train.txt", header = F)

## 1.4 Read Activity files
ActivityTrain <- read.table("./WeekFourProject/UCD_Dataset/UCI HAR Dataset/train/y_train.txt", header = F)

ActivityTest <- read.table("./WeekFourProject/UCD_Dataset/UCI HAR Dataset/test/y_test.txt", header = F)

##1.5 read Features Names


FeaturesNames<- read.table("./WeekFourProject/UCD_Dataset/UCI HAR Dataset/features.txt", header = F)
  

##1.5 Read activity labels

ActivityLabels <- read.table("./WeekFourProject/UCD_Dataset/UCI HAR Dataset/activity_labels.txt", header= F)


##1.6 Merge Data the three Data frames


FeaturesData <- rbind(FeaturesTest, FeaturesTrain)
SubjectData <- rbind(SubjectTest, SubjectTrain)
ActivityData <- rbind(ActivityTest, ActivityTrain)

#1.7 Rename Columns in Activity_Data and Activity_Labels

names(ActivityData) <- "ActivityN"
names(ActivityLabels) <- c("ActivityN", "Activity")


#1.8 Get factor of Activity_names

Activity <- left_join(ActivityData, ActivityLabels, "ActivityN")[, 2]

##1.9 Rename Columns

###Rename SubjectData columns

names(SubjectData) <- "Subject"

#Rename FeaturesData columns using columns from FeaturesNames

names(FeaturesData) <- FeaturesNames$V2


## 1.9.0 Create one large Dataset with only these variables: SubjectData,  Activity,  FeaturesData
DataSet <- cbind(SubjectData, Activity)
DataSet <- cbind(DataSet, FeaturesData)

### 2 Create New datasets by extracting only the measurements on the mean and standard deviation for each measurement
subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
DataNames <- c("Subject", "Activity", as.character(subFeaturesNames))
DataSet <- subset(DataSet, select=DataNames)

#####2.1 Rename the columns of the large dataset using more descriptive activity names
names(DataSet)<-gsub("^t", "time", names(DataSet))
names(DataSet)<-gsub("^f", "frequency", names(DataSet))
names(DataSet)<-gsub("Acc", "Accelerometer", names(DataSet))
names(DataSet)<-gsub("Gyro", "Gyroscope", names(DataSet))
names(DataSet)<-gsub("Mag", "Magnitude", names(DataSet))
names(DataSet)<-gsub("BodyBody", "Body", names(DataSet))

#### 3 Create a second, independent tidy data set with the average of each variable for each activity and each subject
SecondDataSet<-aggregate(. ~Subject + Activity, DataSet, mean)
SecondDataSet<-SecondDataSet[order(SecondDataSet$Subject,SecondDataSet$Activity),]

# 4 Save this tidy dataset to local file
write.table(SecondDataSet, file = "tidydata.txt",row.name=FALSE)