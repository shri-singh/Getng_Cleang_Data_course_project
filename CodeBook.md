---
title: "CodeBook"
author: "Shri Singh"
date: "August 1, 2017"
output: html_document
---

## CodeBook for data cleaning Project

This code book explains the data and processing steps in run_analysis.R 
Raw data zip file used for this anlysis is located at <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>.

### Data folder setup

Download the zip file and extract to local hard drive. Parent directory for unziped file is supplied as <file_path> parameter in the code.

        file_path      <- "C:/Users/Shrisingh/Documents/Courseera/Rprograming/UCI_HAR_Dataset/"

### Data files and Overview

Current assignment required to read experiment data collected on group of 30 volunteers within an age bracket of 19-48 years for six activities:
WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING
from wearable smart phone device.

Following are the files read in analysis:

1. Activity names: 
        activity_lbl<- fread(paste0(file_path,"activity_labels.txt")) #contains the 6 activity labels
        
2. Features or measurements details collected for these 6 activities.
        features  <- fread(paste0(file_path,"features.txt"))        # contains 561 feature metrics
        
3. Measurements on subjects: This data is stored under different folders [TEST/TRAIN]. Each folder contains 3 files

        * Subject Identifier for each measurement
                subject_test   <- fread(paste0(file_path,"test/subject_test.txt"))   # 9 subjects labels for 2947 obs
                subject_train  <- fread(paste0(file_path,"train/subject_train.txt")) # 21 subjects labels for 7352 obs
                
        * Activity Identifier for each measurement
                Y_test   <-  fread(paste0(file_path,"test/y_test.txt"))      # 6 activity labels for 2947 obs
                Y_train  <-  fread(paste0(file_path,"train/y_train.txt"))    # 6 activity labels for 7352 obs
                
        * Measurement file : Each row contains the measurement on 561 feature measures
                X_test   <-  fread(paste0(file_path,"test/X_test.txt"))     # 561 feature measures for 9 subjects 2947 obs
                X_train  <-  fread(paste0(file_path,"train/X_train.txt"))   # 561 feature measures for 21 subjects 7352 obs
                
### Data Processing Steps:
Data Processing in run_analysis.R is divided into five segments as follows:

0. Task 0 reads all the files explained above
1. Merges test and training datasets
        3 files for each group is mearged respectively.
2. Filter only mean() and standard deviation() measurements on features
        Mearged measurement file is given the column header names.
        Then using select statement from dplyr columns are filtered having mean and std dev measures.
3. File in step (2) is merged with activity identifiers and subject identifiers
        This Enables data to have descriptive variable names
4. File in step (3) is brought in state to have descriptive labels for activities
5. Preparation of Independent Tidy Data.
        Data in step (4) is changed to long format using melt function to have all meaurements under variablename.
        This enables easy parsing and extracting information from variable like :
        
                * Time/Frequency/Angle dimension
                * Measure either mean/sd
                * Variable name such that one varible can be stored in one column.
                
        After parsing these info data is conveted to wide format for taking average of measurements across subject and activity as desired.
        
        
                
