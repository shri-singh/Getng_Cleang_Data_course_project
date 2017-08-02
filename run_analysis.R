#This script reads and cleans the data for assignment
# library calls
#-------------------------
library(dplyr)
library(data.table)
library(reshape)
library(stringr)
#-------------------------

#-------------Task-0 : Reading files and variable naming --------------------------------------------
# set the directory where the assignment zip data files are unzipped
file_path      <- "C:/Users/Shrisingh/Documents/Courseera/Rprograming/UCI_HAR_Dataset/"

# read activity_lables and features.txt file(s)
activity_lbl        <- fread(paste0(file_path,"activity_labels.txt")) #contains the 6 activity labels
names(activity_lbl) <-c("activity_code","activity_name")

features            <- fread(paste0(file_path,"features.txt"))        # contains 561 feature metrics
#Cleaning the descriptive names # Replace special characters like -,() with "_" in var name
        
features$varnames<- paste0(gsub("__","",gsub("[^[:alnum:]]","_",features$V2)),"_",features$V1)

# read test datasets
subject_test    <- fread(paste0(file_path,"test/subject_test.txt")) # 9 subjects labels for 2947 obs
table(subject_test$V1)                                              # Freq count for each subject
X_test          <-  fread(paste0(file_path,"test/X_test.txt"))     # 561 feature measures for 9 subjects 2947 obs
dim(X_test)                                                         # 2947 obs , 561 feature vars

Y_test          <-  fread(paste0(file_path,"test/y_test.txt"))      # 6 activity labels for 2947 obs
table(Y_test$V1)                                                    # Freq count for each activity

# read train datasets
subject_train  <- fread(paste0(file_path,"train/subject_train.txt")) # 21 subjects labels for 7352 obs
table(subject_train$V1)                                              # Freq count for each subject

X_train        <-  fread(paste0(file_path,"train/X_train.txt"))      # 561 feature measures for 21 subjects 7352 obs
dim(X_train)

Y_train        <-  fread(paste0(file_path,"train/y_train.txt"))      # 6 activity labels for 7352 obs
table(Y_train$V1)                                                    # Freq count for each activity
#- QC 2947/((2947+7352)) ~ 29% (28.6%) Test sample Obs
#- Test Volunteer 9/30 ~ 30% Test Sample Subjects

#-----Task-1 [Merge Test and Training Datasets Together]
subject_test$sample  <-"TEST"                                           #Flaging subjects to retain sampling info after merge
subject_train$sample <- "TRAIN"
subject_labels       <- rbind.data.frame(subject_test,subject_train)    # Append 2947 +7352 obs of subject labels 
names(subject_labels)[1] <- "Volunter_ID"

activity_lables      <- rbind.data.frame(Y_test,Y_train)                # Append 2947 +7352 obs of activity labels
names(activity_lables)<-"activity_code"
activity_measures    <- rbind.data.frame(X_test,X_train)               # Append 2947 +7352 obs of 561 activity measures

#-----Task-2 [Extract only measurement of features for mean() and stdev() vars]
names(activity_measures) <- features$varnames
filtered_activity_measure <- select(activity_measures,contains("_mean_"),contains("_std_"))
#----- Task-3 & 4 [Use descriptive labels for activities and subject labels ]

filtered_activity_labled<- cbind.data.frame(activity_lables,subject_labels,filtered_activity_measure)
filtered_activity_labled<-left_join(x=filtered_activity_labled,y=activity_lbl,by="activity_code")

#------ Task-5 [Making data Tidy]--------------------------------------
tidy_activity <- melt(filtered_activity_labled,id=c("activity_code","activity_name","Volunter_ID","sample"))
tidy_activity$variable_n <- gsub("_[0-9].*","",tidy_activity$variable)
tidy_activity$feature_   <- str_split_fixed(tidy_activity$variable_n,"_",3)[,1]
tidy_activity$measure    <- str_split_fixed(tidy_activity$variable_n,"_",3)[,2]
tidy_activity$feat_sufx  <- str_split_fixed(tidy_activity$variable_n,"_",3)[,3]
tidy_activity$domain_    <- substr(tidy_activity$feature_,1,1)                             #define time/freq domain
tidy_activity$feature__  <- sub("^f|t","",tidy_activity$feature_)
tidy_activity$feature_name <- paste0(tidy_activity$feature__,"_",tidy_activity$feat_sufx)  #refined activity name
tidy_activity$variable=tidy_activity$variable_n=tidy_activity$feature_=tidy_activity$feat_sufx=tidy_activity$feature__ =NULL #droping columns
tidy_activity_labled <- cast(tidy_activity,activity_code+activity_name+Volunter_ID+sample+domain_+measure~feature_name,fun.aggregate = mean,na.rm=TRUE) #final tidy data
