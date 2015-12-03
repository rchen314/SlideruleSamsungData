---
title: "CodeBook.md"
author: "Robert Chen"
date: "December 2, 2015"
output: html_document
---

# Overview

This is the script to perform the Data Wrangling project for the Sliderule "Foundations of Data Science" course.

It takes the Samsung Galaxy S data found in 

   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

and performs various operations on it.

This data consists of 561 parameters measured for 30 different subjects doing 6 different operations
(walking, going upstairs, going downstairs, sitting, standing, and laying).  The data for the 561
parameters are broken up into 2 files ("X_test.txt" in the "test" and "train" subdirectories).  Also,
data for the subject and activity tested, as well as the text description of the activity and the name
of each parameter can all be found in separate files.

These scripts take the different files and unify them into 1 data frame.  The following operations are 
performed:

   (1) Merge the 2 files with the parameter values into one file (using "rbind")
   
   (2) Extract all columns that have a mean or standard deviation measurement in them.
   
   (3) Create "ActivityLabel" and "ActivityName" columns, using the separate data file with activity
       tested and the separate file that maps each activity number to a text description of the activity.
       
   (4) Create a dataset that has the average value of each parameter for each subject and each activity,
       with the dataset being in tidy form (one parameter value per row)

# Key Variables

Most of the variable names are straightforward.  Key results can be found in the following variables:

      merged      The results of merging the 2 files for item (1)
      
      meanstd     The results of extracting all columns with mean or standard deviation in them for item (2)
      
      ma          The results of adding ActivityLabel and ActivityName for item (3)
      
      final_tidy  The results of making a tidy summary average dataset for item (4)

# Data

The following data files are used:

     test/X_test.txt          2947 values for the 561 parameters
     train/X_train.txt        7352 values for the 561 parameters
     
     test/y_test.txt          The associated activity for the 2947 test values
     test/subject_test.txt    The associated subject for the 2947 test values
     
     train/y_train.txt        The associated activity for the 7352 training values
     train/subject_train.txt  The associated subject for the 7352 training values
     
     features.txt             The name for each of the 561 parameters
     activity_labels.txt      The activity associated with the 6 values of "ActivityLabel"

# Code Explanation / Key Transformations

Most of the code is straightforward.  The key transformations are those done for part (4).  The
finding the average of each parameter for each subject and activity is done using a combination
of "group_by()" and "summarise_each()" from dplyr:

```{r}
final <- ma %>% group_by(Subject, ActivityName) %>% summarise_each(funs(mean))
```

Making this final data tidy requires taking the 561 columns with the average values and making them each
into a separate row.  Here, the "melt()" function from reshape2 is used.  Columns 1 to 3 are
left as-is, and everything after that is assigned a new row with the former column name
reflected in the "Parameter" value:

```{r}
final_tidy <- melt(data=final, id=1:3, variable.name = "Parameter", value.name = "value") 
```

# Issues / Workarounds

There were 2 slightly tricky things encountered. The first was, when making the vector of
column names from the file "features.txt", the data was read in as a data frame.  This
meant concatenating the Activity and Subject labels later didn't turn out as expected.
A force of these names to a vector of characters was done by using colClasses = "character"
when reading in the text file:

```{r}
col_names  <- read.table("features.txt", colClasses = "character")  # Prevent conversion to factors
```

Second, when the summarise_each was attempted, there was an error message that some column
names were not unique.  This was addressed by using make.names() with unique=TRUE set:

```{r}
col_names <- make.names(col_names, unique = TRUE)     # Make names unique
```