Getting and Cleaning Data - Peer Assesment 1
============================================

Study Design:
-------------

Human Activity Recognition Using Smartphones Dataset
Version 1.0

Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto.
Smartlab - Non Linear Complex Systems Laboratory
DITEN - Universit‡ degli Studi di Genova.
Via Opera Pia 11A, I-16145, Genoa, Italy.
activityrecognition@smartlab.ws
www.smartlab.ws

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 

For each record it is provided:

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

Code Book:
----------

The dataset includes the following files:

- 'README.txt'

- 'features_info.txt': Shows information about the variables used on the feature vector.

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent. 

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 

- Features are normalized and bounded within [-1,1].
- Each feature vector is a row on the text file.

For more information about this dataset contact: activityrecognition@smartlab.ws


Instruction List:
-----------------

## 0: Install required packages

```r
install.packages("plyr")
```

```
## Error: trying to use CRAN without setting a mirror
```

```r
library(plyr)
```



## 1: Merge the training and the test sets to create one data set.

Testing and training datasets are combined using the ldply package


```r
files <- list("./UCI HAR Dataset/test/X_test.txt", "./UCI HAR Dataset/train/X_train.txt")
data <- ldply(files, function(fn) read.table(fn))
```



## 2: Extract only the measurements on the mean and standard deviation for each measurement. 
Mean and standard deviations for each measurement are calculated using the apply function. 
These are combined into a single dataframe using the rbind function.

```r
measure_mean <- apply(data, 2, mean)
measure_sd <- apply(data, 2, sd)
measure_m_sd <- rbind(v_mean, v_sd)
```

```
## Error: object 'v_mean' not found
```



## 3: Use descriptive activity names to name the activities in the data set

act_labels are used to convert the numeric actions listed in data2 to their name equivalent.


```r
files2 <- list("./UCI HAR Dataset/test/Y_test.txt", "./UCI HAR Dataset/train/Y_train.txt")
data2 <- ldply(files2, function(fn) read.table(fn))
act_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")

act_names <- data2
act_names[act_names == 1] <- as.character(act_labels[1, 2])
act_names[act_names == 2] <- as.character(act_labels[2, 2])
act_names[act_names == 3] <- as.character(act_labels[3, 2])
act_names[act_names == 4] <- as.character(act_labels[4, 2])
act_names[act_names == 5] <- as.character(act_labels[5, 2])
act_names[act_names == 6] <- as.character(act_labels[6, 2])

data <- cbind(data, data2, act_names)
```



## 4: Appropriately labels the data set with descriptive activity names. 

Data frame names are added and tidied up.


```r
features <- as.vector(read.table("./UCI HAR Dataset/features.txt")[, 2])
features <- c(features, "activity.label", "activity")

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
```


## 5: Create a second, independent tidy data set with the average of each variable for each activity and each subject. 

Subject column is added to the dataset


```r
files3 <- list("./UCI HAR Dataset/test/subject_test.txt", "./UCI HAR Dataset/train/subject_train.txt")
data3 <- ldply(files3, function(fn) read.table(fn))
data[, ncol(data) + 1] <- data3
features <- c(features, "subject")
names(data) <- features
```


Measurement means are calculated for subject and activity splits column names are defined for both means specifying "subject" and using the activity_labels, respectively. 


```r
f <- factor(data$subject)
s <- split(data, f)
subject_mean <- sapply(s, function(data) colMeans(data[, 1:(ncol(data) - 3)]))
for (i in seq_along(colnames(subject_mean))) {
    colnames(subject_mean)[i] <- paste0("subject_", i)
}

f2 <- factor(data$activity)
s2 <- split(data, f2)
activity_mean <- sapply(s2, function(data) colMeans(data[, 1:(ncol(data) - 3)]))
colnames(activity_mean) <- gsub("1", "WALKING", colnames(activity_mean))
colnames(activity_mean) <- gsub("2", "WALKING_UPSTAIRS", colnames(activity_mean))
colnames(activity_mean) <- gsub("3", "WALKING_DOWNSTAIRS", colnames(activity_mean))
colnames(activity_mean) <- gsub("4", "SITTING", colnames(activity_mean))
colnames(activity_mean) <- gsub("5", "STANDING", colnames(activity_mean))
colnames(activity_mean) <- gsub("6", "LAYING", colnames(activity_mean))
```


Tidy dataset of means created by column binding the two data frames.


```r
tidy_data <- cbind(activity_mean, subject_mean)
tidy_data
```

```
##                                         LAYING   SITTING   STANDING
## tBodyAcc-mean()-X                     0.268649  0.273060  0.2791535
## tBodyAcc-mean()-Y                    -0.018318 -0.012690 -0.0161519
## tBodyAcc-mean()-Z                    -0.107436 -0.105517 -0.1065869
## tBodyAcc-std()-X                     -0.960932 -0.983446 -0.9844347
## tBodyAcc-std()-Y                     -0.943507 -0.934881 -0.9325087
## tBodyAcc-std()-Z                     -0.948069 -0.938982 -0.9399135
## tBodyAcc-mad()-X                     -0.963395 -0.985280 -0.9872049
## tBodyAcc-mad()-Y                     -0.944099 -0.934798 -0.9338754
## tBodyAcc-mad()-Z                     -0.947261 -0.936671 -0.9377391
## tBodyAcc-max()-X                     -0.911610 -0.926703 -0.9212653
## tBodyAcc-max()-Y                     -0.541515 -0.531463 -0.5311004
## tBodyAcc-max()-Z                     -0.788488 -0.785243 -0.7853921
## tBodyAcc-min()-X                      0.806889  0.831115  0.8311122
## tBodyAcc-min()-Y                      0.667142  0.671579  0.6625054
## tBodyAcc-min()-Z                      0.820788  0.819410  0.8179436
## tBodyAcc-sma()                       -0.940765 -0.954336 -0.9549922
## tBodyAcc-energy()-X                  -0.994216 -0.998927 -0.9994565
## tBodyAcc-energy()-Y                  -0.988659 -0.993972 -0.9968850
## tBodyAcc-energy()-Z                  -0.982901 -0.988108 -0.9919770
## tBodyAcc-iqr()-X                     -0.967827 -0.987662 -0.9901788
## tBodyAcc-iqr()-Y                     -0.954821 -0.947493 -0.9477336
## tBodyAcc-iqr()-Z                     -0.947830 -0.935422 -0.9361143
## tBodyAcc-entropy()-X                 -0.354908 -0.528898 -0.5042264
## tBodyAcc-entropy()-Y                 -0.530032 -0.457787 -0.4213557
## tBodyAcc-entropy()-Z                 -0.459350 -0.413308 -0.4075415
## tBodyAcc-arCoeff()-X,1               -0.013842  0.128412  0.1660927
## tBodyAcc-arCoeff()-X,2               -0.004578 -0.040325 -0.0464133
## tBodyAcc-arCoeff()-X,3                0.007766  0.059289  0.0765230
## tBodyAcc-arCoeff()-X,4                0.048902  0.067177  0.0741089
## tBodyAcc-arCoeff()-Y,1                0.179418  0.105769  0.0352788
## tBodyAcc-arCoeff()-Y,2               -0.100994 -0.080040 -0.0630439
## tBodyAcc-arCoeff()-Y,3                0.197547  0.178591  0.1963109
## tBodyAcc-arCoeff()-Y,4                0.005827 -0.003342 -0.0475724
## tBodyAcc-arCoeff()-Z,1                0.216346  0.135105  0.1256212
## tBodyAcc-arCoeff()-Z,2               -0.087104 -0.072396 -0.0730049
## tBodyAcc-arCoeff()-Z,3                0.112131  0.077427  0.0920518
## tBodyAcc-arCoeff()-Z,4               -0.103244 -0.086023 -0.1432030
## tBodyAcc-correlation()-X,Y            0.085006 -0.189614  0.0954914
## tBodyAcc-correlation()-X,Z           -0.286605 -0.248874 -0.0714826
## tBodyAcc-correlation()-Y,Z           -0.246892  0.190920  0.2294508
## tGravityAcc-mean()-X                 -0.375021  0.879731  0.9414796
## tGravityAcc-mean()-Y                  0.622270  0.108714 -0.1842465
## tGravityAcc-mean()-Z                  0.555612  0.153774 -0.0140520
## tGravityAcc-std()-X                  -0.943320 -0.979682 -0.9880152
## tGravityAcc-std()-Y                  -0.963192 -0.957673 -0.9693518
## tGravityAcc-std()-Z                  -0.951869 -0.947357 -0.9530825
## tGravityAcc-mad()-X                  -0.944845 -0.980232 -0.9882253
## tGravityAcc-mad()-Y                  -0.964045 -0.959124 -0.9697496
## tGravityAcc-mad()-Z                  -0.953091 -0.948510 -0.9536312
## tGravityAcc-max()-X                  -0.419507  0.812240  0.8704356
## tGravityAcc-max()-Y                   0.589095  0.089624 -0.1983286
## tGravityAcc-max()-Z                   0.552823  0.155968 -0.0123876
## tGravityAcc-min()-X                  -0.342186  0.894066  0.9573471
## tGravityAcc-min()-Y                   0.628483  0.119312 -0.1643070
## tGravityAcc-min()-Z                   0.544958  0.143224 -0.0230655
## tGravityAcc-sma()                     0.173098 -0.129321 -0.2445141
## tGravityAcc-energy()-X               -0.956392  0.701719  0.8431038
## tGravityAcc-energy()-Y                0.058236 -0.892847 -0.9228020
## tGravityAcc-energy()-Z               -0.091266 -0.873145 -0.9527983
## tGravityAcc-iqr()-X                  -0.949241 -0.981887 -0.9888762
## tGravityAcc-iqr()-Y                  -0.966789 -0.964077 -0.9712863
## tGravityAcc-iqr()-Z                  -0.957194 -0.952836 -0.9558516
## tGravityAcc-entropy()-X              -0.642814 -0.831466 -0.8962553
## tGravityAcc-entropy()-Y              -0.696915 -0.705127 -0.9608540
## tGravityAcc-entropy()-Z              -0.624544 -0.625673 -0.7047837
## tGravityAcc-arCoeff()-X,1            -0.606991 -0.436852 -0.3718914
## tGravityAcc-arCoeff()-X,2             0.616055  0.458134  0.3981184
## tGravityAcc-arCoeff()-X,3            -0.624978 -0.479477 -0.4245142
## tGravityAcc-arCoeff()-X,4             0.633908  0.500984  0.4511686
## tGravityAcc-arCoeff()-Y,1            -0.275328 -0.431281 -0.4937768
## tGravityAcc-arCoeff()-Y,2             0.236084  0.400055  0.4627968
## tGravityAcc-arCoeff()-Y,3            -0.244491 -0.406244 -0.4649598
## tGravityAcc-arCoeff()-Y,4             0.273351  0.428542  0.4815592
## tGravityAcc-arCoeff()-Z,1            -0.344569 -0.489816 -0.5137579
## tGravityAcc-arCoeff()-Z,2             0.359560  0.500652  0.5217555
## tGravityAcc-arCoeff()-Z,3            -0.374275 -0.511161 -0.5294252
## tGravityAcc-arCoeff()-Z,4             0.386289  0.518704  0.5341068
## tGravityAcc-correlation()-X,Y         0.186950 -0.346214  0.3767986
## tGravityAcc-correlation()-X,Z        -0.395734 -0.344869  0.1180709
## tGravityAcc-correlation()-Y,Z        -0.415814  0.318619  0.3713077
## tBodyAccJerk-mean()-X                 0.081847  0.075879  0.0750279
## tBodyAccJerk-mean()-Y                 0.011172  0.005047  0.0088053
## tBodyAccJerk-mean()-Z                -0.004860 -0.002487 -0.0045821
## tBodyAccJerk-std()-X                 -0.980382 -0.984997 -0.9799686
## tBodyAccJerk-std()-Y                 -0.971148 -0.973883 -0.9643428
## tBodyAccJerk-std()-Z                 -0.979477 -0.982296 -0.9794859
## tBodyAccJerk-mad()-X                 -0.981738 -0.986283 -0.9820047
## tBodyAccJerk-mad()-Y                 -0.971199 -0.973473 -0.9640181
## tBodyAccJerk-mad()-Z                 -0.979233 -0.981580 -0.9791423
## tBodyAccJerk-max()-X                 -0.978923 -0.983704 -0.9775091
## tBodyAccJerk-max()-Y                 -0.978634 -0.980540 -0.9725695
## tBodyAccJerk-max()-Z                 -0.980418 -0.983108 -0.9796918
## tBodyAccJerk-min()-X                  0.975674  0.979894  0.9734946
## tBodyAccJerk-min()-Y                  0.974278  0.976746  0.9699685
## tBodyAccJerk-min()-Z                  0.973042  0.977500  0.9741709
## tBodyAccJerk-sma()                   -0.979045 -0.982446 -0.9771160
## tBodyAccJerk-energy()-X              -0.999305 -0.999606 -0.9992674
## tBodyAccJerk-energy()-Y              -0.998224 -0.998953 -0.9982951
## tBodyAccJerk-energy()-Z              -0.999039 -0.999410 -0.9992054
## tBodyAccJerk-iqr()-X                 -0.981846 -0.986343 -0.9827227
## tBodyAccJerk-iqr()-Y                 -0.976003 -0.976921 -0.9693697
## tBodyAccJerk-iqr()-Z                 -0.979562 -0.981177 -0.9791834
## tBodyAccJerk-entropy()-X             -0.630928 -0.690435 -0.6547533
## tBodyAccJerk-entropy()-Y             -0.662883 -0.669660 -0.5918357
## tBodyAccJerk-entropy()-Z             -0.662554 -0.667142 -0.6503999
## tBodyAccJerk-arCoeff()-X,1            0.042619  0.125907  0.1497093
## tBodyAccJerk-arCoeff()-X,2            0.132537  0.180802  0.1915168
## tBodyAccJerk-arCoeff()-X,3            0.110838  0.180567  0.2054921
## tBodyAccJerk-arCoeff()-X,4            0.128029  0.223509  0.2458143
## tBodyAccJerk-arCoeff()-Y,1            0.134360  0.081040  0.0276724
## tBodyAccJerk-arCoeff()-Y,2            0.038433  0.017373 -0.0053804
## tBodyAccJerk-arCoeff()-Y,3            0.238841  0.198768  0.1706920
## tBodyAccJerk-arCoeff()-Y,4            0.368242  0.326186  0.3484046
## tBodyAccJerk-arCoeff()-Z,1            0.155168  0.102048  0.1127460
## tBodyAccJerk-arCoeff()-Z,2            0.071108  0.035991  0.0456282
## tBodyAccJerk-arCoeff()-Z,3            0.072442  0.021955  0.0437398
## tBodyAccJerk-arCoeff()-Z,4            0.238544  0.166201  0.1830928
## tBodyAccJerk-correlation()-X,Y       -0.078633 -0.084174 -0.0614138
## tBodyAccJerk-correlation()-X,Z        0.086460  0.084409 -0.0044192
## tBodyAccJerk-correlation()-Y,Z       -0.041086  0.030524  0.0628991
## tBodyGyro-mean()-X                   -0.016725 -0.038431 -0.0266871
## tBodyGyro-mean()-Y                   -0.093411 -0.072121 -0.0677119
## tBodyGyro-mean()-Z                    0.125885  0.077777  0.0801422
## tBodyGyro-std()-X                    -0.967892 -0.981022 -0.9455284
## tBodyGyro-std()-Y                    -0.963192 -0.966708 -0.9612933
## tBodyGyro-std()-Z                    -0.963509 -0.958007 -0.9570531
## tBodyGyro-mad()-X                    -0.970703 -0.982749 -0.9493667
## tBodyGyro-mad()-Y                    -0.966197 -0.969373 -0.9659343
## tBodyGyro-mad()-Z                    -0.965217 -0.960427 -0.9610661
## tBodyGyro-max()-X                    -0.850849 -0.875232 -0.8385283
## tBodyGyro-max()-Y                    -0.935015 -0.935063 -0.9276369
## tBodyGyro-max()-Z                    -0.715996 -0.731206 -0.7244722
## tBodyGyro-min()-X                     0.825174  0.825630  0.8039469
## tBodyGyro-min()-Y                     0.888926  0.895838  0.8908353
## tBodyGyro-min()-Z                     0.818348  0.796596  0.7944590
## tBodyGyro-sma()                      -0.937861 -0.945057 -0.9432717
## tBodyGyro-energy()-X                 -0.995653 -0.997836 -0.9957341
## tBodyGyro-energy()-Y                 -0.996771 -0.996673 -0.9970168
## tBodyGyro-energy()-Z                 -0.989612 -0.990628 -0.9967097
## tBodyGyro-iqr()-X                    -0.974265 -0.984658 -0.9558478
## tBodyGyro-iqr()-Y                    -0.970561 -0.973977 -0.9729405
## tBodyGyro-iqr()-Z                    -0.970637 -0.967848 -0.9706374
## tBodyGyro-entropy()-X                -0.337025 -0.520203 -0.2329636
## tBodyGyro-entropy()-Y                -0.327394 -0.322537 -0.2754932
## tBodyGyro-entropy()-Z                -0.364474 -0.337950 -0.3407926
## tBodyGyro-arCoeff()-X,1              -0.033404 -0.008767 -0.2389298
## tBodyGyro-arCoeff()-X,2               0.006637  0.007312  0.1003739
## tBodyGyro-arCoeff()-X,3               0.170343  0.186664  0.1519447
## tBodyGyro-arCoeff()-X,4              -0.035815 -0.070263  0.0226628
## tBodyGyro-arCoeff()-Y,1              -0.111589 -0.171662 -0.1547954
## tBodyGyro-arCoeff()-Y,2               0.095553  0.101913  0.0816689
## tBodyGyro-arCoeff()-Y,3              -0.003885  0.014518  0.0287254
## tBodyGyro-arCoeff()-Y,4               0.063301  0.098146  0.1370086
## tBodyGyro-arCoeff()-Z,1               0.170969  0.083880  0.0325002
## tBodyGyro-arCoeff()-Z,2              -0.152706 -0.107618 -0.0933424
## tBodyGyro-arCoeff()-Z,3               0.149591  0.111359  0.1310035
## tBodyGyro-arCoeff()-Z,4               0.056515  0.063043  0.0933701
## tBodyGyro-correlation()-X,Y          -0.308691 -0.150917 -0.0975976
## tBodyGyro-correlation()-X,Z           0.135320  0.101394 -0.0307866
## tBodyGyro-correlation()-Y,Z          -0.133814 -0.309413 -0.3346889
## tBodyGyroJerk-mean()-X               -0.101864 -0.095652 -0.0997293
## tBodyGyroJerk-mean()-Y               -0.038198 -0.040780 -0.0423171
## tBodyGyroJerk-mean()-Z               -0.063850 -0.050756 -0.0520955
## tBodyGyroJerk-std()-X                -0.976125 -0.985705 -0.9669579
## tBodyGyroJerk-std()-Y                -0.980474 -0.986502 -0.9802633
## tBodyGyroJerk-std()-Z                -0.984783 -0.983806 -0.9770671
## tBodyGyroJerk-mad()-X                -0.979204 -0.987209 -0.9695892
## tBodyGyroJerk-mad()-Y                -0.983193 -0.988266 -0.9831787
## tBodyGyroJerk-mad()-Z                -0.986734 -0.985791 -0.9797235
## tBodyGyroJerk-max()-X                -0.972487 -0.982965 -0.9646458
## tBodyGyroJerk-max()-Y                -0.979646 -0.985957 -0.9795814
## tBodyGyroJerk-max()-Z                -0.979887 -0.978258 -0.9707013
## tBodyGyroJerk-min()-X                 0.972907  0.984133  0.9660693
## tBodyGyroJerk-min()-Y                 0.982351  0.987766  0.9814735
## tBodyGyroJerk-min()-Z                 0.985784  0.985274  0.9797914
## tBodyGyroJerk-sma()                  -0.983595 -0.988123 -0.9793904
## tBodyGyroJerk-energy()-X             -0.998542 -0.999547 -0.9984346
## tBodyGyroJerk-energy()-Y             -0.999385 -0.999727 -0.9991687
## tBodyGyroJerk-energy()-Z             -0.999466 -0.999509 -0.9991006
## tBodyGyroJerk-iqr()-X                -0.983053 -0.988938 -0.9737966
## tBodyGyroJerk-iqr()-Y                -0.986157 -0.990174 -0.9861621
## tBodyGyroJerk-iqr()-Z                -0.989242 -0.988317 -0.9833052
## tBodyGyroJerk-entropy()-X            -0.514103 -0.583501 -0.3732483
## tBodyGyroJerk-entropy()-Y            -0.398055 -0.484137 -0.4239494
## tBodyGyroJerk-entropy()-Z            -0.574674 -0.521900 -0.4505039
## tBodyGyroJerk-arCoeff()-X,1           0.093502  0.117195 -0.1056163
## tBodyGyroJerk-arCoeff()-X,2          -0.019425 -0.006725 -0.0604892
## tBodyGyroJerk-arCoeff()-X,3           0.201329  0.255152  0.0919762
## tBodyGyroJerk-arCoeff()-X,4           0.185000  0.171740  0.1417959
## tBodyGyroJerk-arCoeff()-Y,1          -0.042850 -0.104643 -0.1074996
## tBodyGyroJerk-arCoeff()-Y,2           0.192019  0.138603  0.1168506
## tBodyGyroJerk-arCoeff()-Y,3           0.151179  0.103982  0.0803506
## tBodyGyroJerk-arCoeff()-Y,4           0.080785  0.077966  0.1232826
## tBodyGyroJerk-arCoeff()-Z,1           0.258002  0.188273  0.1082994
## tBodyGyroJerk-arCoeff()-Z,2          -0.066566 -0.067471 -0.0930670
## tBodyGyroJerk-arCoeff()-Z,3           0.219248  0.182107  0.1163058
## tBodyGyroJerk-arCoeff()-Z,4           0.108034  0.039094  0.1113818
## tBodyGyroJerk-correlation()-X,Y      -0.035375  0.015319  0.0006837
## tBodyGyroJerk-correlation()-X,Z       0.106505  0.079985 -0.0074460
## tBodyGyroJerk-correlation()-Y,Z      -0.100241 -0.090932 -0.2028480
## tBodyAccMag-mean()                   -0.941111 -0.954644 -0.9541797
## tBodyAccMag-std()                    -0.932160 -0.939324 -0.9465348
## tBodyAccMag-mad()                    -0.937985 -0.944413 -0.9517346
## tBodyAccMag-max()                    -0.936582 -0.945607 -0.9473761
## tBodyAccMag-min()                    -0.975725 -0.986538 -0.9852064
## tBodyAccMag-sma()                    -0.941111 -0.954644 -0.9541797
## tBodyAccMag-energy()                 -0.984996 -0.992805 -0.9958093
## tBodyAccMag-iqr()                    -0.944123 -0.949966 -0.9562440
## tBodyAccMag-entropy()                -0.438009 -0.451346 -0.3881783
## tBodyAccMag-arCoeff()1                0.088347  0.055046  0.0156464
## tBodyAccMag-arCoeff()2               -0.096358 -0.076728 -0.0580776
## tBodyAccMag-arCoeff()3                0.142072  0.139706  0.1545490
## tBodyAccMag-arCoeff()4               -0.154279 -0.134447 -0.1434218
## tGravityAccMag-mean()                -0.941111 -0.954644 -0.9541797
## tGravityAccMag-std()                 -0.932160 -0.939324 -0.9465348
## tGravityAccMag-mad()                 -0.937985 -0.944413 -0.9517346
## tGravityAccMag-max()                 -0.936582 -0.945607 -0.9473761
## tGravityAccMag-min()                 -0.975725 -0.986538 -0.9852064
## tGravityAccMag-sma()                 -0.941111 -0.954644 -0.9541797
## tGravityAccMag-energy()              -0.984996 -0.992805 -0.9958093
## tGravityAccMag-iqr()                 -0.944123 -0.949966 -0.9562440
## tGravityAccMag-entropy()             -0.438009 -0.451346 -0.3881783
## tGravityAccMag-arCoeff()1             0.088347  0.055046  0.0156464
## tGravityAccMag-arCoeff()2            -0.096358 -0.076728 -0.0580776
## tGravityAccMag-arCoeff()3             0.142072  0.139706  0.1545490
## tGravityAccMag-arCoeff()4            -0.154279 -0.134447 -0.1434218
## tBodyAccJerkMag-mean()               -0.979209 -0.982444 -0.9771180
## tBodyAccJerkMag-std()                -0.974241 -0.978907 -0.9714530
## tBodyAccJerkMag-mad()                -0.977094 -0.981340 -0.9750842
## tBodyAccJerkMag-max()                -0.972171 -0.976496 -0.9683625
## tBodyAccJerkMag-min()                -0.979093 -0.980385 -0.9779241
## tBodyAccJerkMag-sma()                -0.979209 -0.982444 -0.9771180
## tBodyAccJerkMag-energy()             -0.998817 -0.999309 -0.9988859
## tBodyAccJerkMag-iqr()                -0.982165 -0.985268 -0.9809591
## tBodyAccJerkMag-entropy()            -0.707146 -0.722034 -0.6724892
## tBodyAccJerkMag-arCoeff()1            0.228542  0.213656  0.1980425
## tBodyAccJerkMag-arCoeff()2           -0.171142 -0.152865 -0.1293072
## tBodyAccJerkMag-arCoeff()3           -0.088407 -0.070131 -0.0558630
## tBodyAccJerkMag-arCoeff()4           -0.058965 -0.081957 -0.1108174
## tBodyGyroMag-mean()                  -0.938436 -0.946724 -0.9421525
## tBodyGyroMag-std()                   -0.940596 -0.951199 -0.9295312
## tBodyGyroMag-mad()                   -0.936034 -0.946344 -0.9249075
## tBodyGyroMag-max()                   -0.947447 -0.957894 -0.9417854
## tBodyGyroMag-min()                   -0.937311 -0.941816 -0.9666653
## tBodyGyroMag-sma()                   -0.938436 -0.946724 -0.9421525
## tBodyGyroMag-energy()                -0.992620 -0.994439 -0.9944439
## tBodyGyroMag-iqr()                   -0.940946 -0.948949 -0.9350384
## tBodyGyroMag-entropy()               -0.034940 -0.095361  0.0503263
## tBodyGyroMag-arCoeff()1               0.038302 -0.023462 -0.1294192
## tBodyGyroMag-arCoeff()2              -0.112228 -0.075812 -0.0130348
## tBodyGyroMag-arCoeff()3               0.137941  0.115786  0.1092796
## tBodyGyroMag-arCoeff()4              -0.111286 -0.055460 -0.0171124
## tBodyGyroJerkMag-mean()              -0.982727 -0.987880 -0.9786971
## tBodyGyroJerkMag-std()               -0.976755 -0.984608 -0.9735286
## tBodyGyroJerkMag-mad()               -0.979726 -0.986541 -0.9767081
## tBodyGyroJerkMag-max()               -0.976467 -0.984005 -0.9731314
## tBodyGyroJerkMag-min()               -0.986512 -0.987956 -0.9826917
## tBodyGyroJerkMag-sma()               -0.982727 -0.987880 -0.9786971
## tBodyGyroJerkMag-energy()            -0.999222 -0.999662 -0.9990072
## tBodyGyroJerkMag-iqr()               -0.983499 -0.988885 -0.9804670
## tBodyGyroJerkMag-entropy()           -0.443813 -0.535635 -0.3904511
## tBodyGyroJerkMag-arCoeff()1           0.389428  0.367533  0.2523070
## tBodyGyroJerkMag-arCoeff()2          -0.335668 -0.278101 -0.1810623
## tBodyGyroJerkMag-arCoeff()3          -0.041835 -0.035995 -0.0235257
## tBodyGyroJerkMag-arCoeff()4          -0.065467 -0.149982 -0.1837692
## fBodyAcc-mean()-X                    -0.966812 -0.983092 -0.9816223
## fBodyAcc-mean()-Y                    -0.952678 -0.947918 -0.9431324
## fBodyAcc-mean()-Z                    -0.960018 -0.957031 -0.9573597
## fBodyAcc-std()-X                     -0.959031 -0.983747 -0.9858598
## fBodyAcc-std()-Y                     -0.942461 -0.932533 -0.9311330
## fBodyAcc-std()-Z                     -0.945644 -0.934337 -0.9354396
## fBodyAcc-mad()-X                     -0.965063 -0.983250 -0.9826447
## fBodyAcc-mad()-Y                     -0.953019 -0.947168 -0.9399313
## fBodyAcc-mad()-Z                     -0.955574 -0.949921 -0.9506600
## fBodyAcc-max()-X                     -0.959104 -0.985399 -0.9895271
## fBodyAcc-max()-Y                     -0.947979 -0.937315 -0.9419437
## fBodyAcc-max()-Z                     -0.938342 -0.923315 -0.9248047
## fBodyAcc-min()-X                     -0.969358 -0.986834 -0.9892671
## fBodyAcc-min()-Y                     -0.971879 -0.964303 -0.9768429
## fBodyAcc-min()-Z                     -0.975644 -0.971920 -0.9797365
## fBodyAcc-sma()                       -0.958172 -0.964023 -0.9619160
## fBodyAcc-energy()-X                  -0.996087 -0.999273 -0.9995295
## fBodyAcc-energy()-Y                  -0.989282 -0.988868 -0.9935759
## fBodyAcc-energy()-Z                  -0.990693 -0.990118 -0.9932808
## fBodyAcc-iqr()-X                     -0.974393 -0.982268 -0.9780183
## fBodyAcc-iqr()-Y                     -0.973083 -0.972872 -0.9667257
## fBodyAcc-iqr()-Z                     -0.971587 -0.972939 -0.9706950
## fBodyAcc-entropy()-X                 -0.784361 -0.873190 -0.8566884
## fBodyAcc-entropy()-Y                 -0.807057 -0.774731 -0.7046363
## fBodyAcc-entropy()-Z                 -0.758404 -0.727935 -0.7073154
## fBodyAcc-maxInds-X                   -0.872162 -0.716630 -0.6466506
## fBodyAcc-maxInds-Y                   -0.776509 -0.864191 -0.9086744
## fBodyAcc-maxInds-Z                   -0.838121 -0.905156 -0.9328437
## fBodyAcc-meanFreq()-X                -0.259376 -0.042640  0.0155958
## fBodyAcc-meanFreq()-Y                 0.143046  0.065303 -0.0332741
## fBodyAcc-meanFreq()-Z                 0.203187  0.080298  0.0524670
## fBodyAcc-skewness()-X                 0.039927 -0.344112 -0.4865873
## fBodyAcc-kurtosis()-X                -0.245537 -0.658037 -0.8010271
## fBodyAcc-skewness()-Y                -0.240840 -0.204796 -0.1691589
## fBodyAcc-kurtosis()-Y                -0.506581 -0.498005 -0.4830829
## fBodyAcc-skewness()-Z                -0.320638 -0.188584 -0.1421057
## fBodyAcc-kurtosis()-Z                -0.524296 -0.411299 -0.3678999
## fBodyAcc-bandsEnergy()-1,8           -0.995026 -0.999171 -0.9996374
## fBodyAcc-bandsEnergy()-9,16          -0.999290 -0.999714 -0.9995359
## fBodyAcc-bandsEnergy()-17,24         -0.998786 -0.999449 -0.9991624
## fBodyAcc-bandsEnergy()-25,32         -0.998457 -0.999432 -0.9991214
## fBodyAcc-bandsEnergy()-33,40         -0.998353 -0.999507 -0.9992291
## fBodyAcc-bandsEnergy()-41,48         -0.997927 -0.999497 -0.9993043
## fBodyAcc-bandsEnergy()-49,56         -0.997906 -0.999556 -0.9995857
## fBodyAcc-bandsEnergy()-57,64         -0.996532 -0.999435 -0.9997393
## fBodyAcc-bandsEnergy()-1,16          -0.995821 -0.999256 -0.9995762
## fBodyAcc-bandsEnergy()-17,32         -0.998504 -0.999363 -0.9990250
## fBodyAcc-bandsEnergy()-33,48         -0.998209 -0.999519 -0.9992723
## fBodyAcc-bandsEnergy()-49,64         -0.997446 -0.999515 -0.9996372
## fBodyAcc-bandsEnergy()-1,24          -0.996034 -0.999272 -0.9995485
## fBodyAcc-bandsEnergy()-25,48         -0.998045 -0.999371 -0.9990315
## fBodyAcc-bandsEnergy()-1,8.1         -0.986116 -0.985100 -0.9921192
## fBodyAcc-bandsEnergy()-9,16.1        -0.998308 -0.998763 -0.9983742
## fBodyAcc-bandsEnergy()-17,24.1       -0.998578 -0.998848 -0.9989351
## fBodyAcc-bandsEnergy()-25,32.1       -0.998042 -0.998406 -0.9987393
## fBodyAcc-bandsEnergy()-33,40.1       -0.996740 -0.997268 -0.9981783
## fBodyAcc-bandsEnergy()-41,48.1       -0.996219 -0.996283 -0.9977028
## fBodyAcc-bandsEnergy()-49,56.1       -0.994317 -0.994517 -0.9975815
## fBodyAcc-bandsEnergy()-57,64.1       -0.994577 -0.993475 -0.9979650
## fBodyAcc-bandsEnergy()-1,16.1        -0.988507 -0.987963 -0.9931416
## fBodyAcc-bandsEnergy()-17,32.1       -0.998068 -0.998434 -0.9986142
## fBodyAcc-bandsEnergy()-33,48.1       -0.996199 -0.996609 -0.9978196
## fBodyAcc-bandsEnergy()-49,64.1       -0.994242 -0.993899 -0.9976651
## fBodyAcc-bandsEnergy()-1,24.1        -0.989248 -0.988798 -0.9935458
## fBodyAcc-bandsEnergy()-25,48.1       -0.997391 -0.997788 -0.9984104
## fBodyAcc-bandsEnergy()-1,8.2         -0.988956 -0.987796 -0.9919396
## fBodyAcc-bandsEnergy()-9,16.2        -0.997941 -0.998606 -0.9987024
## fBodyAcc-bandsEnergy()-17,24.2       -0.998923 -0.999189 -0.9991441
## fBodyAcc-bandsEnergy()-25,32.2       -0.999199 -0.999379 -0.9993592
## fBodyAcc-bandsEnergy()-33,40.2       -0.998754 -0.999029 -0.9990976
## fBodyAcc-bandsEnergy()-41,48.2       -0.997258 -0.997914 -0.9982168
## fBodyAcc-bandsEnergy()-49,56.2       -0.995611 -0.996445 -0.9978072
## fBodyAcc-bandsEnergy()-57,64.2       -0.992830 -0.993404 -0.9967703
## fBodyAcc-bandsEnergy()-1,16.2        -0.990539 -0.989826 -0.9931693
## fBodyAcc-bandsEnergy()-17,32.2       -0.999056 -0.999291 -0.9992554
## fBodyAcc-bandsEnergy()-33,48.2       -0.998323 -0.998716 -0.9988503
## fBodyAcc-bandsEnergy()-49,64.2       -0.994749 -0.995512 -0.9974868
## fBodyAcc-bandsEnergy()-1,24.2        -0.990673 -0.990040 -0.9932551
## fBodyAcc-bandsEnergy()-25,48.2       -0.998966 -0.999207 -0.9992308
## fBodyAccJerk-mean()-X                -0.980198 -0.985189 -0.9800087
## fBodyAccJerk-mean()-Y                -0.971384 -0.973988 -0.9645474
## fBodyAccJerk-mean()-Z                -0.976615 -0.979562 -0.9761578
## fBodyAccJerk-std()-X                 -0.982460 -0.986185 -0.9818261
## fBodyAccJerk-std()-Y                 -0.973051 -0.975751 -0.9668316
## fBodyAccJerk-std()-Z                 -0.980972 -0.983671 -0.9815093
## fBodyAccJerk-mad()-X                 -0.977779 -0.982513 -0.9767909
## fBodyAccJerk-mad()-Y                 -0.973147 -0.975889 -0.9671132
## fBodyAccJerk-mad()-Z                 -0.979131 -0.981888 -0.9794046
## fBodyAccJerk-max()-X                 -0.986432 -0.989323 -0.9862724
## fBodyAccJerk-max()-Y                 -0.977623 -0.979645 -0.9726896
## fBodyAccJerk-max()-Z                 -0.982016 -0.984711 -0.9828975
## fBodyAccJerk-min()-X                 -0.989978 -0.992002 -0.9904524
## fBodyAccJerk-min()-Y                 -0.984050 -0.984817 -0.9808590
## fBodyAccJerk-min()-Z                 -0.980475 -0.982061 -0.9806777
## fBodyAccJerk-sma()                   -0.974576 -0.978906 -0.9720462
## fBodyAccJerk-energy()-X              -0.999312 -0.999606 -0.9992665
## fBodyAccJerk-energy()-Y              -0.998234 -0.998965 -0.9982987
## fBodyAccJerk-energy()-Z              -0.999045 -0.999415 -0.9992080
## fBodyAccJerk-iqr()-X                 -0.977640 -0.982444 -0.9759496
## fBodyAccJerk-iqr()-Y                 -0.977807 -0.980066 -0.9732795
## fBodyAccJerk-iqr()-Z                 -0.976639 -0.979143 -0.9765029
## fBodyAccJerk-entropy()-X             -0.933584 -0.949718 -0.9206251
## fBodyAccJerk-entropy()-Y             -0.924264 -0.931027 -0.8902951
## fBodyAccJerk-entropy()-Z             -0.918102 -0.932937 -0.9160892
## fBodyAccJerk-maxInds-X               -0.295494 -0.228025 -0.2096537
## fBodyAccJerk-maxInds-Y               -0.295062 -0.348700 -0.3933054
## fBodyAccJerk-maxInds-Z               -0.221605 -0.261857 -0.2491081
## fBodyAccJerk-meanFreq()-X             0.105179  0.185014  0.2029000
## fBodyAccJerk-meanFreq()-Y             0.004854 -0.058311 -0.1318926
## fBodyAccJerk-meanFreq()-Z             0.069962  0.002996  0.0067002
## fBodyAccJerk-skewness()-X            -0.445286 -0.455483 -0.4559934
## fBodyAccJerk-kurtosis()-X            -0.796412 -0.811075 -0.8095339
## fBodyAccJerk-skewness()-Y            -0.492687 -0.488798 -0.4759758
## fBodyAccJerk-kurtosis()-Y            -0.875929 -0.867167 -0.8643161
## fBodyAccJerk-skewness()-Z            -0.554343 -0.579911 -0.5806956
## fBodyAccJerk-kurtosis()-Z            -0.853484 -0.867552 -0.8671590
## fBodyAccJerk-bandsEnergy()-1,8       -0.999706 -0.999896 -0.9998561
## fBodyAccJerk-bandsEnergy()-9,16      -0.999574 -0.999736 -0.9995166
## fBodyAccJerk-bandsEnergy()-17,24     -0.999296 -0.999545 -0.9992222
## fBodyAccJerk-bandsEnergy()-25,32     -0.999167 -0.999522 -0.9991161
## fBodyAccJerk-bandsEnergy()-33,40     -0.999462 -0.999677 -0.9992341
## fBodyAccJerk-bandsEnergy()-41,48     -0.999335 -0.999641 -0.9991861
## fBodyAccJerk-bandsEnergy()-49,56     -0.999555 -0.999764 -0.9995057
## fBodyAccJerk-bandsEnergy()-57,64     -0.999880 -0.999925 -0.9998673
## fBodyAccJerk-bandsEnergy()-1,16      -0.999597 -0.999786 -0.9996272
## fBodyAccJerk-bandsEnergy()-17,32     -0.999085 -0.999439 -0.9990044
## fBodyAccJerk-bandsEnergy()-33,48     -0.999379 -0.999649 -0.9991644
## fBodyAccJerk-bandsEnergy()-49,64     -0.999540 -0.999754 -0.9994886
## fBodyAccJerk-bandsEnergy()-1,24      -0.999412 -0.999659 -0.9994074
## fBodyAccJerk-bandsEnergy()-25,48     -0.998980 -0.999423 -0.9987979
## fBodyAccJerk-bandsEnergy()-1,8.1     -0.997689 -0.998537 -0.9974856
## fBodyAccJerk-bandsEnergy()-9,16.1    -0.998889 -0.999366 -0.9988085
## fBodyAccJerk-bandsEnergy()-17,24.1   -0.998758 -0.999178 -0.9988347
## fBodyAccJerk-bandsEnergy()-25,32.1   -0.998768 -0.999271 -0.9989735
## fBodyAccJerk-bandsEnergy()-33,40.1   -0.998501 -0.999291 -0.9988605
## fBodyAccJerk-bandsEnergy()-41,48.1   -0.998201 -0.998947 -0.9982061
## fBodyAccJerk-bandsEnergy()-49,56.1   -0.998157 -0.999264 -0.9988955
## fBodyAccJerk-bandsEnergy()-57,64.1   -0.999540 -0.999660 -0.9995026
## fBodyAccJerk-bandsEnergy()-1,16.1    -0.998455 -0.999087 -0.9983342
## fBodyAccJerk-bandsEnergy()-17,32.1   -0.998522 -0.999066 -0.9986748
## fBodyAccJerk-bandsEnergy()-33,48.1   -0.998059 -0.999021 -0.9983541
## fBodyAccJerk-bandsEnergy()-49,64.1   -0.998335 -0.999318 -0.9989761
## fBodyAccJerk-bandsEnergy()-1,24.1    -0.998332 -0.998976 -0.9982773
## fBodyAccJerk-bandsEnergy()-25,48.1   -0.998500 -0.999187 -0.9987427
## fBodyAccJerk-bandsEnergy()-1,8.2     -0.998500 -0.998657 -0.9987904
## fBodyAccJerk-bandsEnergy()-9,16.2    -0.998420 -0.999162 -0.9989481
## fBodyAccJerk-bandsEnergy()-17,24.2   -0.999241 -0.999511 -0.9993210
## fBodyAccJerk-bandsEnergy()-25,32.2   -0.999473 -0.999644 -0.9994812
## fBodyAccJerk-bandsEnergy()-33,40.2   -0.999385 -0.999608 -0.9993819
## fBodyAccJerk-bandsEnergy()-41,48.2   -0.998759 -0.999249 -0.9988574
## fBodyAccJerk-bandsEnergy()-49,56.2   -0.998088 -0.999067 -0.9986859
## fBodyAccJerk-bandsEnergy()-57,64.2   -0.999242 -0.999615 -0.9994741
## fBodyAccJerk-bandsEnergy()-1,16.2    -0.998149 -0.998840 -0.9987038
## fBodyAccJerk-bandsEnergy()-17,32.2   -0.999384 -0.999605 -0.9994288
## fBodyAccJerk-bandsEnergy()-33,48.2   -0.999162 -0.999481 -0.9991900
## fBodyAccJerk-bandsEnergy()-49,64.2   -0.998099 -0.999071 -0.9986935
## fBodyAccJerk-bandsEnergy()-1,24.2    -0.998700 -0.999191 -0.9990012
## fBodyAccJerk-bandsEnergy()-25,48.2   -0.999377 -0.999606 -0.9993929
## fBodyGyro-mean()-X                   -0.962915 -0.977267 -0.9436543
## fBodyGyro-mean()-Y                   -0.967582 -0.972458 -0.9653028
## fBodyGyro-mean()-Z                   -0.964184 -0.961029 -0.9583850
## fBodyGyro-std()-X                    -0.969747 -0.982333 -0.9469716
## fBodyGyro-std()-Y                    -0.961365 -0.964034 -0.9594986
## fBodyGyro-std()-Z                    -0.966725 -0.961030 -0.9606892
## fBodyGyro-mad()-X                    -0.965178 -0.979306 -0.9414455
## fBodyGyro-mad()-Y                    -0.968181 -0.971575 -0.9646394
## fBodyGyro-mad()-Z                    -0.965558 -0.961071 -0.9560174
## fBodyGyro-max()-X                    -0.969729 -0.982495 -0.9474237
## fBodyGyro-max()-Y                    -0.966037 -0.968548 -0.9680996
## fBodyGyro-max()-Z                    -0.971675 -0.966887 -0.9704030
## fBodyGyro-min()-X                    -0.986834 -0.990365 -0.9827342
## fBodyGyro-min()-Y                    -0.984086 -0.983861 -0.9852787
## fBodyGyro-min()-Z                    -0.974910 -0.974369 -0.9849872
## fBodyGyro-sma()                      -0.963988 -0.970728 -0.9544800
## fBodyGyro-energy()-X                 -0.997466 -0.999125 -0.9959452
## fBodyGyro-energy()-Y                 -0.998294 -0.998181 -0.9975660
## fBodyGyro-energy()-Z                 -0.997307 -0.997048 -0.9974559
## fBodyGyro-iqr()-X                    -0.972059 -0.981877 -0.9652398
## fBodyGyro-iqr()-Y                    -0.974440 -0.981921 -0.9744397
## fBodyGyro-iqr()-Z                    -0.977300 -0.975962 -0.9712169
## fBodyGyro-entropy()-X                -0.625619 -0.706141 -0.4967722
## fBodyGyro-entropy()-Y                -0.551756 -0.590198 -0.5434724
## fBodyGyro-entropy()-Z                -0.709567 -0.659699 -0.6184159
## fBodyGyro-maxInds-X                  -0.868484 -0.849784 -0.8888772
## fBodyGyro-maxInds-Y                  -0.871698 -0.910796 -0.8760451
## fBodyGyro-maxInds-Z                  -0.846743 -0.912289 -0.8898216
## fBodyGyro-meanFreq()-X               -0.017461  0.062591 -0.2274947
## fBodyGyro-meanFreq()-Y               -0.139337 -0.218028 -0.2160124
## fBodyGyro-meanFreq()-Z                0.113280 -0.012700 -0.0914294
## fBodyGyro-skewness()-X               -0.143010 -0.308472 -0.1654696
## fBodyGyro-kurtosis()-X               -0.434407 -0.603608 -0.5139162
## fBodyGyro-skewness()-Y               -0.087106 -0.125030 -0.2108628
## fBodyGyro-kurtosis()-Y               -0.411896 -0.491971 -0.5873981
## fBodyGyro-skewness()-Z               -0.228918 -0.148188 -0.2338543
## fBodyGyro-kurtosis()-Z               -0.522405 -0.463694 -0.5691032
## fBodyGyro-bandsEnergy()-1,8          -0.997648 -0.999162 -0.9959700
## fBodyGyro-bandsEnergy()-9,16         -0.998219 -0.999573 -0.9983309
## fBodyGyro-bandsEnergy()-17,24        -0.998806 -0.999533 -0.9988591
## fBodyGyro-bandsEnergy()-25,32        -0.999044 -0.999645 -0.9991477
## fBodyGyro-bandsEnergy()-33,40        -0.998663 -0.999523 -0.9986315
## fBodyGyro-bandsEnergy()-41,48        -0.998506 -0.999459 -0.9985686
## fBodyGyro-bandsEnergy()-49,56        -0.998454 -0.999523 -0.9985521
## fBodyGyro-bandsEnergy()-57,64        -0.998501 -0.999528 -0.9986775
## fBodyGyro-bandsEnergy()-1,16         -0.997526 -0.999149 -0.9959632
## fBodyGyro-bandsEnergy()-17,32        -0.998652 -0.999482 -0.9987367
## fBodyGyro-bandsEnergy()-33,48        -0.998466 -0.999451 -0.9984697
## fBodyGyro-bandsEnergy()-49,64        -0.998474 -0.999525 -0.9986076
## fBodyGyro-bandsEnergy()-1,24         -0.997504 -0.999139 -0.9959705
## fBodyGyro-bandsEnergy()-25,48        -0.998868 -0.999586 -0.9989436
## fBodyGyro-bandsEnergy()-1,8.1        -0.997882 -0.997206 -0.9968849
## fBodyGyro-bandsEnergy()-9,16.1       -0.999480 -0.999714 -0.9991850
## fBodyGyro-bandsEnergy()-17,24.1      -0.999613 -0.999850 -0.9996417
## fBodyGyro-bandsEnergy()-25,32.1      -0.999652 -0.999850 -0.9995542
## fBodyGyro-bandsEnergy()-33,40.1      -0.999707 -0.999826 -0.9995473
## fBodyGyro-bandsEnergy()-41,48.1      -0.999347 -0.999609 -0.9991648
## fBodyGyro-bandsEnergy()-49,56.1      -0.999040 -0.999285 -0.9988836
## fBodyGyro-bandsEnergy()-57,64.1      -0.999245 -0.999190 -0.9992870
## fBodyGyro-bandsEnergy()-1,16.1       -0.998236 -0.997933 -0.9973733
## fBodyGyro-bandsEnergy()-17,32.1      -0.999533 -0.999814 -0.9995301
## fBodyGyro-bandsEnergy()-33,48.1      -0.999630 -0.999780 -0.9994645
## fBodyGyro-bandsEnergy()-49,64.1      -0.998998 -0.999146 -0.9989065
## fBodyGyro-bandsEnergy()-1,24.1       -0.998177 -0.998010 -0.9973899
## fBodyGyro-bandsEnergy()-25,48.1      -0.999619 -0.999817 -0.9994920
## fBodyGyro-bandsEnergy()-1,8.2        -0.997509 -0.997184 -0.9977660
## fBodyGyro-bandsEnergy()-9,16.2       -0.999363 -0.999474 -0.9990989
## fBodyGyro-bandsEnergy()-17,24.2      -0.999464 -0.999494 -0.9993800
## fBodyGyro-bandsEnergy()-25,32.2      -0.999617 -0.999665 -0.9995814
## fBodyGyro-bandsEnergy()-33,40.2      -0.999459 -0.999554 -0.9994924
## fBodyGyro-bandsEnergy()-41,48.2      -0.998956 -0.999100 -0.9991692
## fBodyGyro-bandsEnergy()-49,56.2      -0.997971 -0.998235 -0.9987056
## fBodyGyro-bandsEnergy()-57,64.2      -0.997934 -0.998146 -0.9991386
## fBodyGyro-bandsEnergy()-1,16.2       -0.997419 -0.997146 -0.9975747
## fBodyGyro-bandsEnergy()-17,32.2      -0.999306 -0.999358 -0.9992088
## fBodyGyro-bandsEnergy()-33,48.2      -0.999327 -0.999436 -0.9994094
## fBodyGyro-bandsEnergy()-49,64.2      -0.997955 -0.998196 -0.9988940
## fBodyGyro-bandsEnergy()-1,24.2       -0.997361 -0.997094 -0.9975047
## fBodyGyro-bandsEnergy()-25,48.2      -0.999529 -0.999596 -0.9995300
## fBodyAccMag-mean()                   -0.947673 -0.952410 -0.9558681
## fBodyAccMag-std()                    -0.934917 -0.942000 -0.9496016
## fBodyAccMag-mad()                    -0.940736 -0.945773 -0.9499260
## fBodyAccMag-max()                    -0.942002 -0.949734 -0.9576764
## fBodyAccMag-min()                    -0.959378 -0.961906 -0.9788758
## fBodyAccMag-sma()                    -0.947673 -0.952410 -0.9558681
## fBodyAccMag-energy()                 -0.982587 -0.988673 -0.9948715
## fBodyAccMag-iqr()                    -0.971908 -0.974171 -0.9715861
## fBodyAccMag-entropy()                -0.788347 -0.791071 -0.7523141
## fBodyAccMag-maxInds                  -0.856712 -0.857218 -0.8934400
## fBodyAccMag-meanFreq()                0.116229  0.114105  0.0484947
## fBodyAccMag-skewness()               -0.252904 -0.337734 -0.3096012
## fBodyAccMag-kurtosis()               -0.511825 -0.599278 -0.5857224
## fBodyBodyAccJerkMag-mean()           -0.974300 -0.978684 -0.9710904
## fBodyBodyAccJerkMag-std()            -0.973183 -0.978155 -0.9709480
## fBodyBodyAccJerkMag-mad()            -0.971263 -0.975888 -0.9679731
## fBodyBodyAccJerkMag-max()            -0.976903 -0.981442 -0.9755138
## fBodyBodyAccJerkMag-min()            -0.978555 -0.981437 -0.9776405
## fBodyBodyAccJerkMag-sma()            -0.974300 -0.978684 -0.9710904
## fBodyBodyAccJerkMag-energy()         -0.998304 -0.999094 -0.9984577
## fBodyBodyAccJerkMag-iqr()            -0.977105 -0.980248 -0.9740857
## fBodyBodyAccJerkMag-entropy()        -0.926225 -0.940419 -0.9075432
## fBodyBodyAccJerkMag-maxInds          -0.863936 -0.854919 -0.8897050
## fBodyBodyAccJerkMag-meanFreq()        0.281115  0.281461  0.2512684
## fBodyBodyAccJerkMag-skewness()       -0.474777 -0.489593 -0.4599839
## fBodyBodyAccJerkMag-kurtosis()       -0.759299 -0.768818 -0.7477680
## fBodyBodyGyroMag-mean()              -0.954854 -0.964296 -0.9479085
## fBodyBodyGyroMag-std()               -0.942116 -0.951642 -0.9306367
## fBodyBodyGyroMag-mad()               -0.946217 -0.956723 -0.9330257
## fBodyBodyGyroMag-max()               -0.942022 -0.950193 -0.9353796
## fBodyBodyGyroMag-min()               -0.969001 -0.969404 -0.9745409
## fBodyBodyGyroMag-sma()               -0.954854 -0.964296 -0.9479085
## fBodyBodyGyroMag-energy()            -0.993628 -0.995778 -0.9928682
## fBodyBodyGyroMag-iqr()               -0.964452 -0.973874 -0.9594886
## fBodyBodyGyroMag-entropy()           -0.586888 -0.635102 -0.5291885
## fBodyBodyGyroMag-maxInds             -0.940725 -0.948805 -0.9452740
## fBodyBodyGyroMag-meanFreq()          -0.029365 -0.076440 -0.1837051
## fBodyBodyGyroMag-skewness()          -0.173171 -0.173635 -0.2191610
## fBodyBodyGyroMag-kurtosis()          -0.469403 -0.479961 -0.5537817
## fBodyBodyGyroJerkMag-mean()          -0.977968 -0.985336 -0.9748860
## fBodyBodyGyroJerkMag-std()           -0.976648 -0.984491 -0.9734611
## fBodyBodyGyroJerkMag-mad()           -0.975525 -0.983650 -0.9718521
## fBodyBodyGyroJerkMag-max()           -0.978686 -0.985783 -0.9758621
## fBodyBodyGyroJerkMag-min()           -0.985401 -0.989421 -0.9837736
## fBodyBodyGyroJerkMag-sma()           -0.977968 -0.985336 -0.9748860
## fBodyBodyGyroJerkMag-energy()        -0.998856 -0.999529 -0.9986186
## fBodyBodyGyroJerkMag-iqr()           -0.977377 -0.984315 -0.9732392
## fBodyBodyGyroJerkMag-entropy()       -0.796667 -0.855110 -0.7708077
## fBodyBodyGyroJerkMag-maxInds         -0.910249 -0.909996 -0.9270807
## fBodyBodyGyroJerkMag-meanFreq()       0.165728  0.177739  0.0848650
## fBodyBodyGyroJerkMag-skewness()      -0.342490 -0.384740 -0.3437693
## fBodyBodyGyroJerkMag-kurtosis()      -0.658640 -0.686795 -0.6549889
## angle(tBodyAccMean,gravity)           0.010366  0.012034  0.0069907
## angle(tBodyAccJerkMean),gravityMean)  0.016013  0.002458  0.0103969
## angle(tBodyGyroMean,gravityMean)      0.022788  0.013413  0.0046141
## angle(tBodyGyroJerkMean,gravityMean)  0.009191 -0.033260  0.0159570
## angle(X,gravityMean)                  0.520261 -0.706042 -0.7741428
## angle(Y,gravityMean)                 -0.435944  0.006140  0.2098184
## angle(Z,gravityMean)                 -0.427749 -0.089532  0.0317429
##                                        WALKING WALKING_DOWNSTAIRS
## tBodyAcc-mean()-X                     0.276337          0.2881372
## tBodyAcc-mean()-Y                    -0.017907         -0.0163119
## tBodyAcc-mean()-Z                    -0.108882         -0.1057616
## tBodyAcc-std()-X                     -0.314644          0.1007663
## tBodyAcc-std()-Y                     -0.023583          0.0595486
## tBodyAcc-std()-Z                     -0.273921         -0.1908045
## tBodyAcc-mad()-X                     -0.352470          0.0324260
## tBodyAcc-mad()-Y                     -0.055491          0.0039072
## tBodyAcc-mad()-Z                     -0.274098         -0.2145686
## tBodyAcc-max()-X                     -0.113458          0.4171517
## tBodyAcc-max()-Y                     -0.052047          0.0182505
## tBodyAcc-max()-Z                     -0.325424         -0.2636923
## tBodyAcc-min()-X                      0.228839          0.0434033
## tBodyAcc-min()-Y                      0.073619         -0.0312863
## tBodyAcc-min()-Z                      0.377004          0.2368730
## tBodyAcc-sma()                       -0.171594          0.0796455
## tBodyAcc-energy()-X                  -0.753202         -0.3669809
## tBodyAcc-energy()-Y                  -0.807133         -0.7679669
## tBodyAcc-energy()-Z                  -0.740081         -0.6729062
## tBodyAcc-iqr()-X                     -0.423486         -0.1414511
## tBodyAcc-iqr()-Y                     -0.296665         -0.2784922
## tBodyAcc-iqr()-Z                     -0.316198         -0.3004313
## tBodyAcc-entropy()-X                  0.396592          0.2362437
## tBodyAcc-entropy()-Y                  0.294771          0.3188166
## tBodyAcc-entropy()-Z                  0.165607          0.2337170
## tBodyAcc-arCoeff()-X,1               -0.354866         -0.3499291
## tBodyAcc-arCoeff()-X,2                0.294155          0.2404610
## tBodyAcc-arCoeff()-X,3               -0.101806         -0.1691569
## tBodyAcc-arCoeff()-X,4                0.104094          0.2965634
## tBodyAcc-arCoeff()-Y,1               -0.171894         -0.1538965
## tBodyAcc-arCoeff()-Y,2                0.178098          0.1488938
## tBodyAcc-arCoeff()-Y,3                0.130355          0.1189049
## tBodyAcc-arCoeff()-Y,4               -0.076146          0.0167125
## tBodyAcc-arCoeff()-Z,1               -0.152110         -0.0956253
## tBodyAcc-arCoeff()-Z,2                0.187788          0.1603017
## tBodyAcc-arCoeff()-Z,3               -0.018486         -0.0203398
## tBodyAcc-arCoeff()-Z,4               -0.124872         -0.0501251
## tBodyAcc-correlation()-X,Y           -0.111835         -0.4216362
## tBodyAcc-correlation()-X,Z           -0.134239         -0.2322530
## tBodyAcc-correlation()-Y,Z            0.240679          0.1312576
## tGravityAcc-mean()-X                  0.934992          0.9264574
## tGravityAcc-mean()-Y                 -0.196713         -0.1685072
## tGravityAcc-mean()-Z                 -0.053825         -0.0479709
## tGravityAcc-std()-X                  -0.977612         -0.9497488
## tGravityAcc-std()-Y                  -0.966904         -0.9342661
## tGravityAcc-std()-Z                  -0.954598         -0.9124606
## tGravityAcc-mad()-X                  -0.978129         -0.9506170
## tGravityAcc-mad()-Y                  -0.967646         -0.9351771
## tGravityAcc-mad()-Z                  -0.955760         -0.9139063
## tGravityAcc-max()-X                   0.868631          0.8706897
## tGravityAcc-max()-Y                  -0.208738         -0.1730469
## tGravityAcc-max()-Z                  -0.051161         -0.0372684
## tGravityAcc-min()-X                   0.947221          0.9294881
## tGravityAcc-min()-Y                  -0.177171         -0.1596456
## tGravityAcc-min()-Z                  -0.062491         -0.0679125
## tGravityAcc-sma()                    -0.209355         -0.2975486
## tGravityAcc-energy()-X                0.826475          0.8044710
## tGravityAcc-energy()-Y               -0.920558         -0.9388071
## tGravityAcc-energy()-Z               -0.945661         -0.9459245
## tGravityAcc-iqr()-X                  -0.979266         -0.9526967
## tGravityAcc-iqr()-Y                  -0.970116         -0.9384434
## tGravityAcc-iqr()-Z                  -0.959443         -0.9197547
## tGravityAcc-entropy()-X              -0.754295         -0.5120963
## tGravityAcc-entropy()-Y              -0.973891         -0.9482629
## tGravityAcc-entropy()-Z              -0.714316         -0.6287549
## tGravityAcc-arCoeff()-X,1            -0.407665         -0.5939580
## tGravityAcc-arCoeff()-X,2             0.480524          0.6581706
## tGravityAcc-arCoeff()-X,3            -0.550527         -0.7214786
## tGravityAcc-arCoeff()-X,4             0.617581          0.7838797
## tGravityAcc-arCoeff()-Y,1            -0.105795         -0.2457382
## tGravityAcc-arCoeff()-Y,2             0.120179          0.2584724
## tGravityAcc-arCoeff()-Y,3            -0.194852         -0.3236602
## tGravityAcc-arCoeff()-Y,4             0.291130          0.4086782
## tGravityAcc-arCoeff()-Z,1            -0.283255         -0.3041895
## tGravityAcc-arCoeff()-Z,2             0.335078          0.3507769
## tGravityAcc-arCoeff()-Z,3            -0.385421         -0.3967448
## tGravityAcc-arCoeff()-Z,4             0.431683          0.4395240
## tGravityAcc-correlation()-X,Y         0.171299          0.2632416
## tGravityAcc-correlation()-X,Z        -0.038053         -0.0151786
## tGravityAcc-correlation()-Y,Z         0.050857          0.2073710
## tBodyAccJerk-mean()-X                 0.076719          0.0892267
## tBodyAccJerk-mean()-Y                 0.011506          0.0007467
## tBodyAccJerk-mean()-Z                -0.002319         -0.0087286
## tBodyAccJerk-std()-X                 -0.267288         -0.0338826
## tBodyAccJerk-std()-Y                 -0.103141         -0.0736744
## tBodyAccJerk-std()-Z                 -0.479147         -0.3886661
## tBodyAccJerk-mad()-X                 -0.257194         -0.0304707
## tBodyAccJerk-mad()-Y                 -0.075206         -0.0546324
## tBodyAccJerk-mad()-Z                 -0.464446         -0.3819797
## tBodyAccJerk-max()-X                 -0.439859         -0.0879036
## tBodyAccJerk-max()-Y                 -0.456661         -0.3432462
## tBodyAccJerk-max()-Z                 -0.633508         -0.4825861
## tBodyAccJerk-min()-X                  0.181343          0.1104777
## tBodyAccJerk-min()-Y                  0.261883          0.2829653
## tBodyAccJerk-min()-Z                  0.420366          0.3596030
## tBodyAccJerk-sma()                   -0.235165         -0.1044134
## tBodyAccJerk-energy()-X              -0.711701         -0.5020625
## tBodyAccJerk-energy()-Y              -0.570376         -0.5335332
## tBodyAccJerk-energy()-Z              -0.841559         -0.7813987
## tBodyAccJerk-iqr()-X                 -0.239861         -0.0216192
## tBodyAccJerk-iqr()-Y                 -0.236236         -0.2308327
## tBodyAccJerk-iqr()-Z                 -0.500157         -0.4327136
## tBodyAccJerk-entropy()-X              0.662527          0.5597234
## tBodyAccJerk-entropy()-Y              0.617407          0.5678406
## tBodyAccJerk-entropy()-Z              0.570462          0.5114755
## tBodyAccJerk-arCoeff()-X,1           -0.339419         -0.3676123
## tBodyAccJerk-arCoeff()-X,2            0.217891          0.1323277
## tBodyAccJerk-arCoeff()-X,3            0.025352         -0.1093663
## tBodyAccJerk-arCoeff()-X,4            0.055733          0.0310395
## tBodyAccJerk-arCoeff()-Y,1           -0.233910         -0.2455914
## tBodyAccJerk-arCoeff()-Y,2            0.165878          0.1291661
## tBodyAccJerk-arCoeff()-Y,3            0.209762          0.1282261
## tBodyAccJerk-arCoeff()-Y,4            0.278263          0.3119846
## tBodyAccJerk-arCoeff()-Z,1           -0.187021         -0.1706499
## tBodyAccJerk-arCoeff()-Z,2            0.177967          0.1796246
## tBodyAccJerk-arCoeff()-Z,3            0.011615         -0.0363694
## tBodyAccJerk-arCoeff()-Z,4            0.070431          0.1526281
## tBodyAccJerk-correlation()-X,Y       -0.073811         -0.2866732
## tBodyAccJerk-correlation()-X,Z       -0.010925         -0.1127263
## tBodyAccJerk-correlation()-Y,Z        0.177310          0.1095668
## tBodyGyro-mean()-X                   -0.034728         -0.0840345
## tBodyGyro-mean()-Y                   -0.069420         -0.0529929
## tBodyGyro-mean()-Z                    0.086363          0.0946782
## tBodyGyro-std()-X                    -0.469915         -0.3338175
## tBodyGyro-std()-Y                    -0.347922         -0.3396314
## tBodyGyro-std()-Z                    -0.338449         -0.2728099
## tBodyGyro-mad()-X                    -0.470229         -0.3474077
## tBodyGyro-mad()-Y                    -0.374950         -0.3687180
## tBodyGyro-mad()-Z                    -0.373712         -0.3057302
## tBodyGyro-max()-X                    -0.436264         -0.3565165
## tBodyGyro-max()-Y                    -0.492322         -0.4696321
## tBodyGyro-max()-Z                    -0.227158         -0.1519096
## tBodyGyro-min()-X                     0.445549          0.2841800
## tBodyGyro-min()-Y                     0.557788          0.5015842
## tBodyGyro-min()-Z                     0.297509          0.2055601
## tBodyGyro-sma()                      -0.267145         -0.1335162
## tBodyGyro-energy()-X                 -0.849095         -0.7052683
## tBodyGyro-energy()-Y                 -0.756605         -0.7466492
## tBodyGyro-energy()-Z                 -0.782068         -0.7250773
## tBodyGyro-iqr()-X                    -0.454824         -0.3566601
## tBodyGyro-iqr()-Y                    -0.426511         -0.4193976
## tBodyGyro-iqr()-Z                    -0.491410         -0.4190061
## tBodyGyro-entropy()-X                 0.156219          0.1055772
## tBodyGyro-entropy()-Y                 0.128242          0.2125045
## tBodyGyro-entropy()-Z                 0.300748          0.2762396
## tBodyGyro-arCoeff()-X,1              -0.338982         -0.3629827
## tBodyGyro-arCoeff()-X,2               0.277785          0.2557920
## tBodyGyro-arCoeff()-X,3               0.085025          0.0768264
## tBodyGyro-arCoeff()-X,4              -0.136837         -0.1210837
## tBodyGyro-arCoeff()-Y,1              -0.278225         -0.1822008
## tBodyGyro-arCoeff()-Y,2               0.283441          0.2054609
## tBodyGyro-arCoeff()-Y,3              -0.130705         -0.0637063
## tBodyGyro-arCoeff()-Y,4               0.224772          0.2019830
## tBodyGyro-arCoeff()-Z,1              -0.303273         -0.2281098
## tBodyGyro-arCoeff()-Z,2               0.310447          0.2483602
## tBodyGyro-arCoeff()-Z,3              -0.220456         -0.1368495
## tBodyGyro-arCoeff()-Z,4               0.310692          0.2279797
## tBodyGyro-correlation()-X,Y          -0.193074         -0.1194237
## tBodyGyro-correlation()-X,Z          -0.044633          0.0028776
## tBodyGyro-correlation()-Y,Z           0.122629         -0.1066973
## tBodyGyroJerk-mean()-X               -0.094301         -0.0728532
## tBodyGyroJerk-mean()-Y               -0.044570         -0.0512640
## tBodyGyroJerk-mean()-Z               -0.054006         -0.0546962
## tBodyGyroJerk-std()-X                -0.376221         -0.3826898
## tBodyGyroJerk-std()-Y                -0.512619         -0.4659438
## tBodyGyroJerk-std()-Z                -0.447427         -0.3264560
## tBodyGyroJerk-mad()-X                -0.368518         -0.3836869
## tBodyGyroJerk-mad()-Y                -0.536288         -0.4934216
## tBodyGyroJerk-mad()-Z                -0.456578         -0.3504191
## tBodyGyroJerk-max()-X                -0.433977         -0.4087128
## tBodyGyroJerk-max()-Y                -0.568505         -0.5216639
## tBodyGyroJerk-max()-Z                -0.470912         -0.3012462
## tBodyGyroJerk-min()-X                 0.470046          0.4276111
## tBodyGyroJerk-min()-Y                 0.621070          0.5637210
## tBodyGyroJerk-min()-Z                 0.593518          0.4698970
## tBodyGyroJerk-sma()                  -0.470870         -0.4293013
## tBodyGyroJerk-energy()-X             -0.787144         -0.7821553
## tBodyGyroJerk-energy()-Y             -0.849038         -0.8182960
## tBodyGyroJerk-energy()-Z             -0.831744         -0.7417045
## tBodyGyroJerk-iqr()-X                -0.389322         -0.4040876
## tBodyGyroJerk-iqr()-Y                -0.564038         -0.5265095
## tBodyGyroJerk-iqr()-Z                -0.497077         -0.4083001
## tBodyGyroJerk-entropy()-X             0.578325          0.5756617
## tBodyGyroJerk-entropy()-Y             0.576963          0.5943855
## tBodyGyroJerk-entropy()-Z             0.582133          0.5963607
## tBodyGyroJerk-arCoeff()-X,1          -0.187007         -0.1854459
## tBodyGyroJerk-arCoeff()-X,2           0.138285          0.1114399
## tBodyGyroJerk-arCoeff()-X,3           0.170605          0.1016811
## tBodyGyroJerk-arCoeff()-X,4           0.165288          0.1802568
## tBodyGyroJerk-arCoeff()-Y,1          -0.277527         -0.1864798
## tBodyGyroJerk-arCoeff()-Y,2           0.279094          0.2512273
## tBodyGyroJerk-arCoeff()-Y,3           0.047855          0.0754307
## tBodyGyroJerk-arCoeff()-Y,4           0.052671          0.1273662
## tBodyGyroJerk-arCoeff()-Z,1          -0.315091         -0.2312669
## tBodyGyroJerk-arCoeff()-Z,2           0.228178          0.2104458
## tBodyGyroJerk-arCoeff()-Z,3          -0.032621          0.0077067
## tBodyGyroJerk-arCoeff()-Z,4          -0.045896          0.0344420
## tBodyGyroJerk-correlation()-X,Y       0.096702          0.0527620
## tBodyGyroJerk-correlation()-X,Z       0.075249          0.0423866
## tBodyGyroJerk-correlation()-Y,Z      -0.042808         -0.1610513
## tBodyAccMag-mean()                   -0.167938          0.1012497
## tBodyAccMag-std()                    -0.337754          0.1164889
## tBodyAccMag-mad()                    -0.419058         -0.0355642
## tBodyAccMag-max()                    -0.233791          0.1643169
## tBodyAccMag-min()                    -0.649260         -0.6627002
## tBodyAccMag-sma()                    -0.167938          0.1012497
## tBodyAccMag-energy()                 -0.640871         -0.3113893
## tBodyAccMag-iqr()                    -0.499486         -0.2374955
## tBodyAccMag-entropy()                 0.771674          0.8524760
## tBodyAccMag-arCoeff()1               -0.042134         -0.2928834
## tBodyAccMag-arCoeff()2                0.019089          0.2005621
## tBodyAccMag-arCoeff()3                0.001978         -0.0502870
## tBodyAccMag-arCoeff()4               -0.004876          0.0615270
## tGravityAccMag-mean()                -0.167938          0.1012497
## tGravityAccMag-std()                 -0.337754          0.1164889
## tGravityAccMag-mad()                 -0.419058         -0.0355642
## tGravityAccMag-max()                 -0.233791          0.1643169
## tGravityAccMag-min()                 -0.649260         -0.6627002
## tGravityAccMag-sma()                 -0.167938          0.1012497
## tGravityAccMag-energy()              -0.640871         -0.3113893
## tGravityAccMag-iqr()                 -0.499486         -0.2374955
## tGravityAccMag-entropy()              0.771674          0.8524760
## tGravityAccMag-arCoeff()1            -0.042134         -0.2928834
## tGravityAccMag-arCoeff()2             0.019089          0.2005621
## tGravityAccMag-arCoeff()3             0.001978         -0.0502870
## tGravityAccMag-arCoeff()4            -0.004876          0.0615270
## tBodyAccJerkMag-mean()               -0.241452         -0.1118018
## tBodyAccJerkMag-std()                -0.214556         -0.0112207
## tBodyAccJerkMag-mad()                -0.245901         -0.0534683
## tBodyAccJerkMag-max()                -0.251461         -0.0755791
## tBodyAccJerkMag-min()                -0.547780         -0.5229416
## tBodyAccJerkMag-sma()                -0.241452         -0.1118018
## tBodyAccJerkMag-energy()             -0.678490         -0.5368204
## tBodyAccJerkMag-iqr()                -0.341690         -0.1926247
## tBodyAccJerkMag-entropy()             0.722959          0.7745708
## tBodyAccJerkMag-arCoeff()1           -0.009654         -0.1315367
## tBodyAccJerkMag-arCoeff()2            0.014121          0.1571049
## tBodyAccJerkMag-arCoeff()3           -0.136900         -0.0803653
## tBodyAccJerkMag-arCoeff()4            0.070631         -0.0031968
## tBodyGyroMag-mean()                  -0.274866         -0.1297856
## tBodyGyroMag-std()                   -0.382629         -0.2514278
## tBodyGyroMag-mad()                   -0.316897         -0.1861099
## tBodyGyroMag-max()                   -0.444859         -0.3016310
## tBodyGyroMag-min()                   -0.545246         -0.4341075
## tBodyGyroMag-sma()                   -0.274866         -0.1297856
## tBodyGyroMag-energy()                -0.706003         -0.5795703
## tBodyGyroMag-iqr()                   -0.347482         -0.2472715
## tBodyGyroMag-entropy()                0.651615          0.4548605
## tBodyGyroMag-arCoeff()1               0.066495          0.0999602
## tBodyGyroMag-arCoeff()2              -0.118247         -0.1766548
## tBodyGyroMag-arCoeff()3               0.083828          0.1679856
## tBodyGyroMag-arCoeff()4              -0.031436         -0.1000704
## tBodyGyroJerkMag-mean()              -0.460512         -0.4168916
## tBodyGyroJerkMag-std()               -0.498841         -0.4409293
## tBodyGyroJerkMag-mad()               -0.525829         -0.4838419
## tBodyGyroJerkMag-max()               -0.527880         -0.4465016
## tBodyGyroJerkMag-min()               -0.564543         -0.5328853
## tBodyGyroJerkMag-sma()               -0.460512         -0.4168916
## tBodyGyroJerkMag-energy()            -0.833294         -0.7997206
## tBodyGyroJerkMag-iqr()               -0.550174         -0.5279513
## tBodyGyroJerkMag-entropy()            0.858836          0.8489131
## tBodyGyroJerkMag-arCoeff()1           0.248894          0.2538004
## tBodyGyroJerkMag-arCoeff()2          -0.193886         -0.2250858
## tBodyGyroJerkMag-arCoeff()3          -0.114329         -0.0932889
## tBodyGyroJerkMag-arCoeff()4          -0.053857         -0.0184366
## fBodyAcc-mean()-X                    -0.297891          0.0352597
## fBodyAcc-mean()-Y                    -0.042339          0.0566827
## fBodyAcc-mean()-Z                    -0.341841         -0.2137292
## fBodyAcc-std()-X                     -0.322836          0.1219380
## fBodyAcc-std()-Y                     -0.077206         -0.0082337
## fBodyAcc-std()-Z                     -0.296078         -0.2458729
## fBodyAcc-mad()-X                     -0.252553          0.1317622
## fBodyAcc-mad()-Y                     -0.027500          0.0771454
## fBodyAcc-mad()-Z                     -0.297217         -0.1812865
## fBodyAcc-max()-X                     -0.442247         -0.0007505
## fBodyAcc-max()-Y                     -0.361499         -0.3470051
## fBodyAcc-max()-Z                     -0.346132         -0.3587836
## fBodyAcc-min()-X                     -0.739353         -0.6223713
## fBodyAcc-min()-Y                     -0.762107         -0.7492144
## fBodyAcc-min()-Z                     -0.844617         -0.8159571
## fBodyAcc-sma()                       -0.128030          0.1159537
## fBodyAcc-energy()-X                  -0.753055         -0.3670312
## fBodyAcc-energy()-Y                  -0.498458         -0.3975439
## fBodyAcc-energy()-Z                  -0.706891         -0.6331489
## fBodyAcc-iqr()-X                     -0.313769         -0.0727528
## fBodyAcc-iqr()-Y                     -0.246701         -0.1377961
## fBodyAcc-iqr()-Z                     -0.485913         -0.3315420
## fBodyAcc-entropy()-X                  0.540027          0.6710271
## fBodyAcc-entropy()-Y                  0.531068          0.5755861
## fBodyAcc-entropy()-Z                  0.432387          0.5343564
## fBodyAcc-maxInds-X                   -0.764452         -0.7702932
## fBodyAcc-maxInds-Y                   -0.698839         -0.6775249
## fBodyAcc-maxInds-Z                   -0.777182         -0.7179670
## fBodyAcc-meanFreq()-X                -0.286858         -0.4000196
## fBodyAcc-meanFreq()-Y                 0.051864          0.0006031
## fBodyAcc-meanFreq()-Z                 0.074956          0.0924263
## fBodyAcc-skewness()-X                -0.111500          0.0592387
## fBodyAcc-kurtosis()-X                -0.492101         -0.2953430
## fBodyAcc-skewness()-Y                -0.400757         -0.4612108
## fBodyAcc-kurtosis()-Y                -0.740621         -0.7889505
## fBodyAcc-skewness()-Z                -0.302537         -0.4644855
## fBodyAcc-kurtosis()-Z                -0.571077         -0.7005902
## fBodyAcc-bandsEnergy()-1,8           -0.772254         -0.3162221
## fBodyAcc-bandsEnergy()-9,16          -0.801258         -0.6191920
## fBodyAcc-bandsEnergy()-17,24         -0.661087         -0.5899850
## fBodyAcc-bandsEnergy()-25,32         -0.787868         -0.6532323
## fBodyAcc-bandsEnergy()-33,40         -0.853970         -0.7029959
## fBodyAcc-bandsEnergy()-41,48         -0.852163         -0.6913020
## fBodyAcc-bandsEnergy()-49,56         -0.905267         -0.8155872
## fBodyAcc-bandsEnergy()-57,64         -0.932450         -0.8452914
## fBodyAcc-bandsEnergy()-1,16          -0.759645         -0.3419250
## fBodyAcc-bandsEnergy()-17,32         -0.645869         -0.5446673
## fBodyAcc-bandsEnergy()-33,48         -0.853307         -0.6986252
## fBodyAcc-bandsEnergy()-49,64         -0.914378         -0.8255433
## fBodyAcc-bandsEnergy()-1,24          -0.752642         -0.3595574
## fBodyAcc-bandsEnergy()-25,48         -0.778018         -0.6075036
## fBodyAcc-bandsEnergy()-1,8.1         -0.637264         -0.5352637
## fBodyAcc-bandsEnergy()-9,16.1        -0.638803         -0.5608121
## fBodyAcc-bandsEnergy()-17,24.1       -0.609871         -0.6438776
## fBodyAcc-bandsEnergy()-25,32.1       -0.748471         -0.7491122
## fBodyAcc-bandsEnergy()-33,40.1       -0.761937         -0.7208157
## fBodyAcc-bandsEnergy()-41,48.1       -0.729478         -0.6824019
## fBodyAcc-bandsEnergy()-49,56.1       -0.771720         -0.7446061
## fBodyAcc-bandsEnergy()-57,64.1       -0.895690         -0.8821169
## fBodyAcc-bandsEnergy()-1,16.1        -0.536252         -0.4179709
## fBodyAcc-bandsEnergy()-17,32.1       -0.550326         -0.5833709
## fBodyAcc-bandsEnergy()-33,48.1       -0.722216         -0.6740948
## fBodyAcc-bandsEnergy()-49,64.1       -0.816623         -0.7943432
## fBodyAcc-bandsEnergy()-1,24.1        -0.507378         -0.4052804
## fBodyAcc-bandsEnergy()-25,48.1       -0.727516         -0.7130206
## fBodyAcc-bandsEnergy()-1,8.2         -0.764811         -0.7352994
## fBodyAcc-bandsEnergy()-9,16.2        -0.799241         -0.6762916
## fBodyAcc-bandsEnergy()-17,24.2       -0.805823         -0.7729354
## fBodyAcc-bandsEnergy()-25,32.2       -0.912263         -0.8723010
## fBodyAcc-bandsEnergy()-33,40.2       -0.923516         -0.8796209
## fBodyAcc-bandsEnergy()-41,48.2       -0.870821         -0.8008380
## fBodyAcc-bandsEnergy()-49,56.2       -0.878891         -0.8267341
## fBodyAcc-bandsEnergy()-57,64.2       -0.924395         -0.8972039
## fBodyAcc-bandsEnergy()-1,16.2        -0.747283         -0.6840455
## fBodyAcc-bandsEnergy()-17,32.2       -0.844412         -0.8089613
## fBodyAcc-bandsEnergy()-33,48.2       -0.904427         -0.8506307
## fBodyAcc-bandsEnergy()-49,64.2       -0.891513         -0.8463980
## fBodyAcc-bandsEnergy()-1,24.2        -0.715979         -0.6481661
## fBodyAcc-bandsEnergy()-25,48.2       -0.910045         -0.8661372
## fBodyAccJerk-mean()-X                -0.311127         -0.0722968
## fBodyAccJerk-mean()-Y                -0.170395         -0.1163806
## fBodyAccJerk-mean()-Z                -0.451011         -0.3331903
## fBodyAccJerk-std()-X                 -0.287898         -0.0821905
## fBodyAccJerk-std()-Y                 -0.090870         -0.0914165
## fBodyAccJerk-std()-Z                 -0.506329         -0.4435547
## fBodyAccJerk-mad()-X                 -0.167842          0.0775924
## fBodyAccJerk-mad()-Y                 -0.138452         -0.1062147
## fBodyAccJerk-mad()-Z                 -0.482964         -0.3901660
## fBodyAccJerk-max()-X                 -0.410420         -0.2199722
## fBodyAccJerk-max()-Y                 -0.231080         -0.2738286
## fBodyAccJerk-max()-Z                 -0.534280         -0.5137033
## fBodyAccJerk-min()-X                 -0.775608         -0.6854417
## fBodyAccJerk-min()-Y                 -0.689197         -0.6919158
## fBodyAccJerk-min()-Z                 -0.764094         -0.7251665
## fBodyAccJerk-sma()                   -0.194151         -0.0193224
## fBodyAccJerk-energy()-X              -0.711305         -0.5014710
## fBodyAccJerk-energy()-Y              -0.570555         -0.5337363
## fBodyAccJerk-energy()-Z              -0.841607         -0.7814584
## fBodyAccJerk-iqr()-X                 -0.270256         -0.0052643
## fBodyAccJerk-iqr()-Y                 -0.386581         -0.3227030
## fBodyAccJerk-iqr()-Z                 -0.522435         -0.3955732
## fBodyAccJerk-entropy()-X              0.517530          0.6589992
## fBodyAccJerk-entropy()-Y              0.555794          0.5953505
## fBodyAccJerk-entropy()-Z              0.328089          0.4320354
## fBodyAccJerk-maxInds-X               -0.453821         -0.7075391
## fBodyAccJerk-maxInds-Y               -0.384762         -0.4460597
## fBodyAccJerk-maxInds-Z               -0.321487         -0.3543101
## fBodyAccJerk-meanFreq()-X            -0.258388         -0.3149413
## fBodyAccJerk-meanFreq()-Y            -0.354659         -0.3860443
## fBodyAccJerk-meanFreq()-Z            -0.240686         -0.2374028
## fBodyAccJerk-skewness()-X            -0.149228         -0.1496498
## fBodyAccJerk-kurtosis()-X            -0.618466         -0.5800148
## fBodyAccJerk-skewness()-Y            -0.221067         -0.3402353
## fBodyAccJerk-kurtosis()-Y            -0.711055         -0.8031474
## fBodyAccJerk-skewness()-Z            -0.309843         -0.4418171
## fBodyAccJerk-kurtosis()-Z            -0.701589         -0.8047856
## fBodyAccJerk-bandsEnergy()-1,8       -0.818960         -0.4807637
## fBodyAccJerk-bandsEnergy()-9,16      -0.773355         -0.6432237
## fBodyAccJerk-bandsEnergy()-17,24     -0.695888         -0.6334442
## fBodyAccJerk-bandsEnergy()-25,32     -0.793729         -0.6623298
## fBodyAccJerk-bandsEnergy()-33,40     -0.862580         -0.7266000
## fBodyAccJerk-bandsEnergy()-41,48     -0.829342         -0.6581763
## fBodyAccJerk-bandsEnergy()-49,56     -0.896284         -0.8123156
## fBodyAccJerk-bandsEnergy()-57,64     -0.971904         -0.9477397
## fBodyAccJerk-bandsEnergy()-1,16      -0.773819         -0.5392961
## fBodyAccJerk-bandsEnergy()-17,32     -0.667956         -0.5606115
## fBodyAccJerk-bandsEnergy()-33,48     -0.837476         -0.6756967
## fBodyAccJerk-bandsEnergy()-49,64     -0.892648         -0.8054625
## fBodyAccJerk-bandsEnergy()-1,24      -0.702246         -0.4908595
## fBodyAccJerk-bandsEnergy()-25,48     -0.738510         -0.5327846
## fBodyAccJerk-bandsEnergy()-1,8.1     -0.701211         -0.5465396
## fBodyAccJerk-bandsEnergy()-9,16.1    -0.682424         -0.6261211
## fBodyAccJerk-bandsEnergy()-17,24.1   -0.535049         -0.5890405
## fBodyAccJerk-bandsEnergy()-25,32.1   -0.761484         -0.7602314
## fBodyAccJerk-bandsEnergy()-33,40.1   -0.803817         -0.7664278
## fBodyAccJerk-bandsEnergy()-41,48.1   -0.712756         -0.6571416
## fBodyAccJerk-bandsEnergy()-49,56.1   -0.812383         -0.7901241
## fBodyAccJerk-bandsEnergy()-57,64.1   -0.927074         -0.9243903
## fBodyAccJerk-bandsEnergy()-1,16.1    -0.641647         -0.5541649
## fBodyAccJerk-bandsEnergy()-17,32.1   -0.548275         -0.5870827
## fBodyAccJerk-bandsEnergy()-33,48.1   -0.717773         -0.6636047
## fBodyAccJerk-bandsEnergy()-49,64.1   -0.826855         -0.8070658
## fBodyAccJerk-bandsEnergy()-1,24.1    -0.534608         -0.4947526
## fBodyAccJerk-bandsEnergy()-25,48.1   -0.741428         -0.7197325
## fBodyAccJerk-bandsEnergy()-1,8.2     -0.811578         -0.7622484
## fBodyAccJerk-bandsEnergy()-9,16.2    -0.788564         -0.6742881
## fBodyAccJerk-bandsEnergy()-17,24.2   -0.820841         -0.7863017
## fBodyAccJerk-bandsEnergy()-25,32.2   -0.915310         -0.8750047
## fBodyAccJerk-bandsEnergy()-33,40.2   -0.929881         -0.8878503
## fBodyAccJerk-bandsEnergy()-41,48.2   -0.877443         -0.8092384
## fBodyAccJerk-bandsEnergy()-49,56.2   -0.849843         -0.7827977
## fBodyAccJerk-bandsEnergy()-57,64.2   -0.936089         -0.9094612
## fBodyAccJerk-bandsEnergy()-1,16.2    -0.752216         -0.6369205
## fBodyAccJerk-bandsEnergy()-17,32.2   -0.867057         -0.8296981
## fBodyAccJerk-bandsEnergy()-33,48.2   -0.909342         -0.8565835
## fBodyAccJerk-bandsEnergy()-49,64.2   -0.850202         -0.7835351
## fBodyAccJerk-bandsEnergy()-1,24.2    -0.767403         -0.6926137
## fBodyAccJerk-bandsEnergy()-25,48.2   -0.912990         -0.8677920
## fBodyGyro-mean()-X                   -0.348237         -0.2179229
## fBodyGyro-mean()-Y                   -0.388385         -0.3175927
## fBodyGyro-mean()-Z                   -0.310406         -0.1656251
## fBodyGyro-std()-X                    -0.510432         -0.3751275
## fBodyGyro-std()-Y                    -0.331962         -0.3618537
## fBodyGyro-std()-Z                    -0.410569         -0.3804100
## fBodyGyro-mad()-X                    -0.391574         -0.2576908
## fBodyGyro-mad()-Y                    -0.399913         -0.3693201
## fBodyGyro-mad()-Z                    -0.305640         -0.1930977
## fBodyGyro-max()-X                    -0.512979         -0.3625203
## fBodyGyro-max()-Y                    -0.467009         -0.5516971
## fBodyGyro-max()-Z                    -0.561800         -0.5832985
## fBodyGyro-min()-X                    -0.877453         -0.8470703
## fBodyGyro-min()-Y                    -0.804497         -0.7709316
## fBodyGyro-min()-Z                    -0.838900         -0.8061899
## fBodyGyro-sma()                      -0.315234         -0.2000624
## fBodyGyro-energy()-X                 -0.846020         -0.7515932
## fBodyGyro-energy()-Y                 -0.754015         -0.7488369
## fBodyGyro-energy()-Z                 -0.765471         -0.7110131
## fBodyGyro-iqr()-X                    -0.376084         -0.2957066
## fBodyGyro-iqr()-Y                    -0.487595         -0.3745418
## fBodyGyro-iqr()-Z                    -0.407957         -0.1900462
## fBodyGyro-entropy()-X                 0.542315          0.5774641
## fBodyGyro-entropy()-Y                 0.581813          0.6410754
## fBodyGyro-entropy()-Z                 0.458142          0.5549034
## fBodyGyro-maxInds-X                  -0.842935         -0.8972025
## fBodyGyro-maxInds-Y                  -0.597430         -0.6238700
## fBodyGyro-maxInds-Z                  -0.617806         -0.6653750
## fBodyGyro-meanFreq()-X               -0.067742         -0.1700163
## fBodyGyro-meanFreq()-Y               -0.098453         -0.0440854
## fBodyGyro-meanFreq()-Z               -0.072179         -0.0187918
## fBodyGyro-skewness()-X               -0.187378         -0.1423771
## fBodyGyro-kurtosis()-X               -0.510646         -0.4629937
## fBodyGyro-skewness()-Y               -0.254455         -0.4206144
## fBodyGyro-kurtosis()-Y               -0.631235         -0.7683299
## fBodyGyro-skewness()-Z               -0.234250         -0.4292634
## fBodyGyro-kurtosis()-Z               -0.576423         -0.7425640
## fBodyGyro-bandsEnergy()-1,8          -0.887863         -0.7824352
## fBodyGyro-bandsEnergy()-9,16         -0.756155         -0.7757573
## fBodyGyro-bandsEnergy()-17,24        -0.788536         -0.7979325
## fBodyGyro-bandsEnergy()-25,32        -0.896304         -0.8879620
## fBodyGyro-bandsEnergy()-33,40        -0.886961         -0.8544114
## fBodyGyro-bandsEnergy()-41,48        -0.894755         -0.8647967
## fBodyGyro-bandsEnergy()-49,56        -0.925165         -0.9007675
## fBodyGyro-bandsEnergy()-57,64        -0.955361         -0.9325030
## fBodyGyro-bandsEnergy()-1,16         -0.858829         -0.7624583
## fBodyGyro-bandsEnergy()-17,32        -0.787604         -0.7917580
## fBodyGyro-bandsEnergy()-33,48        -0.878768         -0.8440006
## fBodyGyro-bandsEnergy()-49,64        -0.938526         -0.9148100
## fBodyGyro-bandsEnergy()-1,24         -0.849708         -0.7555032
## fBodyGyro-bandsEnergy()-25,48        -0.890110         -0.8740490
## fBodyGyro-bandsEnergy()-1,8.1        -0.755228         -0.8041022
## fBodyGyro-bandsEnergy()-9,16.1       -0.917557         -0.8632531
## fBodyGyro-bandsEnergy()-17,24.1      -0.882511         -0.8927582
## fBodyGyro-bandsEnergy()-25,32.1      -0.925210         -0.8883696
## fBodyGyro-bandsEnergy()-33,40.1      -0.955093         -0.9209603
## fBodyGyro-bandsEnergy()-41,48.1      -0.913736         -0.8564797
## fBodyGyro-bandsEnergy()-49,56.1      -0.897870         -0.8503908
## fBodyGyro-bandsEnergy()-57,64.1      -0.949943         -0.9406421
## fBodyGyro-bandsEnergy()-1,16.1       -0.781570         -0.7791627
## fBodyGyro-bandsEnergy()-17,32.1      -0.867442         -0.8658813
## fBodyGyro-bandsEnergy()-33,48.1      -0.946141         -0.9069105
## fBodyGyro-bandsEnergy()-49,64.1      -0.906535         -0.8691384
## fBodyGyro-bandsEnergy()-1,24.1       -0.740746         -0.7434375
## fBodyGyro-bandsEnergy()-25,48.1      -0.925975         -0.8855282
## fBodyGyro-bandsEnergy()-1,8.2        -0.818202         -0.8230615
## fBodyGyro-bandsEnergy()-9,16.2       -0.891082         -0.7598892
## fBodyGyro-bandsEnergy()-17,24.2      -0.855672         -0.7776370
## fBodyGyro-bandsEnergy()-25,32.2      -0.931151         -0.8819471
## fBodyGyro-bandsEnergy()-33,40.2      -0.945106         -0.9036013
## fBodyGyro-bandsEnergy()-41,48.2      -0.925826         -0.8743330
## fBodyGyro-bandsEnergy()-49,56.2      -0.907562         -0.8605995
## fBodyGyro-bandsEnergy()-57,64.2      -0.944579         -0.9274846
## fBodyGyro-bandsEnergy()-1,16.2       -0.790556         -0.7512329
## fBodyGyro-bandsEnergy()-17,32.2      -0.829045         -0.7308138
## fBodyGyro-bandsEnergy()-33,48.2      -0.939721         -0.8953770
## fBodyGyro-bandsEnergy()-49,64.2      -0.923656         -0.8896791
## fBodyGyro-bandsEnergy()-1,24.2       -0.772149         -0.7225263
## fBodyGyro-bandsEnergy()-25,48.2      -0.933812         -0.8861159
## fBodyAccMag-mean()                   -0.275558          0.1428494
## fBodyAccMag-std()                    -0.480002         -0.0754252
## fBodyAccMag-mad()                    -0.355583          0.1222918
## fBodyAccMag-max()                    -0.646101         -0.3560880
## fBodyAccMag-min()                    -0.806156         -0.7441042
## fBodyAccMag-sma()                    -0.275558          0.1428494
## fBodyAccMag-energy()                 -0.766054         -0.3512857
## fBodyAccMag-iqr()                    -0.475183         -0.1289315
## fBodyAccMag-entropy()                 0.451806          0.6672043
## fBodyAccMag-maxInds                  -0.643037         -0.5445627
## fBodyAccMag-meanFreq()                0.184417          0.0250365
## fBodyAccMag-skewness()               -0.477940         -0.4149441
## fBodyAccMag-kurtosis()               -0.761674         -0.7135720
## fBodyBodyAccJerkMag-mean()           -0.214654          0.0047625
## fBodyBodyAccJerkMag-std()            -0.221618         -0.0422714
## fBodyBodyAccJerkMag-mad()            -0.193003          0.0180582
## fBodyBodyAccJerkMag-max()            -0.303184         -0.1367364
## fBodyBodyAccJerkMag-min()            -0.604659         -0.4961594
## fBodyBodyAccJerkMag-sma()            -0.214654          0.0047625
## fBodyBodyAccJerkMag-energy()         -0.666557         -0.4758351
## fBodyBodyAccJerkMag-iqr()            -0.351559         -0.1406165
## fBodyBodyAccJerkMag-entropy()         0.352438          0.5091941
## fBodyBodyAccJerkMag-maxInds          -0.889184         -0.8873309
## fBodyBodyAccJerkMag-meanFreq()        0.077314          0.0200704
## fBodyBodyAccJerkMag-skewness()        0.011229         -0.0379045
## fBodyBodyAccJerkMag-kurtosis()       -0.320795         -0.3592977
## fBodyBodyGyroMag-mean()              -0.409173         -0.2895258
## fBodyBodyGyroMag-std()               -0.473833         -0.3612310
## fBodyBodyGyroMag-mad()               -0.424990         -0.2984049
## fBodyBodyGyroMag-max()               -0.533856         -0.4524716
## fBodyBodyGyroMag-min()               -0.788353         -0.7328014
## fBodyBodyGyroMag-sma()               -0.409173         -0.2895258
## fBodyBodyGyroMag-energy()            -0.784949         -0.6902425
## fBodyBodyGyroMag-iqr()               -0.447918         -0.3511380
## fBodyBodyGyroMag-entropy()            0.541917          0.6028487
## fBodyBodyGyroMag-maxInds             -0.725543         -0.8623482
## fBodyBodyGyroMag-meanFreq()           0.163204          0.0671728
## fBodyBodyGyroMag-skewness()          -0.377188         -0.4079318
## fBodyBodyGyroMag-kurtosis()          -0.676337         -0.7061889
## fBodyBodyGyroJerkMag-mean()          -0.515517         -0.4380073
## fBodyBodyGyroJerkMag-std()           -0.514405         -0.4864430
## fBodyBodyGyroJerkMag-mad()           -0.490641         -0.4298068
## fBodyBodyGyroJerkMag-max()           -0.531053         -0.5442212
## fBodyBodyGyroJerkMag-min()           -0.724700         -0.6710113
## fBodyBodyGyroJerkMag-sma()           -0.515517         -0.4380073
## fBodyBodyGyroJerkMag-energy()        -0.844772         -0.8103957
## fBodyBodyGyroJerkMag-iqr()           -0.504809         -0.4272136
## fBodyBodyGyroJerkMag-entropy()        0.388799          0.4592700
## fBodyBodyGyroJerkMag-maxInds         -0.886197         -0.8846666
## fBodyBodyGyroJerkMag-meanFreq()       0.130806          0.0957588
## fBodyBodyGyroJerkMag-skewness()      -0.071308         -0.2770204
## fBodyBodyGyroJerkMag-kurtosis()      -0.400268         -0.6183936
## angle(tBodyAccMean,gravity)           0.014918         -0.0396920
## angle(tBodyAccJerkMean),gravityMean) -0.007011         -0.0186646
## angle(tBodyGyroMean,gravityMean)      0.011332          0.2035881
## angle(tBodyGyroJerkMean,gravityMean) -0.019443         -0.0760295
## angle(X,gravityMean)                 -0.761886         -0.7808731
## angle(Y,gravityMean)                  0.218599          0.2001886
## angle(Z,gravityMean)                  0.059771          0.0558659
##                                      WALKING_UPSTAIRS subject_1  subject_2
## tBodyAcc-mean()-X                            0.262295  0.265697  0.2731131
## tBodyAcc-mean()-Y                           -0.025923 -0.018298 -0.0191323
## tBodyAcc-mean()-Z                           -0.120538 -0.107846 -0.1156500
## tBodyAcc-std()-X                            -0.237990 -0.545795 -0.6055865
## tBodyAcc-std()-Y                            -0.016033 -0.367716 -0.4289630
## tBodyAcc-std()-Z                            -0.175450 -0.502646 -0.5893601
## tBodyAcc-mad()-X                            -0.297094 -0.580163 -0.6399190
## tBodyAcc-mad()-Y                            -0.030865 -0.391228 -0.4453383
## tBodyAcc-mad()-Z                            -0.172811 -0.488075 -0.5946061
## tBodyAcc-max()-X                            -0.015003 -0.397326 -0.4164206
## tBodyAcc-max()-Y                            -0.045139 -0.272417 -0.2754181
## tBodyAcc-max()-Z                            -0.281163 -0.471026 -0.5556965
## tBodyAcc-min()-X                             0.210776  0.419189  0.5386564
## tBodyAcc-min()-Y                             0.113989  0.291388  0.3183185
## tBodyAcc-min()-Z                             0.366632  0.578700  0.5625732
## tBodyAcc-sma()                              -0.102024 -0.447863 -0.5296284
## tBodyAcc-energy()-X                         -0.696636 -0.817833 -0.8405231
## tBodyAcc-energy()-Y                         -0.802463 -0.868583 -0.8795576
## tBodyAcc-energy()-Z                         -0.663408 -0.810084 -0.8476623
## tBodyAcc-iqr()-X                            -0.418226 -0.644457 -0.7225630
## tBodyAcc-iqr()-Y                            -0.245377 -0.568967 -0.5900413
## tBodyAcc-iqr()-Z                            -0.221802 -0.482946 -0.6269875
## tBodyAcc-entropy()-X                         0.351322 -0.036502 -0.1273868
## tBodyAcc-entropy()-Y                         0.236379  0.011998 -0.0804409
## tBodyAcc-entropy()-Z                         0.106595 -0.183984 -0.1439327
## tBodyAcc-arCoeff()-X,1                      -0.414432 -0.155288 -0.0234071
## tBodyAcc-arCoeff()-X,2                       0.286656  0.184761  0.0912012
## tBodyAcc-arCoeff()-X,3                      -0.143025 -0.102988 -0.0949578
## tBodyAcc-arCoeff()-X,4                       0.197262  0.114308  0.1433575
## tBodyAcc-arCoeff()-Y,1                      -0.257279 -0.036453  0.0113430
## tBodyAcc-arCoeff()-Y,2                       0.174495  0.050794  0.0430372
## tBodyAcc-arCoeff()-Y,3                       0.084623  0.144962  0.1072290
## tBodyAcc-arCoeff()-Y,4                       0.004363 -0.019887 -0.0105898
## tBodyAcc-arCoeff()-Z,1                      -0.285479  0.015159  0.0481081
## tBodyAcc-arCoeff()-Z,2                       0.179366  0.052204  0.0108255
## tBodyAcc-arCoeff()-Z,3                      -0.075169  0.021504  0.0465212
## tBodyAcc-arCoeff()-Z,4                       0.039254 -0.132983 -0.0728922
## tBodyAcc-correlation()-X,Y                  -0.300500 -0.203503 -0.1866377
## tBodyAcc-correlation()-X,Z                  -0.222296 -0.140663 -0.1696189
## tBodyAcc-correlation()-Y,Z                   0.101625  0.196151  0.1945358
## tGravityAcc-mean()-X                         0.875003  0.744867  0.6607829
## tGravityAcc-mean()-Y                        -0.281377 -0.082556 -0.1472199
## tGravityAcc-mean()-Z                        -0.140796  0.072340  0.1348653
## tGravityAcc-std()-X                         -0.948191 -0.959859 -0.9630155
## tGravityAcc-std()-Y                         -0.925549 -0.951151 -0.9600336
## tGravityAcc-std()-Z                         -0.901906 -0.925818 -0.9453654
## tGravityAcc-mad()-X                         -0.949417 -0.960843 -0.9640586
## tGravityAcc-mad()-Y                         -0.927013 -0.952142 -0.9610472
## tGravityAcc-mad()-Z                         -0.904456 -0.927662 -0.9469978
## tGravityAcc-max()-X                          0.819845  0.685625  0.6012715
## tGravityAcc-max()-Y                         -0.278498 -0.094077 -0.1585386
## tGravityAcc-max()-Z                         -0.123974  0.080947  0.1382895
## tGravityAcc-min()-X                          0.878135  0.755566  0.6740610
## tGravityAcc-min()-Y                         -0.272038 -0.070172 -0.1303233
## tGravityAcc-min()-Z                         -0.161679  0.056566  0.1240464
## tGravityAcc-sma()                            0.079572 -0.036757  0.1028669
## tGravityAcc-energy()-X                       0.677799  0.527750  0.4282228
## tGravityAcc-energy()-Y                      -0.837445 -0.705210 -0.6510051
## tGravityAcc-energy()-Z                      -0.881463 -0.863347 -0.7981761
## tGravityAcc-iqr()-X                         -0.952836 -0.963156 -0.9668660
## tGravityAcc-iqr()-Y                         -0.931789 -0.954968 -0.9641853
## tGravityAcc-iqr()-Z                         -0.912620 -0.933618 -0.9522944
## tGravityAcc-entropy()-X                     -0.320682 -0.592115 -0.5253590
## tGravityAcc-entropy()-Y                     -0.956405 -0.866636 -0.9612311
## tGravityAcc-entropy()-Z                     -0.717442 -0.861512 -0.5206099
## tGravityAcc-arCoeff()-X,1                   -0.642894 -0.476507 -0.4762656
## tGravityAcc-arCoeff()-X,2                    0.691586  0.521804  0.5153374
## tGravityAcc-arCoeff()-X,3                   -0.739538 -0.565939 -0.5537676
## tGravityAcc-arCoeff()-X,4                    0.786792  0.608935  0.5916062
## tGravityAcc-arCoeff()-Y,1                   -0.497718 -0.275350 -0.2793475
## tGravityAcc-arCoeff()-Y,2                    0.504056  0.278356  0.2671227
## tGravityAcc-arCoeff()-Y,3                   -0.544891 -0.330518 -0.3030725
## tGravityAcc-arCoeff()-Y,4                    0.598650  0.401204  0.3579672
## tGravityAcc-arCoeff()-Z,1                   -0.630765 -0.401394 -0.4210278
## tGravityAcc-arCoeff()-Z,2                    0.657981  0.419651  0.4478963
## tGravityAcc-arCoeff()-Z,3                   -0.684524 -0.436879 -0.4740935
## tGravityAcc-arCoeff()-Z,4                    0.707401  0.450524  0.4969792
## tGravityAcc-correlation()-X,Y                0.439038  0.171825  0.2933060
## tGravityAcc-correlation()-X,Z                0.083361 -0.167498 -0.0741720
## tGravityAcc-correlation()-Y,Z                0.018887  0.146579  0.0691912
## tBodyAccJerk-mean()-X                        0.076729  0.077093  0.0785353
## tBodyAccJerk-mean()-Y                        0.008759  0.016591  0.0070877
## tBodyAccJerk-mean()-Z                       -0.006010 -0.009108  0.0007558
## tBodyAccJerk-std()-X                        -0.360863 -0.524722 -0.5578096
## tBodyAccJerk-std()-Y                        -0.339226 -0.470412 -0.4918759
## tBodyAccJerk-std()-Z                        -0.627064 -0.717322 -0.7418854
## tBodyAccJerk-mad()-X                        -0.349989 -0.518382 -0.5703675
## tBodyAccJerk-mad()-Y                        -0.295645 -0.457974 -0.4924990
## tBodyAccJerk-mad()-Z                        -0.609023 -0.699552 -0.7367727
## tBodyAccJerk-max()-X                        -0.524751 -0.620589 -0.6179689
## tBodyAccJerk-max()-Y                        -0.605158 -0.659588 -0.6218101
## tBodyAccJerk-max()-Z                        -0.739894 -0.799387 -0.8092685
## tBodyAccJerk-min()-X                         0.248362  0.452299  0.4910759
## tBodyAccJerk-min()-Y                         0.470357  0.559418  0.5839605
## tBodyAccJerk-min()-Z                         0.584305  0.693675  0.7061691
## tBodyAccJerk-sma()                          -0.388699 -0.538170 -0.5832511
## tBodyAccJerk-energy()-X                     -0.778902 -0.795977 -0.7996266
## tBodyAccJerk-energy()-Y                     -0.757203 -0.749015 -0.7437355
## tBodyAccJerk-energy()-Z                     -0.916454 -0.923946 -0.9299911
## tBodyAccJerk-iqr()-X                        -0.313840 -0.496324 -0.5868737
## tBodyAccJerk-iqr()-Y                        -0.377793 -0.557268 -0.5996635
## tBodyAccJerk-iqr()-Z                        -0.618528 -0.696303 -0.7607740
## tBodyAccJerk-entropy()-X                     0.597653  0.050127 -0.0127226
## tBodyAccJerk-entropy()-Y                     0.544048  0.036849 -0.0260977
## tBodyAccJerk-entropy()-Z                     0.453584 -0.014082 -0.0719021
## tBodyAccJerk-arCoeff()-X,1                  -0.394289 -0.132740 -0.0114907
## tBodyAccJerk-arCoeff()-X,2                   0.156793  0.226547  0.2289247
## tBodyAccJerk-arCoeff()-X,3                  -0.078778  0.129598  0.1086959
## tBodyAccJerk-arCoeff()-X,4                   0.031276  0.027821  0.0854970
## tBodyAccJerk-arCoeff()-Y,1                  -0.297133 -0.087070 -0.0267701
## tBodyAccJerk-arCoeff()-Y,2                   0.093850  0.107867  0.1292357
## tBodyAccJerk-arCoeff()-Y,3                   0.073257  0.163197  0.2090079
## tBodyAccJerk-arCoeff()-Y,4                   0.233009  0.344590  0.2742579
## tBodyAccJerk-arCoeff()-Z,1                  -0.306081  0.005668 -0.0037755
## tBodyAccJerk-arCoeff()-Z,2                   0.042222  0.109064  0.0781061
## tBodyAccJerk-arCoeff()-Z,3                  -0.157236  0.076560  0.0058208
## tBodyAccJerk-arCoeff()-Z,4                  -0.011532  0.049736  0.1554979
## tBodyAccJerk-correlation()-X,Y              -0.306262 -0.181412 -0.2651533
## tBodyAccJerk-correlation()-X,Z              -0.065535 -0.108980  0.0393154
## tBodyAccJerk-correlation()-Y,Z               0.177171  0.208921  0.1550856
## tBodyGyro-mean()-X                           0.006824 -0.020876 -0.0517031
## tBodyGyro-mean()-Y                          -0.088523 -0.088072 -0.0568420
## tBodyGyro-mean()-Z                           0.059894  0.086264  0.0872599
## tBodyGyro-std()-X                           -0.467607 -0.686556 -0.7106489
## tBodyGyro-std()-Y                           -0.344232 -0.450980 -0.7229437
## tBodyGyro-std()-Z                           -0.237137 -0.597496 -0.6348889
## tBodyGyro-mad()-X                           -0.479919 -0.701040 -0.7144532
## tBodyGyro-mad()-Y                           -0.354269 -0.469461 -0.7360907
## tBodyGyro-mad()-Z                           -0.248285 -0.618771 -0.6456415
## tBodyGyro-max()-X                           -0.380681 -0.621063 -0.6342230
## tBodyGyro-max()-Y                           -0.547276 -0.616037 -0.7397599
## tBodyGyro-max()-Z                           -0.200658 -0.457796 -0.4754584
## tBodyGyro-min()-X                            0.480106  0.570480  0.5972959
## tBodyGyro-min()-Y                            0.568962  0.610995  0.7489246
## tBodyGyro-min()-Z                            0.283490  0.459999  0.5354646
## tBodyGyro-sma()                             -0.168080 -0.475242 -0.6095285
## tBodyGyro-energy()-X                        -0.793807 -0.902024 -0.9033530
## tBodyGyro-energy()-Y                        -0.741551 -0.742583 -0.9248325
## tBodyGyro-energy()-Z                        -0.674097 -0.868534 -0.8696956
## tBodyGyro-iqr()-X                           -0.492269 -0.720752 -0.7117995
## tBodyGyro-iqr()-Y                           -0.382379 -0.508497 -0.7561390
## tBodyGyro-iqr()-Z                           -0.340413 -0.685635 -0.6940751
## tBodyGyro-entropy()-X                        0.073614 -0.061749 -0.1864217
## tBodyGyro-entropy()-Y                        0.124946 -0.163578 -0.1080410
## tBodyGyro-entropy()-Z                        0.259643  0.038652 -0.0156624
## tBodyGyro-arCoeff()-X,1                     -0.430866 -0.239288 -0.1458334
## tBodyGyro-arCoeff()-X,2                      0.302051  0.151028  0.1388319
## tBodyGyro-arCoeff()-X,3                      0.075457  0.225159  0.0473401
## tBodyGyro-arCoeff()-X,4                     -0.174809 -0.212148 -0.0126976
## tBodyGyro-arCoeff()-Y,1                     -0.360623 -0.167613 -0.1283687
## tBodyGyro-arCoeff()-Y,2                      0.290180  0.167009  0.1393693
## tBodyGyro-arCoeff()-Y,3                     -0.126724 -0.076668 -0.0540705
## tBodyGyro-arCoeff()-Y,4                      0.148772  0.111887  0.1114936
## tBodyGyro-arCoeff()-Z,1                     -0.373597 -0.076887  0.0020245
## tBodyGyro-arCoeff()-Z,2                      0.304066  0.072821  0.0447225
## tBodyGyro-arCoeff()-Z,3                     -0.160592 -0.042316 -0.0733459
## tBodyGyro-arCoeff()-Z,4                      0.163578  0.178625  0.1734191
## tBodyGyro-correlation()-X,Y                 -0.122610 -0.034901 -0.1176350
## tBodyGyro-correlation()-X,Z                 -0.106215 -0.043591  0.1775415
## tBodyGyro-correlation()-Y,Z                  0.193132 -0.104994 -0.1691490
## tBodyGyroJerk-mean()-X                      -0.112117 -0.097112 -0.0875587
## tBodyGyroJerk-mean()-Y                      -0.038619 -0.041716 -0.0433987
## tBodyGyroJerk-mean()-Z                      -0.052581 -0.047139 -0.0557542
## tBodyGyroJerk-std()-X                       -0.553133 -0.637813 -0.6716791
## tBodyGyroJerk-std()-Y                       -0.667339 -0.634472 -0.7835955
## tBodyGyroJerk-std()-Z                       -0.560989 -0.664592 -0.6746119
## tBodyGyroJerk-mad()-X                       -0.542983 -0.642637 -0.6878794
## tBodyGyroJerk-mad()-Y                       -0.677014 -0.647484 -0.8018740
## tBodyGyroJerk-mad()-Z                       -0.565664 -0.666658 -0.6913505
## tBodyGyroJerk-max()-X                       -0.581782 -0.664456 -0.6689748
## tBodyGyroJerk-max()-Y                       -0.715842 -0.700737 -0.7990207
## tBodyGyroJerk-max()-Z                       -0.596549 -0.656626 -0.6395597
## tBodyGyroJerk-min()-X                        0.609605  0.686541  0.6606413
## tBodyGyroJerk-min()-Y                        0.746952  0.695081  0.8063349
## tBodyGyroJerk-min()-Z                        0.657956  0.760205  0.7548092
## tBodyGyroJerk-sma()                         -0.614157 -0.649725 -0.7453353
## tBodyGyroJerk-energy()-X                    -0.885982 -0.878976 -0.8896937
## tBodyGyroJerk-energy()-Y                    -0.932689 -0.876883 -0.9503338
## tBodyGyroJerk-energy()-Z                    -0.888261 -0.898404 -0.8930315
## tBodyGyroJerk-iqr()-X                       -0.539451 -0.675814 -0.7239934
## tBodyGyroJerk-iqr()-Y                       -0.687602 -0.662360 -0.8230729
## tBodyGyroJerk-iqr()-Z                       -0.588791 -0.685471 -0.7284451
## tBodyGyroJerk-entropy()-X                    0.509070  0.051774  0.0166713
## tBodyGyroJerk-entropy()-Y                    0.521511  0.077720  0.0623908
## tBodyGyroJerk-entropy()-Z                    0.587233  0.089142  0.0570930
## tBodyGyroJerk-arCoeff()-X,1                 -0.228231 -0.080400 -0.0056211
## tBodyGyroJerk-arCoeff()-X,2                  0.124101  0.028763  0.0834008
## tBodyGyroJerk-arCoeff()-X,3                  0.121483  0.242365  0.1778002
## tBodyGyroJerk-arCoeff()-X,4                  0.144697  0.195514  0.1044169
## tBodyGyroJerk-arCoeff()-Y,1                 -0.296602 -0.106083 -0.0717877
## tBodyGyroJerk-arCoeff()-Y,2                  0.249662  0.232329  0.2213643
## tBodyGyroJerk-arCoeff()-Y,3                  0.025895  0.136060  0.1484382
## tBodyGyroJerk-arCoeff()-Y,4                  0.016932  0.028069  0.0442935
## tBodyGyroJerk-arCoeff()-Z,1                 -0.304334 -0.023958  0.0791252
## tBodyGyroJerk-arCoeff()-Z,2                  0.179644  0.079553  0.0891922
## tBodyGyroJerk-arCoeff()-Z,3                 -0.007505  0.060975  0.1298983
## tBodyGyroJerk-arCoeff()-Z,4                 -0.075029  0.027115 -0.0574607
## tBodyGyroJerk-correlation()-X,Y              0.116566  0.246227  0.1923987
## tBodyGyroJerk-correlation()-X,Z             -0.010819 -0.167193  0.1116216
## tBodyGyroJerk-correlation()-Y,Z             -0.082247 -0.140015 -0.2392844
## tBodyAccMag-mean()                          -0.100204 -0.453633 -0.5352818
## tBodyAccMag-std()                           -0.249875 -0.497096 -0.5528125
## tBodyAccMag-mad()                           -0.344180 -0.547873 -0.6272043
## tBodyAccMag-max()                           -0.178135 -0.482052 -0.4912516
## tBodyAccMag-min()                           -0.680905 -0.833674 -0.8109143
## tBodyAccMag-sma()                           -0.100204 -0.453633 -0.5352818
## tBodyAccMag-energy()                        -0.575563 -0.741395 -0.7743459
## tBodyAccMag-iqr()                           -0.450694 -0.603153 -0.7327709
## tBodyAccMag-entropy()                        0.799118  0.249771  0.1410157
## tBodyAccMag-arCoeff()1                      -0.344057  0.010748  0.0635220
## tBodyAccMag-arCoeff()2                       0.237764 -0.044557 -0.0769758
## tBodyAccMag-arCoeff()3                      -0.096098  0.085444  0.0904740
## tBodyAccMag-arCoeff()4                       0.089295 -0.049192 -0.0570892
## tGravityAccMag-mean()                       -0.100204 -0.453633 -0.5352818
## tGravityAccMag-std()                        -0.249875 -0.497096 -0.5528125
## tGravityAccMag-mad()                        -0.344180 -0.547873 -0.6272043
## tGravityAccMag-max()                        -0.178135 -0.482052 -0.4912516
## tGravityAccMag-min()                        -0.680905 -0.833674 -0.8109143
## tGravityAccMag-sma()                        -0.100204 -0.453633 -0.5352818
## tGravityAccMag-energy()                     -0.575563 -0.741395 -0.7743459
## tGravityAccMag-iqr()                        -0.450694 -0.603153 -0.7327709
## tGravityAccMag-entropy()                     0.799118  0.249771  0.1410157
## tGravityAccMag-arCoeff()1                   -0.344057  0.010748  0.0635220
## tGravityAccMag-arCoeff()2                    0.237764 -0.044557 -0.0769758
## tGravityAccMag-arCoeff()3                   -0.096098  0.085444  0.0904740
## tGravityAccMag-arCoeff()4                    0.089295 -0.049192 -0.0570892
## tBodyAccJerkMag-mean()                      -0.390939 -0.545432 -0.5877774
## tBodyAccJerkMag-std()                       -0.385400 -0.515922 -0.5121153
## tBodyAccJerkMag-mad()                       -0.429036 -0.543385 -0.5442971
## tBodyAccJerkMag-max()                       -0.367795 -0.525482 -0.5253401
## tBodyAccJerkMag-min()                       -0.598088 -0.719663 -0.7718368
## tBodyAccJerkMag-sma()                       -0.390939 -0.545432 -0.5877774
## tBodyAccJerkMag-energy()                    -0.791093 -0.800918 -0.8040011
## tBodyAccJerkMag-iqr()                       -0.526009 -0.614676 -0.6259973
## tBodyAccJerkMag-entropy()                    0.628745  0.084201  0.0108421
## tBodyAccJerkMag-arCoeff()1                  -0.122228  0.124725  0.1465720
## tBodyAccJerkMag-arCoeff()2                   0.198543 -0.087802 -0.1164473
## tBodyAccJerkMag-arCoeff()3                  -0.121301 -0.141036 -0.1534331
## tBodyAccJerkMag-arCoeff()4                  -0.048472  0.035925  0.0688932
## tBodyGyroMag-mean()                         -0.178281 -0.475405 -0.6147711
## tBodyGyroMag-std()                          -0.337142 -0.499840 -0.6805849
## tBodyGyroMag-mad()                          -0.271255 -0.439586 -0.6543232
## tBodyGyroMag-max()                          -0.408279 -0.580657 -0.6984169
## tBodyGyroMag-min()                          -0.408624 -0.692597 -0.7350918
## tBodyGyroMag-sma()                          -0.178281 -0.475405 -0.6147711
## tBodyGyroMag-energy()                       -0.631600 -0.758090 -0.8571549
## tBodyGyroMag-iqr()                          -0.316258 -0.452758 -0.6791294
## tBodyGyroMag-entropy()                       0.520885  0.157223  0.2890058
## tBodyGyroMag-arCoeff()1                     -0.189784  0.069831  0.0945276
## tBodyGyroMag-arCoeff()2                      0.075565 -0.134577 -0.1666045
## tBodyGyroMag-arCoeff()3                      0.029498  0.143896  0.1443815
## tBodyGyroMag-arCoeff()4                     -0.011935 -0.117132 -0.0766789
## tBodyGyroJerkMag-mean()                     -0.608047 -0.639517 -0.7465595
## tBodyGyroJerkMag-std()                      -0.666837 -0.652051 -0.7400887
## tBodyGyroJerkMag-mad()                      -0.685128 -0.675544 -0.7599547
## tBodyGyroJerkMag-max()                      -0.675158 -0.651349 -0.7485008
## tBodyGyroJerkMag-min()                      -0.648266 -0.728591 -0.7984504
## tBodyGyroJerkMag-sma()                      -0.608047 -0.639517 -0.7465595
## tBodyGyroJerkMag-energy()                   -0.916710 -0.879801 -0.9297750
## tBodyGyroJerkMag-iqr()                      -0.698736 -0.687273 -0.7865730
## tBodyGyroJerkMag-entropy()                   0.797973  0.233927  0.1675184
## tBodyGyroJerkMag-arCoeff()1                  0.177462  0.338891  0.3446717
## tBodyGyroJerkMag-arCoeff()2                 -0.126367 -0.245125 -0.3503185
## tBodyGyroJerkMag-arCoeff()3                 -0.047843 -0.067101 -0.0238868
## tBodyGyroJerkMag-arCoeff()4                 -0.152903 -0.128116 -0.0072756
## fBodyAcc-mean()-X                           -0.293407 -0.531895 -0.5737709
## fBodyAcc-mean()-Y                           -0.134951 -0.406435 -0.4325666
## fBodyAcc-mean()-Z                           -0.368122 -0.596411 -0.6300812
## fBodyAcc-std()-X                            -0.218888 -0.553061 -0.6197881
## fBodyAcc-std()-Y                            -0.021811 -0.390151 -0.4647239
## fBodyAcc-std()-Z                            -0.146602 -0.498583 -0.6006786
## fBodyAcc-mad()-X                            -0.219227 -0.508875 -0.5726431
## fBodyAcc-mad()-Y                            -0.072517 -0.395490 -0.4415114
## fBodyAcc-mad()-Z                            -0.251355 -0.558256 -0.5983078
## fBodyAcc-max()-X                            -0.288896 -0.631257 -0.6803361
## fBodyAcc-max()-Y                            -0.235335 -0.546129 -0.6141490
## fBodyAcc-max()-Z                            -0.141708 -0.467374 -0.6385382
## fBodyAcc-min()-X                            -0.740980 -0.819904 -0.8593398
## fBodyAcc-min()-Y                            -0.799829 -0.840051 -0.8511615
## fBodyAcc-min()-Z                            -0.853751 -0.888354 -0.9093181
## fBodyAcc-sma()                              -0.163019 -0.445392 -0.4862000
## fBodyAcc-energy()-X                         -0.697057 -0.818789 -0.8405923
## fBodyAcc-energy()-Y                         -0.491092 -0.669529 -0.6882084
## fBodyAcc-energy()-Z                         -0.624145 -0.794035 -0.8308356
## fBodyAcc-iqr()-X                            -0.372016 -0.519429 -0.5422200
## fBodyAcc-iqr()-Y                            -0.396227 -0.554566 -0.5346092
## fBodyAcc-iqr()-Z                            -0.596015 -0.702083 -0.7134409
## fBodyAcc-entropy()-X                         0.500738 -0.030121 -0.0970730
## fBodyAcc-entropy()-Y                         0.434817 -0.033779 -0.0924082
## fBodyAcc-entropy()-Z                         0.330592 -0.101002 -0.1509286
## fBodyAcc-maxInds-X                          -0.793874 -0.762015 -0.7585986
## fBodyAcc-maxInds-Y                          -0.827979 -0.781556 -0.8245033
## fBodyAcc-maxInds-Z                          -0.859605 -0.902904 -0.8458991
## fBodyAcc-meanFreq()-X                       -0.436684 -0.180559 -0.1067634
## fBodyAcc-meanFreq()-Y                       -0.169851  0.057629  0.1057342
## fBodyAcc-meanFreq()-Z                       -0.265200  0.058369  0.0872106
## fBodyAcc-skewness()-X                        0.110665 -0.188227 -0.2184758
## fBodyAcc-kurtosis()-X                       -0.228633 -0.525706 -0.5466314
## fBodyAcc-skewness()-Y                       -0.173261 -0.204360 -0.3292576
## fBodyAcc-kurtosis()-Y                       -0.531890 -0.506971 -0.6363467
## fBodyAcc-skewness()-Z                       -0.052136 -0.182008 -0.3456692
## fBodyAcc-kurtosis()-Z                       -0.336158 -0.407214 -0.5901581
## fBodyAcc-bandsEnergy()-1,8                  -0.670569 -0.824916 -0.8499414
## fBodyAcc-bandsEnergy()-9,16                 -0.819882 -0.886613 -0.8930996
## fBodyAcc-bandsEnergy()-17,24                -0.809168 -0.716725 -0.7680622
## fBodyAcc-bandsEnergy()-25,32                -0.849666 -0.820710 -0.7838336
## fBodyAcc-bandsEnergy()-33,40                -0.869796 -0.901693 -0.8586945
## fBodyAcc-bandsEnergy()-41,48                -0.868456 -0.891879 -0.8735790
## fBodyAcc-bandsEnergy()-49,56                -0.917280 -0.929093 -0.9314862
## fBodyAcc-bandsEnergy()-57,64                -0.926745 -0.942659 -0.9640219
## fBodyAcc-bandsEnergy()-1,16                 -0.683939 -0.826823 -0.8487147
## fBodyAcc-bandsEnergy()-17,32                -0.791381 -0.703414 -0.7364572
## fBodyAcc-bandsEnergy()-33,48                -0.869308 -0.898028 -0.8642881
## fBodyAcc-bandsEnergy()-49,64                -0.920453 -0.933640 -0.9423913
## fBodyAcc-bandsEnergy()-1,24                 -0.692841 -0.818999 -0.8429838
## fBodyAcc-bandsEnergy()-25,48                -0.829829 -0.822974 -0.7804199
## fBodyAcc-bandsEnergy()-1,8.1                -0.456421 -0.749138 -0.7381072
## fBodyAcc-bandsEnergy()-9,16.1               -0.790229 -0.746119 -0.8312433
## fBodyAcc-bandsEnergy()-17,24.1              -0.831912 -0.816155 -0.7696549
## fBodyAcc-bandsEnergy()-25,32.1              -0.866185 -0.880828 -0.7924946
## fBodyAcc-bandsEnergy()-33,40.1              -0.844653 -0.855649 -0.8368004
## fBodyAcc-bandsEnergy()-41,48.1              -0.820395 -0.843317 -0.8256810
## fBodyAcc-bandsEnergy()-49,56.1              -0.853055 -0.853378 -0.8738461
## fBodyAcc-bandsEnergy()-57,64.1              -0.916772 -0.926431 -0.9434137
## fBodyAcc-bandsEnergy()-1,16.1               -0.475584 -0.677184 -0.7125244
## fBodyAcc-bandsEnergy()-17,32.1              -0.798906 -0.787913 -0.7174480
## fBodyAcc-bandsEnergy()-33,48.1              -0.817564 -0.834397 -0.8138521
## fBodyAcc-bandsEnergy()-49,64.1              -0.875172 -0.879445 -0.8991078
## fBodyAcc-bandsEnergy()-1,24.1               -0.491097 -0.672558 -0.6966533
## fBodyAcc-bandsEnergy()-25,48.1              -0.844267 -0.860337 -0.7885933
## fBodyAcc-bandsEnergy()-1,8.2                -0.588947 -0.790456 -0.8461515
## fBodyAcc-bandsEnergy()-9,16.2               -0.853383 -0.935474 -0.8946435
## fBodyAcc-bandsEnergy()-17,24.2              -0.931815 -0.904919 -0.9282928
## fBodyAcc-bandsEnergy()-25,32.2              -0.962474 -0.946000 -0.9662254
## fBodyAcc-bandsEnergy()-33,40.2              -0.957592 -0.961920 -0.9607630
## fBodyAcc-bandsEnergy()-41,48.2              -0.917750 -0.922917 -0.9309392
## fBodyAcc-bandsEnergy()-49,56.2              -0.915873 -0.924931 -0.9366446
## fBodyAcc-bandsEnergy()-57,64.2              -0.917472 -0.944440 -0.9555707
## fBodyAcc-bandsEnergy()-1,16.2               -0.624154 -0.811713 -0.8430705
## fBodyAcc-bandsEnergy()-17,32.2              -0.942954 -0.919833 -0.9420665
## fBodyAcc-bandsEnergy()-33,48.2              -0.944264 -0.949118 -0.9502665
## fBodyAcc-bandsEnergy()-49,64.2              -0.915645 -0.930151 -0.9417893
## fBodyAcc-bandsEnergy()-1,24.2               -0.623426 -0.798699 -0.8337939
## fBodyAcc-bandsEnergy()-25,48.2              -0.957298 -0.946905 -0.9616910
## fBodyAccJerk-mean()-X                       -0.389897 -0.547349 -0.5616820
## fBodyAccJerk-mean()-Y                       -0.364667 -0.507344 -0.5089038
## fBodyAccJerk-mean()-Z                       -0.591670 -0.695305 -0.7157453
## fBodyAccJerk-std()-X                        -0.388993 -0.543980 -0.5951056
## fBodyAccJerk-std()-Y                        -0.357633 -0.466252 -0.5091475
## fBodyAccJerk-std()-Z                        -0.661591 -0.737862 -0.7670870
## fBodyAccJerk-mad()-X                        -0.284579 -0.454185 -0.4985480
## fBodyAccJerk-mad()-Y                        -0.369024 -0.492385 -0.5086838
## fBodyAccJerk-mad()-Z                        -0.633566 -0.718432 -0.7463257
## fBodyAccJerk-max()-X                        -0.490514 -0.634497 -0.6928793
## fBodyAccJerk-max()-Y                        -0.483678 -0.542341 -0.6113035
## fBodyAccJerk-max()-Z                        -0.697260 -0.762342 -0.7896665
## fBodyAccJerk-min()-X                        -0.788030 -0.860693 -0.8541886
## fBodyAccJerk-min()-Y                        -0.756079 -0.832411 -0.8310874
## fBodyAccJerk-min()-Z                        -0.811641 -0.866418 -0.8745819
## fBodyAccJerk-sma()                          -0.349514 -0.510259 -0.5253438
## fBodyAccJerk-energy()-X                     -0.778651 -0.795727 -0.7993329
## fBodyAccJerk-energy()-Y                     -0.757349 -0.749135 -0.7438454
## fBodyAccJerk-energy()-Z                     -0.916515 -0.923981 -0.9300221
## fBodyAccJerk-iqr()-X                        -0.357210 -0.503543 -0.5087303
## fBodyAccJerk-iqr()-Y                        -0.516364 -0.628122 -0.6145227
## fBodyAccJerk-iqr()-Z                        -0.641241 -0.728636 -0.7477548
## fBodyAccJerk-entropy()-X                     0.447119 -0.069152 -0.1477678
## fBodyAccJerk-entropy()-Y                     0.400914 -0.072183 -0.1396786
## fBodyAccJerk-entropy()-Z                     0.163722 -0.227957 -0.3044872
## fBodyAccJerk-maxInds-X                      -0.718161 -0.336254 -0.2494040
## fBodyAccJerk-maxInds-Y                      -0.553756 -0.407954 -0.3266225
## fBodyAccJerk-maxInds-Z                      -0.595699 -0.300634 -0.2833113
## fBodyAccJerk-meanFreq()-X                   -0.339080 -0.048801  0.0868001
## fBodyAccJerk-meanFreq()-Y                   -0.452501 -0.215279 -0.1397766
## fBodyAccJerk-meanFreq()-Z                   -0.441163 -0.096450 -0.0942652
## fBodyAccJerk-skewness()-X                   -0.153751 -0.326031 -0.4215930
## fBodyAccJerk-kurtosis()-X                   -0.603751 -0.734706 -0.7966302
## fBodyAccJerk-skewness()-Y                   -0.339770 -0.354071 -0.4579808
## fBodyAccJerk-kurtosis()-Y                   -0.798116 -0.787070 -0.8602855
## fBodyAccJerk-skewness()-Z                   -0.423289 -0.461063 -0.5095098
## fBodyAccJerk-kurtosis()-Z                   -0.783341 -0.804808 -0.8302070
## fBodyAccJerk-bandsEnergy()-1,8              -0.793523 -0.869409 -0.8932715
## fBodyAccJerk-bandsEnergy()-9,16             -0.822752 -0.881776 -0.8888193
## fBodyAccJerk-bandsEnergy()-17,24            -0.832588 -0.739544 -0.7801560
## fBodyAccJerk-bandsEnergy()-25,32            -0.856605 -0.828785 -0.7755786
## fBodyAccJerk-bandsEnergy()-33,40            -0.882475 -0.915197 -0.8576904
## fBodyAccJerk-bandsEnergy()-41,48            -0.856707 -0.884906 -0.8453198
## fBodyAccJerk-bandsEnergy()-49,56            -0.921733 -0.926779 -0.9087813
## fBodyAccJerk-bandsEnergy()-57,64            -0.976262 -0.983741 -0.9804031
## fBodyAccJerk-bandsEnergy()-1,16             -0.794122 -0.865865 -0.8810417
## fBodyAccJerk-bandsEnergy()-17,32            -0.804091 -0.718018 -0.7268458
## fBodyAccJerk-bandsEnergy()-33,48            -0.862101 -0.895685 -0.8407682
## fBodyAccJerk-bandsEnergy()-49,64            -0.918500 -0.924904 -0.9065724
## fBodyAccJerk-bandsEnergy()-1,24             -0.771091 -0.792583 -0.8203410
## fBodyAccJerk-bandsEnergy()-25,48            -0.801479 -0.803509 -0.7273232
## fBodyAccJerk-bandsEnergy()-1,8.1            -0.650432 -0.806099 -0.7908735
## fBodyAccJerk-bandsEnergy()-9,16.1           -0.822848 -0.767395 -0.8528801
## fBodyAccJerk-bandsEnergy()-17,24.1          -0.805748 -0.788228 -0.7161914
## fBodyAccJerk-bandsEnergy()-25,32.1          -0.875422 -0.887685 -0.8027901
## fBodyAccJerk-bandsEnergy()-33,40.1          -0.874262 -0.883449 -0.8609632
## fBodyAccJerk-bandsEnergy()-41,48.1          -0.818111 -0.840707 -0.8104468
## fBodyAccJerk-bandsEnergy()-49,56.1          -0.893168 -0.888626 -0.8945308
## fBodyAccJerk-bandsEnergy()-57,64.1          -0.960464 -0.965688 -0.9656736
## fBodyAccJerk-bandsEnergy()-1,16.1           -0.757036 -0.743403 -0.8173425
## fBodyAccJerk-bandsEnergy()-17,32.1          -0.799526 -0.792523 -0.6999315
## fBodyAccJerk-bandsEnergy()-33,48.1          -0.820077 -0.837201 -0.8059842
## fBodyAccJerk-bandsEnergy()-49,64.1          -0.901661 -0.898351 -0.9035095
## fBodyAccJerk-bandsEnergy()-1,24.1           -0.737740 -0.720110 -0.7421684
## fBodyAccJerk-bandsEnergy()-25,48.1          -0.852406 -0.866710 -0.8013943
## fBodyAccJerk-bandsEnergy()-1,8.2            -0.768937 -0.919466 -0.8855320
## fBodyAccJerk-bandsEnergy()-9,16.2           -0.865007 -0.931078 -0.8983924
## fBodyAccJerk-bandsEnergy()-17,24.2          -0.939296 -0.907120 -0.9309969
## fBodyAccJerk-bandsEnergy()-25,32.2          -0.965693 -0.948008 -0.9687739
## fBodyAccJerk-bandsEnergy()-33,40.2          -0.964593 -0.967366 -0.9650824
## fBodyAccJerk-bandsEnergy()-41,48.2          -0.929940 -0.928963 -0.9341321
## fBodyAccJerk-bandsEnergy()-49,56.2          -0.919072 -0.913145 -0.9260833
## fBodyAccJerk-bandsEnergy()-57,64.2          -0.964787 -0.966339 -0.9735061
## fBodyAccJerk-bandsEnergy()-1,16.2           -0.802484 -0.912466 -0.8724491
## fBodyAccJerk-bandsEnergy()-17,32.2          -0.952231 -0.927140 -0.9494959
## fBodyAccJerk-bandsEnergy()-33,48.2          -0.951755 -0.953580 -0.9533961
## fBodyAccJerk-bandsEnergy()-49,64.2          -0.919178 -0.913731 -0.9268292
## fBodyAccJerk-bandsEnergy()-1,24.2           -0.870867 -0.897580 -0.8962006
## fBodyAccJerk-bandsEnergy()-25,48.2          -0.960243 -0.950222 -0.9627581
## fBodyGyro-mean()-X                          -0.394248 -0.623219 -0.6387177
## fBodyGyro-mean()-Y                          -0.459253 -0.505309 -0.7220690
## fBodyGyro-mean()-Z                          -0.296858 -0.553529 -0.6015949
## fBodyGyro-std()-X                           -0.495254 -0.708263 -0.7345885
## fBodyGyro-std()-Y                           -0.293182 -0.429826 -0.7271677
## fBodyGyro-std()-Z                           -0.292041 -0.650476 -0.6831145
## fBodyGyro-mad()-X                           -0.413040 -0.639135 -0.6767911
## fBodyGyro-mad()-Y                           -0.439918 -0.525038 -0.7463367
## fBodyGyro-mad()-Z                           -0.256474 -0.565259 -0.6342483
## fBodyGyro-max()-X                           -0.482225 -0.710144 -0.7273791
## fBodyGyro-max()-Y                           -0.344510 -0.502127 -0.7853538
## fBodyGyro-max()-Z                           -0.405648 -0.754850 -0.7488199
## fBodyGyro-min()-X                           -0.868321 -0.920810 -0.9307757
## fBodyGyro-min()-Y                           -0.821165 -0.834336 -0.9150838
## fBodyGyro-min()-Z                           -0.827120 -0.883244 -0.8971489
## fBodyGyro-sma()                             -0.361356 -0.528334 -0.6450475
## fBodyGyro-energy()-X                        -0.843139 -0.913812 -0.9155185
## fBodyGyro-energy()-Y                        -0.746112 -0.742539 -0.9277398
## fBodyGyro-energy()-Z                        -0.665063 -0.862595 -0.8700839
## fBodyGyro-iqr()-X                           -0.483907 -0.643725 -0.6452403
## fBodyGyro-iqr()-Y                           -0.583314 -0.589042 -0.7532155
## fBodyGyro-iqr()-Z                           -0.467595 -0.603631 -0.6198760
## fBodyGyro-entropy()-X                        0.461421 -0.008774 -0.0402636
## fBodyGyro-entropy()-Y                        0.500437  0.086820 -0.0048494
## fBodyGyro-entropy()-Z                        0.405065  0.006692 -0.0340052
## fBodyGyro-maxInds-X                         -0.936356 -0.750624 -0.8858720
## fBodyGyro-maxInds-Y                         -0.882333 -0.866320 -0.8568682
## fBodyGyro-maxInds-Z                         -0.879266 -0.814369 -0.8403745
## fBodyGyro-meanFreq()-X                      -0.212837 -0.032032 -0.0057650
## fBodyGyro-meanFreq()-Y                      -0.319519 -0.090152 -0.0702155
## fBodyGyro-meanFreq()-Z                      -0.260341 -0.018006  0.0513627
## fBodyGyro-skewness()-X                      -0.101035 -0.206139 -0.2296172
## fBodyGyro-kurtosis()-X                      -0.428034 -0.514355 -0.5401878
## fBodyGyro-skewness()-Y                      -0.009778 -0.115967 -0.2349074
## fBodyGyro-kurtosis()-Y                      -0.342037 -0.455351 -0.5885482
## fBodyGyro-skewness()-Z                      -0.025495 -0.258702 -0.1828559
## fBodyGyro-kurtosis()-Z                      -0.342903 -0.581865 -0.4753559
## fBodyGyro-bandsEnergy()-1,8                 -0.859899 -0.945729 -0.9318401
## fBodyGyro-bandsEnergy()-9,16                -0.864337 -0.801042 -0.9131892
## fBodyGyro-bandsEnergy()-17,24               -0.890526 -0.883406 -0.8938728
## fBodyGyro-bandsEnergy()-25,32               -0.946216 -0.970142 -0.9065547
## fBodyGyro-bandsEnergy()-33,40               -0.928968 -0.960788 -0.9224610
## fBodyGyro-bandsEnergy()-41,48               -0.926055 -0.951810 -0.9380569
## fBodyGyro-bandsEnergy()-49,56               -0.938320 -0.960634 -0.9588296
## fBodyGyro-bandsEnergy()-57,64               -0.950965 -0.971812 -0.9773132
## fBodyGyro-bandsEnergy()-1,16                -0.848311 -0.919852 -0.9231628
## fBodyGyro-bandsEnergy()-17,32               -0.890003 -0.894039 -0.8765126
## fBodyGyro-bandsEnergy()-33,48               -0.920640 -0.953191 -0.9210154
## fBodyGyro-bandsEnergy()-49,64               -0.943915 -0.965580 -0.9670083
## fBodyGyro-bandsEnergy()-1,24                -0.844938 -0.914863 -0.9186881
## fBodyGyro-bandsEnergy()-25,48               -0.938246 -0.964924 -0.9097093
## fBodyGyro-bandsEnergy()-1,8.1               -0.650428 -0.673455 -0.9267463
## fBodyGyro-bandsEnergy()-9,16.1              -0.934289 -0.959545 -0.9790900
## fBodyGyro-bandsEnergy()-17,24.1             -0.961742 -0.913269 -0.9703687
## fBodyGyro-bandsEnergy()-25,32.1             -0.969283 -0.917927 -0.9616949
## fBodyGyro-bandsEnergy()-33,40.1             -0.974101 -0.944319 -0.9738314
## fBodyGyro-bandsEnergy()-41,48.1             -0.949596 -0.901977 -0.9580846
## fBodyGyro-bandsEnergy()-49,56.1             -0.936091 -0.897318 -0.9531504
## fBodyGyro-bandsEnergy()-57,64.1             -0.953123 -0.948376 -0.9852768
## fBodyGyro-bandsEnergy()-1,16.1              -0.721886 -0.753816 -0.9370777
## fBodyGyro-bandsEnergy()-17,32.1             -0.954910 -0.894016 -0.9606847
## fBodyGyro-bandsEnergy()-33,48.1             -0.968804 -0.935055 -0.9703305
## fBodyGyro-bandsEnergy()-49,64.1             -0.934774 -0.905468 -0.9606959
## fBodyGyro-bandsEnergy()-1,24.1              -0.723429 -0.729768 -0.9273436
## fBodyGyro-bandsEnergy()-25,48.1             -0.966751 -0.916934 -0.9614333
## fBodyGyro-bandsEnergy()-1,8.2               -0.700700 -0.900840 -0.9023367
## fBodyGyro-bandsEnergy()-9,16.2              -0.894822 -0.914212 -0.9457708
## fBodyGyro-bandsEnergy()-17,24.2             -0.911028 -0.921397 -0.9129140
## fBodyGyro-bandsEnergy()-25,32.2             -0.955966 -0.958040 -0.9135333
## fBodyGyro-bandsEnergy()-33,40.2             -0.958118 -0.956482 -0.9482752
## fBodyGyro-bandsEnergy()-41,48.2             -0.936987 -0.947778 -0.9407302
## fBodyGyro-bandsEnergy()-49,56.2             -0.911470 -0.944927 -0.9333988
## fBodyGyro-bandsEnergy()-57,64.2             -0.929510 -0.969547 -0.9750823
## fBodyGyro-bandsEnergy()-1,16.2              -0.680018 -0.876925 -0.8889203
## fBodyGyro-bandsEnergy()-17,32.2             -0.893845 -0.904737 -0.8751023
## fBodyGyro-bandsEnergy()-33,48.2             -0.952280 -0.953988 -0.9460646
## fBodyGyro-bandsEnergy()-49,64.2             -0.919313 -0.955631 -0.9515216
## fBodyGyro-bandsEnergy()-1,24.2              -0.669570 -0.866944 -0.8777430
## fBodyGyro-bandsEnergy()-25,48.2             -0.954824 -0.956785 -0.9236288
## fBodyAccMag-mean()                          -0.262028 -0.478449 -0.5145699
## fBodyAccMag-std()                           -0.361753 -0.589710 -0.6466623
## fBodyAccMag-mad()                           -0.245516 -0.510313 -0.5679360
## fBodyAccMag-max()                           -0.539990 -0.711653 -0.7542171
## fBodyAccMag-min()                           -0.840466 -0.846584 -0.8437409
## fBodyAccMag-sma()                           -0.262028 -0.478449 -0.5145699
## fBodyAccMag-energy()                        -0.704736 -0.789964 -0.7961909
## fBodyAccMag-iqr()                           -0.443693 -0.627701 -0.6523726
## fBodyAccMag-entropy()                        0.452050 -0.042213 -0.1290161
## fBodyAccMag-maxInds                         -0.638735 -0.738249 -0.7293903
## fBodyAccMag-meanFreq()                      -0.053217  0.142062  0.1921997
## fBodyAccMag-skewness()                      -0.350612 -0.419852 -0.4121684
## fBodyAccMag-kurtosis()                      -0.660052 -0.688716 -0.6855661
## fBodyBodyAccJerkMag-mean()                  -0.353962 -0.499076 -0.5097464
## fBodyBodyAccJerkMag-std()                   -0.434207 -0.541823 -0.5188008
## fBodyBodyAccJerkMag-mad()                   -0.357772 -0.498715 -0.4959915
## fBodyBodyAccJerkMag-max()                   -0.527395 -0.611393 -0.5735248
## fBodyBodyAccJerkMag-min()                   -0.663694 -0.727621 -0.7536302
## fBodyBodyAccJerkMag-sma()                   -0.353962 -0.499076 -0.5097464
## fBodyBodyAccJerkMag-energy()                -0.793675 -0.785989 -0.7573104
## fBodyBodyAccJerkMag-iqr()                   -0.432325 -0.575736 -0.5935745
## fBodyBodyAccJerkMag-entropy()                0.254379 -0.166897 -0.2267276
## fBodyBodyAccJerkMag-maxInds                 -0.885517 -0.870820 -0.8698623
## fBodyBodyAccJerkMag-meanFreq()               0.062873  0.200055  0.1930668
## fBodyBodyAccJerkMag-skewness()              -0.240673 -0.319889 -0.2790378
## fBodyBodyAccJerkMag-kurtosis()              -0.564373 -0.637882 -0.5931322
## fBodyBodyGyroMag-mean()                     -0.449781 -0.535003 -0.6997429
## fBodyBodyGyroMag-std()                      -0.381406 -0.566577 -0.7253103
## fBodyBodyGyroMag-mad()                      -0.352642 -0.542978 -0.7083431
## fBodyBodyGyroMag-max()                      -0.458416 -0.593440 -0.7561870
## fBodyBodyGyroMag-min()                      -0.842634 -0.801009 -0.8784432
## fBodyBodyGyroMag-sma()                      -0.449781 -0.535003 -0.6997429
## fBodyBodyGyroMag-energy()                   -0.751840 -0.794911 -0.9018246
## fBodyBodyGyroMag-iqr()                      -0.477912 -0.585178 -0.7417831
## fBodyBodyGyroMag-entropy()                   0.460971  0.078226 -0.0498716
## fBodyBodyGyroMag-maxInds                    -0.878803 -0.874381 -0.8522669
## fBodyBodyGyroMag-meanFreq()                 -0.168708  0.064931  0.0471325
## fBodyBodyGyroMag-skewness()                 -0.282269 -0.205848 -0.3046666
## fBodyBodyGyroMag-kurtosis()                 -0.616823 -0.506323 -0.6059822
## fBodyBodyGyroJerkMag-mean()                 -0.658694 -0.645971 -0.7516151
## fBodyBodyGyroJerkMag-std()                  -0.703084 -0.685811 -0.7441950
## fBodyBodyGyroJerkMag-mad()                  -0.660216 -0.649682 -0.7315550
## fBodyBodyGyroJerkMag-max()                  -0.743245 -0.714591 -0.7614508
## fBodyBodyGyroJerkMag-min()                  -0.798077 -0.783031 -0.8632085
## fBodyBodyGyroJerkMag-sma()                  -0.658694 -0.645971 -0.7516151
## fBodyBodyGyroJerkMag-energy()               -0.935229 -0.888647 -0.9270923
## fBodyBodyGyroJerkMag-iqr()                  -0.637372 -0.634812 -0.7541782
## fBodyBodyGyroJerkMag-entropy()               0.256963 -0.088027 -0.2280607
## fBodyBodyGyroJerkMag-maxInds                -0.871741 -0.885550 -0.9082308
## fBodyBodyGyroJerkMag-meanFreq()              0.094112  0.198032  0.1246121
## fBodyBodyGyroJerkMag-skewness()             -0.361533 -0.346916 -0.2441905
## fBodyBodyGyroJerkMag-kurtosis()             -0.682468 -0.656185 -0.5784998
## angle(tBodyAccMean,gravity)                  0.035371  0.037608  0.0098718
## angle(tBodyAccJerkMean),gravityMean)         0.006652  0.009018  0.0140446
## angle(tBodyGyroMean,gravityMean)            -0.129903 -0.013451  0.0745851
## angle(tBodyGyroJerkMean,gravityMean)         0.036432 -0.001630 -0.0372928
## angle(X,gravityMean)                        -0.637980 -0.535774 -0.4344867
## angle(Y,gravityMean)                         0.278642  0.122790  0.1722868
## angle(Z,gravityMean)                         0.122794 -0.039079 -0.0788655
##                                       subject_3 subject_4 subject_5
## tBodyAcc-mean()-X                     0.2734287  0.274183  0.279178
## tBodyAcc-mean()-Y                    -0.0178561 -0.014808 -0.015483
## tBodyAcc-mean()-Z                    -0.1064926 -0.107521 -0.105662
## tBodyAcc-std()-X                     -0.6234136 -0.605212 -0.507691
## tBodyAcc-std()-Y                     -0.4800159 -0.509929 -0.402725
## tBodyAcc-std()-Z                     -0.6536256 -0.709493 -0.646444
## tBodyAcc-mad()-X                     -0.6537651 -0.635361 -0.537623
## tBodyAcc-mad()-Y                     -0.4887856 -0.526101 -0.424938
## tBodyAcc-mad()-Z                     -0.6490333 -0.703257 -0.635705
## tBodyAcc-max()-X                     -0.4443462 -0.459450 -0.376146
## tBodyAcc-max()-Y                     -0.3021403 -0.278236 -0.207048
## tBodyAcc-max()-Z                     -0.5963552 -0.600998 -0.589111
## tBodyAcc-min()-X                      0.5314817  0.515025  0.450079
## tBodyAcc-min()-Y                      0.3582429  0.395016  0.336416
## tBodyAcc-min()-Z                      0.6308375  0.711235  0.626296
## tBodyAcc-sma()                       -0.5625898 -0.578958 -0.477885
## tBodyAcc-energy()-X                  -0.8556830 -0.840810 -0.751051
## tBodyAcc-energy()-Y                  -0.9044520 -0.917417 -0.873787
## tBodyAcc-energy()-Z                  -0.9015952 -0.929177 -0.901032
## tBodyAcc-iqr()-X                     -0.7194459 -0.689998 -0.593892
## tBodyAcc-iqr()-Y                     -0.6047395 -0.640857 -0.575178
## tBodyAcc-iqr()-Z                     -0.6549244 -0.713205 -0.631187
## tBodyAcc-entropy()-X                 -0.0680340 -0.004187 -0.008583
## tBodyAcc-entropy()-Y                 -0.0593208 -0.048753 -0.046865
## tBodyAcc-entropy()-Z                 -0.1148250 -0.194791 -0.112474
## tBodyAcc-arCoeff()-X,1               -0.1427246 -0.132559 -0.192382
## tBodyAcc-arCoeff()-X,2                0.1575141  0.169480  0.177542
## tBodyAcc-arCoeff()-X,3               -0.0902556 -0.141781 -0.053325
## tBodyAcc-arCoeff()-X,4                0.1318968  0.138865  0.086513
## tBodyAcc-arCoeff()-Y,1               -0.0879714 -0.049422 -0.058073
## tBodyAcc-arCoeff()-Y,2                0.1053695  0.113311  0.086446
## tBodyAcc-arCoeff()-Y,3                0.0913272  0.037626  0.167500
## tBodyAcc-arCoeff()-Y,4               -0.0085261  0.043112 -0.045295
## tBodyAcc-arCoeff()-Z,1               -0.0740401 -0.007169 -0.077083
## tBodyAcc-arCoeff()-Z,2                0.0836291  0.044971  0.096724
## tBodyAcc-arCoeff()-Z,3                0.0439367 -0.043462  0.050653
## tBodyAcc-arCoeff()-Z,4               -0.1399456 -0.039543 -0.209385
## tBodyAcc-correlation()-X,Y           -0.1936811 -0.101112 -0.104840
## tBodyAcc-correlation()-X,Z           -0.2262186 -0.089433 -0.139099
## tBodyAcc-correlation()-Y,Z            0.1565443  0.053649  0.183329
## tGravityAcc-mean()-X                  0.7078144  0.706593  0.698154
## tGravityAcc-mean()-Y                 -0.0260590  0.112591  0.112313
## tGravityAcc-mean()-Z                  0.0480938  0.164131  0.092161
## tGravityAcc-std()-X                  -0.9664576 -0.962637 -0.964629
## tGravityAcc-std()-Y                  -0.9445645 -0.941417 -0.939974
## tGravityAcc-std()-Z                  -0.9269663 -0.941403 -0.942079
## tGravityAcc-mad()-X                  -0.9671226 -0.963925 -0.965895
## tGravityAcc-mad()-Y                  -0.9455889 -0.942243 -0.940654
## tGravityAcc-mad()-Z                  -0.9286447 -0.942727 -0.943781
## tGravityAcc-max()-X                   0.6465052  0.648488  0.639237
## tGravityAcc-max()-Y                  -0.0369805  0.097470  0.098509
## tGravityAcc-max()-Z                   0.0554612  0.167224  0.095746
## tGravityAcc-min()-X                   0.7217781  0.720207  0.712006
## tGravityAcc-min()-Y                  -0.0160869  0.118546  0.119259
## tGravityAcc-min()-Z                   0.0319191  0.151874  0.079786
## tGravityAcc-sma()                     0.0215614 -0.360027 -0.499615
## tGravityAcc-energy()-X                0.4709265  0.524695  0.533346
## tGravityAcc-energy()-Y               -0.6251852 -0.661572 -0.638780
## tGravityAcc-energy()-Z               -0.8773821 -0.927201 -0.959185
## tGravityAcc-iqr()-X                  -0.9689252 -0.967661 -0.969029
## tGravityAcc-iqr()-Y                  -0.9493121 -0.945717 -0.942997
## tGravityAcc-iqr()-Z                  -0.9342061 -0.947141 -0.949377
## tGravityAcc-entropy()-X              -0.6201210 -0.816339 -0.824563
## tGravityAcc-entropy()-Y              -0.8478722 -0.854582 -0.817221
## tGravityAcc-entropy()-Z              -0.7811662 -0.333855 -0.561295
## tGravityAcc-arCoeff()-X,1            -0.4938102 -0.469646 -0.470476
## tGravityAcc-arCoeff()-X,2             0.5337464  0.506190  0.508771
## tGravityAcc-arCoeff()-X,3            -0.5728136 -0.541717 -0.545940
## tGravityAcc-arCoeff()-X,4             0.6110549  0.576273  0.582023
## tGravityAcc-arCoeff()-Y,1            -0.3413480 -0.296402 -0.210634
## tGravityAcc-arCoeff()-Y,2             0.3349875  0.286764  0.213553
## tGravityAcc-arCoeff()-Y,3            -0.3732859 -0.324652 -0.270748
## tGravityAcc-arCoeff()-Y,4             0.4291475  0.381382  0.348956
## tGravityAcc-arCoeff()-Z,1            -0.4755016 -0.524554 -0.389687
## tGravityAcc-arCoeff()-Z,2             0.4942636  0.541406  0.406295
## tGravityAcc-arCoeff()-Z,3            -0.5124253 -0.557654 -0.421921
## tGravityAcc-arCoeff()-Z,4             0.5273037  0.570548  0.434066
## tGravityAcc-correlation()-X,Y         0.2505719 -0.078756  0.002550
## tGravityAcc-correlation()-X,Z        -0.0274413 -0.419459 -0.262668
## tGravityAcc-correlation()-Y,Z         0.0152072  0.128165  0.119310
## tBodyAccJerk-mean()-X                 0.0701731  0.078864  0.084102
## tBodyAccJerk-mean()-Y                 0.0144664  0.003513  0.001766
## tBodyAccJerk-mean()-Z                -0.0005268 -0.007374 -0.002954
## tBodyAccJerk-std()-X                 -0.6354847 -0.631853 -0.575891
## tBodyAccJerk-std()-Y                 -0.5572119 -0.584063 -0.506544
## tBodyAccJerk-std()-Z                 -0.7960662 -0.843353 -0.784562
## tBodyAccJerk-mad()-X                 -0.6392163 -0.627204 -0.559951
## tBodyAccJerk-mad()-Y                 -0.5443662 -0.567359 -0.486444
## tBodyAccJerk-mad()-Z                 -0.7904274 -0.830884 -0.776195
## tBodyAccJerk-max()-X                 -0.6775592 -0.707969 -0.644213
## tBodyAccJerk-max()-Y                 -0.7102356 -0.751736 -0.701800
## tBodyAccJerk-max()-Z                 -0.8383713 -0.892470 -0.817810
## tBodyAccJerk-min()-X                  0.6096506  0.613225  0.579126
## tBodyAccJerk-min()-Y                  0.6239812  0.655304  0.602436
## tBodyAccJerk-min()-Z                  0.7761994  0.829201  0.770623
## tBodyAccJerk-sma()                   -0.6462457 -0.662269 -0.591359
## tBodyAccJerk-energy()-X              -0.8630865 -0.865942 -0.819710
## tBodyAccJerk-energy()-Y              -0.8078022 -0.839283 -0.770924
## tBodyAccJerk-energy()-Z              -0.9571925 -0.975366 -0.953627
## tBodyAccJerk-iqr()-X                 -0.6487808 -0.621435 -0.516918
## tBodyAccJerk-iqr()-Y                 -0.6174925 -0.633820 -0.568817
## tBodyAccJerk-iqr()-Z                 -0.8013021 -0.824785 -0.781639
## tBodyAccJerk-entropy()-X              0.0173318  0.019878  0.027336
## tBodyAccJerk-entropy()-Y              0.0321639  0.065071  0.091318
## tBodyAccJerk-entropy()-Z             -0.0923626 -0.117386 -0.071721
## tBodyAccJerk-arCoeff()-X,1           -0.1264562 -0.104218 -0.166648
## tBodyAccJerk-arCoeff()-X,2            0.2165310  0.259076  0.191573
## tBodyAccJerk-arCoeff()-X,3            0.0700700  0.064319  0.107271
## tBodyAccJerk-arCoeff()-X,4            0.0752600  0.065878  0.061036
## tBodyAccJerk-arCoeff()-Y,1           -0.1251358 -0.099612 -0.126258
## tBodyAccJerk-arCoeff()-Y,2            0.1346020  0.185165  0.124127
## tBodyAccJerk-arCoeff()-Y,3            0.1853912  0.177129  0.207772
## tBodyAccJerk-arCoeff()-Y,4            0.2417037  0.213034  0.346346
## tBodyAccJerk-arCoeff()-Z,1           -0.0883132 -0.029284 -0.069280
## tBodyAccJerk-arCoeff()-Z,2            0.0993356  0.094598  0.126880
## tBodyAccJerk-arCoeff()-Z,3            0.0064978 -0.023139  0.060712
## tBodyAccJerk-arCoeff()-Z,4            0.1178900  0.042531  0.102540
## tBodyAccJerk-correlation()-X,Y       -0.1880526  0.027403 -0.041648
## tBodyAccJerk-correlation()-X,Z       -0.0507637  0.199960 -0.102734
## tBodyAccJerk-correlation()-Y,Z        0.0852182  0.120330  0.177155
## tBodyGyro-mean()-X                   -0.0248491 -0.028942 -0.029452
## tBodyGyro-mean()-Y                   -0.0743565 -0.078723 -0.077432
## tBodyGyro-mean()-Z                    0.0866875  0.095717  0.086627
## tBodyGyro-std()-X                    -0.6992622 -0.701398 -0.709956
## tBodyGyro-std()-Y                    -0.7630222 -0.798236 -0.705638
## tBodyGyro-std()-Z                    -0.7094834 -0.726374 -0.606590
## tBodyGyro-mad()-X                    -0.7055983 -0.706845 -0.713554
## tBodyGyro-mad()-Y                    -0.7742032 -0.792094 -0.719304
## tBodyGyro-mad()-Z                    -0.7243233 -0.742683 -0.643191
## tBodyGyro-max()-X                    -0.6161874 -0.645654 -0.636736
## tBodyGyro-max()-Y                    -0.7919266 -0.845547 -0.744945
## tBodyGyro-max()-Z                    -0.4950067 -0.522766 -0.338183
## tBodyGyro-min()-X                     0.6091030  0.605496  0.616339
## tBodyGyro-min()-Y                     0.7759393  0.812643  0.724611
## tBodyGyro-min()-Z                     0.5994142  0.601988  0.495157
## tBodyGyro-sma()                      -0.6451185 -0.659712 -0.600307
## tBodyGyro-energy()-X                 -0.8968211 -0.905527 -0.907089
## tBodyGyro-energy()-Y                 -0.9485005 -0.963931 -0.922584
## tBodyGyro-energy()-Z                 -0.9262066 -0.932624 -0.869480
## tBodyGyro-iqr()-X                    -0.7116487 -0.712165 -0.709760
## tBodyGyro-iqr()-Y                    -0.7961509 -0.783447 -0.743353
## tBodyGyro-iqr()-Z                    -0.7749381 -0.793887 -0.727867
## tBodyGyro-entropy()-X                -0.0816490 -0.060378 -0.082141
## tBodyGyro-entropy()-Y                -0.0568682 -0.023131 -0.006504
## tBodyGyro-entropy()-Z                -0.0018310  0.025079 -0.002573
## tBodyGyro-arCoeff()-X,1              -0.3220594 -0.250533 -0.278389
## tBodyGyro-arCoeff()-X,2               0.2563222  0.209839  0.240662
## tBodyGyro-arCoeff()-X,3               0.0430032 -0.020037  0.062642
## tBodyGyro-arCoeff()-X,4              -0.0899979  0.026003 -0.143217
## tBodyGyro-arCoeff()-Y,1              -0.2175135 -0.267118 -0.209183
## tBodyGyro-arCoeff()-Y,2               0.1768766  0.193641  0.231836
## tBodyGyro-arCoeff()-Y,3              -0.0383312 -0.163748 -0.105814
## tBodyGyro-arCoeff()-Y,4               0.1187272  0.294519  0.104665
## tBodyGyro-arCoeff()-Z,1              -0.1245539  0.008418 -0.105810
## tBodyGyro-arCoeff()-Z,2               0.1126400  0.039301  0.148222
## tBodyGyro-arCoeff()-Z,3              -0.0251658 -0.078354 -0.036889
## tBodyGyro-arCoeff()-Z,4               0.0972574  0.203645  0.112798
## tBodyGyro-correlation()-X,Y          -0.2438573 -0.228854 -0.057334
## tBodyGyro-correlation()-X,Z          -0.0292560  0.254637 -0.053962
## tBodyGyro-correlation()-Y,Z          -0.1300329 -0.057625 -0.109456
## tBodyGyroJerk-mean()-X               -0.0991555 -0.107859 -0.103523
## tBodyGyroJerk-mean()-Y               -0.0401924 -0.040043 -0.049062
## tBodyGyroJerk-mean()-Z               -0.0521178 -0.057809 -0.050626
## tBodyGyroJerk-std()-X                -0.6893284 -0.723789 -0.662581
## tBodyGyroJerk-std()-Y                -0.8426599 -0.902503 -0.774114
## tBodyGyroJerk-std()-Z                -0.7430285 -0.748369 -0.564681
## tBodyGyroJerk-mad()-X                -0.6866696 -0.716357 -0.656131
## tBodyGyroJerk-mad()-Y                -0.8522375 -0.904889 -0.786286
## tBodyGyroJerk-mad()-Z                -0.7532483 -0.758551 -0.589509
## tBodyGyroJerk-max()-X                -0.7156737 -0.749735 -0.688701
## tBodyGyroJerk-max()-Y                -0.8572735 -0.921676 -0.788706
## tBodyGyroJerk-max()-Z                -0.7364113 -0.751243 -0.531786
## tBodyGyroJerk-min()-X                 0.7113100  0.760163  0.709823
## tBodyGyroJerk-min()-Y                 0.8765429  0.926625  0.821496
## tBodyGyroJerk-min()-Z                 0.7967339  0.794703  0.650761
## tBodyGyroJerk-sma()                  -0.7844829 -0.820348 -0.705756
## tBodyGyroJerk-energy()-X             -0.9060808 -0.928207 -0.893403
## tBodyGyroJerk-energy()-Y             -0.9756118 -0.991444 -0.951999
## tBodyGyroJerk-energy()-Z             -0.9343458 -0.935659 -0.816227
## tBodyGyroJerk-iqr()-X                -0.6937932 -0.713226 -0.658771
## tBodyGyroJerk-iqr()-Y                -0.8655524 -0.908052 -0.800195
## tBodyGyroJerk-iqr()-Z                -0.7783472 -0.781238 -0.646003
## tBodyGyroJerk-entropy()-X             0.1097699  0.113645  0.160416
## tBodyGyroJerk-entropy()-Y             0.0995013  0.037651  0.148922
## tBodyGyroJerk-entropy()-Z             0.0602457  0.087664  0.146564
## tBodyGyroJerk-arCoeff()-X,1          -0.1556368 -0.092144 -0.105963
## tBodyGyroJerk-arCoeff()-X,2           0.1160466  0.108072  0.128687
## tBodyGyroJerk-arCoeff()-X,3           0.1706112  0.117129  0.225064
## tBodyGyroJerk-arCoeff()-X,4           0.0862830  0.043019  0.076778
## tBodyGyroJerk-arCoeff()-Y,1          -0.1683810 -0.218539 -0.163359
## tBodyGyroJerk-arCoeff()-Y,2           0.2030963  0.170564  0.301032
## tBodyGyroJerk-arCoeff()-Y,3           0.0947371 -0.022848  0.116405
## tBodyGyroJerk-arCoeff()-Y,4           0.0719234 -0.073502  0.072601
## tBodyGyroJerk-arCoeff()-Z,1          -0.0544720  0.080296 -0.068919
## tBodyGyroJerk-arCoeff()-Z,2           0.0882724  0.088864  0.159984
## tBodyGyroJerk-arCoeff()-Z,3           0.1327791  0.106459  0.125365
## tBodyGyroJerk-arCoeff()-Z,4          -0.0289132 -0.064114  0.038593
## tBodyGyroJerk-correlation()-X,Y       0.0140170 -0.083545  0.051912
## tBodyGyroJerk-correlation()-X,Z       0.0258444  0.335540  0.077862
## tBodyGyroJerk-correlation()-Y,Z      -0.1070258 -0.063391 -0.034019
## tBodyAccMag-mean()                   -0.5631408 -0.561582 -0.460866
## tBodyAccMag-std()                    -0.5912248 -0.606556 -0.521623
## tBodyAccMag-mad()                    -0.6520456 -0.645660 -0.572050
## tBodyAccMag-max()                    -0.5433486 -0.591655 -0.497989
## tBodyAccMag-min()                    -0.8503282 -0.849679 -0.804209
## tBodyAccMag-sma()                    -0.5631408 -0.561582 -0.460866
## tBodyAccMag-energy()                 -0.8135272 -0.816678 -0.718002
## tBodyAccMag-iqr()                    -0.7270321 -0.685019 -0.623837
## tBodyAccMag-entropy()                 0.2136775  0.235689  0.258741
## tBodyAccMag-arCoeff()1               -0.1078222 -0.076930 -0.102185
## tBodyAccMag-arCoeff()2                0.0538960  0.061809  0.050394
## tBodyAccMag-arCoeff()3                0.0566240 -0.012805  0.053124
## tBodyAccMag-arCoeff()4               -0.0629950 -0.045889 -0.063266
## tGravityAccMag-mean()                -0.5631408 -0.561582 -0.460866
## tGravityAccMag-std()                 -0.5912248 -0.606556 -0.521623
## tGravityAccMag-mad()                 -0.6520456 -0.645660 -0.572050
## tGravityAccMag-max()                 -0.5433486 -0.591655 -0.497989
## tGravityAccMag-min()                 -0.8503282 -0.849679 -0.804209
## tGravityAccMag-sma()                 -0.5631408 -0.561582 -0.460866
## tGravityAccMag-energy()              -0.8135272 -0.816678 -0.718002
## tGravityAccMag-iqr()                 -0.7270321 -0.685019 -0.623837
## tGravityAccMag-entropy()              0.2136775  0.235689  0.258741
## tGravityAccMag-arCoeff()1            -0.1078222 -0.076930 -0.102185
## tGravityAccMag-arCoeff()2             0.0538960  0.061809  0.050394
## tGravityAccMag-arCoeff()3             0.0566240 -0.012805  0.053124
## tGravityAccMag-arCoeff()4            -0.0629950 -0.045889 -0.063266
## tBodyAccJerkMag-mean()               -0.6501824 -0.656116 -0.589314
## tBodyAccJerkMag-std()                -0.6076582 -0.647250 -0.589031
## tBodyAccJerkMag-mad()                -0.6338601 -0.661834 -0.610038
## tBodyAccJerkMag-max()                -0.6119104 -0.669653 -0.600535
## tBodyAccJerkMag-min()                -0.7868341 -0.775845 -0.743241
## tBodyAccJerkMag-sma()                -0.6501824 -0.656116 -0.589314
## tBodyAccJerkMag-energy()             -0.8639138 -0.880892 -0.831005
## tBodyAccJerkMag-iqr()                -0.6971162 -0.713528 -0.671531
## tBodyAccJerkMag-entropy()             0.0261101  0.033736  0.076779
## tBodyAccJerkMag-arCoeff()1            0.0502119  0.070119  0.045649
## tBodyAccJerkMag-arCoeff()2           -0.0466331 -0.036673  0.011368
## tBodyAccJerkMag-arCoeff()3           -0.0665679 -0.100277 -0.114345
## tBodyAccJerkMag-arCoeff()4            0.0040782 -0.004905 -0.031322
## tBodyGyroMag-mean()                  -0.6431501 -0.656291 -0.602770
## tBodyGyroMag-std()                   -0.6740103 -0.706738 -0.664078
## tBodyGyroMag-mad()                   -0.6455311 -0.675908 -0.634946
## tBodyGyroMag-max()                   -0.7080878 -0.740227 -0.688205
## tBodyGyroMag-min()                   -0.7728262 -0.739555 -0.743858
## tBodyGyroMag-sma()                   -0.6431501 -0.656291 -0.602770
## tBodyGyroMag-energy()                -0.8779375 -0.894229 -0.858704
## tBodyGyroMag-iqr()                   -0.6800151 -0.696915 -0.660579
## tBodyGyroMag-entropy()                0.4210445  0.493792  0.404536
## tBodyGyroMag-arCoeff()1              -0.0899246 -0.090098  0.080068
## tBodyGyroMag-arCoeff()2              -0.0002643 -0.014334 -0.141135
## tBodyGyroMag-arCoeff()3               0.0680683  0.027028  0.133752
## tBodyGyroMag-arCoeff()4              -0.0535119  0.057931 -0.097746
## tBodyGyroJerkMag-mean()              -0.7840567 -0.819191 -0.707384
## tBodyGyroJerkMag-std()               -0.8036614 -0.844187 -0.734187
## tBodyGyroJerkMag-mad()               -0.8125069 -0.852587 -0.745123
## tBodyGyroJerkMag-max()               -0.8133191 -0.847669 -0.753266
## tBodyGyroJerkMag-min()               -0.8324934 -0.844932 -0.757807
## tBodyGyroJerkMag-sma()               -0.7840567 -0.819191 -0.707384
## tBodyGyroJerkMag-energy()            -0.9554803 -0.970701 -0.921197
## tBodyGyroJerkMag-iqr()               -0.8174376 -0.857256 -0.750535
## tBodyGyroJerkMag-entropy()            0.2364157  0.214533  0.325141
## tBodyGyroJerkMag-arCoeff()1           0.2415473  0.312886  0.260678
## tBodyGyroJerkMag-arCoeff()2          -0.1710737 -0.220025 -0.249912
## tBodyGyroJerkMag-arCoeff()3          -0.0880311 -0.073147 -0.142498
## tBodyGyroJerkMag-arCoeff()4          -0.1211691 -0.140723  0.053265
## fBodyAcc-mean()-X                    -0.6257333 -0.628806 -0.551238
## fBodyAcc-mean()-Y                    -0.5017799 -0.525835 -0.440232
## fBodyAcc-mean()-Z                    -0.6996568 -0.755235 -0.696172
## fBodyAcc-std()-X                     -0.6238050 -0.597551 -0.492830
## fBodyAcc-std()-Y                     -0.5027536 -0.534662 -0.422162
## fBodyAcc-std()-Z                     -0.6574438 -0.708764 -0.649351
## fBodyAcc-mad()-X                     -0.6036193 -0.608417 -0.502469
## fBodyAcc-mad()-Y                     -0.4986090 -0.530593 -0.405336
## fBodyAcc-mad()-Z                     -0.6621005 -0.729897 -0.663625
## fBodyAcc-max()-X                     -0.6659116 -0.622419 -0.524835
## fBodyAcc-max()-Y                     -0.6163363 -0.649429 -0.592576
## fBodyAcc-max()-Z                     -0.6848244 -0.710674 -0.644075
## fBodyAcc-min()-X                     -0.8527408 -0.857905 -0.820791
## fBodyAcc-min()-Y                     -0.8762162 -0.862582 -0.856351
## fBodyAcc-min()-Z                     -0.9284101 -0.927970 -0.925171
## fBodyAcc-sma()                       -0.5575222 -0.585279 -0.499405
## fBodyAcc-energy()-X                  -0.8560589 -0.841063 -0.751216
## fBodyAcc-energy()-Y                  -0.7566021 -0.789976 -0.676435
## fBodyAcc-energy()-Z                  -0.8919029 -0.923734 -0.890286
## fBodyAcc-iqr()-X                     -0.6232551 -0.657495 -0.586286
## fBodyAcc-iqr()-Y                     -0.6047689 -0.620777 -0.576600
## fBodyAcc-iqr()-Z                     -0.7680333 -0.822789 -0.744964
## fBodyAcc-entropy()-X                 -0.1165227 -0.134652 -0.095115
## fBodyAcc-entropy()-Y                 -0.0812331 -0.068134 -0.065078
## fBodyAcc-entropy()-Z                 -0.1694778 -0.219824 -0.150360
## fBodyAcc-maxInds-X                   -0.7612336 -0.767579 -0.737236
## fBodyAcc-maxInds-Y                   -0.7913978 -0.764458 -0.679029
## fBodyAcc-maxInds-Z                   -0.8786375 -0.903664 -0.911615
## fBodyAcc-meanFreq()-X                -0.1928173 -0.184519 -0.226371
## fBodyAcc-meanFreq()-Y                 0.0389283  0.084771  0.074864
## fBodyAcc-meanFreq()-Z                 0.0044726 -0.016410  0.006266
## fBodyAcc-skewness()-X                -0.1955569 -0.009525 -0.102768
## fBodyAcc-kurtosis()-X                -0.5287640 -0.315237 -0.422860
## fBodyAcc-skewness()-Y                -0.2864456 -0.293714 -0.363280
## fBodyAcc-kurtosis()-Y                -0.6018682 -0.596248 -0.677247
## fBodyAcc-skewness()-Z                -0.3074474 -0.104251 -0.121441
## fBodyAcc-kurtosis()-Z                -0.5571561 -0.343442 -0.335103
## fBodyAcc-bandsEnergy()-1,8           -0.8518146 -0.826483 -0.723325
## fBodyAcc-bandsEnergy()-9,16          -0.9143440 -0.919298 -0.866760
## fBodyAcc-bandsEnergy()-17,24         -0.8369149 -0.880475 -0.834928
## fBodyAcc-bandsEnergy()-25,32         -0.9002601 -0.855004 -0.909981
## fBodyAcc-bandsEnergy()-33,40         -0.9220016 -0.916685 -0.913734
## fBodyAcc-bandsEnergy()-41,48         -0.9191711 -0.920615 -0.896960
## fBodyAcc-bandsEnergy()-49,56         -0.9513667 -0.950373 -0.942543
## fBodyAcc-bandsEnergy()-57,64         -0.9660444 -0.958977 -0.944947
## fBodyAcc-bandsEnergy()-1,16          -0.8564654 -0.837698 -0.739864
## fBodyAcc-bandsEnergy()-17,32         -0.8302930 -0.854161 -0.831490
## fBodyAcc-bandsEnergy()-33,48         -0.9209550 -0.918173 -0.907461
## fBodyAcc-bandsEnergy()-49,64         -0.9562862 -0.953257 -0.943349
## fBodyAcc-bandsEnergy()-1,24          -0.8550774 -0.840740 -0.746622
## fBodyAcc-bandsEnergy()-25,48         -0.8907879 -0.857144 -0.891236
## fBodyAcc-bandsEnergy()-1,8.1         -0.7873669 -0.820043 -0.769598
## fBodyAcc-bandsEnergy()-9,16.1        -0.8860365 -0.878339 -0.713416
## fBodyAcc-bandsEnergy()-17,24.1       -0.7881268 -0.879095 -0.843733
## fBodyAcc-bandsEnergy()-25,32.1       -0.8853860 -0.862001 -0.918783
## fBodyAcc-bandsEnergy()-33,40.1       -0.8955059 -0.895655 -0.907327
## fBodyAcc-bandsEnergy()-41,48.1       -0.8853501 -0.890056 -0.871299
## fBodyAcc-bandsEnergy()-49,56.1       -0.8989570 -0.907962 -0.883975
## fBodyAcc-bandsEnergy()-57,64.1       -0.9499612 -0.951284 -0.940295
## fBodyAcc-bandsEnergy()-1,16.1        -0.7784582 -0.799536 -0.676037
## fBodyAcc-bandsEnergy()-17,32.1       -0.7621474 -0.843290 -0.825533
## fBodyAcc-bandsEnergy()-33,48.1       -0.8796593 -0.881574 -0.882909
## fBodyAcc-bandsEnergy()-49,64.1       -0.9172000 -0.923256 -0.903974
## fBodyAcc-bandsEnergy()-1,24.1        -0.7601674 -0.795475 -0.676374
## fBodyAcc-bandsEnergy()-25,48.1       -0.8777895 -0.861084 -0.903509
## fBodyAcc-bandsEnergy()-1,8.2         -0.9006947 -0.922733 -0.903665
## fBodyAcc-bandsEnergy()-9,16.2        -0.9370317 -0.963798 -0.929901
## fBodyAcc-bandsEnergy()-17,24.2       -0.9477486 -0.980336 -0.940870
## fBodyAcc-bandsEnergy()-25,32.2       -0.9812675 -0.982252 -0.978193
## fBodyAcc-bandsEnergy()-33,40.2       -0.9799213 -0.985578 -0.982915
## fBodyAcc-bandsEnergy()-41,48.2       -0.9687259 -0.974025 -0.964601
## fBodyAcc-bandsEnergy()-49,56.2       -0.9664408 -0.975353 -0.966164
## fBodyAcc-bandsEnergy()-57,64.2       -0.9728722 -0.979257 -0.975029
## fBodyAcc-bandsEnergy()-1,16.2        -0.9003411 -0.926590 -0.900416
## fBodyAcc-bandsEnergy()-17,32.2       -0.9599237 -0.981063 -0.954423
## fBodyAcc-bandsEnergy()-33,48.2       -0.9756300 -0.981595 -0.976984
## fBodyAcc-bandsEnergy()-49,64.2       -0.9680927 -0.976323 -0.968544
## fBodyAcc-bandsEnergy()-1,24.2        -0.8930622 -0.925145 -0.891706
## fBodyAcc-bandsEnergy()-25,48.2       -0.9796765 -0.982081 -0.977865
## fBodyAccJerk-mean()-X                -0.6458935 -0.652023 -0.604770
## fBodyAccJerk-mean()-Y                -0.5829499 -0.601696 -0.550992
## fBodyAccJerk-mean()-Z                -0.7801016 -0.825155 -0.768762
## fBodyAccJerk-std()-X                 -0.6578441 -0.644622 -0.584014
## fBodyAccJerk-std()-Y                 -0.5598512 -0.593855 -0.491500
## fBodyAccJerk-std()-Z                 -0.8108060 -0.860545 -0.798836
## fBodyAccJerk-mad()-X                 -0.5838791 -0.587196 -0.522800
## fBodyAccJerk-mad()-Y                 -0.5700708 -0.598458 -0.518116
## fBodyAccJerk-mad()-Z                 -0.7972519 -0.844726 -0.783870
## fBodyAccJerk-max()-X                 -0.7285006 -0.695505 -0.640999
## fBodyAccJerk-max()-Y                 -0.6501114 -0.676830 -0.580834
## fBodyAccJerk-max()-Z                 -0.8292448 -0.881499 -0.819366
## fBodyAccJerk-min()-X                 -0.8896579 -0.894141 -0.867541
## fBodyAccJerk-min()-Y                 -0.8576668 -0.853984 -0.847715
## fBodyAccJerk-min()-Z                 -0.8970129 -0.915755 -0.890595
## fBodyAccJerk-sma()                   -0.6140058 -0.640438 -0.579840
## fBodyAccJerk-energy()-X              -0.8629092 -0.865782 -0.819500
## fBodyAccJerk-energy()-Y              -0.8078873 -0.839358 -0.771039
## fBodyAccJerk-energy()-Z              -0.9572115 -0.975382 -0.953641
## fBodyAccJerk-iqr()-X                 -0.6070549 -0.627028 -0.587798
## fBodyAccJerk-iqr()-Y                 -0.6752318 -0.690599 -0.669791
## fBodyAccJerk-iqr()-Z                 -0.8037626 -0.839877 -0.792505
## fBodyAccJerk-entropy()-X             -0.1893567 -0.199566 -0.155396
## fBodyAccJerk-entropy()-Y             -0.1600294 -0.147375 -0.117679
## fBodyAccJerk-entropy()-Z             -0.3574231 -0.423895 -0.323917
## fBodyAccJerk-maxInds-X               -0.3787683 -0.342461 -0.423576
## fBodyAccJerk-maxInds-Y               -0.3878006 -0.317350 -0.374040
## fBodyAccJerk-maxInds-Z               -0.3414663 -0.275962 -0.285298
## fBodyAccJerk-meanFreq()-X            -0.0476941 -0.000544 -0.102921
## fBodyAccJerk-meanFreq()-Y            -0.2368742 -0.180584 -0.274291
## fBodyAccJerk-meanFreq()-Z            -0.1936575 -0.110566 -0.163706
## fBodyAccJerk-skewness()-X            -0.3614457 -0.270710 -0.245687
## fBodyAccJerk-kurtosis()-X            -0.7569571 -0.682045 -0.668283
## fBodyAccJerk-skewness()-Y            -0.3868707 -0.413090 -0.322777
## fBodyAccJerk-kurtosis()-Y            -0.8236655 -0.841271 -0.788872
## fBodyAccJerk-skewness()-Z            -0.4779613 -0.552512 -0.459218
## fBodyAccJerk-kurtosis()-Z            -0.8127951 -0.861465 -0.807638
## fBodyAccJerk-bandsEnergy()-1,8       -0.8979155 -0.889307 -0.811200
## fBodyAccJerk-bandsEnergy()-9,16      -0.9084442 -0.914434 -0.853225
## fBodyAccJerk-bandsEnergy()-17,24     -0.8550791 -0.889556 -0.854448
## fBodyAccJerk-bandsEnergy()-25,32     -0.9027929 -0.854635 -0.919137
## fBodyAccJerk-bandsEnergy()-33,40     -0.9259287 -0.924879 -0.927879
## fBodyAccJerk-bandsEnergy()-41,48     -0.9063692 -0.912788 -0.889139
## fBodyAccJerk-bandsEnergy()-49,56     -0.9451557 -0.952479 -0.947471
## fBodyAccJerk-bandsEnergy()-57,64     -0.9874221 -0.988437 -0.984032
## fBodyAccJerk-bandsEnergy()-1,16      -0.8956977 -0.895692 -0.821556
## fBodyAccJerk-bandsEnergy()-17,32     -0.8422528 -0.848432 -0.848940
## fBodyAccJerk-bandsEnergy()-33,48     -0.9117272 -0.913664 -0.905946
## fBodyAccJerk-bandsEnergy()-49,64     -0.9436739 -0.951066 -0.945294
## fBodyAccJerk-bandsEnergy()-1,24      -0.8608925 -0.874160 -0.801422
## fBodyAccJerk-bandsEnergy()-25,48     -0.8689266 -0.834675 -0.877108
## fBodyAccJerk-bandsEnergy()-1,8.1     -0.8289587 -0.841216 -0.776537
## fBodyAccJerk-bandsEnergy()-9,16.1    -0.8988169 -0.897549 -0.765985
## fBodyAccJerk-bandsEnergy()-17,24.1   -0.7461500 -0.852163 -0.823052
## fBodyAccJerk-bandsEnergy()-25,32.1   -0.8875442 -0.866611 -0.926673
## fBodyAccJerk-bandsEnergy()-33,40.1   -0.9145560 -0.916001 -0.927951
## fBodyAccJerk-bandsEnergy()-41,48.1   -0.8809170 -0.889704 -0.871391
## fBodyAccJerk-bandsEnergy()-49,56.1   -0.9207138 -0.931282 -0.911673
## fBodyAccJerk-bandsEnergy()-57,64.1   -0.9674904 -0.971317 -0.974790
## fBodyAccJerk-bandsEnergy()-1,16.1    -0.8679697 -0.869706 -0.735164
## fBodyAccJerk-bandsEnergy()-17,32.1   -0.7617518 -0.829242 -0.836316
## fBodyAccJerk-bandsEnergy()-33,48.1   -0.8796792 -0.884608 -0.886508
## fBodyAccJerk-bandsEnergy()-49,64.1   -0.9266187 -0.936336 -0.919639
## fBodyAccJerk-bandsEnergy()-1,24.1    -0.7921850 -0.840131 -0.729451
## fBodyAccJerk-bandsEnergy()-25,48.1   -0.8830189 -0.871787 -0.910206
## fBodyAccJerk-bandsEnergy()-1,8.2     -0.9459128 -0.957128 -0.954819
## fBodyAccJerk-bandsEnergy()-9,16.2    -0.9316447 -0.966216 -0.926905
## fBodyAccJerk-bandsEnergy()-17,24.2   -0.9519745 -0.981089 -0.943812
## fBodyAccJerk-bandsEnergy()-25,32.2   -0.9820222 -0.982910 -0.979707
## fBodyAccJerk-bandsEnergy()-33,40.2   -0.9826500 -0.987474 -0.984873
## fBodyAccJerk-bandsEnergy()-41,48.2   -0.9718310 -0.976703 -0.966619
## fBodyAccJerk-bandsEnergy()-49,56.2   -0.9611130 -0.974136 -0.959717
## fBodyAccJerk-bandsEnergy()-57,64.2   -0.9799019 -0.989630 -0.982585
## fBodyAccJerk-bandsEnergy()-1,16.2    -0.9223406 -0.955904 -0.921448
## fBodyAccJerk-bandsEnergy()-17,32.2   -0.9666947 -0.982009 -0.961391
## fBodyAccJerk-bandsEnergy()-33,48.2   -0.9782255 -0.983388 -0.978350
## fBodyAccJerk-bandsEnergy()-49,64.2   -0.9608003 -0.974272 -0.959783
## fBodyAccJerk-bandsEnergy()-1,24.2    -0.9326972 -0.967531 -0.926708
## fBodyAccJerk-bandsEnergy()-25,48.2   -0.9805565 -0.983123 -0.979200
## fBodyGyro-mean()-X                   -0.6420977 -0.641882 -0.632239
## fBodyGyro-mean()-Y                   -0.7751450 -0.831528 -0.717062
## fBodyGyro-mean()-Z                   -0.6707347 -0.689309 -0.537329
## fBodyGyro-std()-X                    -0.7192766 -0.721749 -0.735739
## fBodyGyro-std()-Y                    -0.7585053 -0.782886 -0.702290
## fBodyGyro-std()-Z                    -0.7510089 -0.767090 -0.669354
## fBodyGyro-mad()-X                    -0.6623521 -0.667310 -0.662477
## fBodyGyro-mad()-Y                    -0.7788703 -0.826639 -0.726736
## fBodyGyro-mad()-Z                    -0.6767985 -0.719531 -0.559209
## fBodyGyro-max()-X                    -0.7038832 -0.724948 -0.737188
## fBodyGyro-max()-Y                    -0.8122733 -0.811565 -0.754664
## fBodyGyro-max()-Z                    -0.8384238 -0.829351 -0.779593
## fBodyGyro-min()-X                    -0.9271060 -0.925759 -0.917975
## fBodyGyro-min()-Y                    -0.9226709 -0.942606 -0.917375
## fBodyGyro-min()-Z                    -0.9197222 -0.922588 -0.880283
## fBodyGyro-sma()                      -0.6873029 -0.717568 -0.624883
## fBodyGyro-energy()-X                 -0.9099330 -0.917055 -0.923942
## fBodyGyro-energy()-Y                 -0.9506823 -0.964597 -0.922863
## fBodyGyro-energy()-Z                 -0.9269000 -0.932935 -0.863322
## fBodyGyro-iqr()-X                    -0.6369505 -0.678621 -0.616997
## fBodyGyro-iqr()-Y                    -0.8090894 -0.882633 -0.739559
## fBodyGyro-iqr()-Z                    -0.6753618 -0.723663 -0.517814
## fBodyGyro-entropy()-X                 0.0072611  0.032083  0.044274
## fBodyGyro-entropy()-Y                -0.0212123 -0.086955  0.065781
## fBodyGyro-entropy()-Z                -0.0608138 -0.037222  0.039449
## fBodyGyro-maxInds-X                  -0.8787879 -0.931441 -0.859161
## fBodyGyro-maxInds-Y                  -0.8227225 -0.899664 -0.850459
## fBodyGyro-maxInds-Z                  -0.8013955 -0.854672 -0.629367
## fBodyGyro-meanFreq()-X               -0.1025681 -0.118518 -0.038165
## fBodyGyro-meanFreq()-Y               -0.1676750 -0.375333 -0.072067
## fBodyGyro-meanFreq()-Z               -0.0321863  0.024189  0.074403
## fBodyGyro-skewness()-X               -0.1974708 -0.136617 -0.243947
## fBodyGyro-kurtosis()-X               -0.5083284 -0.462754 -0.550488
## fBodyGyro-skewness()-Y               -0.2476932 -0.017120 -0.205543
## fBodyGyro-kurtosis()-Y               -0.6255208 -0.387829 -0.537486
## fBodyGyro-skewness()-Z               -0.3142071 -0.234441 -0.357614
## fBodyGyro-kurtosis()-Z               -0.6375102 -0.551309 -0.663122
## fBodyGyro-bandsEnergy()-1,8          -0.9247616 -0.925692 -0.943562
## fBodyGyro-bandsEnergy()-9,16         -0.9158910 -0.937698 -0.899530
## fBodyGyro-bandsEnergy()-17,24        -0.8746497 -0.933484 -0.859238
## fBodyGyro-bandsEnergy()-25,32        -0.9485838 -0.952977 -0.948428
## fBodyGyro-bandsEnergy()-33,40        -0.9610227 -0.947516 -0.956118
## fBodyGyro-bandsEnergy()-41,48        -0.9613729 -0.953292 -0.953424
## fBodyGyro-bandsEnergy()-49,56        -0.9682874 -0.964568 -0.959803
## fBodyGyro-bandsEnergy()-57,64        -0.9780164 -0.972252 -0.971946
## fBodyGyro-bandsEnergy()-1,16         -0.9168949 -0.920956 -0.932201
## fBodyGyro-bandsEnergy()-17,32        -0.8781994 -0.927315 -0.865740
## fBodyGyro-bandsEnergy()-33,48        -0.9572470 -0.944591 -0.950609
## fBodyGyro-bandsEnergy()-49,64        -0.9725923 -0.967968 -0.965176
## fBodyGyro-bandsEnergy()-1,24         -0.9114785 -0.918682 -0.925681
## fBodyGyro-bandsEnergy()-25,48        -0.9505239 -0.950044 -0.948495
## fBodyGyro-bandsEnergy()-1,8.1        -0.9475262 -0.947678 -0.929946
## fBodyGyro-bandsEnergy()-9,16.1       -0.9791801 -0.993401 -0.965811
## fBodyGyro-bandsEnergy()-17,24.1      -0.9848720 -0.996717 -0.964887
## fBodyGyro-bandsEnergy()-25,32.1      -0.9894243 -0.994301 -0.976356
## fBodyGyro-bandsEnergy()-33,40.1      -0.9909941 -0.995347 -0.986320
## fBodyGyro-bandsEnergy()-41,48.1      -0.9813843 -0.991552 -0.973939
## fBodyGyro-bandsEnergy()-49,56.1      -0.9785380 -0.989948 -0.968404
## fBodyGyro-bandsEnergy()-57,64.1      -0.9890699 -0.992608 -0.985698
## fBodyGyro-bandsEnergy()-1,16.1       -0.9511282 -0.960479 -0.930596
## fBodyGyro-bandsEnergy()-17,32.1      -0.9826459 -0.995204 -0.959993
## fBodyGyro-bandsEnergy()-33,48.1      -0.9889289 -0.994521 -0.983638
## fBodyGyro-bandsEnergy()-49,64.1      -0.9801809 -0.989733 -0.971598
## fBodyGyro-bandsEnergy()-1,24.1       -0.9473592 -0.961734 -0.918692
## fBodyGyro-bandsEnergy()-25,48.1      -0.9884492 -0.993928 -0.976807
## fBodyGyro-bandsEnergy()-1,8.2        -0.9524382 -0.950108 -0.949407
## fBodyGyro-bandsEnergy()-9,16.2       -0.9548257 -0.973482 -0.845307
## fBodyGyro-bandsEnergy()-17,24.2      -0.9206350 -0.961919 -0.769358
## fBodyGyro-bandsEnergy()-25,32.2      -0.9757107 -0.937362 -0.931937
## fBodyGyro-bandsEnergy()-33,40.2      -0.9828065 -0.951265 -0.959580
## fBodyGyro-bandsEnergy()-41,48.2      -0.9708907 -0.948449 -0.940585
## fBodyGyro-bandsEnergy()-49,56.2      -0.9667090 -0.960812 -0.921005
## fBodyGyro-bandsEnergy()-57,64.2      -0.9816324 -0.986372 -0.962678
## fBodyGyro-bandsEnergy()-1,16.2       -0.9396198 -0.943652 -0.900050
## fBodyGyro-bandsEnergy()-17,32.2      -0.9125634 -0.933368 -0.747118
## fBodyGyro-bandsEnergy()-33,48.2      -0.9795396 -0.950340 -0.954323
## fBodyGyro-bandsEnergy()-49,64.2      -0.9731974 -0.971924 -0.939123
## fBodyGyro-bandsEnergy()-1,24.2       -0.9292415 -0.938802 -0.869531
## fBodyGyro-bandsEnergy()-25,48.2      -0.9769006 -0.941390 -0.938885
## fBodyAccMag-mean()                   -0.5790765 -0.602098 -0.528503
## fBodyAccMag-std()                    -0.6630798 -0.672948 -0.594260
## fBodyAccMag-mad()                    -0.5896039 -0.618278 -0.530360
## fBodyAccMag-max()                    -0.7669879 -0.753482 -0.699303
## fBodyAccMag-min()                    -0.8958252 -0.888435 -0.883318
## fBodyAccMag-sma()                    -0.5790765 -0.602098 -0.528503
## fBodyAccMag-energy()                 -0.8464951 -0.854811 -0.782520
## fBodyAccMag-iqr()                    -0.6798927 -0.706799 -0.653257
## fBodyAccMag-entropy()                -0.1126862 -0.130314 -0.084712
## fBodyAccMag-maxInds                  -0.7087673 -0.736756 -0.687143
## fBodyAccMag-meanFreq()                0.0770666  0.096364  0.078146
## fBodyAccMag-skewness()               -0.3951285 -0.303683 -0.346154
## fBodyAccMag-kurtosis()               -0.6720932 -0.583167 -0.622500
## fBodyBodyAccJerkMag-mean()           -0.6047521 -0.635019 -0.573176
## fBodyBodyAccJerkMag-std()            -0.6156437 -0.666507 -0.613485
## fBodyBodyAccJerkMag-mad()            -0.5897369 -0.637586 -0.575032
## fBodyBodyAccJerkMag-max()            -0.6585056 -0.702723 -0.659971
## fBodyBodyAccJerkMag-min()            -0.8073908 -0.788321 -0.784904
## fBodyBodyAccJerkMag-sma()            -0.6047521 -0.635019 -0.573176
## fBodyBodyAccJerkMag-energy()         -0.8431968 -0.880604 -0.836020
## fBodyBodyAccJerkMag-iqr()            -0.6601994 -0.687863 -0.634846
## fBodyBodyAccJerkMag-entropy()        -0.2757144 -0.290580 -0.232148
## fBodyBodyAccJerkMag-maxInds          -0.8855839 -0.898152 -0.896037
## fBodyBodyAccJerkMag-meanFreq()        0.1123198  0.160480  0.131619
## fBodyBodyAccJerkMag-skewness()       -0.2526987 -0.252621 -0.262185
## fBodyBodyAccJerkMag-kurtosis()       -0.5617766 -0.562304 -0.584574
## fBodyBodyGyroMag-mean()              -0.7168221 -0.745651 -0.677356
## fBodyBodyGyroMag-std()               -0.7038394 -0.732586 -0.715731
## fBodyBodyGyroMag-mad()               -0.6847773 -0.723467 -0.680898
## fBodyBodyGyroMag-max()               -0.7359480 -0.761139 -0.759488
## fBodyBodyGyroMag-min()               -0.9083264 -0.901723 -0.882877
## fBodyBodyGyroMag-sma()               -0.7168221 -0.745651 -0.677356
## fBodyBodyGyroMag-energy()            -0.8991329 -0.923320 -0.904093
## fBodyBodyGyroMag-iqr()               -0.7205791 -0.774379 -0.682794
## fBodyBodyGyroMag-entropy()           -0.0166017 -0.029491  0.042676
## fBodyBodyGyroMag-maxInds             -0.9057072 -0.901966 -0.876040
## fBodyBodyGyroMag-meanFreq()          -0.0846075 -0.129302  0.062219
## fBodyBodyGyroMag-skewness()          -0.2636954 -0.187310 -0.335160
## fBodyBodyGyroMag-kurtosis()          -0.5775429 -0.527797 -0.628709
## fBodyBodyGyroJerkMag-mean()          -0.8100855 -0.838833 -0.748829
## fBodyBodyGyroJerkMag-std()           -0.8100327 -0.863097 -0.735611
## fBodyBodyGyroJerkMag-mad()           -0.8017018 -0.845168 -0.730623
## fBodyBodyGyroJerkMag-max()           -0.8166815 -0.875672 -0.738844
## fBodyBodyGyroJerkMag-min()           -0.8926698 -0.900226 -0.858866
## fBodyBodyGyroJerkMag-sma()           -0.8100855 -0.838833 -0.748829
## fBodyBodyGyroJerkMag-energy()        -0.9626671 -0.977247 -0.934083
## fBodyBodyGyroJerkMag-iqr()           -0.8047645 -0.832872 -0.749637
## fBodyBodyGyroJerkMag-entropy()       -0.2397449 -0.281515 -0.137702
## fBodyBodyGyroJerkMag-maxInds         -0.9278499 -0.915778 -0.915589
## fBodyBodyGyroJerkMag-meanFreq()       0.0599629  0.159076  0.030756
## fBodyBodyGyroJerkMag-skewness()      -0.1826772 -0.315186 -0.114361
## fBodyBodyGyroJerkMag-kurtosis()      -0.5007184 -0.624502 -0.453200
## angle(tBodyAccMean,gravity)           0.0140944  0.008033 -0.009112
## angle(tBodyAccJerkMean),gravityMean)  0.0134500 -0.011145 -0.015217
## angle(tBodyGyroMean,gravityMean)      0.0359008  0.027081 -0.009531
## angle(tBodyGyroJerkMean,gravityMean) -0.0192075  0.011778 -0.023395
## angle(X,gravityMean)                 -0.5033234 -0.576544 -0.598121
## angle(Y,gravityMean)                  0.0756263 -0.032363 -0.037873
## angle(Z,gravityMean)                 -0.0174902 -0.095462 -0.044082
##                                       subject_6 subject_7  subject_8
## tBodyAcc-mean()-X                     0.2723766  0.270212  0.2707591
## tBodyAcc-mean()-Y                    -0.0175697 -0.018790 -0.0181895
## tBodyAcc-mean()-Z                    -0.1159945 -0.112492 -0.1068096
## tBodyAcc-std()-X                     -0.5050861 -0.577518 -0.5829589
## tBodyAcc-std()-Y                     -0.3684037 -0.546403 -0.3493837
## tBodyAcc-std()-Z                     -0.6725120 -0.456474 -0.4994727
## tBodyAcc-mad()-X                     -0.5401183 -0.602693 -0.6084030
## tBodyAcc-mad()-Y                     -0.3955144 -0.570104 -0.3748586
## tBodyAcc-mad()-Z                     -0.6748390 -0.463887 -0.4998171
## tBodyAcc-max()-X                     -0.3444511 -0.422927 -0.4583838
## tBodyAcc-max()-Y                     -0.2124453 -0.348847 -0.1981282
## tBodyAcc-max()-Z                     -0.5768833 -0.554703 -0.4982579
## tBodyAcc-min()-X                      0.4274622  0.553353  0.4716853
## tBodyAcc-min()-Y                      0.2825345  0.395843  0.2656691
## tBodyAcc-min()-Z                      0.6136228  0.445941  0.5286471
## tBodyAcc-sma()                       -0.4809411 -0.506037 -0.4668954
## tBodyAcc-energy()-X                  -0.7386971 -0.823076 -0.8160053
## tBodyAcc-energy()-Y                  -0.8540937 -0.926626 -0.8329362
## tBodyAcc-energy()-Z                  -0.9081052 -0.755711 -0.7655229
## tBodyAcc-iqr()-X                     -0.6163907 -0.671113 -0.6528485
## tBodyAcc-iqr()-Y                     -0.5666940 -0.701799 -0.5248775
## tBodyAcc-iqr()-Z                     -0.6880434 -0.524368 -0.5358250
## tBodyAcc-entropy()-X                 -0.0707471 -0.087228 -0.0682573
## tBodyAcc-entropy()-Y                 -0.0189952 -0.076088 -0.1349823
## tBodyAcc-entropy()-Z                 -0.1524657 -0.009511 -0.1437327
## tBodyAcc-arCoeff()-X,1               -0.1681021 -0.188167 -0.0900804
## tBodyAcc-arCoeff()-X,2                0.1776199  0.132835  0.0976978
## tBodyAcc-arCoeff()-X,3               -0.0301235 -0.057424 -0.0689634
## tBodyAcc-arCoeff()-X,4                0.0836560  0.166011  0.1403050
## tBodyAcc-arCoeff()-Y,1               -0.0900332 -0.065447  0.0058195
## tBodyAcc-arCoeff()-Y,2                0.0874170  0.052416 -0.0029598
## tBodyAcc-arCoeff()-Y,3                0.2299787  0.150397  0.1743947
## tBodyAcc-arCoeff()-Y,4               -0.1357793 -0.047606 -0.0178807
## tBodyAcc-arCoeff()-Z,1                0.0219830 -0.096484  0.0448233
## tBodyAcc-arCoeff()-Z,2                0.0532337  0.100315  0.0167991
## tBodyAcc-arCoeff()-Z,3                0.0858981  0.009142  0.0457101
## tBodyAcc-arCoeff()-Z,4               -0.1763673 -0.065568 -0.0806902
## tBodyAcc-correlation()-X,Y           -0.1265585 -0.102072 -0.0653799
## tBodyAcc-correlation()-X,Z           -0.2465137 -0.329068 -0.2117207
## tBodyAcc-correlation()-Y,Z            0.1123730  0.282344  0.0724945
## tGravityAcc-mean()-X                  0.6887021  0.681289  0.6474982
## tGravityAcc-mean()-Y                  0.0162055 -0.042022  0.0303211
## tGravityAcc-mean()-Z                  0.0475200  0.034216  0.0836542
## tGravityAcc-std()-X                  -0.9588987 -0.956538 -0.9542567
## tGravityAcc-std()-Y                  -0.9509349 -0.955313 -0.9484465
## tGravityAcc-std()-Z                  -0.9379102 -0.923305 -0.9231807
## tGravityAcc-mad()-X                  -0.9596675 -0.957591 -0.9548996
## tGravityAcc-mad()-Y                  -0.9518592 -0.956021 -0.9496135
## tGravityAcc-mad()-Z                  -0.9389354 -0.924603 -0.9246842
## tGravityAcc-max()-X                   0.6317563  0.624080  0.5915553
## tGravityAcc-max()-Y                   0.0017366 -0.054892  0.0176676
## tGravityAcc-max()-Z                   0.0531021  0.043294  0.0908968
## tGravityAcc-min()-X                   0.7014373  0.692334  0.6594393
## tGravityAcc-min()-Y                   0.0271522 -0.027372  0.0413786
## tGravityAcc-min()-Z                   0.0351164  0.018274  0.0658535
## tGravityAcc-sma()                    -0.3367920 -0.211340 -0.0796161
## tGravityAcc-energy()-X                0.5105312  0.493419  0.4061992
## tGravityAcc-energy()-Y               -0.5971262 -0.901389 -0.7651055
## tGravityAcc-energy()-Z               -0.9627664 -0.620267 -0.6860933
## tGravityAcc-iqr()-X                  -0.9618150 -0.960875 -0.9571600
## tGravityAcc-iqr()-Y                  -0.9547785 -0.959146 -0.9541665
## tGravityAcc-iqr()-Z                  -0.9432353 -0.929480 -0.9315407
## tGravityAcc-entropy()-X              -0.7372856 -0.698071 -0.5991678
## tGravityAcc-entropy()-Y              -0.9188932 -0.859745 -0.8301012
## tGravityAcc-entropy()-Z              -0.5731686 -0.703085 -0.7250323
## tGravityAcc-arCoeff()-X,1            -0.4041599 -0.546004 -0.5492783
## tGravityAcc-arCoeff()-X,2             0.4507479  0.588250  0.5875467
## tGravityAcc-arCoeff()-X,3            -0.4962948 -0.629490 -0.6253235
## tGravityAcc-arCoeff()-X,4             0.5408174  0.669768  0.6626725
## tGravityAcc-arCoeff()-Y,1            -0.1838767 -0.372617 -0.3334644
## tGravityAcc-arCoeff()-Y,2             0.1849098  0.363063  0.3132045
## tGravityAcc-arCoeff()-Y,3            -0.2418787 -0.395663 -0.3369455
## tGravityAcc-arCoeff()-Y,4             0.3204898  0.444889  0.3783786
## tGravityAcc-arCoeff()-Z,1            -0.3184688 -0.445251 -0.4015126
## tGravityAcc-arCoeff()-Z,2             0.3390505  0.486140  0.4323028
## tGravityAcc-arCoeff()-Z,3            -0.3589760 -0.526442 -0.4624610
## tGravityAcc-arCoeff()-Z,4             0.3758479  0.563414  0.4893625
## tGravityAcc-correlation()-X,Y         0.2318258  0.209791  0.1920331
## tGravityAcc-correlation()-X,Z         0.0519986 -0.005346 -0.1712619
## tGravityAcc-correlation()-Y,Z         0.1753809  0.155882  0.0087755
## tBodyAccJerk-mean()-X                 0.0813834  0.083183  0.0842157
## tBodyAccJerk-mean()-Y                 0.0004793  0.007609  0.0008603
## tBodyAccJerk-mean()-Z                -0.0022590 -0.007917 -0.0196720
## tBodyAccJerk-std()-X                 -0.5314683 -0.615131 -0.5759931
## tBodyAccJerk-std()-Y                 -0.4544375 -0.622997 -0.4587249
## tBodyAccJerk-std()-Z                 -0.7389552 -0.664337 -0.6683568
## tBodyAccJerk-mad()-X                 -0.5324828 -0.626469 -0.5553315
## tBodyAccJerk-mad()-Y                 -0.4364332 -0.617347 -0.4226002
## tBodyAccJerk-mad()-Z                 -0.7345271 -0.668329 -0.6539373
## tBodyAccJerk-max()-X                 -0.5982445 -0.671404 -0.6804432
## tBodyAccJerk-max()-Y                 -0.6664277 -0.754449 -0.6414266
## tBodyAccJerk-max()-Z                 -0.7827672 -0.736169 -0.7449773
## tBodyAccJerk-min()-X                  0.4809558  0.580955  0.5632268
## tBodyAccJerk-min()-Y                  0.5524972  0.698594  0.6064298
## tBodyAccJerk-min()-Z                  0.7144421  0.643757  0.6632230
## tBodyAccJerk-sma()                   -0.5506804 -0.617410 -0.5271175
## tBodyAccJerk-energy()-X              -0.7769841 -0.845824 -0.7946075
## tBodyAccJerk-energy()-Y              -0.7086902 -0.850175 -0.6797213
## tBodyAccJerk-energy()-Z              -0.9205039 -0.881579 -0.8696895
## tBodyAccJerk-iqr()-X                 -0.5206579 -0.637807 -0.5098994
## tBodyAccJerk-iqr()-Y                 -0.5355611 -0.695005 -0.4877560
## tBodyAccJerk-iqr()-Z                 -0.7505218 -0.720211 -0.6683705
## tBodyAccJerk-entropy()-X              0.0452560 -0.041910 -0.0957714
## tBodyAccJerk-entropy()-Y              0.0758480 -0.051165 -0.1143729
## tBodyAccJerk-entropy()-Z             -0.0364074  0.023409 -0.1001818
## tBodyAccJerk-arCoeff()-X,1           -0.1640315 -0.186421 -0.0656329
## tBodyAccJerk-arCoeff()-X,2            0.2260268  0.134175  0.1639776
## tBodyAccJerk-arCoeff()-X,3            0.0820612  0.017123  0.1015399
## tBodyAccJerk-arCoeff()-X,4            0.1479305  0.090676  0.0531344
## tBodyAccJerk-arCoeff()-Y,1           -0.1395357 -0.096998 -0.0392376
## tBodyAccJerk-arCoeff()-Y,2            0.0821813  0.077728  0.0536118
## tBodyAccJerk-arCoeff()-Y,3            0.2744214  0.183474  0.1558117
## tBodyAccJerk-arCoeff()-Y,4            0.3344384  0.297128  0.3575839
## tBodyAccJerk-arCoeff()-Z,1           -0.0136752 -0.139854  0.0012551
## tBodyAccJerk-arCoeff()-Z,2            0.1589811  0.096616  0.0741351
## tBodyAccJerk-arCoeff()-Z,3            0.0224434 -0.037915  0.0332908
## tBodyAccJerk-arCoeff()-Z,4            0.2743047  0.113879  0.1180565
## tBodyAccJerk-correlation()-X,Y       -0.1050302 -0.239465 -0.1105506
## tBodyAccJerk-correlation()-X,Z       -0.1764517 -0.149513  0.0618834
## tBodyAccJerk-correlation()-Y,Z        0.1269754  0.289222  0.1274232
## tBodyGyro-mean()-X                   -0.0433612 -0.051872  0.0035905
## tBodyGyro-mean()-Y                   -0.0706129 -0.064608 -0.0910775
## tBodyGyro-mean()-Z                    0.0973130  0.097767  0.0640868
## tBodyGyro-std()-X                    -0.6538007 -0.687155 -0.6562192
## tBodyGyro-std()-Y                    -0.6262521 -0.652409 -0.5709412
## tBodyGyro-std()-Z                    -0.5999102 -0.663341 -0.5113920
## tBodyGyro-mad()-X                    -0.6654633 -0.697234 -0.6630111
## tBodyGyro-mad()-Y                    -0.6516628 -0.686020 -0.5883250
## tBodyGyro-mad()-Z                    -0.6355294 -0.678851 -0.5118526
## tBodyGyro-max()-X                    -0.5800980 -0.626581 -0.5645214
## tBodyGyro-max()-Y                    -0.6704653 -0.651163 -0.6516601
## tBodyGyro-max()-Z                    -0.3144202 -0.444742 -0.4276586
## tBodyGyro-min()-X                     0.5416104  0.588118  0.6099058
## tBodyGyro-min()-Y                     0.6718944  0.690213  0.6832825
## tBodyGyro-min()-Z                     0.4989277  0.590072  0.4768776
## tBodyGyro-sma()                      -0.5462107 -0.582701 -0.4661573
## tBodyGyro-energy()-X                 -0.8689588 -0.894863 -0.8515803
## tBodyGyro-energy()-Y                 -0.8660883 -0.886223 -0.8065977
## tBodyGyro-energy()-Z                 -0.8546595 -0.891399 -0.7344946
## tBodyGyro-iqr()-X                    -0.6748037 -0.709269 -0.6701226
## tBodyGyro-iqr()-Y                    -0.6954555 -0.737922 -0.6183210
## tBodyGyro-iqr()-Z                    -0.7231002 -0.732386 -0.5581716
## tBodyGyro-entropy()-X                -0.0906246 -0.068837 -0.1506622
## tBodyGyro-entropy()-Y                -0.0023348  0.036174 -0.1510246
## tBodyGyro-entropy()-Z                -0.0103276 -0.031193 -0.0977776
## tBodyGyro-arCoeff()-X,1              -0.2224424 -0.275827 -0.2142418
## tBodyGyro-arCoeff()-X,2               0.2110788  0.221172  0.0879068
## tBodyGyro-arCoeff()-X,3               0.0740934 -0.028200  0.2532221
## tBodyGyro-arCoeff()-X,4              -0.0966814  0.089929 -0.1970973
## tBodyGyro-arCoeff()-Y,1              -0.2533035 -0.161914 -0.1734167
## tBodyGyro-arCoeff()-Y,2               0.2707498  0.186461  0.1419721
## tBodyGyro-arCoeff()-Y,3              -0.0708983 -0.074467 -0.0516861
## tBodyGyro-arCoeff()-Y,4               0.1147349  0.178623  0.1651898
## tBodyGyro-arCoeff()-Z,1              -0.0437027 -0.152840 -0.0682327
## tBodyGyro-arCoeff()-Z,2               0.1033851  0.132931  0.0532999
## tBodyGyro-arCoeff()-Z,3               0.0242651 -0.085412 -0.0470069
## tBodyGyro-arCoeff()-Z,4               0.0823385  0.180302  0.2069919
## tBodyGyro-correlation()-X,Y          -0.2077998 -0.172737 -0.1797449
## tBodyGyro-correlation()-X,Z          -0.0484359  0.167617 -0.0828300
## tBodyGyro-correlation()-Y,Z          -0.1808868 -0.219587 -0.0633463
## tBodyGyroJerk-mean()-X               -0.0829160 -0.094204 -0.1049699
## tBodyGyroJerk-mean()-Y               -0.0454921 -0.041440 -0.0400922
## tBodyGyroJerk-mean()-Z               -0.0533610 -0.061031 -0.0582887
## tBodyGyroJerk-std()-X                -0.5460100 -0.701731 -0.6749845
## tBodyGyroJerk-std()-Y                -0.6776360 -0.674920 -0.6830869
## tBodyGyroJerk-std()-Z                -0.5269083 -0.750809 -0.6959703
## tBodyGyroJerk-mad()-X                -0.5461148 -0.715076 -0.6611580
## tBodyGyroJerk-mad()-Y                -0.6937941 -0.713988 -0.6920145
## tBodyGyroJerk-mad()-Z                -0.5578914 -0.762079 -0.6981945
## tBodyGyroJerk-max()-X                -0.5646188 -0.733454 -0.7118499
## tBodyGyroJerk-max()-Y                -0.7241521 -0.651546 -0.7425378
## tBodyGyroJerk-max()-Z                -0.5381139 -0.777743 -0.7315817
## tBodyGyroJerk-min()-X                 0.5854058  0.680276  0.7355259
## tBodyGyroJerk-min()-Y                 0.7329756  0.724518  0.7648803
## tBodyGyroJerk-min()-Z                 0.5689861  0.773466  0.7517553
## tBodyGyroJerk-sma()                  -0.6218692 -0.724681 -0.6842604
## tBodyGyroJerk-energy()-X             -0.7904117 -0.906077 -0.8839705
## tBodyGyroJerk-energy()-Y             -0.8907071 -0.885327 -0.8859736
## tBodyGyroJerk-energy()-Z             -0.7686028 -0.933428 -0.8970327
## tBodyGyroJerk-iqr()-X                -0.5583833 -0.748360 -0.6454146
## tBodyGyroJerk-iqr()-Y                -0.7122295 -0.755753 -0.7046792
## tBodyGyroJerk-iqr()-Z                -0.6149905 -0.782124 -0.7106293
## tBodyGyroJerk-entropy()-X             0.2159632  0.062432 -0.0608212
## tBodyGyroJerk-entropy()-Y             0.2397588  0.108054  0.0098449
## tBodyGyroJerk-entropy()-Z             0.1713581  0.038813 -0.0374772
## tBodyGyroJerk-arCoeff()-X,1          -0.0868732 -0.147344 -0.0371391
## tBodyGyroJerk-arCoeff()-X,2           0.1473237  0.112787 -0.0319292
## tBodyGyroJerk-arCoeff()-X,3           0.1647994  0.032413  0.1900935
## tBodyGyroJerk-arCoeff()-X,4           0.1954543  0.120281  0.2298492
## tBodyGyroJerk-arCoeff()-Y,1          -0.2374460 -0.140021 -0.1283737
## tBodyGyroJerk-arCoeff()-Y,2           0.3034438  0.249950  0.1801162
## tBodyGyroJerk-arCoeff()-Y,3           0.0956571  0.090624  0.0882442
## tBodyGyroJerk-arCoeff()-Y,4           0.1263531  0.077864  0.0291705
## tBodyGyroJerk-arCoeff()-Z,1          -0.0226118 -0.088521 -0.0086618
## tBodyGyroJerk-arCoeff()-Z,2           0.1498475  0.097591  0.0407408
## tBodyGyroJerk-arCoeff()-Z,3           0.1414564  0.063854  0.0780047
## tBodyGyroJerk-arCoeff()-Z,4           0.1271992 -0.038436 -0.0384016
## tBodyGyroJerk-correlation()-X,Y      -0.1181261 -0.010986  0.0073784
## tBodyGyroJerk-correlation()-X,Z      -0.0458112  0.177897 -0.0386131
## tBodyGyroJerk-correlation()-Y,Z      -0.2039901 -0.305084 -0.1272576
## tBodyAccMag-mean()                   -0.4647700 -0.511312 -0.4685226
## tBodyAccMag-std()                    -0.4837906 -0.510670 -0.5540390
## tBodyAccMag-mad()                    -0.5421474 -0.590531 -0.6073993
## tBodyAccMag-max()                    -0.4580750 -0.463467 -0.4959950
## tBodyAccMag-min()                    -0.8207246 -0.822323 -0.8233045
## tBodyAccMag-sma()                    -0.4647700 -0.511312 -0.4685226
## tBodyAccMag-energy()                 -0.6998569 -0.762591 -0.7088579
## tBodyAccMag-iqr()                    -0.6075219 -0.697604 -0.6552699
## tBodyAccMag-entropy()                 0.2600633  0.253139  0.1406903
## tBodyAccMag-arCoeff()1               -0.0530711 -0.165042  0.0121218
## tBodyAccMag-arCoeff()2                0.0330491  0.093185 -0.0317550
## tBodyAccMag-arCoeff()3                0.0091033  0.015595  0.0972805
## tBodyAccMag-arCoeff()4               -0.0309695 -0.010361 -0.1166710
## tGravityAccMag-mean()                -0.4647700 -0.511312 -0.4685226
## tGravityAccMag-std()                 -0.4837906 -0.510670 -0.5540390
## tGravityAccMag-mad()                 -0.5421474 -0.590531 -0.6073993
## tGravityAccMag-max()                 -0.4580750 -0.463467 -0.4959950
## tGravityAccMag-min()                 -0.8207246 -0.822323 -0.8233045
## tGravityAccMag-sma()                 -0.4647700 -0.511312 -0.4685226
## tGravityAccMag-energy()              -0.6998569 -0.762591 -0.7088579
## tGravityAccMag-iqr()                 -0.6075219 -0.697604 -0.6552699
## tGravityAccMag-entropy()              0.2600633  0.253139  0.1406903
## tGravityAccMag-arCoeff()1            -0.0530711 -0.165042  0.0121218
## tGravityAccMag-arCoeff()2             0.0330491  0.093185 -0.0317550
## tGravityAccMag-arCoeff()3             0.0091033  0.015595  0.0972805
## tGravityAccMag-arCoeff()4            -0.0309695 -0.010361 -0.1166710
## tBodyAccJerkMag-mean()               -0.5514137 -0.622816 -0.5342486
## tBodyAccJerkMag-std()                -0.5029351 -0.550560 -0.5644720
## tBodyAccJerkMag-mad()                -0.5325321 -0.580197 -0.5857773
## tBodyAccJerkMag-max()                -0.5029346 -0.566963 -0.5690920
## tBodyAccJerkMag-min()                -0.7558353 -0.789290 -0.6836949
## tBodyAccJerkMag-sma()                -0.5514137 -0.622816 -0.5342486
## tBodyAccJerkMag-energy()             -0.7796641 -0.833938 -0.7600733
## tBodyAccJerkMag-iqr()                -0.6042508 -0.656676 -0.6408687
## tBodyAccJerkMag-entropy()             0.1085350  0.026028 -0.0429970
## tBodyAccJerkMag-arCoeff()1            0.0427347 -0.011688  0.1692982
## tBodyAccJerkMag-arCoeff()2           -0.0111565  0.064659 -0.0726282
## tBodyAccJerkMag-arCoeff()3           -0.0718512 -0.124840 -0.0986690
## tBodyAccJerkMag-arCoeff()4           -0.0325159  0.001205 -0.1035683
## tBodyGyroMag-mean()                  -0.5494949 -0.581900 -0.4762149
## tBodyGyroMag-std()                   -0.5798378 -0.598671 -0.5814229
## tBodyGyroMag-mad()                   -0.5473965 -0.572644 -0.5358078
## tBodyGyroMag-max()                   -0.6080797 -0.624184 -0.6185543
## tBodyGyroMag-min()                   -0.6994210 -0.743167 -0.6348956
## tBodyGyroMag-sma()                   -0.5494949 -0.581900 -0.4762149
## tBodyGyroMag-energy()                -0.7963509 -0.835049 -0.7237640
## tBodyGyroMag-iqr()                   -0.5881528 -0.625994 -0.5533151
## tBodyGyroMag-entropy()                0.3302935  0.376802 -0.0274026
## tBodyGyroMag-arCoeff()1               0.1097325  0.047602 -0.0170081
## tBodyGyroMag-arCoeff()2              -0.1519582 -0.133872 -0.0601828
## tBodyGyroMag-arCoeff()3               0.1345165  0.097241  0.0521096
## tBodyGyroMag-arCoeff()4              -0.1109771  0.013921  0.0053924
## tBodyGyroJerkMag-mean()              -0.6219362 -0.713191 -0.6736255
## tBodyGyroJerkMag-std()               -0.6444745 -0.658018 -0.7158384
## tBodyGyroJerkMag-mad()               -0.6650486 -0.706052 -0.7299918
## tBodyGyroJerkMag-max()               -0.6591893 -0.654497 -0.7278554
## tBodyGyroJerkMag-min()               -0.7058689 -0.796042 -0.7308559
## tBodyGyroJerkMag-sma()               -0.6219362 -0.713191 -0.6736255
## tBodyGyroJerkMag-energy()            -0.8528863 -0.895764 -0.8866519
## tBodyGyroJerkMag-iqr()               -0.6825783 -0.772236 -0.7423524
## tBodyGyroJerkMag-entropy()            0.3649648  0.223581  0.0897256
## tBodyGyroJerkMag-arCoeff()1           0.3330759  0.296619  0.3528663
## tBodyGyroJerkMag-arCoeff()2          -0.2265089 -0.315408 -0.2423443
## tBodyGyroJerkMag-arCoeff()3          -0.1826404 -0.073130 -0.0700894
## tBodyGyroJerkMag-arCoeff()4          -0.0325383  0.080381 -0.1477837
## fBodyAcc-mean()-X                    -0.5061749 -0.593011 -0.5818314
## fBodyAcc-mean()-Y                    -0.3920414 -0.563548 -0.3749442
## fBodyAcc-mean()-Z                    -0.6837259 -0.531006 -0.5509794
## fBodyAcc-std()-X                     -0.5066803 -0.572348 -0.5853435
## fBodyAcc-std()-Y                     -0.3966778 -0.567047 -0.3786565
## fBodyAcc-std()-Z                     -0.6943652 -0.460792 -0.5132063
## fBodyAcc-mad()-X                     -0.4687840 -0.555286 -0.5622168
## fBodyAcc-mad()-Y                     -0.3591879 -0.554255 -0.3596448
## fBodyAcc-mad()-Z                     -0.6746592 -0.480504 -0.5203016
## fBodyAcc-max()-X                     -0.5892944 -0.632851 -0.6342310
## fBodyAcc-max()-Y                     -0.5848596 -0.693171 -0.5667460
## fBodyAcc-max()-Z                     -0.7362740 -0.477260 -0.5389692
## fBodyAcc-min()-X                     -0.8136436 -0.835472 -0.8502862
## fBodyAcc-min()-Y                     -0.8435124 -0.888165 -0.8310347
## fBodyAcc-min()-Z                     -0.9285869 -0.878531 -0.8795766
## fBodyAcc-sma()                       -0.4573911 -0.502641 -0.4458825
## fBodyAcc-energy()-X                  -0.7398954 -0.823809 -0.8166192
## fBodyAcc-energy()-Y                  -0.6229147 -0.811106 -0.5690503
## fBodyAcc-energy()-Z                  -0.8984566 -0.729001 -0.7382261
## fBodyAcc-iqr()-X                     -0.5253628 -0.635243 -0.5702172
## fBodyAcc-iqr()-Y                     -0.5128639 -0.662340 -0.5199100
## fBodyAcc-iqr()-Z                     -0.7319963 -0.663026 -0.6494265
## fBodyAcc-entropy()-X                 -0.0702105 -0.118227 -0.1659991
## fBodyAcc-entropy()-Y                 -0.0487029 -0.138023 -0.1389748
## fBodyAcc-entropy()-Z                 -0.1128614 -0.059230 -0.1470844
## fBodyAcc-maxInds-X                   -0.6970720 -0.773146 -0.7724716
## fBodyAcc-maxInds-Y                   -0.6691282 -0.824892 -0.7615658
## fBodyAcc-maxInds-Z                   -0.8210651 -0.836663 -0.8310977
## fBodyAcc-meanFreq()-X                -0.1915371 -0.311791 -0.2160223
## fBodyAcc-meanFreq()-Y                 0.0590115 -0.030071  0.0263298
## fBodyAcc-meanFreq()-Z                 0.1130461  0.014662  0.0913952
## fBodyAcc-skewness()-X                -0.2693780 -0.034406 -0.0791700
## fBodyAcc-kurtosis()-X                -0.6115900 -0.363810 -0.3949714
## fBodyAcc-skewness()-Y                -0.3829869 -0.166497 -0.2314606
## fBodyAcc-kurtosis()-Y                -0.6967736 -0.474650 -0.5344855
## fBodyAcc-skewness()-Z                -0.3070963 -0.168095 -0.2321653
## fBodyAcc-kurtosis()-Z                -0.5326004 -0.415473 -0.4701246
## fBodyAcc-bandsEnergy()-1,8           -0.7336441 -0.830745 -0.8201904
## fBodyAcc-bandsEnergy()-9,16          -0.8174759 -0.845465 -0.8852176
## fBodyAcc-bandsEnergy()-17,24         -0.7849153 -0.849990 -0.7425864
## fBodyAcc-bandsEnergy()-25,32         -0.8460773 -0.911968 -0.8167940
## fBodyAcc-bandsEnergy()-33,40         -0.8763608 -0.924412 -0.8918083
## fBodyAcc-bandsEnergy()-41,48         -0.8638944 -0.905693 -0.8817739
## fBodyAcc-bandsEnergy()-49,56         -0.9168712 -0.943095 -0.9366907
## fBodyAcc-bandsEnergy()-57,64         -0.9238772 -0.948458 -0.9562788
## fBodyAcc-bandsEnergy()-1,16          -0.7335923 -0.819362 -0.8226396
## fBodyAcc-bandsEnergy()-17,32         -0.7694991 -0.845007 -0.7244362
## fBodyAcc-bandsEnergy()-33,48         -0.8717018 -0.917410 -0.8880611
## fBodyAcc-bandsEnergy()-49,64         -0.9192194 -0.944892 -0.9432561
## fBodyAcc-bandsEnergy()-1,24          -0.7372417 -0.821541 -0.8169513
## fBodyAcc-bandsEnergy()-25,48         -0.8284181 -0.897440 -0.8153837
## fBodyAcc-bandsEnergy()-1,8.1         -0.7406244 -0.854732 -0.6736875
## fBodyAcc-bandsEnergy()-9,16.1        -0.6798192 -0.867827 -0.6692147
## fBodyAcc-bandsEnergy()-17,24.1       -0.7485244 -0.870752 -0.7581288
## fBodyAcc-bandsEnergy()-25,32.1       -0.9015293 -0.924670 -0.8362423
## fBodyAcc-bandsEnergy()-33,40.1       -0.8861218 -0.919303 -0.8138426
## fBodyAcc-bandsEnergy()-41,48.1       -0.8282864 -0.898153 -0.7935356
## fBodyAcc-bandsEnergy()-49,56.1       -0.8407539 -0.901186 -0.8228925
## fBodyAcc-bandsEnergy()-57,64.1       -0.9085020 -0.957906 -0.9161330
## fBodyAcc-bandsEnergy()-1,16.1        -0.6365515 -0.820708 -0.5798060
## fBodyAcc-bandsEnergy()-17,32.1       -0.7285462 -0.853342 -0.7189556
## fBodyAcc-bandsEnergy()-33,48.1       -0.8509053 -0.901967 -0.7847366
## fBodyAcc-bandsEnergy()-49,64.1       -0.8641721 -0.921914 -0.8564895
## fBodyAcc-bandsEnergy()-1,24.1        -0.6234958 -0.813353 -0.5733308
## fBodyAcc-bandsEnergy()-25,48.1       -0.8807878 -0.913793 -0.8119018
## fBodyAcc-bandsEnergy()-1,8.2         -0.9414970 -0.772619 -0.7740732
## fBodyAcc-bandsEnergy()-9,16.2        -0.8960959 -0.789976 -0.8440633
## fBodyAcc-bandsEnergy()-17,24.2       -0.9143089 -0.871373 -0.8533050
## fBodyAcc-bandsEnergy()-25,32.2       -0.9539701 -0.949253 -0.9130608
## fBodyAcc-bandsEnergy()-33,40.2       -0.9465296 -0.952670 -0.9421832
## fBodyAcc-bandsEnergy()-41,48.2       -0.9287121 -0.892995 -0.8895823
## fBodyAcc-bandsEnergy()-49,56.2       -0.9471867 -0.900038 -0.8919786
## fBodyAcc-bandsEnergy()-57,64.2       -0.9753025 -0.917948 -0.9173713
## fBodyAcc-bandsEnergy()-1,16.2        -0.9197590 -0.750538 -0.7691404
## fBodyAcc-bandsEnergy()-17,32.2       -0.9287086 -0.899617 -0.8749832
## fBodyAcc-bandsEnergy()-33,48.2       -0.9381461 -0.933834 -0.9244433
## fBodyAcc-bandsEnergy()-49,64.2       -0.9551765 -0.904567 -0.8986820
## fBodyAcc-bandsEnergy()-1,24.2        -0.9048386 -0.732738 -0.7469222
## fBodyAcc-bandsEnergy()-25,48.2       -0.9494742 -0.944872 -0.9163227
## fBodyAccJerk-mean()-X                -0.5493943 -0.637522 -0.5916350
## fBodyAccJerk-mean()-Y                -0.5035590 -0.641687 -0.4959062
## fBodyAccJerk-mean()-Z                -0.7208672 -0.642516 -0.6442858
## fBodyAccJerk-std()-X                 -0.5553462 -0.626786 -0.5985462
## fBodyAccJerk-std()-Y                 -0.4378375 -0.628532 -0.4563684
## fBodyAccJerk-std()-Z                 -0.7557511 -0.684856 -0.6914809
## fBodyAccJerk-mad()-X                 -0.4686629 -0.570839 -0.5195048
## fBodyAccJerk-mad()-Y                 -0.4704807 -0.636026 -0.4960515
## fBodyAccJerk-mad()-Z                 -0.7372628 -0.668174 -0.6723059
## fBodyAccJerk-max()-X                 -0.6499984 -0.683207 -0.6796650
## fBodyAccJerk-max()-Y                 -0.5244572 -0.705969 -0.5086977
## fBodyAccJerk-max()-Z                 -0.7752591 -0.707053 -0.7210997
## fBodyAccJerk-min()-X                 -0.8462111 -0.875077 -0.8708513
## fBodyAccJerk-min()-Y                 -0.8070559 -0.860168 -0.8028690
## fBodyAccJerk-min()-Z                 -0.8831825 -0.831052 -0.8499417
## fBodyAccJerk-sma()                   -0.5198069 -0.576560 -0.5074953
## fBodyAccJerk-energy()-X              -0.7767249 -0.845644 -0.7943194
## fBodyAccJerk-energy()-Y              -0.7088282 -0.850245 -0.6798530
## fBodyAccJerk-energy()-Z              -0.9205183 -0.881636 -0.8697410
## fBodyAccJerk-iqr()-X                 -0.5201312 -0.627030 -0.5543089
## fBodyAccJerk-iqr()-Y                 -0.6438433 -0.727430 -0.6315219
## fBodyAccJerk-iqr()-Z                 -0.7469090 -0.693821 -0.6902780
## fBodyAccJerk-entropy()-X             -0.1342067 -0.203340 -0.2236506
## fBodyAccJerk-entropy()-Y             -0.1059314 -0.236066 -0.2019319
## fBodyAccJerk-entropy()-Z             -0.2780518 -0.208699 -0.2821044
## fBodyAccJerk-maxInds-X               -0.4184615 -0.457403 -0.3641281
## fBodyAccJerk-maxInds-Y               -0.3846154 -0.390260 -0.3860498
## fBodyAccJerk-maxInds-Z               -0.2936615 -0.397792 -0.3098932
## fBodyAccJerk-meanFreq()-X            -0.0956140 -0.119784  0.0212337
## fBodyAccJerk-meanFreq()-Y            -0.3054227 -0.239502 -0.1690616
## fBodyAccJerk-meanFreq()-Z            -0.1006824 -0.220261 -0.0826086
## fBodyAccJerk-skewness()-X            -0.3035755 -0.250407 -0.3723021
## fBodyAccJerk-kurtosis()-X            -0.7334988 -0.659475 -0.7572768
## fBodyAccJerk-skewness()-Y            -0.3092306 -0.414149 -0.3594507
## fBodyAccJerk-kurtosis()-Y            -0.7790771 -0.842258 -0.7608945
## fBodyAccJerk-skewness()-Z            -0.4428723 -0.427529 -0.4621719
## fBodyAccJerk-kurtosis()-Z            -0.7886940 -0.780006 -0.7906479
## fBodyAccJerk-bandsEnergy()-1,8       -0.8169510 -0.875745 -0.8595567
## fBodyAccJerk-bandsEnergy()-9,16      -0.8190495 -0.863975 -0.8829188
## fBodyAccJerk-bandsEnergy()-17,24     -0.8093622 -0.865792 -0.7614120
## fBodyAccJerk-bandsEnergy()-25,32     -0.8538801 -0.918064 -0.8168474
## fBodyAccJerk-bandsEnergy()-33,40     -0.8861054 -0.935988 -0.8930373
## fBodyAccJerk-bandsEnergy()-41,48     -0.8570711 -0.899111 -0.8598073
## fBodyAccJerk-bandsEnergy()-49,56     -0.9224328 -0.944497 -0.9292755
## fBodyAccJerk-bandsEnergy()-57,64     -0.9750529 -0.980823 -0.9812033
## fBodyAccJerk-bandsEnergy()-1,16      -0.8022154 -0.857284 -0.8621960
## fBodyAccJerk-bandsEnergy()-17,32     -0.7844608 -0.857471 -0.7301217
## fBodyAccJerk-bandsEnergy()-33,48     -0.8646897 -0.915496 -0.8704717
## fBodyAccJerk-bandsEnergy()-49,64     -0.9189532 -0.941751 -0.9268665
## fBodyAccJerk-bandsEnergy()-1,24      -0.7686148 -0.834330 -0.7980702
## fBodyAccJerk-bandsEnergy()-25,48     -0.8012060 -0.882733 -0.7777517
## fBodyAccJerk-bandsEnergy()-1,8.1     -0.7752260 -0.877421 -0.7850572
## fBodyAccJerk-bandsEnergy()-9,16.1    -0.7224357 -0.882008 -0.7050165
## fBodyAccJerk-bandsEnergy()-17,24.1   -0.7176616 -0.851072 -0.7267624
## fBodyAccJerk-bandsEnergy()-25,32.1   -0.9143041 -0.928453 -0.8447679
## fBodyAccJerk-bandsEnergy()-33,40.1   -0.9119354 -0.932913 -0.8485118
## fBodyAccJerk-bandsEnergy()-41,48.1   -0.8281523 -0.891529 -0.7774955
## fBodyAccJerk-bandsEnergy()-49,56.1   -0.8872370 -0.917817 -0.8549409
## fBodyAccJerk-bandsEnergy()-57,64.1   -0.9434100 -0.972670 -0.9368176
## fBodyAccJerk-bandsEnergy()-1,16.1    -0.6953612 -0.864138 -0.6818793
## fBodyAccJerk-bandsEnergy()-17,32.1   -0.7535801 -0.857602 -0.7274367
## fBodyAccJerk-bandsEnergy()-33,48.1   -0.8550133 -0.899146 -0.7817821
## fBodyAccJerk-bandsEnergy()-49,64.1   -0.8943272 -0.924741 -0.8652736
## fBodyAccJerk-bandsEnergy()-1,24.1    -0.6540917 -0.835601 -0.6482931
## fBodyAccJerk-bandsEnergy()-25,48.1   -0.8902879 -0.916200 -0.8183908
## fBodyAccJerk-bandsEnergy()-1,8.2     -0.9652871 -0.793875 -0.8164108
## fBodyAccJerk-bandsEnergy()-9,16.2    -0.8746804 -0.805592 -0.8415348
## fBodyAccJerk-bandsEnergy()-17,24.2   -0.9206318 -0.883121 -0.8588619
## fBodyAccJerk-bandsEnergy()-25,32.2   -0.9531868 -0.951431 -0.9178557
## fBodyAccJerk-bandsEnergy()-33,40.2   -0.9480683 -0.957747 -0.9488743
## fBodyAccJerk-bandsEnergy()-41,48.2   -0.9281482 -0.905065 -0.9015508
## fBodyAccJerk-bandsEnergy()-49,56.2   -0.9286751 -0.886215 -0.8801835
## fBodyAccJerk-bandsEnergy()-57,64.2   -0.9731691 -0.943506 -0.9520111
## fBodyAccJerk-bandsEnergy()-1,16.2    -0.8804782 -0.760501 -0.7992564
## fBodyAccJerk-bandsEnergy()-17,32.2   -0.9365775 -0.916548 -0.8877335
## fBodyAccJerk-bandsEnergy()-33,48.2   -0.9385757 -0.939001 -0.9311532
## fBodyAccJerk-bandsEnergy()-49,64.2   -0.9292499 -0.885564 -0.8808146
## fBodyAccJerk-bandsEnergy()-1,24.2    -0.8926574 -0.813756 -0.8143148
## fBodyAccJerk-bandsEnergy()-25,48.2   -0.9474720 -0.946573 -0.9231049
## fBodyGyro-mean()-X                   -0.5372014 -0.643768 -0.6013824
## fBodyGyro-mean()-Y                   -0.6211887 -0.630419 -0.5759385
## fBodyGyro-mean()-Z                   -0.5076042 -0.655083 -0.5255629
## fBodyGyro-std()-X                    -0.6928624 -0.703884 -0.6752754
## fBodyGyro-std()-Y                    -0.6332362 -0.671162 -0.5730873
## fBodyGyro-std()-Z                    -0.6730203 -0.698950 -0.5539686
## fBodyGyro-mad()-X                    -0.5886608 -0.663727 -0.6094043
## fBodyGyro-mad()-Y                    -0.6383326 -0.668603 -0.5977271
## fBodyGyro-mad()-Z                    -0.5477130 -0.655832 -0.5128675
## fBodyGyro-max()-X                    -0.7094381 -0.696537 -0.6748822
## fBodyGyro-max()-Y                    -0.7316321 -0.769271 -0.6611174
## fBodyGyro-max()-Z                    -0.7949449 -0.762868 -0.6563727
## fBodyGyro-min()-X                    -0.9084298 -0.922410 -0.9141681
## fBodyGyro-min()-Y                    -0.8731952 -0.871921 -0.8600987
## fBodyGyro-min()-Z                    -0.8879168 -0.899051 -0.8529483
## fBodyGyro-sma()                      -0.5388775 -0.617746 -0.5459862
## fBodyGyro-energy()-X                 -0.8805040 -0.910060 -0.8717644
## fBodyGyro-energy()-Y                 -0.8668668 -0.887061 -0.8076192
## fBodyGyro-energy()-Z                 -0.8482001 -0.897605 -0.7288947
## fBodyGyro-iqr()-X                    -0.5021066 -0.689232 -0.6519711
## fBodyGyro-iqr()-Y                    -0.6431426 -0.651083 -0.6132633
## fBodyGyro-iqr()-Z                    -0.4759018 -0.704864 -0.6465687
## fBodyGyro-entropy()-X                 0.1328715  0.002763 -0.0988629
## fBodyGyro-entropy()-Y                 0.1577150  0.109364  0.0078327
## fBodyGyro-entropy()-Z                 0.0611484 -0.109404 -0.1455333
## fBodyGyro-maxInds-X                  -0.8264615 -0.843290 -0.9017794
## fBodyGyro-maxInds-Y                  -0.6327543 -0.687474 -0.8344622
## fBodyGyro-maxInds-Z                  -0.6019098 -0.830721 -0.8147012
## fBodyGyro-meanFreq()-X                0.0289087 -0.134492 -0.1171028
## fBodyGyro-meanFreq()-Y               -0.0427900 -0.103885 -0.1538797
## fBodyGyro-meanFreq()-Z                0.1010448 -0.086341 -0.0430259
## fBodyGyro-skewness()-X               -0.3761267 -0.078715 -0.1283451
## fBodyGyro-kurtosis()-X               -0.6702031 -0.405854 -0.4468127
## fBodyGyro-skewness()-Y               -0.3822708 -0.226164 -0.1586313
## fBodyGyro-kurtosis()-Y               -0.7248636 -0.562804 -0.5091473
## fBodyGyro-skewness()-Z               -0.4250613 -0.123691 -0.1730963
## fBodyGyro-kurtosis()-Z               -0.7195341 -0.443334 -0.5015749
## fBodyGyro-bandsEnergy()-1,8          -0.9244529 -0.923982 -0.8964439
## fBodyGyro-bandsEnergy()-9,16         -0.7597513 -0.905225 -0.8212010
## fBodyGyro-bandsEnergy()-17,24        -0.8014195 -0.927469 -0.8973504
## fBodyGyro-bandsEnergy()-25,32        -0.8905494 -0.935107 -0.9645571
## fBodyGyro-bandsEnergy()-33,40        -0.8517278 -0.950152 -0.9507829
## fBodyGyro-bandsEnergy()-41,48        -0.8963206 -0.951377 -0.9396020
## fBodyGyro-bandsEnergy()-49,56        -0.9287019 -0.967062 -0.9494079
## fBodyGyro-bandsEnergy()-57,64        -0.9625413 -0.979093 -0.9627684
## fBodyGyro-bandsEnergy()-1,16         -0.8937943 -0.914603 -0.8764078
## fBodyGyro-bandsEnergy()-17,32        -0.7956185 -0.915185 -0.9029758
## fBodyGyro-bandsEnergy()-33,48        -0.8549764 -0.945639 -0.9412819
## fBodyGyro-bandsEnergy()-49,64        -0.9436753 -0.972386 -0.9553198
## fBodyGyro-bandsEnergy()-1,24         -0.8847769 -0.912109 -0.8729249
## fBodyGyro-bandsEnergy()-25,48        -0.8790861 -0.937440 -0.9574521
## fBodyGyro-bandsEnergy()-1,8.1        -0.9225497 -0.940299 -0.8089208
## fBodyGyro-bandsEnergy()-9,16.1       -0.9135001 -0.943469 -0.9216999
## fBodyGyro-bandsEnergy()-17,24.1      -0.9218109 -0.921567 -0.9313303
## fBodyGyro-bandsEnergy()-25,32.1      -0.9488540 -0.914909 -0.9282761
## fBodyGyro-bandsEnergy()-33,40.1      -0.9712545 -0.954335 -0.9528909
## fBodyGyro-bandsEnergy()-41,48.1      -0.9432159 -0.923790 -0.9134508
## fBodyGyro-bandsEnergy()-49,56.1      -0.9321966 -0.906687 -0.9025510
## fBodyGyro-bandsEnergy()-57,64.1      -0.9673731 -0.974347 -0.9497202
## fBodyGyro-bandsEnergy()-1,16.1       -0.8915957 -0.923037 -0.8204179
## fBodyGyro-bandsEnergy()-17,32.1      -0.9113674 -0.900866 -0.9140465
## fBodyGyro-bandsEnergy()-33,48.1      -0.9652028 -0.947596 -0.9443100
## fBodyGyro-bandsEnergy()-49,64.1      -0.9382119 -0.923307 -0.9097284
## fBodyGyro-bandsEnergy()-1,24.1       -0.8617783 -0.890849 -0.8002785
## fBodyGyro-bandsEnergy()-25,48.1      -0.9500158 -0.918563 -0.9277432
## fBodyGyro-bandsEnergy()-1,8.2        -0.9506610 -0.919936 -0.7572580
## fBodyGyro-bandsEnergy()-9,16.2       -0.8262099 -0.954834 -0.9240259
## fBodyGyro-bandsEnergy()-17,24.2      -0.7219688 -0.938317 -0.9179610
## fBodyGyro-bandsEnergy()-25,32.2      -0.8960101 -0.964707 -0.9525588
## fBodyGyro-bandsEnergy()-33,40.2      -0.9233314 -0.977673 -0.9574554
## fBodyGyro-bandsEnergy()-41,48.2      -0.9104864 -0.970473 -0.9360980
## fBodyGyro-bandsEnergy()-49,56.2      -0.8951376 -0.954329 -0.9034212
## fBodyGyro-bandsEnergy()-57,64.2      -0.9630527 -0.971225 -0.9128239
## fBodyGyro-bandsEnergy()-1,16.2       -0.8948461 -0.908700 -0.7436093
## fBodyGyro-bandsEnergy()-17,32.2      -0.6845368 -0.924098 -0.8988062
## fBodyGyro-bandsEnergy()-33,48.2      -0.9196040 -0.975659 -0.9515539
## fBodyGyro-bandsEnergy()-49,64.2      -0.9246650 -0.961675 -0.9075094
## fBodyGyro-bandsEnergy()-1,24.2       -0.8579839 -0.900843 -0.7337936
## fBodyGyro-bandsEnergy()-25,48.2      -0.9033325 -0.968107 -0.9522489
## fBodyAccMag-mean()                   -0.4739749 -0.518324 -0.5121068
## fBodyAccMag-std()                    -0.5709103 -0.583820 -0.6516381
## fBodyAccMag-mad()                    -0.5039225 -0.523422 -0.5667556
## fBodyAccMag-max()                    -0.6749491 -0.695676 -0.7578959
## fBodyAccMag-min()                    -0.8629890 -0.869575 -0.8610095
## fBodyAccMag-sma()                    -0.4739749 -0.518324 -0.5121068
## fBodyAccMag-energy()                 -0.7341172 -0.775164 -0.7970899
## fBodyAccMag-iqr()                    -0.6144337 -0.659039 -0.6276881
## fBodyAccMag-entropy()                -0.0584206 -0.085381 -0.1465062
## fBodyAccMag-maxInds                  -0.7585146 -0.786834 -0.7324825
## fBodyAccMag-meanFreq()                0.1023467 -0.010687  0.1465414
## fBodyAccMag-skewness()               -0.3134515 -0.227780 -0.3841784
## fBodyAccMag-kurtosis()               -0.5976373 -0.527079 -0.6395608
## fBodyBodyAccJerkMag-mean()           -0.4948823 -0.553360 -0.5292449
## fBodyBodyAccJerkMag-std()            -0.5167113 -0.550683 -0.6180274
## fBodyBodyAccJerkMag-mad()            -0.4717463 -0.538698 -0.5508121
## fBodyBodyAccJerkMag-max()            -0.5961383 -0.581437 -0.6999086
## fBodyBodyAccJerkMag-min()            -0.7541854 -0.767281 -0.7524256
## fBodyBodyAccJerkMag-sma()            -0.4948823 -0.553360 -0.5292449
## fBodyBodyAccJerkMag-energy()         -0.7529535 -0.790859 -0.7855336
## fBodyBodyAccJerkMag-iqr()            -0.5698662 -0.614528 -0.5973627
## fBodyBodyAccJerkMag-entropy()        -0.1847185 -0.243110 -0.2697284
## fBodyBodyAccJerkMag-maxInds          -0.9092552 -0.872604 -0.8675931
## fBodyBodyAccJerkMag-meanFreq()        0.0831165  0.108696  0.2715289
## fBodyBodyAccJerkMag-skewness()       -0.2642063 -0.199256 -0.4672411
## fBodyBodyAccJerkMag-kurtosis()       -0.6082449 -0.508127 -0.7587060
## fBodyBodyGyroMag-mean()              -0.5791301 -0.628877 -0.6099843
## fBodyBodyGyroMag-std()               -0.6573687 -0.650924 -0.6366739
## fBodyBodyGyroMag-mad()               -0.6049375 -0.642431 -0.6092303
## fBodyBodyGyroMag-max()               -0.7176911 -0.668101 -0.6712550
## fBodyBodyGyroMag-min()               -0.8392234 -0.829373 -0.8347979
## fBodyBodyGyroMag-sma()               -0.5791301 -0.628877 -0.6099843
## fBodyBodyGyroMag-energy()            -0.8334541 -0.859488 -0.8244533
## fBodyBodyGyroMag-iqr()               -0.5883959 -0.697600 -0.6355292
## fBodyBodyGyroMag-entropy()            0.1285921  0.041165 -0.0335501
## fBodyBodyGyroMag-maxInds             -0.8668245 -0.919580 -0.8928734
## fBodyBodyGyroMag-meanFreq()           0.1041934 -0.035228 -0.0232242
## fBodyBodyGyroMag-skewness()          -0.4513679 -0.175919 -0.2240055
## fBodyBodyGyroMag-kurtosis()          -0.7288490 -0.493482 -0.5239956
## fBodyBodyGyroJerkMag-mean()          -0.6518869 -0.668879 -0.7021562
## fBodyBodyGyroJerkMag-std()           -0.6601759 -0.668963 -0.7557173
## fBodyBodyGyroJerkMag-mad()           -0.6344921 -0.639466 -0.7156659
## fBodyBodyGyroJerkMag-max()           -0.6896553 -0.697846 -0.7918702
## fBodyBodyGyroJerkMag-min()           -0.8069511 -0.821746 -0.8241433
## fBodyBodyGyroJerkMag-sma()           -0.6518869 -0.668879 -0.7021562
## fBodyBodyGyroJerkMag-energy()        -0.8683093 -0.870232 -0.9085272
## fBodyBodyGyroJerkMag-iqr()           -0.6389561 -0.659487 -0.6914730
## fBodyBodyGyroJerkMag-entropy()       -0.0363694 -0.125229 -0.2172919
## fBodyBodyGyroJerkMag-maxInds         -0.9313309 -0.901051 -0.8732418
## fBodyBodyGyroJerkMag-meanFreq()       0.0818176  0.063192  0.2237487
## fBodyBodyGyroJerkMag-skewness()      -0.2192801 -0.252253 -0.4412513
## fBodyBodyGyroJerkMag-kurtosis()      -0.5684126 -0.602510 -0.7412232
## angle(tBodyAccMean,gravity)          -0.0138330  0.002690  0.0241015
## angle(tBodyAccJerkMean),gravityMean) -0.0034817 -0.010143 -0.0447761
## angle(tBodyGyroMean,gravityMean)      0.0923274  0.042196 -0.0456563
## angle(tBodyGyroJerkMean,gravityMean) -0.0623474 -0.023012 -0.0142492
## angle(X,gravityMean)                 -0.5286579 -0.525683 -0.4640376
## angle(Y,gravityMean)                  0.0197335  0.108787  0.0469562
## angle(Z,gravityMean)                 -0.0125524 -0.033426 -0.0596438
##                                      subject_9 subject_10 subject_11
## tBodyAcc-mean()-X                     0.270314   0.276848  2.766e-01
## tBodyAcc-mean()-Y                    -0.020947  -0.017836 -1.913e-02
## tBodyAcc-mean()-Z                    -0.101234  -0.111302 -1.089e-01
## tBodyAcc-std()-X                     -0.555657  -0.537808 -5.895e-01
## tBodyAcc-std()-Y                     -0.575888  -0.497406 -4.904e-01
## tBodyAcc-std()-Z                     -0.506112  -0.614777 -6.653e-01
## tBodyAcc-mad()-X                     -0.585175  -0.567943 -6.126e-01
## tBodyAcc-mad()-Y                     -0.581992  -0.514818 -4.982e-01
## tBodyAcc-mad()-Z                     -0.499956  -0.615910 -6.532e-01
## tBodyAcc-max()-X                     -0.413250  -0.386095 -4.705e-01
## tBodyAcc-max()-Y                     -0.305332  -0.247375 -3.291e-01
## tBodyAcc-max()-Z                     -0.547846  -0.488660 -5.551e-01
## tBodyAcc-min()-X                      0.511255   0.433832  5.076e-01
## tBodyAcc-min()-Y                      0.471526   0.411396  3.815e-01
## tBodyAcc-min()-Z                      0.520373   0.625720  7.095e-01
## tBodyAcc-sma()                       -0.507745  -0.514379 -5.467e-01
## tBodyAcc-energy()-X                  -0.799754  -0.770479 -8.218e-01
## tBodyAcc-energy()-Y                  -0.938426  -0.904521 -9.056e-01
## tBodyAcc-energy()-Z                  -0.797355  -0.860848 -8.992e-01
## tBodyAcc-iqr()-X                     -0.656786  -0.620852 -6.640e-01
## tBodyAcc-iqr()-Y                     -0.671451  -0.642018 -6.155e-01
## tBodyAcc-iqr()-Z                     -0.527139  -0.634037 -6.434e-01
## tBodyAcc-entropy()-X                 -0.009695  -0.050960 -1.126e-01
## tBodyAcc-entropy()-Y                 -0.120812  -0.157324 -8.498e-02
## tBodyAcc-entropy()-Z                 -0.022630  -0.224508 -2.310e-01
## tBodyAcc-arCoeff()-X,1               -0.243673  -0.092193 -1.302e-01
## tBodyAcc-arCoeff()-X,2                0.160137   0.110414  1.034e-01
## tBodyAcc-arCoeff()-X,3                0.038060  -0.011864 -1.461e-02
## tBodyAcc-arCoeff()-X,4                0.080481   0.108540  1.436e-01
## tBodyAcc-arCoeff()-Y,1               -0.075596   0.052147 -2.137e-02
## tBodyAcc-arCoeff()-Y,2                0.018275  -0.013597  1.486e-02
## tBodyAcc-arCoeff()-Y,3                0.175231   0.174107  2.032e-01
## tBodyAcc-arCoeff()-Y,4                0.025016   0.022569 -2.137e-02
## tBodyAcc-arCoeff()-Z,1               -0.118821   0.124521  4.306e-02
## tBodyAcc-arCoeff()-Z,2                0.091147  -0.009948  1.223e-02
## tBodyAcc-arCoeff()-Z,3                0.037086   0.038097  5.307e-02
## tBodyAcc-arCoeff()-Z,4               -0.026722  -0.095709 -9.117e-02
## tBodyAcc-correlation()-X,Y           -0.104216  -0.093934 -2.105e-01
## tBodyAcc-correlation()-X,Z           -0.265625  -0.102112  2.787e-03
## tBodyAcc-correlation()-Y,Z            0.021208  -0.010505 -5.459e-02
## tGravityAcc-mean()-X                  0.670846   0.642906  7.305e-01
## tGravityAcc-mean()-Y                 -0.046745  -0.074025  5.274e-02
## tGravityAcc-mean()-Z                  0.104354   0.055205  1.402e-01
## tGravityAcc-std()-X                  -0.958785  -0.965808 -9.754e-01
## tGravityAcc-std()-Y                  -0.949938  -0.954524 -9.571e-01
## tGravityAcc-std()-Z                  -0.920554  -0.938706 -9.568e-01
## tGravityAcc-mad()-X                  -0.959551  -0.966520 -9.764e-01
## tGravityAcc-mad()-Y                  -0.951241  -0.955409 -9.576e-01
## tGravityAcc-mad()-Z                  -0.921847  -0.940279 -9.585e-01
## tGravityAcc-max()-X                   0.613698   0.582461  6.661e-01
## tGravityAcc-max()-Y                  -0.058271  -0.086171  3.592e-02
## tGravityAcc-max()-Z                   0.112578   0.060729  1.410e-01
## tGravityAcc-min()-X                   0.684042   0.658051  7.465e-01
## tGravityAcc-min()-Y                  -0.034689  -0.059972  6.563e-02
## tGravityAcc-min()-Z                   0.086634   0.042669  1.317e-01
## tGravityAcc-sma()                    -0.383766  -0.289626 -1.294e-01
## tGravityAcc-energy()-X                0.515609   0.425877  4.872e-01
## tGravityAcc-energy()-Y               -0.953004  -0.636681 -5.854e-01
## tGravityAcc-energy()-Z               -0.615732  -0.843957 -9.566e-01
## tGravityAcc-iqr()-X                  -0.961892  -0.968299 -9.784e-01
## tGravityAcc-iqr()-Y                  -0.954831  -0.958373 -9.600e-01
## tGravityAcc-iqr()-Z                  -0.926757  -0.945711 -9.631e-01
## tGravityAcc-entropy()-X              -0.734370  -0.749179 -6.855e-01
## tGravityAcc-entropy()-Y              -0.660090  -0.712083 -9.015e-01
## tGravityAcc-entropy()-Z              -0.711774  -0.471928 -4.237e-01
## tGravityAcc-arCoeff()-X,1            -0.503117  -0.445785 -5.207e-01
## tGravityAcc-arCoeff()-X,2             0.557192   0.494202  5.622e-01
## tGravityAcc-arCoeff()-X,3            -0.610483  -0.541931 -6.031e-01
## tGravityAcc-arCoeff()-X,4             0.663003   0.588996  6.435e-01
## tGravityAcc-arCoeff()-Y,1            -0.458110  -0.263785 -3.211e-01
## tGravityAcc-arCoeff()-Y,2             0.452226   0.263259  3.205e-01
## tGravityAcc-arCoeff()-Y,3            -0.483109  -0.312909 -3.663e-01
## tGravityAcc-arCoeff()-Y,4             0.528532   0.381915  4.300e-01
## tGravityAcc-arCoeff()-Z,1            -0.502595  -0.346077 -4.041e-01
## tGravityAcc-arCoeff()-Z,2             0.542896   0.367368  4.227e-01
## tGravityAcc-arCoeff()-Z,3            -0.582852  -0.387720 -4.405e-01
## tGravityAcc-arCoeff()-Z,4             0.619601   0.404674  4.549e-01
## tGravityAcc-correlation()-X,Y        -0.158427  -0.057180  9.525e-05
## tGravityAcc-correlation()-X,Z         0.002424  -0.228466 -2.183e-01
## tGravityAcc-correlation()-Y,Z         0.087382   0.042491  1.266e-01
## tBodyAccJerk-mean()-X                 0.084017   0.079811  8.301e-02
## tBodyAccJerk-mean()-Y                 0.006785   0.012914  7.804e-03
## tBodyAccJerk-mean()-Z                -0.001030  -0.011356 -6.574e-03
## tBodyAccJerk-std()-X                 -0.578305  -0.529383 -6.593e-01
## tBodyAccJerk-std()-Y                 -0.678924  -0.540237 -6.088e-01
## tBodyAccJerk-std()-Z                 -0.721610  -0.750729 -8.425e-01
## tBodyAccJerk-mad()-X                 -0.569240  -0.526082 -6.512e-01
## tBodyAccJerk-mad()-Y                 -0.659911  -0.535496 -5.893e-01
## tBodyAccJerk-mad()-Z                 -0.712175  -0.748816 -8.389e-01
## tBodyAccJerk-max()-X                 -0.660373  -0.601376 -7.205e-01
## tBodyAccJerk-max()-Y                 -0.797571  -0.688275 -7.680e-01
## tBodyAccJerk-max()-Z                 -0.778751  -0.807702 -8.791e-01
## tBodyAccJerk-min()-X                  0.596661   0.462394  6.543e-01
## tBodyAccJerk-min()-Y                  0.760029   0.622478  6.785e-01
## tBodyAccJerk-min()-Z                  0.708827   0.704264  8.195e-01
## tBodyAccJerk-sma()                   -0.621302  -0.581146 -6.814e-01
## tBodyAccJerk-energy()-X              -0.824622  -0.764189 -8.801e-01
## tBodyAccJerk-energy()-Y              -0.898339  -0.780382 -8.487e-01
## tBodyAccJerk-energy()-Z              -0.921105  -0.930831 -9.734e-01
## tBodyAccJerk-iqr()-X                 -0.546324  -0.509382 -6.370e-01
## tBodyAccJerk-iqr()-Y                 -0.702387  -0.630150 -6.520e-01
## tBodyAccJerk-iqr()-Z                 -0.727972  -0.766232 -8.460e-01
## tBodyAccJerk-entropy()-X              0.047566  -0.018314 -4.949e-02
## tBodyAccJerk-entropy()-Y             -0.052103  -0.060826 -3.267e-02
## tBodyAccJerk-entropy()-Z              0.013373  -0.128063 -1.779e-01
## tBodyAccJerk-arCoeff()-X,1           -0.254433  -0.093308 -1.358e-01
## tBodyAccJerk-arCoeff()-X,2            0.141648   0.188099  1.357e-01
## tBodyAccJerk-arCoeff()-X,3           -0.002265   0.093521  6.804e-02
## tBodyAccJerk-arCoeff()-X,4            0.227287   0.160581  1.276e-01
## tBodyAccJerk-arCoeff()-Y,1           -0.130433  -0.015239 -8.608e-02
## tBodyAccJerk-arCoeff()-Y,2           -0.003162   0.046843  2.988e-02
## tBodyAccJerk-arCoeff()-Y,3            0.080992   0.200289  1.920e-01
## tBodyAccJerk-arCoeff()-Y,4            0.348342   0.321143  3.541e-01
## tBodyAccJerk-arCoeff()-Z,1           -0.183175   0.083789  1.019e-02
## tBodyAccJerk-arCoeff()-Z,2            0.055242   0.119740  6.998e-02
## tBodyAccJerk-arCoeff()-Z,3           -0.090575   0.053361  3.230e-02
## tBodyAccJerk-arCoeff()-Z,4            0.169133   0.152004  1.136e-01
## tBodyAccJerk-correlation()-X,Y       -0.079319  -0.061004 -1.769e-01
## tBodyAccJerk-correlation()-X,Z        0.123154   0.019220  1.394e-01
## tBodyAccJerk-correlation()-Y,Z       -0.114242  -0.101968  4.131e-02
## tBodyGyro-mean()-X                   -0.070132  -0.018502 -5.473e-02
## tBodyGyro-mean()-Y                   -0.072988  -0.084640 -5.823e-02
## tBodyGyro-mean()-Z                    0.109093   0.091027  8.728e-02
## tBodyGyro-std()-X                    -0.676452  -0.673906 -7.399e-01
## tBodyGyro-std()-Y                    -0.670498  -0.591333 -7.035e-01
## tBodyGyro-std()-Z                    -0.587558  -0.598142 -7.250e-01
## tBodyGyro-mad()-X                    -0.679911  -0.679431 -7.479e-01
## tBodyGyro-mad()-Y                    -0.685891  -0.586178 -7.041e-01
## tBodyGyro-mad()-Z                    -0.597041  -0.626630 -7.461e-01
## tBodyGyro-max()-X                    -0.634877  -0.609987 -6.658e-01
## tBodyGyro-max()-Y                    -0.741110  -0.702714 -7.869e-01
## tBodyGyro-max()-Z                    -0.437098  -0.410180 -5.453e-01
## tBodyGyro-min()-X                     0.592104   0.606046  6.463e-01
## tBodyGyro-min()-Y                     0.710618   0.709562  7.757e-01
## tBodyGyro-min()-Z                     0.524386   0.512669  5.992e-01
## tBodyGyro-sma()                      -0.549542  -0.518073 -6.336e-01
## tBodyGyro-energy()-X                 -0.885244  -0.876638 -9.086e-01
## tBodyGyro-energy()-Y                 -0.901809  -0.828243 -9.110e-01
## tBodyGyro-energy()-Z                 -0.850081  -0.844132 -9.255e-01
## tBodyGyro-iqr()-X                    -0.677833  -0.682162 -7.582e-01
## tBodyGyro-iqr()-Y                    -0.715871  -0.579322 -7.096e-01
## tBodyGyro-iqr()-Z                    -0.645178  -0.706202 -8.060e-01
## tBodyGyro-entropy()-X                -0.060119  -0.150182 -2.284e-01
## tBodyGyro-entropy()-Y                 0.001874  -0.151189 -1.345e-01
## tBodyGyro-entropy()-Z                 0.009893  -0.058280 -7.769e-02
## tBodyGyro-arCoeff()-X,1              -0.354183  -0.205239 -3.214e-01
## tBodyGyro-arCoeff()-X,2               0.233021   0.130762  2.272e-01
## tBodyGyro-arCoeff()-X,3               0.101664   0.186142  9.634e-02
## tBodyGyro-arCoeff()-X,4              -0.113015  -0.150625 -8.918e-02
## tBodyGyro-arCoeff()-Y,1              -0.307559  -0.154585 -1.901e-01
## tBodyGyro-arCoeff()-Y,2               0.242738   0.135244  1.310e-01
## tBodyGyro-arCoeff()-Y,3              -0.048684  -0.028266  1.631e-02
## tBodyGyro-arCoeff()-Y,4               0.174791   0.184148  1.412e-01
## tBodyGyro-arCoeff()-Z,1              -0.263385  -0.109857 -1.384e-01
## tBodyGyro-arCoeff()-Z,2               0.152420   0.090932  8.800e-02
## tBodyGyro-arCoeff()-Z,3               0.024376  -0.045327  3.297e-02
## tBodyGyro-arCoeff()-Z,4               0.106158   0.200931  6.462e-02
## tBodyGyro-correlation()-X,Y          -0.039890  -0.046079 -6.486e-02
## tBodyGyro-correlation()-X,Z           0.052321  -0.015439  9.530e-02
## tBodyGyro-correlation()-Y,Z           0.050377   0.022920  1.234e-02
## tBodyGyroJerk-mean()-X               -0.089225  -0.108151 -8.055e-02
## tBodyGyroJerk-mean()-Y               -0.039734  -0.042422 -4.939e-02
## tBodyGyroJerk-mean()-Z               -0.053403  -0.055552 -4.801e-02
## tBodyGyroJerk-std()-X                -0.761711  -0.703243 -7.817e-01
## tBodyGyroJerk-std()-Y                -0.773274  -0.768642 -8.684e-01
## tBodyGyroJerk-std()-Z                -0.744656  -0.686800 -7.955e-01
## tBodyGyroJerk-mad()-X                -0.763637  -0.695726 -7.765e-01
## tBodyGyroJerk-mad()-Y                -0.779055  -0.778533 -8.691e-01
## tBodyGyroJerk-mad()-Z                -0.752110  -0.692750 -7.932e-01
## tBodyGyroJerk-max()-X                -0.746619  -0.722561 -7.996e-01
## tBodyGyroJerk-max()-Y                -0.792998  -0.805921 -8.924e-01
## tBodyGyroJerk-max()-Z                -0.721248  -0.680893 -7.936e-01
## tBodyGyroJerk-min()-X                 0.799679   0.753236  8.059e-01
## tBodyGyroJerk-min()-Y                 0.845671   0.814717  9.033e-01
## tBodyGyroJerk-min()-Z                 0.819718   0.771565  8.690e-01
## tBodyGyroJerk-sma()                  -0.768410  -0.736080 -8.266e-01
## tBodyGyroJerk-energy()-X             -0.948851  -0.912384 -9.532e-01
## tBodyGyroJerk-energy()-Y             -0.948140  -0.945897 -9.826e-01
## tBodyGyroJerk-energy()-Z             -0.935356  -0.895874 -9.559e-01
## tBodyGyroJerk-iqr()-X                -0.775673  -0.693929 -7.738e-01
## tBodyGyroJerk-iqr()-Y                -0.784490  -0.790100 -8.673e-01
## tBodyGyroJerk-iqr()-Z                -0.774849  -0.716542 -7.972e-01
## tBodyGyroJerk-entropy()-X             0.114600   0.015964 -2.223e-02
## tBodyGyroJerk-entropy()-Y             0.137382   0.063724 -5.730e-02
## tBodyGyroJerk-entropy()-Z             0.042172   0.014038 -8.462e-03
## tBodyGyroJerk-arCoeff()-X,1          -0.173665  -0.047569 -1.631e-01
## tBodyGyroJerk-arCoeff()-X,2           0.056471   0.029512  5.966e-02
## tBodyGyroJerk-arCoeff()-X,3           0.158442   0.205354  1.785e-01
## tBodyGyroJerk-arCoeff()-X,4           0.096460   0.190505  1.047e-01
## tBodyGyroJerk-arCoeff()-Y,1          -0.290445  -0.128343 -1.535e-01
## tBodyGyroJerk-arCoeff()-Y,2           0.220250   0.179219  1.404e-01
## tBodyGyroJerk-arCoeff()-Y,3           0.001266   0.084021  1.092e-01
## tBodyGyroJerk-arCoeff()-Y,4           0.171195   0.106208  9.826e-02
## tBodyGyroJerk-arCoeff()-Z,1          -0.217769  -0.069066 -6.600e-02
## tBodyGyroJerk-arCoeff()-Z,2           0.019986   0.072484  2.868e-02
## tBodyGyroJerk-arCoeff()-Z,3           0.045546   0.031524  1.462e-01
## tBodyGyroJerk-arCoeff()-Z,4           0.048105   0.056717 -1.114e-02
## tBodyGyroJerk-correlation()-X,Y      -0.011129   0.012412  1.039e-01
## tBodyGyroJerk-correlation()-X,Z       0.167045  -0.153199 -5.747e-02
## tBodyGyroJerk-correlation()-Y,Z       0.118755   0.050020  2.742e-02
## tBodyAccMag-mean()                   -0.505183  -0.502500 -5.428e-01
## tBodyAccMag-std()                    -0.553038  -0.545349 -6.129e-01
## tBodyAccMag-mad()                    -0.613478  -0.596592 -6.523e-01
## tBodyAccMag-max()                    -0.530875  -0.520496 -5.852e-01
## tBodyAccMag-min()                    -0.819609  -0.816338 -8.407e-01
## tBodyAccMag-sma()                    -0.505183  -0.502500 -5.428e-01
## tBodyAccMag-energy()                 -0.762463  -0.738741 -7.881e-01
## tBodyAccMag-iqr()                    -0.693649  -0.653278 -6.931e-01
## tBodyAccMag-entropy()                 0.279319   0.140024  1.151e-01
## tBodyAccMag-arCoeff()1               -0.176990   0.031940 -5.255e-02
## tBodyAccMag-arCoeff()2                0.097006  -0.067328  1.218e-02
## tBodyAccMag-arCoeff()3                0.050539   0.149118  5.633e-02
## tBodyAccMag-arCoeff()4               -0.057228  -0.121169 -4.705e-02
## tGravityAccMag-mean()                -0.505183  -0.502500 -5.428e-01
## tGravityAccMag-std()                 -0.553038  -0.545349 -6.129e-01
## tGravityAccMag-mad()                 -0.613478  -0.596592 -6.523e-01
## tGravityAccMag-max()                 -0.530875  -0.520496 -5.852e-01
## tGravityAccMag-min()                 -0.819609  -0.816338 -8.407e-01
## tGravityAccMag-sma()                 -0.505183  -0.502500 -5.428e-01
## tGravityAccMag-energy()              -0.762463  -0.738741 -7.881e-01
## tGravityAccMag-iqr()                 -0.693649  -0.653278 -6.931e-01
## tGravityAccMag-entropy()              0.279319   0.140024  1.151e-01
## tGravityAccMag-arCoeff()1            -0.176990   0.031940 -5.255e-02
## tGravityAccMag-arCoeff()2             0.097006  -0.067328  1.218e-02
## tGravityAccMag-arCoeff()3             0.050539   0.149118  5.633e-02
## tGravityAccMag-arCoeff()4            -0.057228  -0.121169 -4.705e-02
## tBodyAccJerkMag-mean()               -0.621608  -0.577762 -6.798e-01
## tBodyAccJerkMag-std()                -0.608862  -0.529340 -6.642e-01
## tBodyAccJerkMag-mad()                -0.621701  -0.562573 -6.772e-01
## tBodyAccJerkMag-max()                -0.636669  -0.528863 -6.801e-01
## tBodyAccJerkMag-min()                -0.799650  -0.765949 -8.196e-01
## tBodyAccJerkMag-sma()                -0.621608  -0.577762 -6.798e-01
## tBodyAccJerkMag-energy()             -0.851764  -0.795415 -8.896e-01
## tBodyAccJerkMag-iqr()                -0.669035  -0.634178 -7.175e-01
## tBodyAccJerkMag-entropy()             0.070013  -0.001171 -3.614e-02
## tBodyAccJerkMag-arCoeff()1           -0.018295   0.116061  5.254e-02
## tBodyAccJerkMag-arCoeff()2            0.058418  -0.107477  7.275e-03
## tBodyAccJerkMag-arCoeff()3           -0.006108  -0.048119 -6.839e-02
## tBodyAccJerkMag-arCoeff()4           -0.129471  -0.019512 -8.449e-02
## tBodyGyroMag-mean()                  -0.550202  -0.521820 -6.284e-01
## tBodyGyroMag-std()                   -0.663198  -0.624408 -6.968e-01
## tBodyGyroMag-mad()                   -0.626993  -0.584156 -6.657e-01
## tBodyGyroMag-max()                   -0.687183  -0.658518 -7.396e-01
## tBodyGyroMag-min()                   -0.638353  -0.666573 -7.522e-01
## tBodyGyroMag-sma()                   -0.550202  -0.521820 -6.284e-01
## tBodyGyroMag-energy()                -0.826695  -0.779389 -8.665e-01
## tBodyGyroMag-iqr()                   -0.642010  -0.603694 -6.833e-01
## tBodyGyroMag-entropy()                0.396390   0.127905  2.655e-01
## tBodyGyroMag-arCoeff()1              -0.134986   0.005768 -1.445e-01
## tBodyGyroMag-arCoeff()2               0.019133  -0.085595  3.648e-02
## tBodyGyroMag-arCoeff()3               0.100129   0.107935  4.518e-02
## tBodyGyroMag-arCoeff()4              -0.081713  -0.065034 -9.774e-03
## tBodyGyroJerkMag-mean()              -0.762980  -0.734466 -8.268e-01
## tBodyGyroJerkMag-std()               -0.786177  -0.768822 -8.669e-01
## tBodyGyroJerkMag-mad()               -0.796944  -0.779985 -8.722e-01
## tBodyGyroJerkMag-max()               -0.795635  -0.778060 -8.716e-01
## tBodyGyroJerkMag-min()               -0.796349  -0.748490 -8.214e-01
## tBodyGyroJerkMag-sma()               -0.762980  -0.734466 -8.268e-01
## tBodyGyroJerkMag-energy()            -0.946364  -0.931943 -9.728e-01
## tBodyGyroJerkMag-iqr()               -0.806594  -0.787599 -8.732e-01
## tBodyGyroJerkMag-entropy()            0.315574   0.208858  7.182e-02
## tBodyGyroJerkMag-arCoeff()1           0.232590   0.307456  2.098e-01
## tBodyGyroJerkMag-arCoeff()2          -0.161324  -0.220384 -1.427e-01
## tBodyGyroJerkMag-arCoeff()3          -0.016063  -0.034943 -2.642e-02
## tBodyGyroJerkMag-arCoeff()4          -0.196946  -0.171350 -2.008e-01
## fBodyAcc-mean()-X                    -0.579258  -0.532289 -6.195e-01
## fBodyAcc-mean()-Y                    -0.610268  -0.494651 -5.315e-01
## fBodyAcc-mean()-Z                    -0.592119  -0.655062 -7.500e-01
## fBodyAcc-std()-X                     -0.547996  -0.541170 -5.795e-01
## fBodyAcc-std()-Y                     -0.586766  -0.532135 -5.026e-01
## fBodyAcc-std()-Z                     -0.501074  -0.625872 -6.521e-01
## fBodyAcc-mad()-X                     -0.525031  -0.509996 -5.762e-01
## fBodyAcc-mad()-Y                     -0.592698  -0.507312 -5.045e-01
## fBodyAcc-mad()-Z                     -0.540027  -0.642707 -7.195e-01
## fBodyAcc-max()-X                     -0.618326  -0.609755 -6.228e-01
## fBodyAcc-max()-Y                     -0.702926  -0.673954 -6.199e-01
## fBodyAcc-max()-Z                     -0.496503  -0.624525 -6.076e-01
## fBodyAcc-min()-X                     -0.841865  -0.819306 -8.560e-01
## fBodyAcc-min()-Y                     -0.899105  -0.858248 -8.801e-01
## fBodyAcc-min()-Z                     -0.904607  -0.890828 -9.303e-01
## fBodyAcc-sma()                       -0.530618  -0.492484 -5.805e-01
## fBodyAcc-energy()-X                  -0.800466  -0.770717 -8.219e-01
## fBodyAcc-energy()-Y                  -0.842777  -0.754864 -7.561e-01
## fBodyAcc-energy()-Z                  -0.776743  -0.846177 -8.869e-01
## fBodyAcc-iqr()-X                     -0.638414  -0.545551 -6.700e-01
## fBodyAcc-iqr()-Y                     -0.734336  -0.606608 -6.511e-01
## fBodyAcc-iqr()-Z                     -0.711950  -0.737431 -8.255e-01
## fBodyAcc-entropy()-X                 -0.076530  -0.118252 -1.898e-01
## fBodyAcc-entropy()-Y                 -0.144562  -0.117924 -1.636e-01
## fBodyAcc-entropy()-Z                 -0.065259  -0.188748 -2.875e-01
## fBodyAcc-maxInds-X                   -0.716398  -0.705508 -7.560e-01
## fBodyAcc-maxInds-Y                   -0.798148  -0.761451 -7.622e-01
## fBodyAcc-maxInds-Z                   -0.756143  -0.862899 -8.659e-01
## fBodyAcc-meanFreq()-X                -0.291349  -0.156151 -2.244e-01
## fBodyAcc-meanFreq()-Y                -0.087900   0.094813  3.186e-02
## fBodyAcc-meanFreq()-Z                -0.030433   0.150687  5.028e-02
## fBodyAcc-skewness()-X                -0.164121  -0.230920 -1.806e-01
## fBodyAcc-kurtosis()-X                -0.523332  -0.572974 -5.193e-01
## fBodyAcc-skewness()-Y                -0.229582  -0.340767 -2.889e-01
## fBodyAcc-kurtosis()-Y                -0.564785  -0.651773 -5.979e-01
## fBodyAcc-skewness()-Z                -0.188662  -0.316268 -1.738e-01
## fBodyAcc-kurtosis()-Z                -0.440169  -0.546557 -3.804e-01
## fBodyAcc-bandsEnergy()-1,8           -0.817080  -0.768795 -8.018e-01
## fBodyAcc-bandsEnergy()-9,16          -0.783232  -0.840913 -9.038e-01
## fBodyAcc-bandsEnergy()-17,24         -0.885043  -0.789702 -8.903e-01
## fBodyAcc-bandsEnergy()-25,32         -0.931703  -0.810168 -9.293e-01
## fBodyAcc-bandsEnergy()-33,40         -0.920764  -0.864567 -9.291e-01
## fBodyAcc-bandsEnergy()-41,48         -0.914203  -0.868738 -9.302e-01
## fBodyAcc-bandsEnergy()-49,56         -0.942593  -0.922757 -9.466e-01
## fBodyAcc-bandsEnergy()-57,64         -0.948598  -0.940601 -9.481e-01
## fBodyAcc-bandsEnergy()-1,16          -0.790128  -0.768559 -8.135e-01
## fBodyAcc-bandsEnergy()-17,32         -0.880977  -0.762887 -8.847e-01
## fBodyAcc-bandsEnergy()-33,48         -0.918319  -0.866144 -9.296e-01
## fBodyAcc-bandsEnergy()-49,64         -0.944606  -0.928738 -9.471e-01
## fBodyAcc-bandsEnergy()-1,24          -0.796876  -0.770063 -8.189e-01
## fBodyAcc-bandsEnergy()-25,48         -0.911965  -0.800111 -9.157e-01
## fBodyAcc-bandsEnergy()-1,8.1         -0.872126  -0.822666 -7.827e-01
## fBodyAcc-bandsEnergy()-9,16.1        -0.880817  -0.824413 -8.496e-01
## fBodyAcc-bandsEnergy()-17,24.1       -0.944057  -0.826230 -8.820e-01
## fBodyAcc-bandsEnergy()-25,32.1       -0.936522  -0.830862 -9.376e-01
## fBodyAcc-bandsEnergy()-33,40.1       -0.928928  -0.850812 -9.231e-01
## fBodyAcc-bandsEnergy()-41,48.1       -0.925459  -0.824546 -8.911e-01
## fBodyAcc-bandsEnergy()-49,56.1       -0.937380  -0.872012 -9.101e-01
## fBodyAcc-bandsEnergy()-57,64.1       -0.967592  -0.946777 -9.544e-01
## fBodyAcc-bandsEnergy()-1,16.1        -0.840719  -0.773803 -7.561e-01
## fBodyAcc-bandsEnergy()-17,32.1       -0.927602  -0.783206 -8.680e-01
## fBodyAcc-bandsEnergy()-33,48.1       -0.919479  -0.823659 -9.020e-01
## fBodyAcc-bandsEnergy()-49,64.1       -0.948097  -0.899408 -9.259e-01
## fBodyAcc-bandsEnergy()-1,24.1        -0.844570  -0.762634 -7.563e-01
## fBodyAcc-bandsEnergy()-25,48.1       -0.928009  -0.820029 -9.234e-01
## fBodyAcc-bandsEnergy()-1,8.2         -0.791405  -0.851110 -8.741e-01
## fBodyAcc-bandsEnergy()-9,16.2        -0.845257  -0.941112 -9.700e-01
## fBodyAcc-bandsEnergy()-17,24.2       -0.937888  -0.932708 -9.703e-01
## fBodyAcc-bandsEnergy()-25,32.2       -0.969742  -0.941256 -9.837e-01
## fBodyAcc-bandsEnergy()-33,40.2       -0.957825  -0.949845 -9.858e-01
## fBodyAcc-bandsEnergy()-41,48.2       -0.932752  -0.923426 -9.692e-01
## fBodyAcc-bandsEnergy()-49,56.2       -0.929828  -0.928222 -9.703e-01
## fBodyAcc-bandsEnergy()-57,64.2       -0.946168  -0.951214 -9.719e-01
## fBodyAcc-bandsEnergy()-1,16.2        -0.783381  -0.862018 -8.897e-01
## fBodyAcc-bandsEnergy()-17,32.2       -0.949460  -0.935837 -9.752e-01
## fBodyAcc-bandsEnergy()-33,48.2       -0.948356  -0.939460 -9.805e-01
## fBodyAcc-bandsEnergy()-49,64.2       -0.934139  -0.934514 -9.706e-01
## fBodyAcc-bandsEnergy()-1,24.2        -0.778229  -0.852983 -8.875e-01
## fBodyAcc-bandsEnergy()-25,48.2       -0.963660  -0.940760 -9.828e-01
## fBodyAccJerk-mean()-X                -0.621377  -0.547243 -6.767e-01
## fBodyAccJerk-mean()-Y                -0.699767  -0.555105 -6.324e-01
## fBodyAccJerk-mean()-Z                -0.702932  -0.721690 -8.256e-01
## fBodyAccJerk-std()-X                 -0.572820  -0.553403 -6.722e-01
## fBodyAccJerk-std()-Y                 -0.679066  -0.556272 -6.094e-01
## fBodyAccJerk-std()-Z                 -0.739140  -0.779168 -8.583e-01
## fBodyAccJerk-mad()-X                 -0.529770  -0.468300 -6.174e-01
## fBodyAccJerk-mad()-Y                 -0.699923  -0.561360 -6.236e-01
## fBodyAccJerk-mad()-Z                 -0.724116  -0.755148 -8.453e-01
## fBodyAccJerk-max()-X                 -0.625732  -0.617124 -7.178e-01
## fBodyAccJerk-max()-Y                 -0.707393  -0.649869 -6.799e-01
## fBodyAccJerk-max()-Z                 -0.761690  -0.811062 -8.711e-01
## fBodyAccJerk-min()-X                 -0.875664  -0.842350 -8.805e-01
## fBodyAccJerk-min()-Y                 -0.883582  -0.823126 -8.630e-01
## fBodyAccJerk-min()-Z                 -0.878950  -0.854825 -9.171e-01
## fBodyAccJerk-sma()                   -0.611545  -0.536203 -6.623e-01
## fBodyAccJerk-energy()-X              -0.824410  -0.763874 -8.800e-01
## fBodyAccJerk-energy()-Y              -0.898395  -0.780468 -8.487e-01
## fBodyAccJerk-energy()-Z              -0.921142  -0.930859 -9.735e-01
## fBodyAccJerk-iqr()-X                 -0.623691  -0.509590 -6.608e-01
## fBodyAccJerk-iqr()-Y                 -0.775468  -0.657344 -7.246e-01
## fBodyAccJerk-iqr()-Z                 -0.740340  -0.750808 -8.442e-01
## fBodyAccJerk-entropy()-X             -0.157223  -0.166237 -2.393e-01
## fBodyAccJerk-entropy()-Y             -0.275234  -0.184806 -2.164e-01
## fBodyAccJerk-entropy()-Z             -0.229881  -0.326957 -4.389e-01
## fBodyAccJerk-maxInds-X               -0.496111  -0.411020 -4.556e-01
## fBodyAccJerk-maxInds-Y               -0.486806  -0.372109 -4.465e-01
## fBodyAccJerk-maxInds-Z               -0.496250  -0.214422 -3.425e-01
## fBodyAccJerk-meanFreq()-X            -0.219176  -0.031301 -8.743e-02
## fBodyAccJerk-meanFreq()-Y            -0.296108  -0.148941 -2.426e-01
## fBodyAccJerk-meanFreq()-Z            -0.290292   0.011239 -9.923e-02
## fBodyAccJerk-skewness()-X            -0.177773  -0.297103 -2.946e-01
## fBodyAccJerk-kurtosis()-X            -0.617750  -0.694123 -6.982e-01
## fBodyAccJerk-skewness()-Y            -0.334749  -0.416044 -3.630e-01
## fBodyAccJerk-kurtosis()-Y            -0.746900  -0.834243 -8.037e-01
## fBodyAccJerk-skewness()-Z            -0.423756  -0.538776 -4.998e-01
## fBodyAccJerk-kurtosis()-Z            -0.777952  -0.855449 -8.225e-01
## fBodyAccJerk-bandsEnergy()-1,8       -0.860976  -0.809442 -8.635e-01
## fBodyAccJerk-bandsEnergy()-9,16      -0.779078  -0.817732 -9.153e-01
## fBodyAccJerk-bandsEnergy()-17,24     -0.906441  -0.805787 -9.061e-01
## fBodyAccJerk-bandsEnergy()-25,32     -0.939164  -0.809280 -9.366e-01
## fBodyAccJerk-bandsEnergy()-33,40     -0.933552  -0.873252 -9.404e-01
## fBodyAccJerk-bandsEnergy()-41,48     -0.908391  -0.849382 -9.304e-01
## fBodyAccJerk-bandsEnergy()-49,56     -0.948497  -0.915768 -9.549e-01
## fBodyAccJerk-bandsEnergy()-57,64     -0.987172  -0.976651 -9.861e-01
## fBodyAccJerk-bandsEnergy()-1,16      -0.796260  -0.798016 -8.847e-01
## fBodyAccJerk-bandsEnergy()-17,32     -0.899008  -0.762008 -8.976e-01
## fBodyAccJerk-bandsEnergy()-33,48     -0.917680  -0.852892 -9.313e-01
## fBodyAccJerk-bandsEnergy()-49,64     -0.946909  -0.912713 -9.529e-01
## fBodyAccJerk-bandsEnergy()-1,24      -0.801230  -0.763884 -8.718e-01
## fBodyAccJerk-bandsEnergy()-25,48     -0.899778  -0.760351 -9.070e-01
## fBodyAccJerk-bandsEnergy()-1,8.1     -0.914717  -0.834115 -8.183e-01
## fBodyAccJerk-bandsEnergy()-9,16.1    -0.903668  -0.855078 -8.781e-01
## fBodyAccJerk-bandsEnergy()-17,24.1   -0.937292  -0.785173 -8.631e-01
## fBodyAccJerk-bandsEnergy()-25,32.1   -0.937044  -0.838729 -9.433e-01
## fBodyAccJerk-bandsEnergy()-33,40.1   -0.941225  -0.872790 -9.396e-01
## fBodyAccJerk-bandsEnergy()-41,48.1   -0.923374  -0.807028 -8.849e-01
## fBodyAccJerk-bandsEnergy()-49,56.1   -0.952777  -0.886925 -9.310e-01
## fBodyAccJerk-bandsEnergy()-57,64.1   -0.986426  -0.954235 -9.760e-01
## fBodyAccJerk-bandsEnergy()-1,16.1    -0.892563  -0.829518 -8.467e-01
## fBodyAccJerk-bandsEnergy()-17,32.1   -0.924568  -0.767212 -8.734e-01
## fBodyAccJerk-bandsEnergy()-33,48.1   -0.919507  -0.814145 -9.018e-01
## fBodyAccJerk-bandsEnergy()-49,64.1   -0.957026  -0.895420 -9.367e-01
## fBodyAccJerk-bandsEnergy()-1,24.1    -0.894243  -0.781401 -8.282e-01
## fBodyAccJerk-bandsEnergy()-25,48.1   -0.929451  -0.827094 -9.266e-01
## fBodyAccJerk-bandsEnergy()-1,8.2     -0.821721  -0.930305 -9.543e-01
## fBodyAccJerk-bandsEnergy()-9,16.2    -0.847335  -0.938734 -9.698e-01
## fBodyAccJerk-bandsEnergy()-17,24.2   -0.944607  -0.934576 -9.728e-01
## fBodyAccJerk-bandsEnergy()-25,32.2   -0.970985  -0.941381 -9.847e-01
## fBodyAccJerk-bandsEnergy()-33,40.2   -0.963272  -0.952988 -9.876e-01
## fBodyAccJerk-bandsEnergy()-41,48.2   -0.939502  -0.928827 -9.739e-01
## fBodyAccJerk-bandsEnergy()-49,56.2   -0.922627  -0.914627 -9.718e-01
## fBodyAccJerk-bandsEnergy()-57,64.2   -0.979427  -0.962939 -9.896e-01
## fBodyAccJerk-bandsEnergy()-1,16.2    -0.806104  -0.922865 -9.579e-01
## fBodyAccJerk-bandsEnergy()-17,32.2   -0.957533  -0.937932 -9.786e-01
## fBodyAccJerk-bandsEnergy()-33,48.2   -0.953635  -0.942544 -9.826e-01
## fBodyAccJerk-bandsEnergy()-49,64.2   -0.924227  -0.914748 -9.721e-01
## fBodyAccJerk-bandsEnergy()-1,24.2    -0.876112  -0.921007 -9.627e-01
## fBodyAccJerk-bandsEnergy()-25,48.2   -0.964195  -0.941863 -9.839e-01
## fBodyGyro-mean()-X                   -0.639863  -0.620379 -7.099e-01
## fBodyGyro-mean()-Y                   -0.683924  -0.648351 -7.769e-01
## fBodyGyro-mean()-Z                   -0.612680  -0.567457 -7.088e-01
## fBodyGyro-std()-X                    -0.690690  -0.692654 -7.518e-01
## fBodyGyro-std()-Y                    -0.667203  -0.565944 -6.709e-01
## fBodyGyro-std()-Z                    -0.619469  -0.645948 -7.560e-01
## fBodyGyro-mad()-X                    -0.654160  -0.638161 -7.102e-01
## fBodyGyro-mad()-Y                    -0.689384  -0.659802 -7.600e-01
## fBodyGyro-mad()-Z                    -0.581748  -0.568519 -6.980e-01
## fBodyGyro-max()-X                    -0.680580  -0.677523 -7.397e-01
## fBodyGyro-max()-Y                    -0.752159  -0.593457 -6.822e-01
## fBodyGyro-max()-Z                    -0.692391  -0.748565 -8.280e-01
## fBodyGyro-min()-X                    -0.902582  -0.920474 -9.359e-01
## fBodyGyro-min()-Y                    -0.897086  -0.865492 -9.257e-01
## fBodyGyro-min()-Z                    -0.896974  -0.890236 -9.282e-01
## fBodyGyro-sma()                      -0.630640  -0.596273 -7.222e-01
## fBodyGyro-energy()-X                 -0.905646  -0.893345 -9.285e-01
## fBodyGyro-energy()-Y                 -0.903385  -0.829387 -9.125e-01
## fBodyGyro-energy()-Z                 -0.843773  -0.834964 -9.260e-01
## fBodyGyro-iqr()-X                    -0.725900  -0.656352 -7.503e-01
## fBodyGyro-iqr()-Y                    -0.731695  -0.738971 -8.468e-01
## fBodyGyro-iqr()-Z                    -0.699623  -0.629281 -7.420e-01
## fBodyGyro-entropy()-X                 0.052049  -0.046499 -1.474e-01
## fBodyGyro-entropy()-Y                 0.111427  -0.003276 -1.749e-01
## fBodyGyro-entropy()-Z                -0.082872  -0.087148 -1.553e-01
## fBodyGyro-maxInds-X                  -0.914815  -0.881633 -8.781e-01
## fBodyGyro-maxInds-Y                  -0.738799  -0.680930 -7.666e-01
## fBodyGyro-maxInds-Z                  -0.774425  -0.814684 -8.577e-01
## fBodyGyro-meanFreq()-X               -0.205909  -0.066315 -1.119e-01
## fBodyGyro-meanFreq()-Y               -0.240880  -0.088152 -1.818e-01
## fBodyGyro-meanFreq()-Z               -0.196153  -0.050074 -8.110e-02
## fBodyGyro-skewness()-X               -0.134612  -0.204940 -2.037e-01
## fBodyGyro-kurtosis()-X               -0.471263  -0.513083 -5.217e-01
## fBodyGyro-skewness()-Y               -0.243920  -0.165533 -1.208e-01
## fBodyGyro-kurtosis()-Y               -0.612189  -0.506476 -4.426e-01
## fBodyGyro-skewness()-Z               -0.179202  -0.245630 -2.849e-01
## fBodyGyro-kurtosis()-Z               -0.514050  -0.571799 -6.165e-01
## fBodyGyro-bandsEnergy()-1,8          -0.910253  -0.907317 -9.363e-01
## fBodyGyro-bandsEnergy()-9,16         -0.946571  -0.893338 -9.350e-01
## fBodyGyro-bandsEnergy()-17,24        -0.955428  -0.925158 -9.472e-01
## fBodyGyro-bandsEnergy()-25,32        -0.967932  -0.955903 -9.853e-01
## fBodyGyro-bandsEnergy()-33,40        -0.947132  -0.943453 -9.800e-01
## fBodyGyro-bandsEnergy()-41,48        -0.949625  -0.944534 -9.768e-01
## fBodyGyro-bandsEnergy()-49,56        -0.955607  -0.957345 -9.767e-01
## fBodyGyro-bandsEnergy()-57,64        -0.959788  -0.969065 -9.784e-01
## fBodyGyro-bandsEnergy()-1,16         -0.907720  -0.897181 -9.306e-01
## fBodyGyro-bandsEnergy()-17,32        -0.951066  -0.921811 -9.516e-01
## fBodyGyro-bandsEnergy()-33,48        -0.942832  -0.938208 -9.767e-01
## fBodyGyro-bandsEnergy()-49,64        -0.957457  -0.962531 -9.775e-01
## fBodyGyro-bandsEnergy()-1,24         -0.906870  -0.894859 -9.289e-01
## fBodyGyro-bandsEnergy()-25,48        -0.960337  -0.950314 -9.827e-01
## fBodyGyro-bandsEnergy()-1,8.1        -0.912105  -0.759504 -8.658e-01
## fBodyGyro-bandsEnergy()-9,16.1       -0.941715  -0.963567 -9.860e-01
## fBodyGyro-bandsEnergy()-17,24.1      -0.973682  -0.978145 -9.916e-01
## fBodyGyro-bandsEnergy()-25,32.1      -0.978572  -0.967875 -9.948e-01
## fBodyGyro-bandsEnergy()-33,40.1      -0.979029  -0.964920 -9.937e-01
## fBodyGyro-bandsEnergy()-41,48.1      -0.957943  -0.946567 -9.865e-01
## fBodyGyro-bandsEnergy()-49,56.1      -0.959485  -0.942302 -9.816e-01
## fBodyGyro-bandsEnergy()-57,64.1      -0.979701  -0.965116 -9.852e-01
## fBodyGyro-bandsEnergy()-1,16.1       -0.902912  -0.814372 -9.006e-01
## fBodyGyro-bandsEnergy()-17,32.1      -0.968892  -0.969831 -9.906e-01
## fBodyGyro-bandsEnergy()-33,48.1      -0.974485  -0.960792 -9.922e-01
## fBodyGyro-bandsEnergy()-49,64.1      -0.962731  -0.944335 -9.807e-01
## fBodyGyro-bandsEnergy()-1,24.1       -0.897220  -0.817172 -9.037e-01
## fBodyGyro-bandsEnergy()-25,48.1      -0.975629  -0.963163 -9.935e-01
## fBodyGyro-bandsEnergy()-1,8.2        -0.863925  -0.876196 -9.462e-01
## fBodyGyro-bandsEnergy()-9,16.2       -0.941225  -0.898987 -9.479e-01
## fBodyGyro-bandsEnergy()-17,24.2      -0.955366  -0.930472 -9.676e-01
## fBodyGyro-bandsEnergy()-25,32.2      -0.983599  -0.950302 -9.866e-01
## fBodyGyro-bandsEnergy()-33,40.2      -0.983478  -0.961449 -9.906e-01
## fBodyGyro-bandsEnergy()-41,48.2      -0.969481  -0.951064 -9.819e-01
## fBodyGyro-bandsEnergy()-49,56.2      -0.954839  -0.931226 -9.743e-01
## fBodyGyro-bandsEnergy()-57,64.2      -0.961430  -0.952153 -9.839e-01
## fBodyGyro-bandsEnergy()-1,16.2       -0.850853  -0.848379 -9.313e-01
## fBodyGyro-bandsEnergy()-17,32.2      -0.949501  -0.909644 -9.626e-01
## fBodyGyro-bandsEnergy()-33,48.2      -0.979652  -0.958519 -9.882e-01
## fBodyGyro-bandsEnergy()-49,64.2      -0.957705  -0.940324 -9.785e-01
## fBodyGyro-bandsEnergy()-1,24.2       -0.845559  -0.839752 -9.273e-01
## fBodyGyro-bandsEnergy()-25,48.2      -0.982377  -0.952854 -9.871e-01
## fBodyAccMag-mean()                   -0.553186  -0.518734 -6.115e-01
## fBodyAccMag-std()                    -0.624457  -0.633196 -6.745e-01
## fBodyAccMag-mad()                    -0.546123  -0.560493 -6.111e-01
## fBodyAccMag-max()                    -0.741092  -0.739467 -7.746e-01
## fBodyAccMag-min()                    -0.888814  -0.856429 -8.953e-01
## fBodyAccMag-sma()                    -0.553186  -0.518734 -6.115e-01
## fBodyAccMag-energy()                 -0.803100  -0.793898 -8.472e-01
## fBodyAccMag-iqr()                    -0.658504  -0.662387 -7.078e-01
## fBodyAccMag-entropy()                -0.074578  -0.135326 -1.996e-01
## fBodyAccMag-maxInds                  -0.732040  -0.752053 -6.894e-01
## fBodyAccMag-meanFreq()               -0.003583   0.173254  1.273e-01
## fBodyAccMag-skewness()               -0.364914  -0.418344 -4.210e-01
## fBodyAccMag-kurtosis()               -0.654878  -0.686749 -6.961e-01
## fBodyBodyAccJerkMag-mean()           -0.609194  -0.515141 -6.561e-01
## fBodyBodyAccJerkMag-std()            -0.611619  -0.553027 -6.769e-01
## fBodyBodyAccJerkMag-mad()            -0.600411  -0.511922 -6.453e-01
## fBodyBodyAccJerkMag-max()            -0.637215  -0.626339 -7.194e-01
## fBodyBodyAccJerkMag-min()            -0.792029  -0.734330 -8.363e-01
## fBodyBodyAccJerkMag-sma()            -0.609194  -0.515141 -6.561e-01
## fBodyBodyAccJerkMag-energy()         -0.845843  -0.769003 -8.847e-01
## fBodyBodyAccJerkMag-iqr()            -0.664966  -0.602417 -7.024e-01
## fBodyBodyAccJerkMag-entropy()        -0.266530  -0.241462 -3.293e-01
## fBodyBodyAccJerkMag-maxInds          -0.900904  -0.867833 -8.979e-01
## fBodyBodyAccJerkMag-meanFreq()        0.098360   0.163073  1.584e-01
## fBodyBodyAccJerkMag-skewness()       -0.146345  -0.334668 -2.953e-01
## fBodyBodyAccJerkMag-kurtosis()       -0.448280  -0.655902 -6.039e-01
## fBodyBodyGyroMag-mean()              -0.700863  -0.661497 -7.576e-01
## fBodyBodyGyroMag-std()               -0.697729  -0.666015 -7.113e-01
## fBodyBodyGyroMag-mad()               -0.675545  -0.634437 -7.037e-01
## fBodyBodyGyroMag-max()               -0.735488  -0.717727 -7.431e-01
## fBodyBodyGyroMag-min()               -0.895827  -0.889005 -9.225e-01
## fBodyBodyGyroMag-sma()               -0.700863  -0.661497 -7.576e-01
## fBodyBodyGyroMag-energy()            -0.906480  -0.863589 -9.095e-01
## fBodyBodyGyroMag-iqr()               -0.713014  -0.670479 -7.725e-01
## fBodyBodyGyroMag-entropy()            0.051152  -0.017243 -1.469e-01
## fBodyBodyGyroMag-maxInds             -0.892450  -0.858713 -8.913e-01
## fBodyBodyGyroMag-meanFreq()          -0.108829   0.012086 -1.098e-01
## fBodyBodyGyroMag-skewness()          -0.266756  -0.337144 -2.574e-01
## fBodyBodyGyroMag-kurtosis()          -0.584530  -0.636295 -5.719e-01
## fBodyBodyGyroJerkMag-mean()          -0.786474  -0.767780 -8.648e-01
## fBodyBodyGyroJerkMag-std()           -0.801296  -0.787144 -8.793e-01
## fBodyBodyGyroJerkMag-mad()           -0.787483  -0.763009 -8.577e-01
## fBodyBodyGyroJerkMag-max()           -0.805993  -0.809498 -9.017e-01
## fBodyBodyGyroJerkMag-min()           -0.870732  -0.857311 -9.309e-01
## fBodyBodyGyroJerkMag-sma()           -0.786474  -0.767780 -8.648e-01
## fBodyBodyGyroJerkMag-energy()        -0.954244  -0.946714 -9.825e-01
## fBodyBodyGyroJerkMag-iqr()           -0.779833  -0.761714 -8.459e-01
## fBodyBodyGyroJerkMag-entropy()       -0.177847  -0.205253 -3.580e-01
## fBodyBodyGyroJerkMag-maxInds         -0.901014  -0.875067 -8.766e-01
## fBodyBodyGyroJerkMag-meanFreq()       0.092776   0.153580  1.179e-01
## fBodyBodyGyroJerkMag-skewness()      -0.207821  -0.345873 -4.018e-01
## fBodyBodyGyroJerkMag-kurtosis()      -0.518703  -0.666458 -7.050e-01
## angle(tBodyAccMean,gravity)           0.006596   0.002833  8.840e-05
## angle(tBodyAccJerkMean),gravityMean) -0.010428  -0.003624 -1.890e-02
## angle(tBodyGyroMean,gravityMean)      0.086784  -0.019220  5.063e-02
## angle(tBodyGyroJerkMean,gravityMean) -0.023103   0.052032 -3.509e-02
## angle(X,gravityMean)                 -0.558093  -0.502995 -5.360e-01
## angle(Y,gravityMean)                  0.116895   0.140515  1.652e-03
## angle(Z,gravityMean)                 -0.089849  -0.004994 -7.691e-02
##                                      subject_12 subject_13 subject_14
## tBodyAcc-mean()-X                     0.2736087   0.275896  0.2701846
## tBodyAcc-mean()-Y                    -0.0183372  -0.017650 -0.0162548
## tBodyAcc-mean()-Z                    -0.1066491  -0.109135 -0.1009859
## tBodyAcc-std()-X                     -0.5839622  -0.624844 -0.6116711
## tBodyAcc-std()-Y                     -0.5220400  -0.448816 -0.3747308
## tBodyAcc-std()-Z                     -0.6992935  -0.587231 -0.2935427
## tBodyAcc-mad()-X                     -0.6133688  -0.649848 -0.6456939
## tBodyAcc-mad()-Y                     -0.5454915  -0.462358 -0.4020488
## tBodyAcc-mad()-Z                     -0.7042342  -0.593589 -0.3225746
## tBodyAcc-max()-X                     -0.4100800  -0.494129 -0.4416370
## tBodyAcc-max()-Y                     -0.3050868  -0.288710 -0.2271786
## tBodyAcc-max()-Z                     -0.6182523  -0.581163 -0.3691478
## tBodyAcc-min()-X                      0.5120896   0.516149  0.5275768
## tBodyAcc-min()-Y                      0.3786401   0.366325  0.2941096
## tBodyAcc-min()-Z                      0.6335480   0.545533  0.3832167
## tBodyAcc-sma()                       -0.5727950  -0.540567 -0.4432274
## tBodyAcc-energy()-X                  -0.8171896  -0.854603 -0.8472349
## tBodyAcc-energy()-Y                  -0.9119476  -0.883345 -0.8566723
## tBodyAcc-energy()-Z                  -0.9218435  -0.847931 -0.5684917
## tBodyAcc-iqr()-X                     -0.6798895  -0.696128 -0.7175541
## tBodyAcc-iqr()-Y                     -0.6756462  -0.594652 -0.5560359
## tBodyAcc-iqr()-Z                     -0.7297416  -0.630954 -0.4280486
## tBodyAcc-entropy()-X                 -0.0975625  -0.081298 -0.0285057
## tBodyAcc-entropy()-Y                 -0.0882723  -0.084742 -0.0801001
## tBodyAcc-entropy()-Z                 -0.1062603  -0.114949 -0.0604046
## tBodyAcc-arCoeff()-X,1               -0.1307255  -0.116475 -0.1511589
## tBodyAcc-arCoeff()-X,2                0.1545624   0.115635  0.0468258
## tBodyAcc-arCoeff()-X,3               -0.0656186  -0.032297  0.0518547
## tBodyAcc-arCoeff()-X,4                0.1228845   0.076134  0.1474287
## tBodyAcc-arCoeff()-Y,1               -0.0416707  -0.074185 -0.0709038
## tBodyAcc-arCoeff()-Y,2                0.0706526   0.064894 -0.0183940
## tBodyAcc-arCoeff()-Y,3                0.1255745   0.146114  0.2004049
## tBodyAcc-arCoeff()-Y,4               -0.0210160  -0.072527  0.0233288
## tBodyAcc-arCoeff()-Z,1                0.0080845  -0.015015 -0.0754690
## tBodyAcc-arCoeff()-Z,2                0.0493368   0.076150  0.0265088
## tBodyAcc-arCoeff()-Z,3                0.0183544   0.008038  0.0475521
## tBodyAcc-arCoeff()-Z,4               -0.0947712  -0.125352 -0.0154265
## tBodyAcc-correlation()-X,Y           -0.1280585  -0.013816 -0.0614123
## tBodyAcc-correlation()-X,Z           -0.2712785  -0.190156 -0.2577104
## tBodyAcc-correlation()-Y,Z            0.0797941   0.155413  0.0473392
## tGravityAcc-mean()-X                  0.6992225   0.709997  0.6720812
## tGravityAcc-mean()-Y                  0.0299768  -0.042086 -0.1117014
## tGravityAcc-mean()-Z                  0.0330296   0.044301 -0.1611797
## tGravityAcc-std()-X                  -0.9673834  -0.967268 -0.9412457
## tGravityAcc-std()-Y                  -0.9605729  -0.953541 -0.9423773
## tGravityAcc-std()-Z                  -0.9468086  -0.938728 -0.9159278
## tGravityAcc-mad()-X                  -0.9682142  -0.968063 -0.9418513
## tGravityAcc-mad()-Y                  -0.9615260  -0.954149 -0.9439915
## tGravityAcc-mad()-Z                  -0.9478880  -0.939697 -0.9178148
## tGravityAcc-max()-X                   0.6385344   0.648658  0.6204189
## tGravityAcc-max()-Y                   0.0133108  -0.055169 -0.1199029
## tGravityAcc-max()-Z                   0.0358629   0.048676 -0.1503623
## tGravityAcc-min()-X                   0.7139555   0.724045  0.6794500
## tGravityAcc-min()-Y                   0.0439907  -0.029013 -0.1021892
## tGravityAcc-min()-Z                   0.0218416   0.031071 -0.1811525
## tGravityAcc-sma()                    -0.3319008   0.015550  0.3306342
## tGravityAcc-energy()-X                0.5143370   0.453122  0.3323651
## tGravityAcc-energy()-Y               -0.6872152  -0.710095 -0.8353088
## tGravityAcc-energy()-Z               -0.8713941  -0.772638 -0.5255256
## tGravityAcc-iqr()-X                  -0.9700984  -0.970351 -0.9435741
## tGravityAcc-iqr()-Y                  -0.9647704  -0.956566 -0.9484618
## tGravityAcc-iqr()-Z                  -0.9517769  -0.943866 -0.9244201
## tGravityAcc-entropy()-X              -0.7820117  -0.603867 -0.4161986
## tGravityAcc-entropy()-Y              -0.8654876  -0.875130 -0.8958427
## tGravityAcc-entropy()-Z              -0.7850806  -0.706060 -0.8758697
## tGravityAcc-arCoeff()-X,1            -0.4410957  -0.480581 -0.5974147
## tGravityAcc-arCoeff()-X,2             0.4868186   0.519306  0.6372293
## tGravityAcc-arCoeff()-X,3            -0.5316203  -0.557235 -0.6767638
## tGravityAcc-arCoeff()-X,4             0.5755250   0.594413  0.7160887
## tGravityAcc-arCoeff()-Y,1            -0.2817785  -0.352016 -0.5128740
## tGravityAcc-arCoeff()-Y,2             0.2663591   0.342054  0.5000787
## tGravityAcc-arCoeff()-Y,3            -0.2990519  -0.375683 -0.5197465
## tGravityAcc-arCoeff()-Y,4             0.3509970   0.426543  0.5524940
## tGravityAcc-arCoeff()-Z,1            -0.4089476  -0.398940 -0.5588419
## tGravityAcc-arCoeff()-Z,2             0.4339226   0.425778  0.5804351
## tGravityAcc-arCoeff()-Z,3            -0.4583888  -0.451968 -0.6014347
## tGravityAcc-arCoeff()-Z,4             0.4797467   0.474905  0.6189928
## tGravityAcc-correlation()-X,Y         0.1505065   0.287621  0.3905488
## tGravityAcc-correlation()-X,Z        -0.0878266   0.029551  0.1836802
## tGravityAcc-correlation()-Y,Z         0.1620018   0.075029 -0.0027578
## tBodyAccJerk-mean()-X                 0.0704303   0.079439  0.0741757
## tBodyAccJerk-mean()-Y                 0.0053115   0.003880  0.0044368
## tBodyAccJerk-mean()-Z                 0.0003081  -0.012349 -0.0025304
## tBodyAccJerk-std()-X                 -0.5824183  -0.638890 -0.6419642
## tBodyAccJerk-std()-Y                 -0.5713598  -0.569701 -0.5864596
## tBodyAccJerk-std()-Z                 -0.7926219  -0.728453 -0.6568556
## tBodyAccJerk-mad()-X                 -0.5898998  -0.630430 -0.6358547
## tBodyAccJerk-mad()-Y                 -0.5611806  -0.553560 -0.5682127
## tBodyAccJerk-mad()-Z                 -0.7881889  -0.721666 -0.6376757
## tBodyAccJerk-max()-X                 -0.6800214  -0.707287 -0.7131759
## tBodyAccJerk-max()-Y                 -0.6977829  -0.743570 -0.7163690
## tBodyAccJerk-max()-Z                 -0.8391968  -0.783565 -0.7316239
## tBodyAccJerk-min()-X                  0.4945076   0.625895  0.6316166
## tBodyAccJerk-min()-Y                  0.6601872   0.658539  0.6723366
## tBodyAccJerk-min()-Z                  0.7766999   0.701868  0.6486616
## tBodyAccJerk-sma()                   -0.6294486  -0.620237 -0.5962959
## tBodyAccJerk-energy()-X              -0.8115339  -0.858407 -0.8639224
## tBodyAccJerk-energy()-Y              -0.8015733  -0.801416 -0.8172213
## tBodyAccJerk-energy()-Z              -0.9519296  -0.916361 -0.8779388
## tBodyAccJerk-iqr()-X                 -0.6007443  -0.609080 -0.6305435
## tBodyAccJerk-iqr()-Y                 -0.6441444  -0.635646 -0.6227624
## tBodyAccJerk-iqr()-Z                 -0.8055892  -0.735147 -0.6401314
## tBodyAccJerk-entropy()-X              0.0413773  -0.087822 -0.0028008
## tBodyAccJerk-entropy()-Y             -0.0182770  -0.068201 -0.0335157
## tBodyAccJerk-entropy()-Z             -0.1012325  -0.099526 -0.0093911
## tBodyAccJerk-arCoeff()-X,1           -0.1245030  -0.087450 -0.1680683
## tBodyAccJerk-arCoeff()-X,2            0.2157471   0.187744  0.0573581
## tBodyAccJerk-arCoeff()-X,3            0.0909040   0.112263 -0.0395124
## tBodyAccJerk-arCoeff()-X,4            0.1018012   0.111894  0.2350126
## tBodyAccJerk-arCoeff()-Y,1           -0.0857041  -0.093249 -0.1174513
## tBodyAccJerk-arCoeff()-Y,2            0.1182551   0.091344 -0.0570195
## tBodyAccJerk-arCoeff()-Y,3            0.1944595   0.209564  0.0667704
## tBodyAccJerk-arCoeff()-Y,4            0.2832119   0.273645  0.3555190
## tBodyAccJerk-arCoeff()-Z,1           -0.0263376  -0.036266 -0.1280093
## tBodyAccJerk-arCoeff()-Z,2            0.1107586   0.132197  0.0115117
## tBodyAccJerk-arCoeff()-Z,3            0.0131298   0.049295 -0.1364533
## tBodyAccJerk-arCoeff()-Z,4            0.1153430   0.087311  0.1973692
## tBodyAccJerk-correlation()-X,Y       -0.1689791  -0.066822 -0.1804890
## tBodyAccJerk-correlation()-X,Z       -0.1570647  -0.067370 -0.0625415
## tBodyAccJerk-correlation()-Y,Z        0.0001018   0.188734  0.0524424
## tBodyGyro-mean()-X                   -0.0628663  -0.056247  0.0002537
## tBodyGyro-mean()-Y                   -0.0592027  -0.061661 -0.0954921
## tBodyGyro-mean()-Z                    0.0960742   0.098866  0.0606712
## tBodyGyro-std()-X                    -0.7278817  -0.715110 -0.7286614
## tBodyGyro-std()-Y                    -0.7350628  -0.645729 -0.3989594
## tBodyGyro-std()-Z                    -0.6710577  -0.643337 -0.3644782
## tBodyGyro-mad()-X                    -0.7386759  -0.715504 -0.7337927
## tBodyGyro-mad()-Y                    -0.7476288  -0.666396 -0.4225202
## tBodyGyro-mad()-Z                    -0.6761409  -0.658583 -0.3850307
## tBodyGyro-max()-X                    -0.6470209  -0.664255 -0.6423924
## tBodyGyro-max()-Y                    -0.7638976  -0.690154 -0.5223619
## tBodyGyro-max()-Z                    -0.5100480  -0.440496 -0.2986057
## tBodyGyro-min()-X                     0.6146899   0.620003  0.6503885
## tBodyGyro-min()-Y                     0.7683011   0.695275  0.6190224
## tBodyGyro-min()-Z                     0.5705279   0.565792  0.3494181
## tBodyGyro-sma()                      -0.6294152  -0.575832 -0.4020273
## tBodyGyro-energy()-X                 -0.9089432  -0.897418 -0.9149306
## tBodyGyro-energy()-Y                 -0.9327712  -0.871938 -0.6441843
## tBodyGyro-energy()-Z                 -0.8978533  -0.879045 -0.5992015
## tBodyGyro-iqr()-X                    -0.7543272  -0.711007 -0.7351708
## tBodyGyro-iqr()-Y                    -0.7710085  -0.701377 -0.4848811
## tBodyGyro-iqr()-Z                    -0.7141457  -0.718039 -0.4692183
## tBodyGyro-entropy()-X                -0.1509310  -0.166183 -0.0212492
## tBodyGyro-entropy()-Y                -0.0377171  -0.055162 -0.1890732
## tBodyGyro-entropy()-Z                -0.0003970  -0.051923 -0.0440511
## tBodyGyro-arCoeff()-X,1              -0.2350201  -0.200028 -0.2792162
## tBodyGyro-arCoeff()-X,2               0.1649783   0.143053  0.1240490
## tBodyGyro-arCoeff()-X,3               0.1027219   0.081865  0.1858994
## tBodyGyro-arCoeff()-X,4              -0.0703587  -0.048899 -0.0598559
## tBodyGyro-arCoeff()-Y,1              -0.1826066  -0.137211 -0.3819570
## tBodyGyro-arCoeff()-Y,2               0.1821524   0.163695  0.2544837
## tBodyGyro-arCoeff()-Y,3              -0.0950300  -0.053825 -0.0083778
## tBodyGyro-arCoeff()-Y,4               0.1975529   0.098012  0.1004641
## tBodyGyro-arCoeff()-Z,1              -0.0936538  -0.020795 -0.2268354
## tBodyGyro-arCoeff()-Z,2               0.0919925   0.041301  0.0935844
## tBodyGyro-arCoeff()-Z,3              -0.0779841  -0.027898  0.0858667
## tBodyGyro-arCoeff()-Z,4               0.2166856   0.160962  0.0795448
## tBodyGyro-correlation()-X,Y          -0.1424972  -0.213499 -0.0816445
## tBodyGyro-correlation()-X,Z          -0.0270154   0.011795  0.0047871
## tBodyGyro-correlation()-Y,Z          -0.0623164  -0.134262 -0.0592846
## tBodyGyroJerk-mean()-X               -0.0731134  -0.088118 -0.1075561
## tBodyGyroJerk-mean()-Y               -0.0436788  -0.044084 -0.0433200
## tBodyGyroJerk-mean()-Z               -0.0574585  -0.058272 -0.0450694
## tBodyGyroJerk-std()-X                -0.7097261  -0.715773 -0.7862917
## tBodyGyroJerk-std()-Y                -0.8112326  -0.718989 -0.6979155
## tBodyGyroJerk-std()-Z                -0.7493519  -0.712716 -0.6382991
## tBodyGyroJerk-mad()-X                -0.7154517  -0.716614 -0.7813352
## tBodyGyroJerk-mad()-Y                -0.8225881  -0.735150 -0.7049111
## tBodyGyroJerk-mad()-Z                -0.7601883  -0.718549 -0.6424510
## tBodyGyroJerk-max()-X                -0.7092043  -0.733179 -0.8044542
## tBodyGyroJerk-max()-Y                -0.8272047  -0.741595 -0.7438105
## tBodyGyroJerk-max()-Z                -0.7235236  -0.731024 -0.6958780
## tBodyGyroJerk-min()-X                 0.7291327   0.751028  0.8142878
## tBodyGyroJerk-min()-Y                 0.8443441   0.759534  0.7734967
## tBodyGyroJerk-min()-Z                 0.8019043   0.774417  0.7044971
## tBodyGyroJerk-sma()                  -0.7789808  -0.725820 -0.7110140
## tBodyGyroJerk-energy()-X             -0.9110498  -0.908328 -0.9552766
## tBodyGyroJerk-energy()-Y             -0.9627367  -0.905097 -0.9061394
## tBodyGyroJerk-energy()-Z             -0.9319085  -0.909115 -0.8551311
## tBodyGyroJerk-iqr()-X                -0.7370347  -0.732799 -0.7784969
## tBodyGyroJerk-iqr()-Y                -0.8378920  -0.753021 -0.7099334
## tBodyGyroJerk-iqr()-Z                -0.7820336  -0.738366 -0.6635625
## tBodyGyroJerk-entropy()-X             0.0888641  -0.014341  0.0293133
## tBodyGyroJerk-entropy()-Y             0.1200467   0.077041  0.1201013
## tBodyGyroJerk-entropy()-Z             0.0725385   0.007692  0.1215111
## tBodyGyroJerk-arCoeff()-X,1          -0.0826351  -0.042314 -0.1358655
## tBodyGyroJerk-arCoeff()-X,2           0.0606172   0.056974 -0.0315374
## tBodyGyroJerk-arCoeff()-X,3           0.1511625   0.154290  0.0659602
## tBodyGyroJerk-arCoeff()-X,4           0.1535885   0.112524  0.2583539
## tBodyGyroJerk-arCoeff()-Y,1          -0.1505772  -0.093131 -0.3317679
## tBodyGyroJerk-arCoeff()-Y,2           0.2323953   0.250086  0.1770552
## tBodyGyroJerk-arCoeff()-Y,3           0.0660014   0.162263  0.0108362
## tBodyGyroJerk-arCoeff()-Y,4           0.0676885   0.036451  0.1516059
## tBodyGyroJerk-arCoeff()-Z,1          -0.0357799   0.037253 -0.1806877
## tBodyGyroJerk-arCoeff()-Z,2           0.0763475   0.082266 -0.0090285
## tBodyGyroJerk-arCoeff()-Z,3           0.0638303   0.098866 -0.0226338
## tBodyGyroJerk-arCoeff()-Z,4          -0.0339308   0.041180  0.1851017
## tBodyGyroJerk-correlation()-X,Y       0.0802777  -0.065184  0.1046870
## tBodyGyroJerk-correlation()-X,Z      -0.0490622   0.063133  0.1592788
## tBodyGyroJerk-correlation()-Y,Z      -0.0366385  -0.236135 -0.1030520
## tBodyAccMag-mean()                   -0.5595865  -0.539872 -0.4532626
## tBodyAccMag-std()                    -0.5743865  -0.597231 -0.4740586
## tBodyAccMag-mad()                    -0.6370552  -0.643770 -0.5306031
## tBodyAccMag-max()                    -0.5416624  -0.561948 -0.4631424
## tBodyAccMag-min()                    -0.8519543  -0.815730 -0.8332302
## tBodyAccMag-sma()                    -0.5595865  -0.539872 -0.4532626
## tBodyAccMag-energy()                 -0.7940029  -0.787066 -0.6932828
## tBodyAccMag-iqr()                    -0.7199435  -0.695387 -0.5871108
## tBodyAccMag-entropy()                 0.2072762   0.139086  0.2593803
## tBodyAccMag-arCoeff()1               -0.0400424  -0.070838 -0.1854845
## tBodyAccMag-arCoeff()2                0.0018512   0.029304  0.0883600
## tBodyAccMag-arCoeff()3                0.0356968   0.061958  0.0717420
## tBodyAccMag-arCoeff()4               -0.0038239  -0.081201 -0.0496904
## tGravityAccMag-mean()                -0.5595865  -0.539872 -0.4532626
## tGravityAccMag-std()                 -0.5743865  -0.597231 -0.4740586
## tGravityAccMag-mad()                 -0.6370552  -0.643770 -0.5306031
## tGravityAccMag-max()                 -0.5416624  -0.561948 -0.4631424
## tGravityAccMag-min()                 -0.8519543  -0.815730 -0.8332302
## tGravityAccMag-sma()                 -0.5595865  -0.539872 -0.4532626
## tGravityAccMag-energy()              -0.7940029  -0.787066 -0.6932828
## tGravityAccMag-iqr()                 -0.7199435  -0.695387 -0.5871108
## tGravityAccMag-entropy()              0.2072762   0.139086  0.2593803
## tGravityAccMag-arCoeff()1            -0.0400424  -0.070838 -0.1854845
## tGravityAccMag-arCoeff()2             0.0018512   0.029304  0.0883600
## tGravityAccMag-arCoeff()3             0.0356968   0.061958  0.0717420
## tGravityAccMag-arCoeff()4            -0.0038239  -0.081201 -0.0496904
## tBodyAccJerkMag-mean()               -0.6300505  -0.625467 -0.6089734
## tBodyAccJerkMag-std()                -0.5663657  -0.610249 -0.6051443
## tBodyAccJerkMag-mad()                -0.5955066  -0.626950 -0.6221717
## tBodyAccJerkMag-max()                -0.5727115  -0.629636 -0.6219522
## tBodyAccJerkMag-min()                -0.7990461  -0.754719 -0.7530944
## tBodyAccJerkMag-sma()                -0.6300505  -0.625467 -0.6089734
## tBodyAccJerkMag-energy()             -0.8337885  -0.842770 -0.8334081
## tBodyAccJerkMag-iqr()                -0.6682549  -0.678954 -0.6733742
## tBodyAccJerkMag-entropy()             0.0175723  -0.047385  0.0258114
## tBodyAccJerkMag-arCoeff()1            0.0862926   0.064539  0.0398159
## tBodyAccJerkMag-arCoeff()2           -0.0197377  -0.034505  0.0103200
## tBodyAccJerkMag-arCoeff()3           -0.1710743  -0.083663 -0.0328714
## tBodyAccJerkMag-arCoeff()4            0.0307703  -0.020436 -0.1196578
## tBodyGyroMag-mean()                  -0.6316681  -0.581215 -0.4164598
## tBodyGyroMag-std()                   -0.6848581  -0.636365 -0.4714867
## tBodyGyroMag-mad()                   -0.6522284  -0.606612 -0.4303990
## tBodyGyroMag-max()                   -0.7182180  -0.649097 -0.5201804
## tBodyGyroMag-min()                   -0.7299218  -0.719313 -0.6404850
## tBodyGyroMag-sma()                   -0.6316681  -0.581215 -0.4164598
## tBodyGyroMag-energy()                -0.8720832  -0.826463 -0.6530857
## tBodyGyroMag-iqr()                   -0.6729064  -0.633659 -0.4815071
## tBodyGyroMag-entropy()                0.4162569   0.253993  0.0555612
## tBodyGyroMag-arCoeff()1               0.0080170   0.089985 -0.1939995
## tBodyGyroMag-arCoeff()2              -0.1277538  -0.127995  0.0565347
## tBodyGyroMag-arCoeff()3               0.1821471   0.110521  0.1005772
## tBodyGyroMag-arCoeff()4              -0.0844226  -0.112067 -0.0669493
## tBodyGyroJerkMag-mean()              -0.7772945  -0.712745 -0.7005209
## tBodyGyroJerkMag-std()               -0.7863865  -0.712056 -0.7270230
## tBodyGyroJerkMag-mad()               -0.7986849  -0.736552 -0.7460305
## tBodyGyroJerkMag-max()               -0.7962210  -0.713846 -0.7247804
## tBodyGyroJerkMag-min()               -0.8138326  -0.767513 -0.7351063
## tBodyGyroJerkMag-sma()               -0.7772945  -0.712745 -0.7005209
## tBodyGyroJerkMag-energy()            -0.9476824  -0.905973 -0.9090643
## tBodyGyroJerkMag-iqr()               -0.8114938  -0.760081 -0.7610846
## tBodyGyroJerkMag-entropy()            0.2624015   0.178255  0.2285753
## tBodyGyroJerkMag-arCoeff()1           0.2721564   0.367434  0.1660798
## tBodyGyroJerkMag-arCoeff()2          -0.2452623  -0.328703 -0.0845367
## tBodyGyroJerkMag-arCoeff()3          -0.0729843  -0.129171  0.0160373
## tBodyGyroJerkMag-arCoeff()4          -0.0323395   0.054339 -0.2728282
## fBodyAcc-mean()-X                    -0.5789202  -0.638818 -0.6195133
## fBodyAcc-mean()-Y                    -0.5232871  -0.493467 -0.4552376
## fBodyAcc-mean()-Z                    -0.7266403  -0.629736 -0.4406507
## fBodyAcc-std()-X                     -0.5869226  -0.620602 -0.6094064
## fBodyAcc-std()-Y                     -0.5530766  -0.462584 -0.3768300
## fBodyAcc-std()-Z                     -0.7099832  -0.599037 -0.2750137
## fBodyAcc-mad()-X                     -0.5522741  -0.604455 -0.5846474
## fBodyAcc-mad()-Y                     -0.5230826  -0.456406 -0.4113612
## fBodyAcc-mad()-Z                     -0.7098444  -0.595929 -0.3496821
## fBodyAcc-max()-X                     -0.6552228  -0.664306 -0.6632282
## fBodyAcc-max()-Y                     -0.6933388  -0.607469 -0.5217153
## fBodyAcc-max()-Z                     -0.7273232  -0.631402 -0.3013562
## fBodyAcc-min()-X                     -0.8415488  -0.884938 -0.8496316
## fBodyAcc-min()-Y                     -0.8860802  -0.880340 -0.8811371
## fBodyAcc-min()-Z                     -0.9344283  -0.901896 -0.8702703
## fBodyAcc-sma()                       -0.5493226  -0.537993 -0.4524037
## fBodyAcc-energy()-X                  -0.8175436  -0.854740 -0.8495264
## fBodyAcc-energy()-Y                  -0.7719119  -0.699125 -0.6305678
## fBodyAcc-energy()-Z                  -0.9129828  -0.830784 -0.5180073
## fBodyAcc-iqr()-X                     -0.5788267  -0.654225 -0.6666583
## fBodyAcc-iqr()-Y                     -0.5954218  -0.617891 -0.6476311
## fBodyAcc-iqr()-Z                     -0.7745637  -0.699238 -0.6481496
## fBodyAcc-entropy()-X                 -0.1131318  -0.199270 -0.1165424
## fBodyAcc-entropy()-Y                 -0.1161128  -0.171257 -0.0935749
## fBodyAcc-entropy()-Z                 -0.1884956  -0.174000 -0.0309058
## fBodyAcc-maxInds-X                   -0.7112903  -0.799152 -0.7940677
## fBodyAcc-maxInds-Y                   -0.8000000  -0.809582 -0.8691434
## fBodyAcc-maxInds-Z                   -0.8430288  -0.868502 -0.8825911
## fBodyAcc-meanFreq()-X                -0.1837382  -0.222057 -0.3191711
## fBodyAcc-meanFreq()-Y                 0.0444598  -0.034831 -0.1530835
## fBodyAcc-meanFreq()-Z                 0.0689110   0.048726 -0.1078443
## fBodyAcc-skewness()-X                -0.2183136  -0.096581 -0.1267333
## fBodyAcc-kurtosis()-X                -0.5559726  -0.415751 -0.4905223
## fBodyAcc-skewness()-Y                -0.3518505  -0.133958 -0.1625573
## fBodyAcc-kurtosis()-Y                -0.6607835  -0.421993 -0.5036321
## fBodyAcc-skewness()-Z                -0.2698392  -0.206383 -0.1442248
## fBodyAcc-kurtosis()-Z                -0.5023326  -0.431637 -0.4234714
## fBodyAcc-bandsEnergy()-1,8           -0.8260092  -0.855986 -0.8578635
## fBodyAcc-bandsEnergy()-9,16          -0.8550207  -0.893071 -0.8515332
## fBodyAcc-bandsEnergy()-17,24         -0.8004668  -0.848458 -0.9151082
## fBodyAcc-bandsEnergy()-25,32         -0.8420526  -0.910475 -0.9226768
## fBodyAcc-bandsEnergy()-33,40         -0.8954806  -0.935414 -0.9127772
## fBodyAcc-bandsEnergy()-41,48         -0.9007049  -0.933337 -0.9110159
## fBodyAcc-bandsEnergy()-49,56         -0.9395575  -0.959842 -0.9451860
## fBodyAcc-bandsEnergy()-57,64         -0.9528686  -0.974764 -0.9630277
## fBodyAcc-bandsEnergy()-1,16          -0.8183947  -0.853533 -0.8428016
## fBodyAcc-bandsEnergy()-17,32         -0.7816420  -0.843247 -0.9040804
## fBodyAcc-bandsEnergy()-33,48         -0.8974533  -0.934650 -0.9121314
## fBodyAcc-bandsEnergy()-49,64         -0.9440190  -0.964843 -0.9511661
## fBodyAcc-bandsEnergy()-1,24          -0.8171220  -0.853174 -0.8479425
## fBodyAcc-bandsEnergy()-25,48         -0.8379322  -0.904668 -0.9025455
## fBodyAcc-bandsEnergy()-1,8.1         -0.8262748  -0.743133 -0.6251491
## fBodyAcc-bandsEnergy()-9,16.1        -0.8518203  -0.802931 -0.8084875
## fBodyAcc-bandsEnergy()-17,24.1       -0.8189602  -0.839767 -0.9061157
## fBodyAcc-bandsEnergy()-25,32.1       -0.8689332  -0.919263 -0.9102508
## fBodyAcc-bandsEnergy()-33,40.1       -0.8913093  -0.910086 -0.8552686
## fBodyAcc-bandsEnergy()-41,48.1       -0.8817473  -0.894820 -0.8361128
## fBodyAcc-bandsEnergy()-49,56.1       -0.9047168  -0.900445 -0.8952192
## fBodyAcc-bandsEnergy()-57,64.1       -0.9549672  -0.949605 -0.9566341
## fBodyAcc-bandsEnergy()-1,16.1        -0.7906683  -0.701810 -0.6142640
## fBodyAcc-bandsEnergy()-17,32.1       -0.7871858  -0.821839 -0.8833461
## fBodyAcc-bandsEnergy()-33,48.1       -0.8752092  -0.893950 -0.8313547
## fBodyAcc-bandsEnergy()-49,64.1       -0.9228289  -0.917958 -0.9177347
## fBodyAcc-bandsEnergy()-1,24.1        -0.7767645  -0.699228 -0.6309233
## fBodyAcc-bandsEnergy()-25,48.1       -0.8642328  -0.907299 -0.8811582
## fBodyAcc-bandsEnergy()-1,8.2         -0.9286797  -0.856793 -0.4947014
## fBodyAcc-bandsEnergy()-9,16.2        -0.9447920  -0.894719 -0.7578079
## fBodyAcc-bandsEnergy()-17,24.2       -0.9452886  -0.892947 -0.9203556
## fBodyAcc-bandsEnergy()-25,32.2       -0.9668181  -0.956163 -0.9474934
## fBodyAcc-bandsEnergy()-33,40.2       -0.9767218  -0.966659 -0.9251817
## fBodyAcc-bandsEnergy()-41,48.2       -0.9604210  -0.937185 -0.8719817
## fBodyAcc-bandsEnergy()-49,56.2       -0.9637579  -0.929740 -0.8847398
## fBodyAcc-bandsEnergy()-57,64.2       -0.9803408  -0.948226 -0.9069079
## fBodyAcc-bandsEnergy()-1,16.2        -0.9252150  -0.851602 -0.5179942
## fBodyAcc-bandsEnergy()-17,32.2       -0.9531204  -0.915879 -0.9302187
## fBodyAcc-bandsEnergy()-33,48.2       -0.9708754  -0.956672 -0.9060795
## fBodyAcc-bandsEnergy()-49,64.2       -0.9684307  -0.934694 -0.8904147
## fBodyAcc-bandsEnergy()-1,24.2        -0.9165368  -0.834676 -0.5186753
## fBodyAcc-bandsEnergy()-25,48.2       -0.9679915  -0.956324 -0.9357002
## fBodyAccJerk-mean()-X                -0.5991093  -0.660082 -0.6543850
## fBodyAccJerk-mean()-Y                -0.5912964  -0.603340 -0.5986995
## fBodyAccJerk-mean()-Z                -0.7754266  -0.710832 -0.6187122
## fBodyAccJerk-std()-X                 -0.6029601  -0.649606 -0.6614604
## fBodyAccJerk-std()-Y                 -0.5791681  -0.562130 -0.6021589
## fBodyAccJerk-std()-Z                 -0.8085830  -0.744824 -0.6944250
## fBodyAccJerk-mad()-X                 -0.5225678  -0.592354 -0.6006069
## fBodyAccJerk-mad()-Y                 -0.5848791  -0.579880 -0.6114766
## fBodyAccJerk-mad()-Z                 -0.7934845  -0.728003 -0.6657311
## fBodyAccJerk-max()-X                 -0.6771776  -0.699372 -0.7286986
## fBodyAccJerk-max()-Y                 -0.6679457  -0.650840 -0.6669694
## fBodyAccJerk-max()-Z                 -0.8298692  -0.764291 -0.7298129
## fBodyAccJerk-min()-X                 -0.8789148  -0.885754 -0.8845341
## fBodyAccJerk-min()-Y                 -0.8332096  -0.847657 -0.8481881
## fBodyAccJerk-min()-Z                 -0.8919325  -0.873362 -0.8106755
## fBodyAccJerk-sma()                   -0.5931224  -0.600705 -0.5610179
## fBodyAccJerk-energy()-X              -0.8112849  -0.858194 -0.8637463
## fBodyAccJerk-energy()-Y              -0.8016468  -0.801520 -0.8173042
## fBodyAccJerk-energy()-Z              -0.9519425  -0.916393 -0.8780066
## fBodyAccJerk-iqr()-X                 -0.5622765  -0.634585 -0.6346615
## fBodyAccJerk-iqr()-Y                 -0.6854459  -0.705516 -0.6978413
## fBodyAccJerk-iqr()-Z                 -0.7997248  -0.741798 -0.6672663
## fBodyAccJerk-entropy()-X             -0.1819751  -0.254677 -0.2129777
## fBodyAccJerk-entropy()-Y             -0.2076040  -0.240282 -0.2093611
## fBodyAccJerk-entropy()-Z             -0.3697213  -0.319184 -0.2014830
## fBodyAccJerk-maxInds-X               -0.3888750  -0.365138 -0.5465015
## fBodyAccJerk-maxInds-Y               -0.3563750  -0.372110 -0.5154180
## fBodyAccJerk-maxInds-Z               -0.2955000  -0.280979 -0.4871827
## fBodyAccJerk-meanFreq()-X            -0.0466199  -0.024196 -0.1486573
## fBodyAccJerk-meanFreq()-Y            -0.2046942  -0.238329 -0.3053554
## fBodyAccJerk-meanFreq()-Z            -0.0975640  -0.120605 -0.2392007
## fBodyAccJerk-skewness()-X            -0.3449926  -0.286697 -0.3116675
## fBodyAccJerk-kurtosis()-X            -0.7463005  -0.679123 -0.7242151
## fBodyAccJerk-skewness()-Y            -0.4227100  -0.395431 -0.3787489
## fBodyAccJerk-kurtosis()-Y            -0.8496952  -0.831112 -0.7971374
## fBodyAccJerk-skewness()-Z            -0.5011341  -0.455388 -0.5012172
## fBodyAccJerk-kurtosis()-Z            -0.8319261  -0.797471 -0.8277253
## fBodyAccJerk-bandsEnergy()-1,8       -0.8746707  -0.897127 -0.8974681
## fBodyAccJerk-bandsEnergy()-9,16      -0.8547271  -0.884283 -0.8525086
## fBodyAccJerk-bandsEnergy()-17,24     -0.8200389  -0.861158 -0.9285189
## fBodyAccJerk-bandsEnergy()-25,32     -0.8417146  -0.910591 -0.9226255
## fBodyAccJerk-bandsEnergy()-33,40     -0.8994864  -0.935510 -0.9169499
## fBodyAccJerk-bandsEnergy()-41,48     -0.8869955  -0.917633 -0.8926769
## fBodyAccJerk-bandsEnergy()-49,56     -0.9370468  -0.951730 -0.9388895
## fBodyAccJerk-bandsEnergy()-57,64     -0.9829973  -0.983004 -0.9877951
## fBodyAccJerk-bandsEnergy()-1,16      -0.8508754  -0.879856 -0.8596385
## fBodyAccJerk-bandsEnergy()-17,32     -0.7875830  -0.850507 -0.9092550
## fBodyAccJerk-bandsEnergy()-33,48     -0.8859933  -0.922799 -0.9000610
## fBodyAccJerk-bandsEnergy()-49,64     -0.9348499  -0.949280 -0.9375884
## fBodyAccJerk-bandsEnergy()-1,24      -0.8115968  -0.850578 -0.8603594
## fBodyAccJerk-bandsEnergy()-25,48     -0.8065411  -0.882124 -0.8757285
## fBodyAccJerk-bandsEnergy()-1,8.1     -0.8511877  -0.781786 -0.7741586
## fBodyAccJerk-bandsEnergy()-9,16.1    -0.8643569  -0.828259 -0.8413731
## fBodyAccJerk-bandsEnergy()-17,24.1   -0.7811160  -0.817276 -0.8941872
## fBodyAccJerk-bandsEnergy()-25,32.1   -0.8741882  -0.928269 -0.9096585
## fBodyAccJerk-bandsEnergy()-33,40.1   -0.9088919  -0.929390 -0.8733652
## fBodyAccJerk-bandsEnergy()-41,48.1   -0.8727422  -0.890784 -0.8188460
## fBodyAccJerk-bandsEnergy()-49,56.1   -0.9239526  -0.922393 -0.9042008
## fBodyAccJerk-bandsEnergy()-57,64.1   -0.9669642  -0.969502 -0.9726173
## fBodyAccJerk-bandsEnergy()-1,16.1    -0.8419533  -0.792875 -0.8029711
## fBodyAccJerk-bandsEnergy()-17,32.1   -0.7809700  -0.832854 -0.8802027
## fBodyAccJerk-bandsEnergy()-33,48.1   -0.8715801  -0.895961 -0.8196606
## fBodyAccJerk-bandsEnergy()-49,64.1   -0.9293825  -0.928340 -0.9128356
## fBodyAccJerk-bandsEnergy()-1,24.1    -0.7886591  -0.768885 -0.8100963
## fBodyAccJerk-bandsEnergy()-25,48.1   -0.8715125  -0.914856 -0.8737268
## fBodyAccJerk-bandsEnergy()-1,8.2     -0.9477621  -0.882060 -0.6700533
## fBodyAccJerk-bandsEnergy()-9,16.2    -0.9422879  -0.891757 -0.7860230
## fBodyAccJerk-bandsEnergy()-17,24.2   -0.9473440  -0.898271 -0.9304640
## fBodyAccJerk-bandsEnergy()-25,32.2   -0.9680194  -0.959753 -0.9489413
## fBodyAccJerk-bandsEnergy()-33,40.2   -0.9783276  -0.971383 -0.9318151
## fBodyAccJerk-bandsEnergy()-41,48.2   -0.9616466  -0.942946 -0.8845185
## fBodyAccJerk-bandsEnergy()-49,56.2   -0.9522635  -0.917337 -0.8742897
## fBodyAccJerk-bandsEnergy()-57,64.2   -0.9817906  -0.962860 -0.9407873
## fBodyAccJerk-bandsEnergy()-1,16.2    -0.9321041  -0.865538 -0.6997913
## fBodyAccJerk-bandsEnergy()-17,32.2   -0.9574817  -0.928360 -0.9395267
## fBodyAccJerk-bandsEnergy()-33,48.2   -0.9718417  -0.960879 -0.9129591
## fBodyAccJerk-bandsEnergy()-49,64.2   -0.9526195  -0.917311 -0.8739367
## fBodyAccJerk-bandsEnergy()-1,24.2    -0.9338528  -0.870710 -0.8192829
## fBodyAccJerk-bandsEnergy()-25,48.2   -0.9695467  -0.960221 -0.9348303
## fBodyGyro-mean()-X                   -0.6612468  -0.658642 -0.6991664
## fBodyGyro-mean()-Y                   -0.7447981  -0.647153 -0.5046332
## fBodyGyro-mean()-Z                   -0.6573699  -0.620471 -0.4239182
## fBodyGyro-std()-X                    -0.7503939  -0.734658 -0.7400522
## fBodyGyro-std()-Y                    -0.7334567  -0.650624 -0.3488642
## fBodyGyro-std()-Z                    -0.7082332  -0.685774 -0.4076721
## fBodyGyro-mad()-X                    -0.6911017  -0.677452 -0.6987248
## fBodyGyro-mad()-Y                    -0.7617663  -0.669354 -0.4633377
## fBodyGyro-mad()-Z                    -0.6684553  -0.630825 -0.3600119
## fBodyGyro-max()-X                    -0.7510112  -0.737584 -0.7285591
## fBodyGyro-max()-Y                    -0.7824887  -0.734098 -0.4024753
## fBodyGyro-max()-Z                    -0.7729055  -0.762536 -0.5191638
## fBodyGyro-min()-X                    -0.9252917  -0.931738 -0.9427526
## fBodyGyro-min()-Y                    -0.9171042  -0.866744 -0.8594749
## fBodyGyro-min()-Z                    -0.9183235  -0.897744 -0.8555498
## fBodyGyro-sma()                      -0.6771823  -0.622536 -0.5246361
## fBodyGyro-energy()-X                 -0.9279420  -0.914928 -0.9267807
## fBodyGyro-energy()-Y                 -0.9341621  -0.873823 -0.6429488
## fBodyGyro-energy()-Z                 -0.8935538  -0.876133 -0.5885324
## fBodyGyro-iqr()-X                    -0.6719046  -0.680698 -0.7714717
## fBodyGyro-iqr()-Y                    -0.7796524  -0.678298 -0.6198466
## fBodyGyro-iqr()-Z                    -0.6984854  -0.674081 -0.6148587
## fBodyGyro-entropy()-X                 0.0172529  -0.070629 -0.0675782
## fBodyGyro-entropy()-Y                 0.0398753   0.014625  0.0941693
## fBodyGyro-entropy()-Z                -0.0690967  -0.123372 -0.0580087
## fBodyGyro-maxInds-X                  -0.8910417  -0.898063 -0.9244582
## fBodyGyro-maxInds-Y                  -0.7695565  -0.717471 -0.8414062
## fBodyGyro-maxInds-Z                  -0.8096983  -0.781293 -0.8270524
## fBodyGyro-meanFreq()-X               -0.0843498  -0.112645 -0.2413411
## fBodyGyro-meanFreq()-Y               -0.1073099  -0.080613 -0.3454348
## fBodyGyro-meanFreq()-Z               -0.0648494  -0.005050 -0.2128185
## fBodyGyro-skewness()-X               -0.2235447  -0.063134 -0.1293043
## fBodyGyro-kurtosis()-X               -0.5375372  -0.368306 -0.4686001
## fBodyGyro-skewness()-Y               -0.2647736  -0.162938 -0.0959248
## fBodyGyro-kurtosis()-Y               -0.6073243  -0.486402 -0.4640137
## fBodyGyro-skewness()-Z               -0.1970305  -0.133523 -0.1456847
## fBodyGyro-kurtosis()-Z               -0.5137019  -0.438821 -0.4786264
## fBodyGyro-bandsEnergy()-1,8          -0.9422953  -0.930572 -0.9318141
## fBodyGyro-bandsEnergy()-9,16         -0.9180392  -0.899041 -0.9459741
## fBodyGyro-bandsEnergy()-17,24        -0.9065054  -0.905752 -0.9675748
## fBodyGyro-bandsEnergy()-25,32        -0.9499303  -0.967119 -0.9815522
## fBodyGyro-bandsEnergy()-33,40        -0.9453895  -0.948960 -0.9667338
## fBodyGyro-bandsEnergy()-41,48        -0.9478135  -0.951223 -0.9669419
## fBodyGyro-bandsEnergy()-49,56        -0.9640562  -0.967419 -0.9782651
## fBodyGyro-bandsEnergy()-57,64        -0.9761747  -0.976567 -0.9839191
## fBodyGyro-bandsEnergy()-1,16         -0.9337123  -0.919902 -0.9279278
## fBodyGyro-bandsEnergy()-17,32        -0.9043715  -0.910779 -0.9663942
## fBodyGyro-bandsEnergy()-33,48        -0.9408861  -0.944750 -0.9634745
## fBodyGyro-bandsEnergy()-49,64        -0.9694185  -0.971467 -0.9807669
## fBodyGyro-bandsEnergy()-1,24         -0.9297463  -0.916132 -0.9273943
## fBodyGyro-bandsEnergy()-25,48        -0.9467736  -0.960304 -0.9761332
## fBodyGyro-bandsEnergy()-1,8.1        -0.9256241  -0.904979 -0.5503187
## fBodyGyro-bandsEnergy()-9,16.1       -0.9805329  -0.937726 -0.8482063
## fBodyGyro-bandsEnergy()-17,24.1      -0.9799641  -0.931884 -0.9601462
## fBodyGyro-bandsEnergy()-25,32.1      -0.9730762  -0.945194 -0.9710902
## fBodyGyro-bandsEnergy()-33,40.1      -0.9816480  -0.969822 -0.9732966
## fBodyGyro-bandsEnergy()-41,48.1      -0.9688583  -0.940744 -0.9375467
## fBodyGyro-bandsEnergy()-49,56.1      -0.9689639  -0.924900 -0.9243457
## fBodyGyro-bandsEnergy()-57,64.1      -0.9888837  -0.966639 -0.9469400
## fBodyGyro-bandsEnergy()-1,16.1       -0.9372604  -0.895520 -0.5984954
## fBodyGyro-bandsEnergy()-17,32.1      -0.9731066  -0.919684 -0.9539636
## fBodyGyro-bandsEnergy()-33,48.1      -0.9788342  -0.963542 -0.9656820
## fBodyGyro-bandsEnergy()-49,64.1      -0.9733719  -0.932766 -0.9238401
## fBodyGyro-bandsEnergy()-1,24.1       -0.9321260  -0.870263 -0.6081151
## fBodyGyro-bandsEnergy()-25,48.1      -0.9727947  -0.946699 -0.9671523
## fBodyGyro-bandsEnergy()-1,8.2        -0.9143446  -0.910164 -0.6624068
## fBodyGyro-bandsEnergy()-9,16.2       -0.9575319  -0.925574 -0.7638147
## fBodyGyro-bandsEnergy()-17,24.2      -0.9453997  -0.927864 -0.9313014
## fBodyGyro-bandsEnergy()-25,32.2      -0.9598904  -0.956921 -0.9685598
## fBodyGyro-bandsEnergy()-33,40.2      -0.9673759  -0.962100 -0.9529675
## fBodyGyro-bandsEnergy()-41,48.2      -0.9622236  -0.953301 -0.9275661
## fBodyGyro-bandsEnergy()-49,56.2      -0.9553484  -0.939885 -0.9003283
## fBodyGyro-bandsEnergy()-57,64.2      -0.9770273  -0.963954 -0.9137916
## fBodyGyro-bandsEnergy()-1,16.2       -0.9042842  -0.889602 -0.5997018
## fBodyGyro-bandsEnergy()-17,32.2      -0.9285205  -0.910361 -0.9192732
## fBodyGyro-bandsEnergy()-33,48.2      -0.9658777  -0.959600 -0.9459600
## fBodyGyro-bandsEnergy()-49,64.2      -0.9647738  -0.950350 -0.9061819
## fBodyGyro-bandsEnergy()-1,24.2       -0.8973997  -0.880430 -0.5923555
## fBodyGyro-bandsEnergy()-25,48.2      -0.9617500  -0.957754 -0.9615495
## fBodyAccMag-mean()                   -0.5592837  -0.589928 -0.4908742
## fBodyAccMag-std()                    -0.6505333  -0.665345 -0.5482699
## fBodyAccMag-mad()                    -0.5861378  -0.601401 -0.4658975
## fBodyAccMag-max()                    -0.7503358  -0.761925 -0.6715255
## fBodyAccMag-min()                    -0.8722212  -0.895869 -0.8826558
## fBodyAccMag-sma()                    -0.5592837  -0.589928 -0.4908742
## fBodyAccMag-energy()                 -0.8175105  -0.839445 -0.7180007
## fBodyAccMag-iqr()                    -0.6862335  -0.694920 -0.6152729
## fBodyAccMag-entropy()                -0.1327881  -0.187007 -0.0846590
## fBodyAccMag-maxInds                  -0.7859914  -0.755563 -0.8353795
## fBodyAccMag-meanFreq()                0.0755927   0.084948 -0.0600681
## fBodyAccMag-skewness()               -0.3340385  -0.323741 -0.3208936
## fBodyAccMag-kurtosis()               -0.6225895  -0.606502 -0.6198153
## fBodyBodyAccJerkMag-mean()           -0.5642392  -0.607295 -0.5968963
## fBodyBodyAccJerkMag-std()            -0.5716149  -0.617075 -0.6192151
## fBodyBodyAccJerkMag-mad()            -0.5533003  -0.601976 -0.5961592
## fBodyBodyAccJerkMag-max()            -0.6187490  -0.644068 -0.6580956
## fBodyBodyAccJerkMag-min()            -0.7645087  -0.790480 -0.7847486
## fBodyBodyAccJerkMag-sma()            -0.5642392  -0.607295 -0.5968963
## fBodyBodyAccJerkMag-energy()         -0.7969473  -0.837236 -0.8276517
## fBodyBodyAccJerkMag-iqr()            -0.6387076  -0.664079 -0.6612747
## fBodyBodyAccJerkMag-entropy()        -0.2697443  -0.315644 -0.2922210
## fBodyBodyAccJerkMag-maxInds          -0.9053571  -0.880297 -0.8851049
## fBodyBodyAccJerkMag-meanFreq()        0.1263236   0.182861  0.1372395
## fBodyBodyAccJerkMag-skewness()       -0.2154740  -0.256255 -0.2413619
## fBodyBodyAccJerkMag-kurtosis()       -0.5450528  -0.545165 -0.5403741
## fBodyBodyGyroMag-mean()              -0.7173117  -0.652225 -0.5430305
## fBodyBodyGyroMag-std()               -0.7194381  -0.691915 -0.5169305
## fBodyBodyGyroMag-mad()               -0.7025480  -0.665277 -0.4724111
## fBodyBodyGyroMag-max()               -0.7575141  -0.722226 -0.5680614
## fBodyBodyGyroMag-min()               -0.8897211  -0.862269 -0.8529866
## fBodyBodyGyroMag-sma()               -0.7173117  -0.652225 -0.5430305
## fBodyBodyGyroMag-energy()            -0.9094946  -0.873223 -0.7301848
## fBodyBodyGyroMag-iqr()               -0.7497889  -0.676078 -0.5547453
## fBodyBodyGyroMag-entropy()           -0.0084909  -0.013684  0.0530498
## fBodyBodyGyroMag-maxInds             -0.8647436  -0.902611 -0.8899738
## fBodyBodyGyroMag-meanFreq()          -0.0455357   0.062589 -0.1385448
## fBodyBodyGyroMag-skewness()          -0.2960702  -0.257652 -0.2627109
## fBodyBodyGyroMag-kurtosis()          -0.6152238  -0.551795 -0.5794298
## fBodyBodyGyroJerkMag-mean()          -0.7899029  -0.712054 -0.7175901
## fBodyBodyGyroJerkMag-std()           -0.7973615  -0.733184 -0.7605601
## fBodyBodyGyroJerkMag-mad()           -0.7828316  -0.714029 -0.7143243
## fBodyBodyGyroJerkMag-max()           -0.8134732  -0.747549 -0.8052472
## fBodyBodyGyroJerkMag-min()           -0.8681532  -0.809930 -0.8515084
## fBodyBodyGyroJerkMag-sma()           -0.7899029  -0.712054 -0.7175901
## fBodyBodyGyroJerkMag-energy()        -0.9515837  -0.905916 -0.9203574
## fBodyBodyGyroJerkMag-iqr()           -0.7915658  -0.712693 -0.6842555
## fBodyBodyGyroJerkMag-entropy()       -0.2134274  -0.191027 -0.1535597
## fBodyBodyGyroJerkMag-maxInds         -0.9203373  -0.895733 -0.8929677
## fBodyBodyGyroJerkMag-meanFreq()       0.0705874   0.157417  0.0907580
## fBodyBodyGyroJerkMag-skewness()      -0.2316081  -0.195447 -0.4073100
## fBodyBodyGyroJerkMag-kurtosis()      -0.5775492  -0.519881 -0.7110352
## angle(tBodyAccMean,gravity)           0.0167089  -0.004638  0.0322300
## angle(tBodyAccJerkMean),gravityMean)  0.0163308   0.012223  0.0224017
## angle(tBodyGyroMean,gravityMean)      0.1188816   0.093953 -0.0525746
## angle(tBodyGyroJerkMean,gravityMean) -0.0644949  -0.027674  0.0278352
## angle(X,gravityMean)                 -0.5585711  -0.500095 -0.4188683
## angle(Y,gravityMean)                  0.0284576   0.091682  0.1571153
## angle(Z,gravityMean)                 -0.0097818  -0.024323  0.1215016
##                                      subject_15 subject_16 subject_17
## tBodyAcc-mean()-X                     0.2782134  2.779e-01  0.2740295
## tBodyAcc-mean()-Y                    -0.0164645 -1.586e-02 -0.0175416
## tBodyAcc-mean()-Z                    -0.1125636 -1.073e-01 -0.1091999
## tBodyAcc-std()-X                     -0.5565412 -6.682e-01 -0.6084552
## tBodyAcc-std()-Y                     -0.4816795 -6.499e-01 -0.5670053
## tBodyAcc-std()-Z                     -0.7057066 -6.038e-01 -0.6605828
## tBodyAcc-mad()-X                     -0.5863571 -6.801e-01 -0.6279498
## tBodyAcc-mad()-Y                     -0.4976267 -6.610e-01 -0.5748073
## tBodyAcc-mad()-Z                     -0.7059563 -6.083e-01 -0.6590971
## tBodyAcc-max()-X                     -0.4193041 -5.818e-01 -0.4910954
## tBodyAcc-max()-Y                     -0.3222557 -3.420e-01 -0.3289687
## tBodyAcc-max()-Z                     -0.5765635 -6.103e-01 -0.6129062
## tBodyAcc-min()-X                      0.4861691  5.949e-01  0.5366562
## tBodyAcc-min()-Y                      0.3537366  5.058e-01  0.4501021
## tBodyAcc-min()-Z                      0.6894149  5.515e-01  0.6411077
## tBodyAcc-sma()                       -0.5448076 -6.158e-01 -0.5749636
## tBodyAcc-energy()-X                  -0.7638413 -8.532e-01 -0.8133139
## tBodyAcc-energy()-Y                  -0.8914480 -9.479e-01 -0.9201699
## tBodyAcc-energy()-Z                  -0.9180680 -8.408e-01 -0.8834722
## tBodyAcc-iqr()-X                     -0.6533898 -7.053e-01 -0.6699021
## tBodyAcc-iqr()-Y                     -0.6208134 -7.460e-01 -0.6707401
## tBodyAcc-iqr()-Z                     -0.7179857 -6.439e-01 -0.6668118
## tBodyAcc-entropy()-X                 -0.1320278 -1.652e-01 -0.1828095
## tBodyAcc-entropy()-Y                 -0.1339600 -2.106e-01 -0.2089220
## tBodyAcc-entropy()-Z                 -0.2390410 -1.262e-01 -0.2131449
## tBodyAcc-arCoeff()-X,1               -0.0727046 -1.074e-01 -0.1283209
## tBodyAcc-arCoeff()-X,2                0.0528970  8.637e-02  0.0893906
## tBodyAcc-arCoeff()-X,3                0.0098792 -3.923e-02  0.0119223
## tBodyAcc-arCoeff()-X,4                0.1257893  1.463e-01  0.0460453
## tBodyAcc-arCoeff()-Y,1                0.0015780 -2.576e-02 -0.0313801
## tBodyAcc-arCoeff()-Y,2                0.0133142  2.131e-02  0.0221974
## tBodyAcc-arCoeff()-Y,3                0.1548442  1.424e-01  0.1594549
## tBodyAcc-arCoeff()-Y,4                0.0212175 -2.463e-02 -0.1309435
## tBodyAcc-arCoeff()-Z,1                0.0799262 -4.718e-02 -0.0447906
## tBodyAcc-arCoeff()-Z,2               -0.0279989  7.481e-02  0.0402226
## tBodyAcc-arCoeff()-Z,3                0.0561611 -8.195e-03  0.0612914
## tBodyAcc-arCoeff()-Z,4               -0.0455784 -5.658e-02 -0.1509048
## tBodyAcc-correlation()-X,Y           -0.2522627 -5.828e-02 -0.0079212
## tBodyAcc-correlation()-X,Z           -0.0471930 -2.489e-01 -0.1434789
## tBodyAcc-correlation()-Y,Z            0.0030834  3.113e-03  0.1052996
## tGravityAcc-mean()-X                  0.6888725  7.009e-01  0.6989374
## tGravityAcc-mean()-Y                  0.1026605 -6.052e-02 -0.0137347
## tGravityAcc-mean()-Z                  0.0372898  4.021e-02 -0.0177042
## tGravityAcc-std()-X                  -0.9687334 -9.712e-01 -0.9717717
## tGravityAcc-std()-Y                  -0.9563695 -9.647e-01 -0.9588100
## tGravityAcc-std()-Z                  -0.9472401 -9.453e-01 -0.9490392
## tGravityAcc-mad()-X                  -0.9695025 -9.717e-01 -0.9722152
## tGravityAcc-mad()-Y                  -0.9571228 -9.655e-01 -0.9594471
## tGravityAcc-mad()-Z                  -0.9484151 -9.465e-01 -0.9501530
## tGravityAcc-max()-X                   0.6272350  6.381e-01  0.6355736
## tGravityAcc-max()-Y                   0.0843259 -7.609e-02 -0.0292521
## tGravityAcc-max()-Z                   0.0404522  4.345e-02 -0.0143429
## tGravityAcc-min()-X                   0.7039398  7.168e-01  0.7148843
## tGravityAcc-min()-Y                   0.1138037 -4.386e-02  0.0002851
## tGravityAcc-min()-Z                   0.0266176  2.907e-02 -0.0274402
## tGravityAcc-sma()                    -0.1764269 -9.998e-03  0.0373731
## tGravityAcc-energy()-X                0.4377184  4.530e-01  0.4434686
## tGravityAcc-energy()-Y               -0.5634115 -8.885e-01 -0.7572964
## tGravityAcc-energy()-Z               -0.9349693 -6.013e-01 -0.7115745
## tGravityAcc-iqr()-X                  -0.9711769 -9.735e-01 -0.9736146
## tGravityAcc-iqr()-Y                  -0.9601777 -9.685e-01 -0.9622224
## tGravityAcc-iqr()-Z                  -0.9527495 -9.508e-01 -0.9538571
## tGravityAcc-entropy()-X              -0.6987741 -6.397e-01 -0.6055691
## tGravityAcc-entropy()-Y              -0.8623963 -7.410e-01 -0.8562233
## tGravityAcc-entropy()-Z              -0.4674535 -8.677e-01 -0.8445962
## tGravityAcc-arCoeff()-X,1            -0.5271442 -5.298e-01 -0.4945605
## tGravityAcc-arCoeff()-X,2             0.5656970  5.650e-01  0.5260459
## tGravityAcc-arCoeff()-X,3            -0.6037661 -5.994e-01 -0.5568862
## tGravityAcc-arCoeff()-X,4             0.6414115  6.332e-01  0.5871497
## tGravityAcc-arCoeff()-Y,1            -0.3445627 -3.972e-01 -0.3695411
## tGravityAcc-arCoeff()-Y,2             0.3359476  3.753e-01  0.3398749
## tGravityAcc-arCoeff()-Y,3            -0.3716662 -3.933e-01 -0.3514872
## tGravityAcc-arCoeff()-Y,4             0.4249398  4.275e-01  0.3803483
## tGravityAcc-arCoeff()-Z,1            -0.4727971 -4.478e-01 -0.4634068
## tGravityAcc-arCoeff()-Z,2             0.4926420  4.777e-01  0.4842969
## tGravityAcc-arCoeff()-Z,3            -0.5118854 -5.070e-01 -0.5047442
## tGravityAcc-arCoeff()-Z,4             0.5278471  5.331e-01  0.5220724
## tGravityAcc-correlation()-X,Y         0.0454748 -6.794e-02  0.4315263
## tGravityAcc-correlation()-X,Z        -0.1103355  1.003e-01  0.1890183
## tGravityAcc-correlation()-Y,Z         0.1355917  8.012e-03  0.0849058
## tBodyAccJerk-mean()-X                 0.0776897  7.755e-02  0.0814061
## tBodyAccJerk-mean()-Y                 0.0048939  8.840e-03  0.0084895
## tBodyAccJerk-mean()-Z                -0.0044099 -1.437e-03  0.0027029
## tBodyAccJerk-std()-X                 -0.6240558 -7.279e-01 -0.6826031
## tBodyAccJerk-std()-Y                 -0.5943127 -7.351e-01 -0.6686938
## tBodyAccJerk-std()-Z                 -0.8258209 -7.679e-01 -0.8133396
## tBodyAccJerk-mad()-X                 -0.6218041 -7.184e-01 -0.6713237
## tBodyAccJerk-mad()-Y                 -0.5776082 -7.242e-01 -0.6524267
## tBodyAccJerk-mad()-Z                 -0.8205172 -7.729e-01 -0.8071411
## tBodyAccJerk-max()-X                 -0.6924477 -7.844e-01 -0.7414920
## tBodyAccJerk-max()-Y                 -0.7251703 -8.277e-01 -0.8074853
## tBodyAccJerk-max()-Z                 -0.8688695 -8.330e-01 -0.8821459
## tBodyAccJerk-min()-X                  0.6261907  7.273e-01  0.6940932
## tBodyAccJerk-min()-Y                  0.6933251  7.937e-01  0.7260330
## tBodyAccJerk-min()-Z                  0.8040858  7.107e-01  0.7752849
## tBodyAccJerk-sma()                   -0.6590946 -7.240e-01 -0.6962640
## tBodyAccJerk-energy()-X              -0.8329177 -9.042e-01 -0.8793733
## tBodyAccJerk-energy()-Y              -0.8162617 -9.155e-01 -0.8696346
## tBodyAccJerk-energy()-Z              -0.9608376 -9.316e-01 -0.9570498
## tBodyAccJerk-iqr()-X                 -0.6210928 -6.995e-01 -0.6430014
## tBodyAccJerk-iqr()-Y                 -0.6416812 -7.672e-01 -0.7069488
## tBodyAccJerk-iqr()-Z                 -0.8303096 -8.066e-01 -0.8178333
## tBodyAccJerk-entropy()-X             -0.1217566 -2.044e-01 -0.1935009
## tBodyAccJerk-entropy()-Y             -0.0965875 -2.403e-01 -0.1956694
## tBodyAccJerk-entropy()-Z             -0.1970094 -1.664e-01 -0.1992841
## tBodyAccJerk-arCoeff()-X,1           -0.0808832 -9.559e-02 -0.1033145
## tBodyAccJerk-arCoeff()-X,2            0.1396878  1.449e-01  0.1598254
## tBodyAccJerk-arCoeff()-X,3            0.0445129  5.472e-02  0.0951853
## tBodyAccJerk-arCoeff()-X,4            0.2007125  1.159e-01  0.1773947
## tBodyAccJerk-arCoeff()-Y,1           -0.0645056 -4.972e-02 -0.0175018
## tBodyAccJerk-arCoeff()-Y,2            0.0733593  6.621e-02  0.0889858
## tBodyAccJerk-arCoeff()-Y,3            0.1386888  1.704e-01  0.2506149
## tBodyAccJerk-arCoeff()-Y,4            0.3713117  2.971e-01  0.2884003
## tBodyAccJerk-arCoeff()-Z,1            0.0283790 -8.918e-02 -0.0556073
## tBodyAccJerk-arCoeff()-Z,2            0.0512966  1.051e-01  0.0728683
## tBodyAccJerk-arCoeff()-Z,3           -0.0232667 -3.550e-02  0.0073716
## tBodyAccJerk-arCoeff()-Z,4            0.1845871  1.175e-01  0.1466528
## tBodyAccJerk-correlation()-X,Y       -0.1512963  1.702e-02 -0.0823369
## tBodyAccJerk-correlation()-X,Z        0.1417639 -1.152e-02  0.0452587
## tBodyAccJerk-correlation()-Y,Z       -0.0616459 -4.863e-02  0.0424222
## tBodyGyro-mean()-X                   -0.0281279 -1.223e-02 -0.0146686
## tBodyGyro-mean()-Y                   -0.0758788 -7.244e-02 -0.0827109
## tBodyGyro-mean()-Z                    0.0906659  7.301e-02  0.0770251
## tBodyGyro-std()-X                    -0.6968595 -7.995e-01 -0.7590111
## tBodyGyro-std()-Y                    -0.7087791 -8.101e-01 -0.7648670
## tBodyGyro-std()-Z                    -0.7218270 -7.376e-01 -0.7207410
## tBodyGyro-mad()-X                    -0.7001778 -8.025e-01 -0.7566226
## tBodyGyro-mad()-Y                    -0.7141460 -8.164e-01 -0.7722944
## tBodyGyro-mad()-Z                    -0.7287848 -7.417e-01 -0.7227346
## tBodyGyro-max()-X                    -0.6392088 -7.153e-01 -0.6858036
## tBodyGyro-max()-Y                    -0.7813847 -8.277e-01 -0.8103538
## tBodyGyro-max()-Z                    -0.5611062 -5.628e-01 -0.5621803
## tBodyGyro-min()-X                     0.6180694  7.067e-01  0.6873206
## tBodyGyro-min()-Y                     0.7582094  8.065e-01  0.7708426
## tBodyGyro-min()-Z                     0.6114065  6.466e-01  0.6204919
## tBodyGyro-sma()                      -0.6179399 -7.165e-01 -0.6702027
## tBodyGyro-energy()-X                 -0.8885070 -9.395e-01 -0.9182501
## tBodyGyro-energy()-Y                 -0.9037256 -9.584e-01 -0.9364177
## tBodyGyro-energy()-Z                 -0.9208853 -9.185e-01 -0.9112808
## tBodyGyro-iqr()-X                    -0.6972108 -8.042e-01 -0.7369482
## tBodyGyro-iqr()-Y                    -0.7290066 -8.293e-01 -0.7929404
## tBodyGyro-iqr()-Z                    -0.7650845 -7.705e-01 -0.7499727
## tBodyGyro-entropy()-X                -0.1649167 -1.596e-01 -0.2121040
## tBodyGyro-entropy()-Y                -0.1105050 -1.461e-01 -0.1674237
## tBodyGyro-entropy()-Z                -0.0832201 -2.097e-01 -0.1607973
## tBodyGyro-arCoeff()-X,1              -0.2633338 -2.211e-01 -0.1946965
## tBodyGyro-arCoeff()-X,2               0.1396743  1.194e-01  0.1400432
## tBodyGyro-arCoeff()-X,3               0.2152257  1.781e-01  0.1136911
## tBodyGyro-arCoeff()-X,4              -0.1630903 -1.209e-01 -0.1368333
## tBodyGyro-arCoeff()-Y,1              -0.2303391 -1.705e-01 -0.1676571
## tBodyGyro-arCoeff()-Y,2               0.1608216  1.187e-01  0.1474301
## tBodyGyro-arCoeff()-Y,3              -0.0342802  4.010e-02  0.0045307
## tBodyGyro-arCoeff()-Y,4               0.1662236  6.905e-02  0.0328060
## tBodyGyro-arCoeff()-Z,1              -0.0605244 -8.132e-02 -0.0516489
## tBodyGyro-arCoeff()-Z,2               0.0239132  6.788e-02  0.0539899
## tBodyGyro-arCoeff()-Z,3               0.0229815 -1.272e-02 -0.0168763
## tBodyGyro-arCoeff()-Z,4               0.1858971  1.141e-01  0.0735064
## tBodyGyro-correlation()-X,Y          -0.2442858  2.538e-05 -0.3451860
## tBodyGyro-correlation()-X,Z          -0.0677039 -9.172e-02 -0.1261481
## tBodyGyro-correlation()-Y,Z          -0.0164188  3.155e-02 -0.0939284
## tBodyGyroJerk-mean()-X               -0.0960910 -1.074e-01 -0.1078542
## tBodyGyroJerk-mean()-Y               -0.0441271 -4.166e-02 -0.0391719
## tBodyGyroJerk-mean()-Z               -0.0555645 -5.395e-02 -0.0508497
## tBodyGyroJerk-std()-X                -0.7313827 -8.583e-01 -0.7883880
## tBodyGyroJerk-std()-Y                -0.8539566 -8.696e-01 -0.8259887
## tBodyGyroJerk-std()-Z                -0.7956262 -8.370e-01 -0.8082513
## tBodyGyroJerk-mad()-X                -0.7220000 -8.554e-01 -0.7888637
## tBodyGyroJerk-mad()-Y                -0.8609459 -8.757e-01 -0.8329441
## tBodyGyroJerk-mad()-Z                -0.7990383 -8.395e-01 -0.8120870
## tBodyGyroJerk-max()-X                -0.7713414 -8.625e-01 -0.8127865
## tBodyGyroJerk-max()-Y                -0.8763311 -8.769e-01 -0.8425496
## tBodyGyroJerk-max()-Z                -0.7844488 -8.275e-01 -0.8214868
## tBodyGyroJerk-min()-X                 0.7725532  8.811e-01  0.8058188
## tBodyGyroJerk-min()-Y                 0.8826853  9.049e-01  0.8736022
## tBodyGyroJerk-min()-Z                 0.8539439  8.892e-01  0.8468327
## tBodyGyroJerk-sma()                  -0.8088983 -8.621e-01 -0.8161275
## tBodyGyroJerk-energy()-X             -0.9201228 -9.767e-01 -0.9465874
## tBodyGyroJerk-energy()-Y             -0.9750361 -9.787e-01 -0.9612628
## tBodyGyroJerk-energy()-Z             -0.9523856 -9.666e-01 -0.9565143
## tBodyGyroJerk-iqr()-X                -0.7167897 -8.544e-01 -0.8015936
## tBodyGyroJerk-iqr()-Y                -0.8673636 -8.814e-01 -0.8431855
## tBodyGyroJerk-iqr()-Z                -0.8100895 -8.474e-01 -0.8242665
## tBodyGyroJerk-entropy()-X            -0.0328449 -1.536e-01 -0.1427502
## tBodyGyroJerk-entropy()-Y            -0.0691075 -1.092e-01 -0.1484097
## tBodyGyroJerk-entropy()-Z            -0.0546787 -1.895e-01 -0.1344914
## tBodyGyroJerk-arCoeff()-X,1          -0.0994037 -5.767e-02 -0.0155821
## tBodyGyroJerk-arCoeff()-X,2          -0.0031243 -3.174e-03  0.0578696
## tBodyGyroJerk-arCoeff()-X,3           0.1752384  1.794e-01  0.2335183
## tBodyGyroJerk-arCoeff()-X,4           0.2169033  1.665e-01  0.1099384
## tBodyGyroJerk-arCoeff()-Y,1          -0.1933365 -1.150e-01 -0.1045173
## tBodyGyroJerk-arCoeff()-Y,2           0.1691123  1.618e-01  0.2159833
## tBodyGyroJerk-arCoeff()-Y,3           0.0481457  1.242e-01  0.1622337
## tBodyGyroJerk-arCoeff()-Y,4           0.0916014  1.211e-01  0.0940165
## tBodyGyroJerk-arCoeff()-Z,1          -0.0318484 -9.466e-03  0.0489259
## tBodyGyroJerk-arCoeff()-Z,2           0.0194187  7.071e-02  0.0665889
## tBodyGyroJerk-arCoeff()-Z,3           0.0247103  1.037e-01  0.1805028
## tBodyGyroJerk-arCoeff()-Z,4           0.1330779  4.377e-02 -0.0153525
## tBodyGyroJerk-correlation()-X,Y      -0.0612294  1.631e-01  0.0340211
## tBodyGyroJerk-correlation()-X,Z      -0.0568249  6.216e-02 -0.0046710
## tBodyGyroJerk-correlation()-Y,Z      -0.0358990  4.249e-02 -0.1565414
## tBodyAccMag-mean()                   -0.5272854 -6.161e-01 -0.5683672
## tBodyAccMag-std()                    -0.5571479 -6.617e-01 -0.6360745
## tBodyAccMag-mad()                    -0.6096075 -7.000e-01 -0.6726851
## tBodyAccMag-max()                    -0.5404963 -6.471e-01 -0.6187204
## tBodyAccMag-min()                    -0.8360594 -8.790e-01 -0.8319801
## tBodyAccMag-sma()                    -0.5272854 -6.161e-01 -0.5683672
## tBodyAccMag-energy()                 -0.7417291 -8.193e-01 -0.7854412
## tBodyAccMag-iqr()                    -0.6752739 -7.432e-01 -0.7062078
## tBodyAccMag-entropy()                 0.1065945  2.714e-02  0.0423613
## tBodyAccMag-arCoeff()1               -0.0895921 -9.888e-02 -0.1069657
## tBodyAccMag-arCoeff()2                0.0255347  5.538e-02  0.0582734
## tBodyAccMag-arCoeff()3                0.0955136  3.288e-02  0.0530355
## tBodyAccMag-arCoeff()4               -0.0758776 -5.856e-02 -0.0922540
## tGravityAccMag-mean()                -0.5272854 -6.161e-01 -0.5683672
## tGravityAccMag-std()                 -0.5571479 -6.617e-01 -0.6360745
## tGravityAccMag-mad()                 -0.6096075 -7.000e-01 -0.6726851
## tGravityAccMag-max()                 -0.5404963 -6.471e-01 -0.6187204
## tGravityAccMag-min()                 -0.8360594 -8.790e-01 -0.8319801
## tGravityAccMag-sma()                 -0.5272854 -6.161e-01 -0.5683672
## tGravityAccMag-energy()              -0.7417291 -8.193e-01 -0.7854412
## tGravityAccMag-iqr()                 -0.6752739 -7.432e-01 -0.7062078
## tGravityAccMag-entropy()              0.1065945  2.714e-02  0.0423613
## tGravityAccMag-arCoeff()1            -0.0895921 -9.888e-02 -0.1069657
## tGravityAccMag-arCoeff()2             0.0255347  5.538e-02  0.0582734
## tGravityAccMag-arCoeff()3             0.0955136  3.288e-02  0.0530355
## tGravityAccMag-arCoeff()4            -0.0758776 -5.856e-02 -0.0922540
## tBodyAccJerkMag-mean()               -0.6547997 -7.252e-01 -0.6964652
## tBodyAccJerkMag-std()                -0.6256604 -7.196e-01 -0.6939464
## tBodyAccJerkMag-mad()                -0.6443729 -7.287e-01 -0.7012109
## tBodyAccJerkMag-max()                -0.6433569 -7.312e-01 -0.7151950
## tBodyAccJerkMag-min()                -0.7962011 -8.255e-01 -0.8259915
## tBodyAccJerkMag-sma()                -0.6547997 -7.252e-01 -0.6964652
## tBodyAccJerkMag-energy()             -0.8521407 -9.011e-01 -0.8876648
## tBodyAccJerkMag-iqr()                -0.6990666 -7.594e-01 -0.7287932
## tBodyAccJerkMag-entropy()            -0.0882881 -1.961e-01 -0.1654559
## tBodyAccJerkMag-arCoeff()1            0.0523711  8.340e-02  0.0754041
## tBodyAccJerkMag-arCoeff()2            0.0044671 -2.414e-02 -0.0445824
## tBodyAccJerkMag-arCoeff()3           -0.0888147 -8.819e-02 -0.0433946
## tBodyAccJerkMag-arCoeff()4           -0.0514610 -5.983e-02 -0.0733402
## tBodyGyroMag-mean()                  -0.6177218 -7.182e-01 -0.6761851
## tBodyGyroMag-std()                   -0.6753370 -7.848e-01 -0.7501453
## tBodyGyroMag-mad()                   -0.6437301 -7.629e-01 -0.7205114
## tBodyGyroMag-max()                   -0.7182379 -8.075e-01 -0.7784043
## tBodyGyroMag-min()                   -0.7405101 -7.699e-01 -0.7719229
## tBodyGyroMag-sma()                   -0.6177218 -7.182e-01 -0.6761851
## tBodyGyroMag-energy()                -0.8464446 -9.135e-01 -0.8841138
## tBodyGyroMag-iqr()                   -0.6675815 -7.774e-01 -0.7258583
## tBodyGyroMag-entropy()                0.1940266  2.185e-01  0.1340165
## tBodyGyroMag-arCoeff()1              -0.1429391 -2.072e-02  0.0643773
## tBodyGyroMag-arCoeff()2               0.0021780 -9.853e-02 -0.1371520
## tBodyGyroMag-arCoeff()3               0.1203043  1.419e-01  0.1440649
## tBodyGyroMag-arCoeff()4              -0.0542745 -4.959e-02 -0.1132379
## tBodyGyroJerkMag-mean()              -0.8052827 -8.604e-01 -0.8104382
## tBodyGyroJerkMag-std()               -0.8371201 -8.748e-01 -0.8252560
## tBodyGyroJerkMag-mad()               -0.8444100 -8.847e-01 -0.8318841
## tBodyGyroJerkMag-max()               -0.8437983 -8.735e-01 -0.8335639
## tBodyGyroJerkMag-min()               -0.8206236 -8.637e-01 -0.8484286
## tBodyGyroJerkMag-sma()               -0.8052827 -8.604e-01 -0.8104382
## tBodyGyroJerkMag-energy()            -0.9604689 -9.766e-01 -0.9574333
## tBodyGyroJerkMag-iqr()               -0.8487507 -8.937e-01 -0.8338629
## tBodyGyroJerkMag-entropy()            0.0763535 -5.381e-02 -0.0434051
## tBodyGyroJerkMag-arCoeff()1           0.2249658  3.040e-01  0.3849297
## tBodyGyroJerkMag-arCoeff()2          -0.1666401 -2.717e-01 -0.2965370
## tBodyGyroJerkMag-arCoeff()3           0.0328164  5.718e-03 -0.0901326
## tBodyGyroJerkMag-arCoeff()4          -0.2391897 -1.232e-01 -0.0884314
## fBodyAcc-mean()-X                    -0.5837723 -7.009e-01 -0.6517804
## fBodyAcc-mean()-Y                    -0.5077352 -6.716e-01 -0.6017414
## fBodyAcc-mean()-Z                    -0.7417457 -6.610e-01 -0.7189474
## fBodyAcc-std()-X                     -0.5471509 -6.570e-01 -0.5935102
## fBodyAcc-std()-Y                     -0.5015684 -6.618e-01 -0.5769301
## fBodyAcc-std()-Z                     -0.7114313 -6.056e-01 -0.6566229
## fBodyAcc-mad()-X                     -0.5305325 -6.691e-01 -0.5929279
## fBodyAcc-mad()-Y                     -0.4943444 -6.545e-01 -0.5756304
## fBodyAcc-mad()-Z                     -0.7202366 -6.189e-01 -0.6727070
## fBodyAcc-max()-X                     -0.6099609 -6.832e-01 -0.6403616
## fBodyAcc-max()-Y                     -0.6442494 -7.686e-01 -0.6845585
## fBodyAcc-max()-Z                     -0.7332772 -6.233e-01 -0.6681572
## fBodyAcc-min()-X                     -0.8565879 -8.810e-01 -0.8576102
## fBodyAcc-min()-Y                     -0.8578911 -9.151e-01 -0.9060702
## fBodyAcc-min()-Z                     -0.9249966 -9.100e-01 -0.9270453
## fBodyAcc-sma()                       -0.5521491 -6.349e-01 -0.6080018
## fBodyAcc-energy()-X                  -0.7639923 -8.535e-01 -0.8133952
## fBodyAcc-energy()-Y                  -0.7200282 -8.660e-01 -0.7938379
## fBodyAcc-energy()-Z                  -0.9092606 -8.229e-01 -0.8697344
## fBodyAcc-iqr()-X                     -0.6499780 -7.466e-01 -0.7285271
## fBodyAcc-iqr()-Y                     -0.6373560 -7.519e-01 -0.7030243
## fBodyAcc-iqr()-Z                     -0.8065027 -7.522e-01 -0.7953290
## fBodyAcc-entropy()-X                 -0.2167406 -3.311e-01 -0.3142508
## fBodyAcc-entropy()-Y                 -0.1903852 -3.295e-01 -0.2866558
## fBodyAcc-entropy()-Z                 -0.2702642 -2.686e-01 -0.3013516
## fBodyAcc-maxInds-X                   -0.7309205 -7.800e-01 -0.8194250
## fBodyAcc-maxInds-Y                   -0.7985772 -8.446e-01 -0.8893116
## fBodyAcc-maxInds-Z                   -0.8663227 -8.331e-01 -0.8689381
## fBodyAcc-meanFreq()-X                -0.2186371 -2.386e-01 -0.2262924
## fBodyAcc-meanFreq()-Y                 0.0505085 -2.764e-02  0.0052999
## fBodyAcc-meanFreq()-Z                 0.0424520  2.782e-02  0.0075564
## fBodyAcc-skewness()-X                -0.2238301 -7.497e-02 -0.1399255
## fBodyAcc-kurtosis()-X                -0.5684656 -3.906e-01 -0.4829056
## fBodyAcc-skewness()-Y                -0.3172697 -1.893e-01 -0.1262315
## fBodyAcc-kurtosis()-Y                -0.6403495 -4.828e-01 -0.4326702
## fBodyAcc-skewness()-Z                -0.2820982 -2.064e-01 -0.1771482
## fBodyAcc-kurtosis()-Z                -0.5226794 -4.525e-01 -0.4283917
## fBodyAcc-bandsEnergy()-1,8           -0.7375769 -8.347e-01 -0.7975851
## fBodyAcc-bandsEnergy()-9,16          -0.8627102 -9.228e-01 -0.8751238
## fBodyAcc-bandsEnergy()-17,24         -0.8846164 -9.256e-01 -0.9083126
## fBodyAcc-bandsEnergy()-25,32         -0.9242453 -9.426e-01 -0.9523941
## fBodyAcc-bandsEnergy()-33,40         -0.8995242 -9.416e-01 -0.9502348
## fBodyAcc-bandsEnergy()-41,48         -0.8965965 -9.387e-01 -0.9380961
## fBodyAcc-bandsEnergy()-49,56         -0.9454303 -9.636e-01 -0.9583723
## fBodyAcc-bandsEnergy()-57,64         -0.9515680 -9.623e-01 -0.9563637
## fBodyAcc-bandsEnergy()-1,16          -0.7500509 -8.453e-01 -0.8016187
## fBodyAcc-bandsEnergy()-17,32         -0.8783844 -9.190e-01 -0.9071203
## fBodyAcc-bandsEnergy()-33,48         -0.8984410 -9.405e-01 -0.9456992
## fBodyAcc-bandsEnergy()-49,64         -0.9474875 -9.632e-01 -0.9576991
## fBodyAcc-bandsEnergy()-1,24          -0.7596169 -8.510e-01 -0.8092037
## fBodyAcc-bandsEnergy()-25,48         -0.8970798 -9.304e-01 -0.9399058
## fBodyAcc-bandsEnergy()-1,8.1         -0.7738456 -8.798e-01 -0.7990828
## fBodyAcc-bandsEnergy()-9,16.1        -0.7892294 -9.184e-01 -0.9138880
## fBodyAcc-bandsEnergy()-17,24.1       -0.8867164 -9.397e-01 -0.8591421
## fBodyAcc-bandsEnergy()-25,32.1       -0.9037770 -9.512e-01 -0.9438599
## fBodyAcc-bandsEnergy()-33,40.1       -0.8719238 -9.562e-01 -0.9361557
## fBodyAcc-bandsEnergy()-41,48.1       -0.8481675 -9.450e-01 -0.9267387
## fBodyAcc-bandsEnergy()-49,56.1       -0.8812136 -9.528e-01 -0.9349120
## fBodyAcc-bandsEnergy()-57,64.1       -0.9381351 -9.744e-01 -0.9618653
## fBodyAcc-bandsEnergy()-1,16.1        -0.7182942 -8.659e-01 -0.8017639
## fBodyAcc-bandsEnergy()-17,32.1       -0.8627295 -9.277e-01 -0.8476707
## fBodyAcc-bandsEnergy()-33,48.1       -0.8481547 -9.469e-01 -0.9252540
## fBodyAcc-bandsEnergy()-49,64.1       -0.9013774 -9.604e-01 -0.9441727
## fBodyAcc-bandsEnergy()-1,24.1        -0.7225735 -8.668e-01 -0.7939918
## fBodyAcc-bandsEnergy()-25,48.1       -0.8815950 -9.474e-01 -0.9352344
## fBodyAcc-bandsEnergy()-1,8.2         -0.9174087 -8.418e-01 -0.8716614
## fBodyAcc-bandsEnergy()-9,16.2        -0.9498412 -8.774e-01 -0.9302523
## fBodyAcc-bandsEnergy()-17,24.2       -0.9543197 -9.272e-01 -0.9534009
## fBodyAcc-bandsEnergy()-25,32.2       -0.9815550 -9.697e-01 -0.9857123
## fBodyAcc-bandsEnergy()-33,40.2       -0.9724130 -9.680e-01 -0.9839680
## fBodyAcc-bandsEnergy()-41,48.2       -0.9524420 -9.440e-01 -0.9674150
## fBodyAcc-bandsEnergy()-49,56.2       -0.9587008 -9.388e-01 -0.9658835
## fBodyAcc-bandsEnergy()-57,64.2       -0.9732480 -9.376e-01 -0.9698340
## fBodyAcc-bandsEnergy()-1,16.2        -0.9178329 -8.340e-01 -0.8749456
## fBodyAcc-bandsEnergy()-17,32.2       -0.9642186 -9.426e-01 -0.9651387
## fBodyAcc-bandsEnergy()-33,48.2       -0.9653062 -9.596e-01 -0.9785703
## fBodyAcc-bandsEnergy()-49,64.2       -0.9627202 -9.379e-01 -0.9667868
## fBodyAcc-bandsEnergy()-1,24.2        -0.9112949 -8.248e-01 -0.8697479
## fBodyAcc-bandsEnergy()-25,48.2       -0.9769381 -9.669e-01 -0.9836923
## fBodyAccJerk-mean()-X                -0.6434695 -7.447e-01 -0.7166816
## fBodyAccJerk-mean()-Y                -0.6094081 -7.486e-01 -0.6947548
## fBodyAccJerk-mean()-Z                -0.8055435 -7.523e-01 -0.8025288
## fBodyAccJerk-std()-X                 -0.6376552 -7.348e-01 -0.6765449
## fBodyAccJerk-std()-Y                 -0.6058549 -7.384e-01 -0.6631584
## fBodyAccJerk-std()-Z                 -0.8451111 -7.821e-01 -0.8228017
## fBodyAccJerk-mad()-X                 -0.5823310 -6.996e-01 -0.6421219
## fBodyAccJerk-mad()-Y                 -0.6145837 -7.437e-01 -0.6809882
## fBodyAccJerk-mad()-Z                 -0.8301289 -7.686e-01 -0.8143680
## fBodyAccJerk-max()-X                 -0.6847014 -7.560e-01 -0.7124368
## fBodyAccJerk-max()-Y                 -0.6784269 -7.832e-01 -0.7022569
## fBodyAccJerk-max()-Z                 -0.8606355 -7.983e-01 -0.8345918
## fBodyAccJerk-min()-X                 -0.8701909 -9.050e-01 -0.9123795
## fBodyAccJerk-min()-Y                 -0.8562675 -9.058e-01 -0.8834420
## fBodyAccJerk-min()-Z                 -0.9042586 -8.896e-01 -0.9160418
## fBodyAccJerk-sma()                   -0.6314442 -7.043e-01 -0.6927610
## fBodyAccJerk-energy()-X              -0.8327107 -9.041e-01 -0.8792452
## fBodyAccJerk-energy()-Y              -0.8163718 -9.155e-01 -0.8696974
## fBodyAccJerk-energy()-Z              -0.9608542 -9.316e-01 -0.9570744
## fBodyAccJerk-iqr()-X                 -0.6293595 -7.351e-01 -0.7103465
## fBodyAccJerk-iqr()-Y                 -0.7074618 -8.034e-01 -0.7695978
## fBodyAccJerk-iqr()-Z                 -0.8252092 -7.828e-01 -0.8300776
## fBodyAccJerk-entropy()-X             -0.2811163 -3.994e-01 -0.3525298
## fBodyAccJerk-entropy()-Y             -0.2612427 -4.198e-01 -0.3576707
## fBodyAccJerk-entropy()-Z             -0.4590526 -4.206e-01 -0.4570595
## fBodyAccJerk-maxInds-X               -0.4050000 -4.600e-01 -0.3873913
## fBodyAccJerk-maxInds-Y               -0.4270732 -3.750e-01 -0.3216304
## fBodyAccJerk-maxInds-Z               -0.3042683 -3.493e-01 -0.3321739
## fBodyAccJerk-meanFreq()-X            -0.0490274 -3.189e-02 -0.0799060
## fBodyAccJerk-meanFreq()-Y            -0.1974087 -1.945e-01 -0.1616348
## fBodyAccJerk-meanFreq()-Z            -0.0737834 -1.706e-01 -0.1623848
## fBodyAccJerk-skewness()-X            -0.3216579 -2.526e-01 -0.2529672
## fBodyAccJerk-kurtosis()-X            -0.7163374 -6.406e-01 -0.6598752
## fBodyAccJerk-skewness()-Y            -0.4140604 -4.362e-01 -0.3918237
## fBodyAccJerk-kurtosis()-Y            -0.8346057 -8.421e-01 -0.8060010
## fBodyAccJerk-skewness()-Z            -0.5483847 -4.583e-01 -0.4622175
## fBodyAccJerk-kurtosis()-Z            -0.8502972 -7.952e-01 -0.7948286
## fBodyAccJerk-bandsEnergy()-1,8       -0.7970573 -8.882e-01 -0.8474932
## fBodyAccJerk-bandsEnergy()-9,16      -0.8640537 -9.284e-01 -0.8926563
## fBodyAccJerk-bandsEnergy()-17,24     -0.9005087 -9.353e-01 -0.9246426
## fBodyAccJerk-bandsEnergy()-25,32     -0.9294072 -9.458e-01 -0.9604534
## fBodyAccJerk-bandsEnergy()-33,40     -0.9073301 -9.519e-01 -0.9613109
## fBodyAccJerk-bandsEnergy()-41,48     -0.8835936 -9.375e-01 -0.9394037
## fBodyAccJerk-bandsEnergy()-49,56     -0.9483095 -9.710e-01 -0.9667508
## fBodyAccJerk-bandsEnergy()-57,64     -0.9849155 -9.910e-01 -0.9909549
## fBodyAccJerk-bandsEnergy()-1,16      -0.8221787 -9.041e-01 -0.8630489
## fBodyAccJerk-bandsEnergy()-17,32     -0.8900097 -9.248e-01 -0.9228161
## fBodyAccJerk-bandsEnergy()-33,48     -0.8898614 -9.420e-01 -0.9490880
## fBodyAccJerk-bandsEnergy()-49,64     -0.9462885 -9.697e-01 -0.9655779
## fBodyAccJerk-bandsEnergy()-1,24      -0.8196517 -8.985e-01 -0.8615914
## fBodyAccJerk-bandsEnergy()-25,48     -0.8738808 -9.210e-01 -0.9366024
## fBodyAccJerk-bandsEnergy()-1,8.1     -0.8212417 -9.120e-01 -0.8464152
## fBodyAccJerk-bandsEnergy()-9,16.1    -0.8382825 -9.295e-01 -0.9190937
## fBodyAccJerk-bandsEnergy()-17,24.1   -0.8657673 -9.295e-01 -0.8393097
## fBodyAccJerk-bandsEnergy()-25,32.1   -0.9097019 -9.538e-01 -0.9485852
## fBodyAccJerk-bandsEnergy()-33,40.1   -0.8932359 -9.656e-01 -0.9505868
## fBodyAccJerk-bandsEnergy()-41,48.1   -0.8448522 -9.458e-01 -0.9296486
## fBodyAccJerk-bandsEnergy()-49,56.1   -0.9129378 -9.642e-01 -0.9543629
## fBodyAccJerk-bandsEnergy()-57,64.1   -0.9753714 -9.860e-01 -0.9819736
## fBodyAccJerk-bandsEnergy()-1,16.1    -0.8112555 -9.154e-01 -0.8904689
## fBodyAccJerk-bandsEnergy()-17,32.1   -0.8594849 -9.268e-01 -0.8585107
## fBodyAccJerk-bandsEnergy()-33,48.1   -0.8469326 -9.489e-01 -0.9298032
## fBodyAccJerk-bandsEnergy()-49,64.1   -0.9208179 -9.669e-01 -0.9578500
## fBodyAccJerk-bandsEnergy()-1,24.1    -0.8036072 -9.074e-01 -0.8495731
## fBodyAccJerk-bandsEnergy()-25,48.1   -0.8842811 -9.513e-01 -0.9406663
## fBodyAccJerk-bandsEnergy()-1,8.2     -0.9547944 -8.616e-01 -0.8942292
## fBodyAccJerk-bandsEnergy()-9,16.2    -0.9505164 -8.873e-01 -0.9275576
## fBodyAccJerk-bandsEnergy()-17,24.2   -0.9581481 -9.347e-01 -0.9586745
## fBodyAccJerk-bandsEnergy()-25,32.2   -0.9821476 -9.726e-01 -0.9871410
## fBodyAccJerk-bandsEnergy()-33,40.2   -0.9743987 -9.745e-01 -0.9861933
## fBodyAccJerk-bandsEnergy()-41,48.2   -0.9557609 -9.538e-01 -0.9725103
## fBodyAccJerk-bandsEnergy()-49,56.2   -0.9485537 -9.449e-01 -0.9658224
## fBodyAccJerk-bandsEnergy()-57,64.2   -0.9784878 -9.712e-01 -0.9876086
## fBodyAccJerk-bandsEnergy()-1,16.2    -0.9416417 -8.545e-01 -0.9004925
## fBodyAccJerk-bandsEnergy()-17,32.2   -0.9699112 -9.532e-01 -0.9726217
## fBodyAccJerk-bandsEnergy()-33,48.2   -0.9670580 -9.666e-01 -0.9811405
## fBodyAccJerk-bandsEnergy()-49,64.2   -0.9487212 -9.444e-01 -0.9661514
## fBodyAccJerk-bandsEnergy()-1,24.2    -0.9454856 -8.908e-01 -0.9276017
## fBodyAccJerk-bandsEnergy()-25,48.2   -0.9762452 -9.702e-01 -0.9848095
## fBodyGyro-mean()-X                   -0.6643544 -7.898e-01 -0.7287104
## fBodyGyro-mean()-Y                   -0.7607114 -8.160e-01 -0.7747453
## fBodyGyro-mean()-Z                   -0.7111945 -7.563e-01 -0.7268578
## fBodyGyro-std()-X                    -0.7093362 -8.050e-01 -0.7700572
## fBodyGyro-std()-Y                    -0.6845047 -8.094e-01 -0.7613352
## fBodyGyro-std()-Z                    -0.7516965 -7.570e-01 -0.7451015
## fBodyGyro-mad()-X                    -0.6648394 -7.863e-01 -0.7364394
## fBodyGyro-mad()-Y                    -0.7532526 -8.256e-01 -0.7773180
## fBodyGyro-mad()-Z                    -0.7090894 -7.376e-01 -0.7118107
## fBodyGyro-max()-X                    -0.7034311 -7.896e-01 -0.7560574
## fBodyGyro-max()-Y                    -0.7041204 -8.480e-01 -0.8184785
## fBodyGyro-max()-Z                    -0.8107654 -8.007e-01 -0.8052481
## fBodyGyro-min()-X                    -0.9396762 -9.526e-01 -0.9387024
## fBodyGyro-min()-Y                    -0.9092664 -9.339e-01 -0.9258120
## fBodyGyro-min()-Z                    -0.9164134 -9.350e-01 -0.9388970
## fBodyGyro-sma()                      -0.6985968 -7.808e-01 -0.7324144
## fBodyGyro-energy()-X                 -0.9029883 -9.521e-01 -0.9317348
## fBodyGyro-energy()-Y                 -0.9052529 -9.602e-01 -0.9375277
## fBodyGyro-energy()-Z                 -0.9175165 -9.200e-01 -0.9105663
## fBodyGyro-iqr()-X                    -0.7293821 -8.511e-01 -0.7644907
## fBodyGyro-iqr()-Y                    -0.8263201 -8.453e-01 -0.8034809
## fBodyGyro-iqr()-Z                    -0.7675162 -7.995e-01 -0.7652679
## fBodyGyro-entropy()-X                -0.1194818 -2.694e-01 -0.2321429
## fBodyGyro-entropy()-Y                -0.1382657 -1.797e-01 -0.1950865
## fBodyGyro-entropy()-Z                -0.1899562 -3.385e-01 -0.2974009
## fBodyGyro-maxInds-X                  -0.8969512 -8.974e-01 -0.9365942
## fBodyGyro-maxInds-Y                  -0.8288749 -8.555e-01 -0.7892707
## fBodyGyro-maxInds-Z                  -0.8095038 -8.457e-01 -0.8766867
## fBodyGyro-meanFreq()-X               -0.1432567 -1.379e-01 -0.0811028
## fBodyGyro-meanFreq()-Y               -0.2221375 -1.580e-01 -0.1067783
## fBodyGyro-meanFreq()-Z               -0.0579761 -5.389e-02 -0.0322665
## fBodyGyro-skewness()-X               -0.1751999 -6.506e-02 -0.0383764
## fBodyGyro-kurtosis()-X               -0.5106786 -3.689e-01 -0.3468663
## fBodyGyro-skewness()-Y               -0.1158827 -1.841e-01 -0.1622325
## fBodyGyro-kurtosis()-Y               -0.4729716 -5.407e-01 -0.5167913
## fBodyGyro-skewness()-Z               -0.2460872 -1.349e-01 -0.1673791
## fBodyGyro-kurtosis()-Z               -0.5737429 -4.360e-01 -0.4905416
## fBodyGyro-bandsEnergy()-1,8          -0.9205332 -9.539e-01 -0.9378061
## fBodyGyro-bandsEnergy()-9,16         -0.8619913 -9.699e-01 -0.9537323
## fBodyGyro-bandsEnergy()-17,24        -0.9477577 -9.865e-01 -0.9394479
## fBodyGyro-bandsEnergy()-25,32        -0.9734935 -9.911e-01 -0.9744432
## fBodyGyro-bandsEnergy()-33,40        -0.9630065 -9.846e-01 -0.9738429
## fBodyGyro-bandsEnergy()-41,48        -0.9564168 -9.817e-01 -0.9704659
## fBodyGyro-bandsEnergy()-49,56        -0.9676675 -9.855e-01 -0.9758811
## fBodyGyro-bandsEnergy()-57,64        -0.9765870 -9.871e-01 -0.9806778
## fBodyGyro-bandsEnergy()-1,16         -0.9050408 -9.522e-01 -0.9347011
## fBodyGyro-bandsEnergy()-17,32        -0.9471665 -9.855e-01 -0.9408701
## fBodyGyro-bandsEnergy()-33,48        -0.9566043 -9.819e-01 -0.9698387
## fBodyGyro-bandsEnergy()-49,64        -0.9716143 -9.862e-01 -0.9780036
## fBodyGyro-bandsEnergy()-1,24         -0.9038182 -9.523e-01 -0.9325162
## fBodyGyro-bandsEnergy()-25,48        -0.9683295 -9.884e-01 -0.9728358
## fBodyGyro-bandsEnergy()-1,8.1        -0.8623881 -9.572e-01 -0.9441576
## fBodyGyro-bandsEnergy()-9,16.1       -0.9801086 -9.848e-01 -0.9726794
## fBodyGyro-bandsEnergy()-17,24.1      -0.9888039 -9.879e-01 -0.9680825
## fBodyGyro-bandsEnergy()-25,32.1      -0.9904869 -9.887e-01 -0.9861010
## fBodyGyro-bandsEnergy()-33,40.1      -0.9893064 -9.888e-01 -0.9902679
## fBodyGyro-bandsEnergy()-41,48.1      -0.9785693 -9.783e-01 -0.9795806
## fBodyGyro-bandsEnergy()-49,56.1      -0.9735193 -9.799e-01 -0.9757358
## fBodyGyro-bandsEnergy()-57,64.1      -0.9795201 -9.925e-01 -0.9854110
## fBodyGyro-bandsEnergy()-1,16.1       -0.8944053 -9.613e-01 -0.9446322
## fBodyGyro-bandsEnergy()-17,32.1      -0.9866462 -9.852e-01 -0.9659316
## fBodyGyro-bandsEnergy()-33,48.1      -0.9869924 -9.865e-01 -0.9879739
## fBodyGyro-bandsEnergy()-49,64.1      -0.9725156 -9.826e-01 -0.9766261
## fBodyGyro-bandsEnergy()-1,24.1       -0.8965922 -9.583e-01 -0.9332577
## fBodyGyro-bandsEnergy()-25,48.1      -0.9886536 -9.871e-01 -0.9856110
## fBodyGyro-bandsEnergy()-1,8.2        -0.9371483 -9.303e-01 -0.9240499
## fBodyGyro-bandsEnergy()-9,16.2       -0.9501247 -9.716e-01 -0.9696919
## fBodyGyro-bandsEnergy()-17,24.2      -0.9661287 -9.725e-01 -0.9546989
## fBodyGyro-bandsEnergy()-25,32.2      -0.9843809 -9.918e-01 -0.9857151
## fBodyGyro-bandsEnergy()-33,40.2      -0.9798795 -9.919e-01 -0.9897312
## fBodyGyro-bandsEnergy()-41,48.2      -0.9727355 -9.870e-01 -0.9842032
## fBodyGyro-bandsEnergy()-49,56.2      -0.9682725 -9.817e-01 -0.9796402
## fBodyGyro-bandsEnergy()-57,64.2      -0.9785622 -9.852e-01 -0.9850500
## fBodyGyro-bandsEnergy()-1,16.2       -0.9234983 -9.242e-01 -0.9175911
## fBodyGyro-bandsEnergy()-17,32.2      -0.9601426 -9.698e-01 -0.9498891
## fBodyGyro-bandsEnergy()-33,48.2      -0.9778886 -9.905e-01 -0.9882106
## fBodyGyro-bandsEnergy()-49,64.2      -0.9727463 -9.833e-01 -0.9819924
## fBodyGyro-bandsEnergy()-1,24.2       -0.9193087 -9.209e-01 -0.9118935
## fBodyGyro-bandsEnergy()-25,48.2      -0.9823684 -9.914e-01 -0.9864913
## fBodyAccMag-mean()                   -0.5629484 -6.670e-01 -0.6461892
## fBodyAccMag-std()                    -0.6236556 -7.127e-01 -0.6875369
## fBodyAccMag-mad()                    -0.5528832 -6.655e-01 -0.6306080
## fBodyAccMag-max()                    -0.7347268 -7.922e-01 -0.7842587
## fBodyAccMag-min()                    -0.8965099 -9.170e-01 -0.9201302
## fBodyAccMag-sma()                    -0.5629484 -6.670e-01 -0.6461892
## fBodyAccMag-energy()                 -0.7815292 -8.618e-01 -0.8429541
## fBodyAccMag-iqr()                    -0.6791556 -7.493e-01 -0.7416782
## fBodyAccMag-entropy()                -0.1996732 -3.043e-01 -0.2991515
## fBodyAccMag-maxInds                  -0.7439024 -7.388e-01 -0.7908546
## fBodyAccMag-meanFreq()                0.0614279  5.587e-02  0.0355324
## fBodyAccMag-skewness()               -0.3744181 -3.255e-01 -0.2643061
## fBodyAccMag-kurtosis()               -0.6569909 -6.053e-01 -0.5384729
## fBodyBodyAccJerkMag-mean()           -0.6148176 -7.132e-01 -0.6975756
## fBodyBodyAccJerkMag-std()            -0.6431012 -7.299e-01 -0.6925958
## fBodyBodyAccJerkMag-mad()            -0.6018521 -7.051e-01 -0.6778990
## fBodyBodyAccJerkMag-max()            -0.7001428 -7.626e-01 -0.7283253
## fBodyBodyAccJerkMag-min()            -0.7988948 -8.553e-01 -0.8575061
## fBodyBodyAccJerkMag-sma()            -0.6148176 -7.132e-01 -0.6975756
## fBodyBodyAccJerkMag-energy()         -0.8348454 -8.991e-01 -0.8888760
## fBodyBodyAccJerkMag-iqr()            -0.6602683 -7.465e-01 -0.7378010
## fBodyBodyAccJerkMag-entropy()        -0.3433912 -4.572e-01 -0.4266659
## fBodyBodyAccJerkMag-maxInds          -0.8740805 -8.628e-01 -0.8523119
## fBodyBodyAccJerkMag-meanFreq()        0.1584042  2.217e-01  0.2163941
## fBodyBodyAccJerkMag-skewness()       -0.3619235 -3.648e-01 -0.3486174
## fBodyBodyAccJerkMag-kurtosis()       -0.6776404 -6.611e-01 -0.6303033
## fBodyBodyGyroMag-mean()              -0.7323945 -8.171e-01 -0.7694986
## fBodyBodyGyroMag-std()               -0.6953468 -8.021e-01 -0.7822325
## fBodyBodyGyroMag-mad()               -0.6795069 -7.986e-01 -0.7631530
## fBodyBodyGyroMag-max()               -0.7375432 -8.214e-01 -0.8129408
## fBodyBodyGyroMag-min()               -0.9231228 -9.266e-01 -0.9051747
## fBodyBodyGyroMag-sma()               -0.7323945 -8.171e-01 -0.7694986
## fBodyBodyGyroMag-energy()            -0.8945334 -9.487e-01 -0.9304116
## fBodyBodyGyroMag-iqr()               -0.7485614 -8.508e-01 -0.7886258
## fBodyBodyGyroMag-entropy()           -0.1316557 -2.581e-01 -0.2369608
## fBodyBodyGyroMag-maxInds             -0.8683552 -8.775e-01 -0.9119287
## fBodyBodyGyroMag-meanFreq()          -0.1496809 -5.012e-02  0.0048834
## fBodyBodyGyroMag-skewness()          -0.2557517 -2.505e-01 -0.1955919
## fBodyBodyGyroMag-kurtosis()          -0.5821984 -5.656e-01 -0.4931954
## fBodyBodyGyroJerkMag-mean()          -0.8368019 -8.728e-01 -0.8291245
## fBodyBodyGyroJerkMag-std()           -0.8496345 -8.865e-01 -0.8337010
## fBodyBodyGyroJerkMag-mad()           -0.8305229 -8.716e-01 -0.8263508
## fBodyBodyGyroJerkMag-max()           -0.8683532 -9.018e-01 -0.8416249
## fBodyBodyGyroJerkMag-min()           -0.9103113 -9.175e-01 -0.9058430
## fBodyBodyGyroJerkMag-sma()           -0.8368019 -8.728e-01 -0.8291245
## fBodyBodyGyroJerkMag-energy()        -0.9707058 -9.803e-01 -0.9629057
## fBodyBodyGyroJerkMag-iqr()           -0.8225560 -8.701e-01 -0.8281142
## fBodyBodyGyroJerkMag-entropy()       -0.3390612 -4.521e-01 -0.3929016
## fBodyBodyGyroJerkMag-maxInds         -0.8745645 -9.014e-01 -0.8688751
## fBodyBodyGyroJerkMag-meanFreq()       0.0955564  1.532e-01  0.2327925
## fBodyBodyGyroJerkMag-skewness()      -0.3530968 -3.851e-01 -0.3203329
## fBodyBodyGyroJerkMag-kurtosis()      -0.6693696 -7.051e-01 -0.6179105
## angle(tBodyAccMean,gravity)           0.0134188 -5.828e-04  0.0135537
## angle(tBodyAccJerkMean),gravityMean) -0.0123872  2.056e-02 -0.0027713
## angle(tBodyGyroMean,gravityMean)      0.0007278 -2.633e-02  0.0151696
## angle(tBodyGyroJerkMean,gravityMean)  0.0066752  3.511e-02  0.0111459
## angle(X,gravityMean)                 -0.5225720 -5.150e-01 -0.4953054
## angle(Y,gravityMean)                 -0.0283466  1.253e-01  0.0821581
## angle(Z,gravityMean)                 -0.0039690 -3.445e-02  0.0213229
##                                      subject_18 subject_19 subject_20
## tBodyAcc-mean()-X                     0.2763242  2.697e-01  2.684e-01
## tBodyAcc-mean()-Y                    -0.0172832 -1.820e-02 -1.759e-02
## tBodyAcc-mean()-Z                    -0.1081123 -1.183e-01 -1.080e-01
## tBodyAcc-std()-X                     -0.6946169 -5.747e-01 -6.048e-01
## tBodyAcc-std()-Y                     -0.6271175 -5.070e-01 -3.693e-01
## tBodyAcc-std()-Z                     -0.7015960 -6.492e-01 -6.348e-01
## tBodyAcc-mad()-X                     -0.7210611 -5.939e-01 -6.299e-01
## tBodyAcc-mad()-Y                     -0.6311316 -5.082e-01 -3.797e-01
## tBodyAcc-mad()-Z                     -0.7049387 -6.599e-01 -6.408e-01
## tBodyAcc-max()-X                     -0.5293647 -4.638e-01 -4.695e-01
## tBodyAcc-max()-Y                     -0.3798455 -2.919e-01 -2.675e-01
## tBodyAcc-max()-Z                     -0.6436200 -5.823e-01 -5.509e-01
## tBodyAcc-min()-X                      0.6178165  4.862e-01  4.915e-01
## tBodyAcc-min()-Y                      0.4827457  4.172e-01  3.065e-01
## tBodyAcc-min()-Z                      0.6495582  5.797e-01  6.212e-01
## tBodyAcc-sma()                       -0.6582848 -5.381e-01 -5.180e-01
## tBodyAcc-energy()-X                  -0.9009882 -7.448e-01 -8.193e-01
## tBodyAcc-energy()-Y                  -0.9452097 -8.803e-01 -8.314e-01
## tBodyAcc-energy()-Z                  -0.9154248 -8.529e-01 -8.745e-01
## tBodyAcc-iqr()-X                     -0.7812276 -6.244e-01 -6.804e-01
## tBodyAcc-iqr()-Y                     -0.7124552 -5.991e-01 -5.287e-01
## tBodyAcc-iqr()-Z                     -0.7286284 -6.885e-01 -6.746e-01
## tBodyAcc-entropy()-X                 -0.2062871 -1.184e-01 -1.183e-01
## tBodyAcc-entropy()-Y                 -0.1653042 -2.114e-01 -8.160e-02
## tBodyAcc-entropy()-Z                 -0.2109042 -2.339e-01 -1.402e-01
## tBodyAcc-arCoeff()-X,1               -0.1159242 -8.626e-02 -1.488e-01
## tBodyAcc-arCoeff()-X,2                0.0952422  7.896e-02  1.247e-01
## tBodyAcc-arCoeff()-X,3                0.0385138 -2.021e-02  1.252e-03
## tBodyAcc-arCoeff()-X,4                0.0588047  8.284e-02  8.288e-02
## tBodyAcc-arCoeff()-Y,1               -0.0342834  2.355e-02 -7.712e-02
## tBodyAcc-arCoeff()-Y,2                0.0351668  1.101e-02  4.595e-02
## tBodyAcc-arCoeff()-Y,3                0.1478817  1.497e-01  1.681e-01
## tBodyAcc-arCoeff()-Y,4               -0.0070854  1.273e-02 -1.962e-05
## tBodyAcc-arCoeff()-Z,1                0.0036922  1.346e-01 -2.045e-02
## tBodyAcc-arCoeff()-Z,2                0.0315753 -1.565e-02  5.007e-02
## tBodyAcc-arCoeff()-Z,3                0.0399009  4.455e-02  7.463e-02
## tBodyAcc-arCoeff()-Z,4               -0.1135443 -8.589e-02 -9.771e-02
## tBodyAcc-correlation()-X,Y           -0.1971518 -2.029e-01 -4.341e-02
## tBodyAcc-correlation()-X,Z           -0.1999610 -2.770e-01 -2.494e-01
## tBodyAcc-correlation()-Y,Z            0.1269735  1.525e-01  1.326e-01
## tGravityAcc-mean()-X                  0.7168632  4.753e-01  6.280e-01
## tGravityAcc-mean()-Y                 -0.0157820  9.641e-02 -3.731e-02
## tGravityAcc-mean()-Z                  0.0899902  2.330e-01  1.072e-01
## tGravityAcc-std()-X                  -0.9801387 -9.583e-01 -9.582e-01
## tGravityAcc-std()-Y                  -0.9695420 -9.593e-01 -9.525e-01
## tGravityAcc-std()-Z                  -0.9594342 -9.418e-01 -9.410e-01
## tGravityAcc-mad()-X                  -0.9806478 -9.591e-01 -9.589e-01
## tGravityAcc-mad()-Y                  -0.9700092 -9.600e-01 -9.533e-01
## tGravityAcc-mad()-Z                  -0.9603862 -9.428e-01 -9.420e-01
## tGravityAcc-max()-X                   0.6502309  4.184e-01  5.711e-01
## tGravityAcc-max()-Y                  -0.0342033  7.908e-02 -5.069e-02
## tGravityAcc-max()-Z                   0.0904498  2.368e-01  1.114e-01
## tGravityAcc-min()-X                   0.7347852  4.919e-01  6.419e-01
## tGravityAcc-min()-Y                   0.0017825  1.099e-01 -2.519e-02
## tGravityAcc-min()-Z                   0.0829826  2.221e-01  9.549e-02
## tGravityAcc-sma()                     0.0118105  1.723e-01 -1.688e-02
## tGravityAcc-energy()-X                0.4811175  2.362e-01  3.909e-01
## tGravityAcc-energy()-Y               -0.7141018 -6.204e-01 -5.537e-01
## tGravityAcc-energy()-Z               -0.7970895 -6.442e-01 -8.679e-01
## tGravityAcc-iqr()-X                  -0.9821288 -9.617e-01 -9.612e-01
## tGravityAcc-iqr()-Y                  -0.9714823 -9.625e-01 -9.571e-01
## tGravityAcc-iqr()-Z                  -0.9631666 -9.461e-01 -9.454e-01
## tGravityAcc-entropy()-X              -0.7047781 -6.358e-01 -5.768e-01
## tGravityAcc-entropy()-Y              -0.9401406 -8.576e-01 -9.232e-01
## tGravityAcc-entropy()-Z              -0.6744871 -7.117e-01 -5.734e-01
## tGravityAcc-arCoeff()-X,1            -0.4694860 -5.204e-01 -5.066e-01
## tGravityAcc-arCoeff()-X,2             0.5069603  5.578e-01  5.480e-01
## tGravityAcc-arCoeff()-X,3            -0.5436854 -5.948e-01 -5.890e-01
## tGravityAcc-arCoeff()-X,4             0.5797106  6.313e-01  6.296e-01
## tGravityAcc-arCoeff()-Y,1            -0.3571494 -2.883e-01 -3.875e-01
## tGravityAcc-arCoeff()-Y,2             0.3378565  2.727e-01  3.891e-01
## tGravityAcc-arCoeff()-Y,3            -0.3612290 -3.051e-01 -4.328e-01
## tGravityAcc-arCoeff()-Y,4             0.4018743  3.569e-01  4.927e-01
## tGravityAcc-arCoeff()-Z,1            -0.4487414 -3.636e-01 -4.023e-01
## tGravityAcc-arCoeff()-Z,2             0.4657888  3.902e-01  4.360e-01
## tGravityAcc-arCoeff()-Z,3            -0.4821602 -4.162e-01 -4.692e-01
## tGravityAcc-arCoeff()-Z,4             0.4952298  4.393e-01  4.995e-01
## tGravityAcc-correlation()-X,Y         0.2387269  1.436e-01  2.959e-01
## tGravityAcc-correlation()-X,Z        -0.0489552 -1.332e-01 -4.751e-02
## tGravityAcc-correlation()-Y,Z         0.0862184  1.756e-01  1.158e-01
## tBodyAccJerk-mean()-X                 0.0774809  7.742e-02  7.982e-02
## tBodyAccJerk-mean()-Y                 0.0128850  1.158e-02  2.209e-03
## tBodyAccJerk-mean()-Z                 0.0008485 -1.862e-03 -4.506e-03
## tBodyAccJerk-std()-X                 -0.7346445 -5.711e-01 -6.271e-01
## tBodyAccJerk-std()-Y                 -0.7329692 -5.713e-01 -5.272e-01
## tBodyAccJerk-std()-Z                 -0.8472578 -7.053e-01 -7.474e-01
## tBodyAccJerk-mad()-X                 -0.7345029 -5.617e-01 -6.245e-01
## tBodyAccJerk-mad()-Y                 -0.7144999 -5.293e-01 -5.266e-01
## tBodyAccJerk-mad()-Z                 -0.8433239 -6.904e-01 -7.374e-01
## tBodyAccJerk-max()-X                 -0.7822909 -6.517e-01 -6.964e-01
## tBodyAccJerk-max()-Y                 -0.8424900 -7.392e-01 -6.961e-01
## tBodyAccJerk-max()-Z                 -0.8859889 -7.708e-01 -7.937e-01
## tBodyAccJerk-min()-X                  0.7137911  5.563e-01  5.996e-01
## tBodyAccJerk-min()-Y                  0.7839365  7.075e-01  6.000e-01
## tBodyAccJerk-min()-Z                  0.8266654  6.917e-01  7.433e-01
## tBodyAccJerk-sma()                   -0.7534216 -5.733e-01 -6.157e-01
## tBodyAccJerk-energy()-X              -0.9235306 -7.388e-01 -8.405e-01
## tBodyAccJerk-energy()-Y              -0.9233138 -7.559e-01 -7.330e-01
## tBodyAccJerk-energy()-Z              -0.9724692 -8.667e-01 -9.270e-01
## tBodyAccJerk-iqr()-X                 -0.7410643 -5.387e-01 -6.181e-01
## tBodyAccJerk-iqr()-Y                 -0.7448566 -5.648e-01 -6.282e-01
## tBodyAccJerk-iqr()-Z                 -0.8541194 -6.944e-01 -7.466e-01
## tBodyAccJerk-entropy()-X             -0.1122551 -1.797e-01 -1.001e-01
## tBodyAccJerk-entropy()-Y             -0.1408529 -1.880e-01 -6.972e-02
## tBodyAccJerk-entropy()-Z             -0.2159570 -2.240e-01 -1.229e-01
## tBodyAccJerk-arCoeff()-X,1           -0.1036354 -6.103e-02 -1.403e-01
## tBodyAccJerk-arCoeff()-X,2            0.1516395  1.659e-01  1.660e-01
## tBodyAccJerk-arCoeff()-X,3            0.1056418  1.046e-01  8.230e-02
## tBodyAccJerk-arCoeff()-X,4            0.1766634  1.165e-01  1.558e-01
## tBodyAccJerk-arCoeff()-Y,1           -0.0713499 -3.616e-02 -1.354e-01
## tBodyAccJerk-arCoeff()-Y,2            0.0540740  9.322e-02  4.226e-02
## tBodyAccJerk-arCoeff()-Y,3            0.1938136  1.576e-01  1.253e-01
## tBodyAccJerk-arCoeff()-Y,4            0.2696410  3.681e-01  3.394e-01
## tBodyAccJerk-arCoeff()-Z,1           -0.0131034  8.343e-02 -7.996e-02
## tBodyAccJerk-arCoeff()-Z,2            0.0734415  1.018e-01  9.081e-02
## tBodyAccJerk-arCoeff()-Z,3            0.0383756  6.379e-02 -3.030e-02
## tBodyAccJerk-arCoeff()-Z,4            0.0890328  1.256e-01  2.278e-01
## tBodyAccJerk-correlation()-X,Y       -0.1941671 -1.536e-01 -1.160e-01
## tBodyAccJerk-correlation()-X,Z        0.0119546  1.824e-02 -1.554e-01
## tBodyAccJerk-correlation()-Y,Z        0.1055698 -9.151e-03  1.238e-01
## tBodyGyro-mean()-X                   -0.0373994 -3.857e-02 -2.425e-02
## tBodyGyro-mean()-Y                   -0.0678200 -6.814e-02 -7.894e-02
## tBodyGyro-mean()-Z                    0.0908403  8.836e-02  8.563e-02
## tBodyGyro-std()-X                    -0.8045337 -6.378e-01 -6.846e-01
## tBodyGyro-std()-Y                    -0.7773617 -6.439e-01 -5.737e-01
## tBodyGyro-std()-Z                    -0.7456125 -6.457e-01 -5.273e-01
## tBodyGyro-mad()-X                    -0.8062529 -6.428e-01 -6.933e-01
## tBodyGyro-mad()-Y                    -0.7810404 -6.546e-01 -5.911e-01
## tBodyGyro-mad()-Z                    -0.7541295 -6.574e-01 -5.620e-01
## tBodyGyro-max()-X                    -0.7308405 -5.765e-01 -6.024e-01
## tBodyGyro-max()-Y                    -0.8160057 -7.064e-01 -6.589e-01
## tBodyGyro-max()-Z                    -0.5732114 -4.669e-01 -3.806e-01
## tBodyGyro-min()-X                     0.7013003  5.649e-01  6.071e-01
## tBodyGyro-min()-Y                     0.8053458  7.153e-01  6.432e-01
## tBodyGyro-min()-Z                     0.6391750  5.487e-01  4.350e-01
## tBodyGyro-sma()                      -0.7135088 -5.469e-01 -5.114e-01
## tBodyGyro-energy()-X                 -0.9458079 -8.145e-01 -8.803e-01
## tBodyGyro-energy()-Y                 -0.9471819 -8.286e-01 -7.986e-01
## tBodyGyro-energy()-Z                 -0.9345650 -8.470e-01 -7.684e-01
## tBodyGyro-iqr()-X                    -0.8052020 -6.455e-01 -6.996e-01
## tBodyGyro-iqr()-Y                    -0.7919359 -6.814e-01 -6.172e-01
## tBodyGyro-iqr()-Z                    -0.7986927 -7.122e-01 -6.589e-01
## tBodyGyro-entropy()-X                -0.2150427 -2.106e-01 -1.336e-01
## tBodyGyro-entropy()-Y                -0.1171754 -1.452e-01 -8.206e-02
## tBodyGyro-entropy()-Z                -0.0849647 -9.364e-02 -2.852e-02
## tBodyGyro-arCoeff()-X,1              -0.2363268 -1.394e-01 -2.492e-01
## tBodyGyro-arCoeff()-X,2               0.1517088  9.548e-02  1.306e-01
## tBodyGyro-arCoeff()-X,3               0.1470828  1.572e-01  1.740e-01
## tBodyGyro-arCoeff()-X,4              -0.0931474 -6.903e-02 -6.669e-02
## tBodyGyro-arCoeff()-Y,1              -0.2204837 -1.826e-01 -2.812e-01
## tBodyGyro-arCoeff()-Y,2               0.1569230  1.430e-01  2.227e-01
## tBodyGyro-arCoeff()-Y,3              -0.0172467 -1.755e-02 -3.071e-02
## tBodyGyro-arCoeff()-Y,4               0.1073183  1.184e-01  1.104e-01
## tBodyGyro-arCoeff()-Z,1              -0.1134109  1.691e-03 -1.620e-01
## tBodyGyro-arCoeff()-Z,2               0.0722107 -9.148e-03  8.130e-02
## tBodyGyro-arCoeff()-Z,3               0.0330457  4.201e-02  5.495e-02
## tBodyGyro-arCoeff()-Z,4               0.0904442  1.108e-01  1.016e-01
## tBodyGyro-correlation()-X,Y          -0.2062308 -2.130e-01 -2.257e-01
## tBodyGyro-correlation()-X,Z          -0.0167599  1.137e-01 -2.463e-02
## tBodyGyro-correlation()-Y,Z          -0.1159049 -2.114e-01 -1.417e-01
## tBodyGyroJerk-mean()-X               -0.0944030 -8.959e-02 -9.498e-02
## tBodyGyroJerk-mean()-Y               -0.0441692 -3.832e-02 -4.144e-02
## tBodyGyroJerk-mean()-Z               -0.0568483 -5.696e-02 -5.430e-02
## tBodyGyroJerk-std()-X                -0.8428935 -6.188e-01 -6.984e-01
## tBodyGyroJerk-std()-Y                -0.8840505 -7.260e-01 -6.843e-01
## tBodyGyroJerk-std()-Z                -0.8386147 -6.867e-01 -6.367e-01
## tBodyGyroJerk-mad()-X                -0.8352094 -6.107e-01 -7.011e-01
## tBodyGyroJerk-mad()-Y                -0.8856478 -7.356e-01 -7.072e-01
## tBodyGyroJerk-mad()-Z                -0.8388673 -6.884e-01 -6.511e-01
## tBodyGyroJerk-max()-X                -0.8608155 -6.504e-01 -6.850e-01
## tBodyGyroJerk-max()-Y                -0.8965745 -7.528e-01 -7.246e-01
## tBodyGyroJerk-max()-Z                -0.8367938 -7.021e-01 -6.552e-01
## tBodyGyroJerk-min()-X                 0.8658651  6.788e-01  7.447e-01
## tBodyGyroJerk-min()-Y                 0.9193303  8.017e-01  7.227e-01
## tBodyGyroJerk-min()-Z                 0.8848338  7.696e-01  7.157e-01
## tBodyGyroJerk-sma()                  -0.8614325 -6.902e-01 -6.922e-01
## tBodyGyroJerk-energy()-X             -0.9718812 -8.016e-01 -8.992e-01
## tBodyGyroJerk-energy()-Y             -0.9845949 -8.758e-01 -8.867e-01
## tBodyGyroJerk-energy()-Z             -0.9718951 -8.592e-01 -8.444e-01
## tBodyGyroJerk-iqr()-X                -0.8249377 -6.132e-01 -7.143e-01
## tBodyGyroJerk-iqr()-Y                -0.8859576 -7.456e-01 -7.335e-01
## tBodyGyroJerk-iqr()-Z                -0.8453487 -7.019e-01 -6.909e-01
## tBodyGyroJerk-entropy()-X            -0.1247099 -7.707e-02  8.565e-03
## tBodyGyroJerk-entropy()-Y            -0.0741400 -6.884e-02  8.408e-02
## tBodyGyroJerk-entropy()-Z            -0.0623304 -9.704e-02  3.514e-02
## tBodyGyroJerk-arCoeff()-X,1          -0.0821440 -6.239e-03 -1.126e-01
## tBodyGyroJerk-arCoeff()-X,2           0.0182563  2.302e-02 -1.667e-04
## tBodyGyroJerk-arCoeff()-X,3           0.1943916  1.947e-01  1.023e-01
## tBodyGyroJerk-arCoeff()-X,4           0.1225219  1.785e-01  2.454e-01
## tBodyGyroJerk-arCoeff()-Y,1          -0.1609654 -1.298e-01 -2.401e-01
## tBodyGyroJerk-arCoeff()-Y,2           0.1783472  1.836e-01  2.155e-01
## tBodyGyroJerk-arCoeff()-Y,3           0.0909989  1.011e-01  6.606e-02
## tBodyGyroJerk-arCoeff()-Y,4           0.0897833  8.431e-02  1.105e-01
## tBodyGyroJerk-arCoeff()-Z,1          -0.0484933  7.225e-02 -1.108e-01
## tBodyGyroJerk-arCoeff()-Z,2           0.0340620  9.343e-03 -1.156e-02
## tBodyGyroJerk-arCoeff()-Z,3           0.1188445  1.392e-01  1.109e-01
## tBodyGyroJerk-arCoeff()-Z,4           0.0612200  3.226e-02  1.839e-02
## tBodyGyroJerk-correlation()-X,Y       0.0819106 -9.006e-02  3.652e-02
## tBodyGyroJerk-correlation()-X,Z      -0.0370949  2.046e-01 -7.878e-02
## tBodyGyroJerk-correlation()-Y,Z      -0.0565245 -1.698e-01 -8.138e-02
## tBodyAccMag-mean()                   -0.6583710 -5.315e-01 -5.173e-01
## tBodyAccMag-std()                    -0.6896719 -5.996e-01 -5.723e-01
## tBodyAccMag-mad()                    -0.7366494 -6.453e-01 -6.260e-01
## tBodyAccMag-max()                    -0.6572032 -5.657e-01 -5.262e-01
## tBodyAccMag-min()                    -0.8726853 -8.461e-01 -8.261e-01
## tBodyAccMag-sma()                    -0.6583710 -5.315e-01 -5.173e-01
## tBodyAccMag-energy()                 -0.8734334 -7.041e-01 -7.393e-01
## tBodyAccMag-iqr()                    -0.8003666 -6.894e-01 -6.808e-01
## tBodyAccMag-entropy()                 0.0219182  3.404e-02  1.538e-01
## tBodyAccMag-arCoeff()1               -0.0904403 -6.195e-03 -6.040e-02
## tBodyAccMag-arCoeff()2                0.0366096 -1.972e-02  2.113e-02
## tBodyAccMag-arCoeff()3                0.0902651  8.409e-02  4.721e-02
## tBodyAccMag-arCoeff()4               -0.1034207 -9.442e-02 -5.026e-02
## tGravityAccMag-mean()                -0.6583710 -5.315e-01 -5.173e-01
## tGravityAccMag-std()                 -0.6896719 -5.996e-01 -5.723e-01
## tGravityAccMag-mad()                 -0.7366494 -6.453e-01 -6.260e-01
## tGravityAccMag-max()                 -0.6572032 -5.657e-01 -5.262e-01
## tGravityAccMag-min()                 -0.8726853 -8.461e-01 -8.261e-01
## tGravityAccMag-sma()                 -0.6583710 -5.315e-01 -5.173e-01
## tGravityAccMag-energy()              -0.8734334 -7.041e-01 -7.393e-01
## tGravityAccMag-iqr()                 -0.8003666 -6.894e-01 -6.808e-01
## tGravityAccMag-entropy()              0.0219182  3.404e-02  1.538e-01
## tGravityAccMag-arCoeff()1            -0.0904403 -6.195e-03 -6.040e-02
## tGravityAccMag-arCoeff()2             0.0366096 -1.972e-02  2.113e-02
## tGravityAccMag-arCoeff()3             0.0902651  8.409e-02  4.721e-02
## tGravityAccMag-arCoeff()4            -0.1034207 -9.442e-02 -5.026e-02
## tBodyAccJerkMag-mean()               -0.7539047 -5.762e-01 -6.197e-01
## tBodyAccJerkMag-std()                -0.7452128 -6.019e-01 -5.886e-01
## tBodyAccJerkMag-mad()                -0.7541647 -6.205e-01 -6.138e-01
## tBodyAccJerkMag-max()                -0.7604409 -6.039e-01 -5.921e-01
## tBodyAccJerkMag-min()                -0.8529716 -7.253e-01 -7.722e-01
## tBodyAccJerkMag-sma()                -0.7539047 -5.762e-01 -6.197e-01
## tBodyAccJerkMag-energy()             -0.9301591 -7.494e-01 -8.210e-01
## tBodyAccJerkMag-iqr()                -0.7858053 -6.676e-01 -6.781e-01
## tBodyAccJerkMag-entropy()            -0.1497890 -1.664e-01 -5.177e-02
## tBodyAccJerkMag-arCoeff()1            0.0942269  1.297e-01  9.787e-03
## tBodyAccJerkMag-arCoeff()2           -0.0207770 -7.710e-02  6.571e-02
## tBodyAccJerkMag-arCoeff()3           -0.1064261 -1.184e-01 -9.997e-02
## tBodyAccJerkMag-arCoeff()4           -0.0659253 -1.436e-02 -7.415e-02
## tBodyGyroMag-mean()                  -0.7147357 -5.489e-01 -5.169e-01
## tBodyGyroMag-std()                   -0.7757791 -6.101e-01 -5.800e-01
## tBodyGyroMag-mad()                   -0.7550186 -5.651e-01 -5.452e-01
## tBodyGyroMag-max()                   -0.7985884 -6.552e-01 -6.020e-01
## tBodyGyroMag-min()                   -0.7764152 -7.145e-01 -6.723e-01
## tBodyGyroMag-sma()                   -0.7147357 -5.489e-01 -5.169e-01
## tBodyGyroMag-energy()                -0.9159329 -7.336e-01 -7.488e-01
## tBodyGyroMag-iqr()                   -0.7744871 -5.751e-01 -5.792e-01
## tBodyGyroMag-entropy()                0.2718171 -1.643e-05  1.090e-01
## tBodyGyroMag-arCoeff()1              -0.0550629  1.370e-02 -7.268e-02
## tBodyGyroMag-arCoeff()2              -0.0395281 -1.164e-01 -1.905e-02
## tBodyGyroMag-arCoeff()3               0.0958085  1.563e-01  3.341e-02
## tBodyGyroMag-arCoeff()4              -0.0611415 -8.381e-02  4.492e-02
## tBodyGyroJerkMag-mean()              -0.8598999 -6.834e-01 -6.840e-01
## tBodyGyroJerkMag-std()               -0.8885653 -7.256e-01 -6.835e-01
## tBodyGyroJerkMag-mad()               -0.8949507 -7.366e-01 -7.120e-01
## tBodyGyroJerkMag-max()               -0.8878335 -7.386e-01 -6.883e-01
## tBodyGyroJerkMag-min()               -0.8573538 -7.289e-01 -7.494e-01
## tBodyGyroJerkMag-sma()               -0.8598999 -6.834e-01 -6.840e-01
## tBodyGyroJerkMag-energy()            -0.9801757 -8.577e-01 -8.831e-01
## tBodyGyroJerkMag-iqr()               -0.8978560 -7.389e-01 -7.445e-01
## tBodyGyroJerkMag-entropy()            0.0119777  1.412e-02  1.849e-01
## tBodyGyroJerkMag-arCoeff()1           0.2949270  3.158e-01  2.339e-01
## tBodyGyroJerkMag-arCoeff()2          -0.2129077 -2.778e-01 -1.569e-01
## tBodyGyroJerkMag-arCoeff()3          -0.0323997 -3.406e-02 -1.275e-01
## tBodyGyroJerkMag-arCoeff()4          -0.1796583 -8.270e-02 -6.893e-02
## fBodyAcc-mean()-X                    -0.7142278 -5.871e-01 -6.126e-01
## fBodyAcc-mean()-Y                    -0.6636597 -5.219e-01 -4.264e-01
## fBodyAcc-mean()-Z                    -0.7612292 -6.470e-01 -6.650e-01
## fBodyAcc-std()-X                     -0.6878505 -5.709e-01 -6.031e-01
## fBodyAcc-std()-Y                     -0.6328382 -5.309e-01 -3.815e-01
## fBodyAcc-std()-Z                     -0.6948741 -6.803e-01 -6.475e-01
## fBodyAcc-mad()-X                     -0.6780634 -5.653e-01 -5.683e-01
## fBodyAcc-mad()-Y                     -0.6461040 -5.174e-01 -3.919e-01
## fBodyAcc-mad()-Z                     -0.7251390 -6.500e-01 -6.347e-01
## fBodyAcc-max()-X                     -0.7215402 -6.099e-01 -6.735e-01
## fBodyAcc-max()-Y                     -0.7120894 -6.590e-01 -5.161e-01
## fBodyAcc-max()-Z                     -0.6861022 -7.320e-01 -6.857e-01
## fBodyAcc-min()-X                     -0.9046371 -8.303e-01 -8.594e-01
## fBodyAcc-min()-Y                     -0.9181966 -8.768e-01 -8.460e-01
## fBodyAcc-min()-Z                     -0.9412394 -9.076e-01 -9.159e-01
## fBodyAcc-sma()                       -0.6732077 -5.261e-01 -5.160e-01
## fBodyAcc-energy()-X                  -0.9010112 -7.450e-01 -8.203e-01
## fBodyAcc-energy()-Y                  -0.8584646 -6.908e-01 -5.631e-01
## fBodyAcc-energy()-Z                  -0.9054274 -8.371e-01 -8.604e-01
## fBodyAcc-iqr()-X                     -0.7434842 -6.175e-01 -6.381e-01
## fBodyAcc-iqr()-Y                     -0.7530464 -6.276e-01 -5.901e-01
## fBodyAcc-iqr()-Z                     -0.8274926 -6.971e-01 -7.308e-01
## fBodyAcc-entropy()-X                 -0.2881724 -2.704e-01 -2.042e-01
## fBodyAcc-entropy()-Y                 -0.2892495 -2.674e-01 -1.589e-01
## fBodyAcc-entropy()-Z                 -0.3249042 -2.685e-01 -1.940e-01
## fBodyAcc-maxInds-X                   -0.7339596 -8.002e-01 -7.500e-01
## fBodyAcc-maxInds-Y                   -0.8126374 -7.944e-01 -7.832e-01
## fBodyAcc-maxInds-Z                   -0.8761623 -8.096e-01 -7.953e-01
## fBodyAcc-meanFreq()-X                -0.2102881 -2.124e-01 -2.282e-01
## fBodyAcc-meanFreq()-Y                 0.0142018  7.039e-02 -1.144e-02
## fBodyAcc-meanFreq()-Z                 0.0023795  1.604e-01  7.796e-02
## fBodyAcc-skewness()-X                -0.1841011 -1.800e-02 -2.555e-01
## fBodyAcc-kurtosis()-X                -0.5145355 -3.217e-01 -6.100e-01
## fBodyAcc-skewness()-Y                -0.2742842 -2.769e-01 -2.819e-01
## fBodyAcc-kurtosis()-Y                -0.5966268 -5.794e-01 -6.068e-01
## fBodyAcc-skewness()-Z                -0.1672227 -3.569e-01 -3.274e-01
## fBodyAcc-kurtosis()-Z                -0.4091967 -5.778e-01 -5.694e-01
## fBodyAcc-bandsEnergy()-1,8           -0.8956391 -7.482e-01 -8.165e-01
## fBodyAcc-bandsEnergy()-9,16          -0.9306294 -8.040e-01 -8.746e-01
## fBodyAcc-bandsEnergy()-17,24         -0.9399449 -7.775e-01 -8.320e-01
## fBodyAcc-bandsEnergy()-25,32         -0.9582535 -8.033e-01 -9.136e-01
## fBodyAcc-bandsEnergy()-33,40         -0.9649574 -8.636e-01 -9.319e-01
## fBodyAcc-bandsEnergy()-41,48         -0.9568615 -8.497e-01 -9.219e-01
## fBodyAcc-bandsEnergy()-49,56         -0.9751969 -9.081e-01 -9.489e-01
## fBodyAcc-bandsEnergy()-57,64         -0.9781205 -9.382e-01 -9.570e-01
## fBodyAcc-bandsEnergy()-1,16          -0.8962516 -7.413e-01 -8.165e-01
## fBodyAcc-bandsEnergy()-17,32         -0.9360123 -7.504e-01 -8.301e-01
## fBodyAcc-bandsEnergy()-33,48         -0.9619374 -8.584e-01 -9.281e-01
## fBodyAcc-bandsEnergy()-49,64         -0.9761768 -9.182e-01 -9.516e-01
## fBodyAcc-bandsEnergy()-1,24          -0.8993588 -7.438e-01 -8.176e-01
## fBodyAcc-bandsEnergy()-25,48         -0.9518994 -7.915e-01 -9.038e-01
## fBodyAcc-bandsEnergy()-1,8.1         -0.8519239 -7.608e-01 -6.061e-01
## fBodyAcc-bandsEnergy()-9,16.1        -0.9455223 -7.745e-01 -7.382e-01
## fBodyAcc-bandsEnergy()-17,24.1       -0.9350414 -8.186e-01 -7.845e-01
## fBodyAcc-bandsEnergy()-25,32.1       -0.9495570 -8.763e-01 -8.969e-01
## fBodyAcc-bandsEnergy()-33,40.1       -0.9563606 -8.535e-01 -8.486e-01
## fBodyAcc-bandsEnergy()-41,48.1       -0.9426336 -8.319e-01 -8.377e-01
## fBodyAcc-bandsEnergy()-49,56.1       -0.9541361 -8.795e-01 -8.412e-01
## fBodyAcc-bandsEnergy()-57,64.1       -0.9746271 -9.420e-01 -8.989e-01
## fBodyAcc-bandsEnergy()-1,16.1        -0.8585277 -7.007e-01 -5.635e-01
## fBodyAcc-bandsEnergy()-17,32.1       -0.9226581 -7.889e-01 -7.619e-01
## fBodyAcc-bandsEnergy()-33,48.1       -0.9461222 -8.285e-01 -8.271e-01
## fBodyAcc-bandsEnergy()-49,64.1       -0.9612942 -9.020e-01 -8.604e-01
## fBodyAcc-bandsEnergy()-1,24.1        -0.8592545 -6.945e-01 -5.631e-01
## fBodyAcc-bandsEnergy()-25,48.1       -0.9459412 -8.552e-01 -8.699e-01
## fBodyAcc-bandsEnergy()-1,8.2         -0.8991864 -8.939e-01 -8.966e-01
## fBodyAcc-bandsEnergy()-9,16.2        -0.9675604 -8.842e-01 -8.665e-01
## fBodyAcc-bandsEnergy()-17,24.2       -0.9701391 -8.550e-01 -9.252e-01
## fBodyAcc-bandsEnergy()-25,32.2       -0.9848791 -8.884e-01 -9.703e-01
## fBodyAcc-bandsEnergy()-33,40.2       -0.9873695 -9.112e-01 -9.641e-01
## fBodyAcc-bandsEnergy()-41,48.2       -0.9744256 -8.737e-01 -9.385e-01
## fBodyAcc-bandsEnergy()-49,56.2       -0.9759671 -8.990e-01 -9.426e-01
## fBodyAcc-bandsEnergy()-57,64.2       -0.9797431 -9.512e-01 -9.536e-01
## fBodyAcc-bandsEnergy()-1,16.2        -0.9089795 -8.779e-01 -8.743e-01
## fBodyAcc-bandsEnergy()-17,32.2       -0.9755117 -8.671e-01 -9.416e-01
## fBodyAcc-bandsEnergy()-33,48.2       -0.9831520 -8.952e-01 -9.549e-01
## fBodyAcc-bandsEnergy()-49,64.2       -0.9769039 -9.138e-01 -9.454e-01
## fBodyAcc-bandsEnergy()-1,24.2        -0.9060446 -8.521e-01 -8.633e-01
## fBodyAcc-bandsEnergy()-25,48.2       -0.9844032 -8.903e-01 -9.659e-01
## fBodyAccJerk-mean()-X                -0.7500201 -5.932e-01 -6.523e-01
## fBodyAccJerk-mean()-Y                -0.7441134 -5.967e-01 -5.578e-01
## fBodyAccJerk-mean()-Z                -0.8330321 -6.809e-01 -7.328e-01
## fBodyAccJerk-std()-X                 -0.7425179 -5.869e-01 -6.347e-01
## fBodyAccJerk-std()-Y                 -0.7391978 -5.726e-01 -5.259e-01
## fBodyAccJerk-std()-Z                 -0.8601690 -7.285e-01 -7.605e-01
## fBodyAccJerk-mad()-X                 -0.7004406 -5.228e-01 -5.739e-01
## fBodyAccJerk-mad()-Y                 -0.7436216 -5.901e-01 -5.406e-01
## fBodyAccJerk-mad()-Z                 -0.8485800 -7.064e-01 -7.466e-01
## fBodyAccJerk-max()-X                 -0.7837333 -6.480e-01 -7.056e-01
## fBodyAccJerk-max()-Y                 -0.7954474 -6.349e-01 -6.277e-01
## fBodyAccJerk-max()-Z                 -0.8775580 -7.530e-01 -7.788e-01
## fBodyAccJerk-min()-X                 -0.9122718 -8.521e-01 -8.909e-01
## fBodyAccJerk-min()-Y                 -0.9027041 -8.515e-01 -8.399e-01
## fBodyAccJerk-min()-Z                 -0.9246666 -8.759e-01 -8.847e-01
## fBodyAccJerk-sma()                   -0.7364408 -5.557e-01 -5.904e-01
## fBodyAccJerk-energy()-X              -0.9234316 -7.384e-01 -8.403e-01
## fBodyAccJerk-energy()-Y              -0.9233595 -7.560e-01 -7.332e-01
## fBodyAccJerk-energy()-Z              -0.9724842 -8.668e-01 -9.271e-01
## fBodyAccJerk-iqr()-X                 -0.7389000 -5.746e-01 -6.454e-01
## fBodyAccJerk-iqr()-Y                 -0.8066149 -6.966e-01 -6.754e-01
## fBodyAccJerk-iqr()-Z                 -0.8519996 -7.092e-01 -7.637e-01
## fBodyAccJerk-entropy()-X             -0.3465386 -3.464e-01 -2.717e-01
## fBodyAccJerk-entropy()-Y             -0.3774428 -3.442e-01 -2.363e-01
## fBodyAccJerk-entropy()-Z             -0.4873415 -4.112e-01 -3.440e-01
## fBodyAccJerk-maxInds-X               -0.4353846 -3.767e-01 -3.973e-01
## fBodyAccJerk-maxInds-Y               -0.4376923 -3.942e-01 -4.635e-01
## fBodyAccJerk-maxInds-Z               -0.3026374 -2.242e-01 -3.715e-01
## fBodyAccJerk-meanFreq()-X            -0.0691388  2.639e-03 -9.466e-02
## fBodyAccJerk-meanFreq()-Y            -0.2118002 -1.608e-01 -2.959e-01
## fBodyAccJerk-meanFreq()-Z            -0.1232359  2.256e-03 -1.738e-01
## fBodyAccJerk-skewness()-X            -0.2705566 -3.382e-01 -3.240e-01
## fBodyAccJerk-kurtosis()-X            -0.6890331 -7.285e-01 -7.349e-01
## fBodyAccJerk-skewness()-Y            -0.4232448 -3.982e-01 -3.930e-01
## fBodyAccJerk-kurtosis()-Y            -0.8461468 -8.125e-01 -8.276e-01
## fBodyAccJerk-skewness()-Z            -0.5144569 -5.205e-01 -4.530e-01
## fBodyAccJerk-kurtosis()-Z            -0.8420066 -8.334e-01 -7.935e-01
## fBodyAccJerk-bandsEnergy()-1,8       -0.9302895 -7.689e-01 -8.501e-01
## fBodyAccJerk-bandsEnergy()-9,16      -0.9272302 -7.969e-01 -8.737e-01
## fBodyAccJerk-bandsEnergy()-17,24     -0.9459159 -7.997e-01 -8.528e-01
## fBodyAccJerk-bandsEnergy()-25,32     -0.9608903 -8.026e-01 -9.194e-01
## fBodyAccJerk-bandsEnergy()-33,40     -0.9689403 -8.667e-01 -9.386e-01
## fBodyAccJerk-bandsEnergy()-41,48     -0.9522744 -8.196e-01 -9.139e-01
## fBodyAccJerk-bandsEnergy()-49,56     -0.9753573 -8.925e-01 -9.491e-01
## fBodyAccJerk-bandsEnergy()-57,64     -0.9921109 -9.748e-01 -9.852e-01
## fBodyAccJerk-bandsEnergy()-1,16      -0.9222050 -7.665e-01 -8.521e-01
## fBodyAccJerk-bandsEnergy()-17,32     -0.9398901 -7.542e-01 -8.478e-01
## fBodyAccJerk-bandsEnergy()-33,48     -0.9595095 -8.363e-01 -9.233e-01
## fBodyAccJerk-bandsEnergy()-49,64     -0.9742589 -8.895e-01 -9.471e-01
## fBodyAccJerk-bandsEnergy()-1,24      -0.9170376 -7.364e-01 -8.252e-01
## fBodyAccJerk-bandsEnergy()-25,48     -0.9439284 -7.442e-01 -8.890e-01
## fBodyAccJerk-bandsEnergy()-1,8.1     -0.8996636 -7.543e-01 -6.483e-01
## fBodyAccJerk-bandsEnergy()-9,16.1    -0.9542830 -7.977e-01 -7.828e-01
## fBodyAccJerk-bandsEnergy()-17,24.1   -0.9217129 -7.930e-01 -7.620e-01
## fBodyAccJerk-bandsEnergy()-25,32.1   -0.9544014 -8.806e-01 -9.091e-01
## fBodyAccJerk-bandsEnergy()-33,40.1   -0.9651638 -8.783e-01 -8.858e-01
## fBodyAccJerk-bandsEnergy()-41,48.1   -0.9423230 -8.170e-01 -8.382e-01
## fBodyAccJerk-bandsEnergy()-49,56.1   -0.9673799 -9.042e-01 -8.942e-01
## fBodyAccJerk-bandsEnergy()-57,64.1   -0.9889973 -9.697e-01 -9.602e-01
## fBodyAccJerk-bandsEnergy()-1,16.1    -0.9349200 -7.587e-01 -7.202e-01
## fBodyAccJerk-bandsEnergy()-17,32.1   -0.9213835 -7.927e-01 -7.835e-01
## fBodyAccJerk-bandsEnergy()-33,48.1   -0.9470749 -8.229e-01 -8.380e-01
## fBodyAccJerk-bandsEnergy()-49,64.1   -0.9701110 -9.125e-01 -9.026e-01
## fBodyAccJerk-bandsEnergy()-1,24.1    -0.9181916 -7.333e-01 -6.917e-01
## fBodyAccJerk-bandsEnergy()-25,48.1   -0.9509825 -8.568e-01 -8.805e-01
## fBodyAccJerk-bandsEnergy()-1,8.2     -0.9409085 -8.908e-01 -8.930e-01
## fBodyAccJerk-bandsEnergy()-9,16.2    -0.9677290 -8.837e-01 -8.586e-01
## fBodyAccJerk-bandsEnergy()-17,24.2   -0.9716364 -8.562e-01 -9.351e-01
## fBodyAccJerk-bandsEnergy()-25,32.2   -0.9858024 -8.917e-01 -9.714e-01
## fBodyAccJerk-bandsEnergy()-33,40.2   -0.9889025 -9.147e-01 -9.688e-01
## fBodyAccJerk-bandsEnergy()-41,48.2   -0.9769893 -8.746e-01 -9.454e-01
## fBodyAccJerk-bandsEnergy()-49,56.2   -0.9737165 -8.675e-01 -9.395e-01
## fBodyAccJerk-bandsEnergy()-57,64.2   -0.9882732 -9.605e-01 -9.748e-01
## fBodyAccJerk-bandsEnergy()-1,16.2    -0.9514393 -8.617e-01 -8.410e-01
## fBodyAccJerk-bandsEnergy()-17,32.2   -0.9785918 -8.736e-01 -9.529e-01
## fBodyAccJerk-bandsEnergy()-33,48.2   -0.9845662 -8.969e-01 -9.597e-01
## fBodyAccJerk-bandsEnergy()-49,64.2   -0.9737181 -8.697e-01 -9.397e-01
## fBodyAccJerk-bandsEnergy()-1,24.2    -0.9590731 -8.402e-01 -8.851e-01
## fBodyAccJerk-bandsEnergy()-25,48.2   -0.9853427 -8.938e-01 -9.668e-01
## fBodyGyro-mean()-X                   -0.7877576 -5.531e-01 -6.264e-01
## fBodyGyro-mean()-Y                   -0.8163859 -6.413e-01 -5.910e-01
## fBodyGyro-mean()-Z                   -0.7559268 -6.026e-01 -5.184e-01
## fBodyGyro-std()-X                    -0.8121752 -6.661e-01 -7.045e-01
## fBodyGyro-std()-Y                    -0.7596656 -6.501e-01 -5.676e-01
## fBodyGyro-std()-Z                    -0.7663817 -6.947e-01 -5.750e-01
## fBodyGyro-mad()-X                    -0.7906381 -5.887e-01 -6.387e-01
## fBodyGyro-mad()-Y                    -0.8068866 -6.671e-01 -5.921e-01
## fBodyGyro-mad()-Z                    -0.7383513 -6.218e-01 -4.914e-01
## fBodyGyro-max()-X                    -0.8015465 -6.813e-01 -7.109e-01
## fBodyGyro-max()-Y                    -0.7883733 -7.451e-01 -6.658e-01
## fBodyGyro-max()-Z                    -0.8199257 -7.835e-01 -6.782e-01
## fBodyGyro-min()-X                    -0.9527820 -9.094e-01 -9.261e-01
## fBodyGyro-min()-Y                    -0.9383708 -8.686e-01 -8.769e-01
## fBodyGyro-min()-Z                    -0.9431373 -9.017e-01 -8.959e-01
## fBodyGyro-sma()                      -0.7801815 -5.769e-01 -5.604e-01
## fBodyGyro-energy()-X                 -0.9555473 -8.180e-01 -8.929e-01
## fBodyGyro-energy()-Y                 -0.9486491 -8.305e-01 -8.028e-01
## fBodyGyro-energy()-Z                 -0.9326577 -8.417e-01 -7.559e-01
## fBodyGyro-iqr()-X                    -0.8278622 -5.966e-01 -6.808e-01
## fBodyGyro-iqr()-Y                    -0.8639251 -6.834e-01 -6.348e-01
## fBodyGyro-iqr()-Z                    -0.8039123 -6.338e-01 -5.881e-01
## fBodyGyro-entropy()-X                -0.2383820 -1.228e-01 -5.519e-02
## fBodyGyro-entropy()-Y                -0.1888396 -8.631e-02  4.445e-02
## fBodyGyro-entropy()-Z                -0.2656987 -1.883e-01 -8.371e-02
## fBodyGyro-maxInds-X                  -0.8659341 -8.343e-01 -8.782e-01
## fBodyGyro-maxInds-Y                  -0.8711450 -8.308e-01 -7.709e-01
## fBodyGyro-maxInds-Z                  -0.8186813 -8.360e-01 -7.742e-01
## fBodyGyro-meanFreq()-X               -0.1135963 -3.218e-02 -1.530e-01
## fBodyGyro-meanFreq()-Y               -0.2454772 -1.963e-01 -1.973e-01
## fBodyGyro-meanFreq()-Z               -0.0890928 -4.150e-02 -1.383e-01
## fBodyGyro-skewness()-X               -0.1463024 -2.724e-01 -2.385e-01
## fBodyGyro-kurtosis()-X               -0.4614080 -5.853e-01 -5.754e-01
## fBodyGyro-skewness()-Y               -0.0940893 -1.664e-01 -2.872e-01
## fBodyGyro-kurtosis()-Y               -0.4535859 -5.249e-01 -6.672e-01
## fBodyGyro-skewness()-Z               -0.2281193 -1.710e-01 -2.518e-01
## fBodyGyro-kurtosis()-Z               -0.5551817 -4.872e-01 -5.944e-01
## fBodyGyro-bandsEnergy()-1,8          -0.9595589 -8.491e-01 -9.087e-01
## fBodyGyro-bandsEnergy()-9,16         -0.9645266 -8.033e-01 -8.878e-01
## fBodyGyro-bandsEnergy()-17,24        -0.9726124 -8.158e-01 -9.103e-01
## fBodyGyro-bandsEnergy()-25,32        -0.9841298 -8.916e-01 -9.537e-01
## fBodyGyro-bandsEnergy()-33,40        -0.9862948 -8.703e-01 -9.367e-01
## fBodyGyro-bandsEnergy()-41,48        -0.9831812 -8.699e-01 -9.407e-01
## fBodyGyro-bandsEnergy()-49,56        -0.9840516 -8.930e-01 -9.571e-01
## fBodyGyro-bandsEnergy()-57,64        -0.9869507 -9.356e-01 -9.677e-01
## fBodyGyro-bandsEnergy()-1,16         -0.9567529 -8.292e-01 -8.977e-01
## fBodyGyro-bandsEnergy()-17,32        -0.9714979 -8.076e-01 -9.090e-01
## fBodyGyro-bandsEnergy()-33,48        -0.9836501 -8.571e-01 -9.320e-01
## fBodyGyro-bandsEnergy()-49,64        -0.9853344 -9.118e-01 -9.618e-01
## fBodyGyro-bandsEnergy()-1,24         -0.9560000 -8.221e-01 -8.946e-01
## fBodyGyro-bandsEnergy()-25,48        -0.9838190 -8.804e-01 -9.469e-01
## fBodyGyro-bandsEnergy()-1,8.1        -0.9284479 -8.609e-01 -8.116e-01
## fBodyGyro-bandsEnergy()-9,16.1       -0.9887565 -9.187e-01 -9.107e-01
## fBodyGyro-bandsEnergy()-17,24.1      -0.9907712 -9.297e-01 -9.203e-01
## fBodyGyro-bandsEnergy()-25,32.1      -0.9941410 -9.084e-01 -9.499e-01
## fBodyGyro-bandsEnergy()-33,40.1      -0.9941717 -9.334e-01 -9.740e-01
## fBodyGyro-bandsEnergy()-41,48.1      -0.9886362 -8.925e-01 -9.400e-01
## fBodyGyro-bandsEnergy()-49,56.1      -0.9865314 -8.958e-01 -9.254e-01
## fBodyGyro-bandsEnergy()-57,64.1      -0.9914852 -9.577e-01 -9.538e-01
## fBodyGyro-bandsEnergy()-1,16.1       -0.9445100 -8.535e-01 -8.151e-01
## fBodyGyro-bandsEnergy()-17,32.1      -0.9895926 -9.065e-01 -9.103e-01
## fBodyGyro-bandsEnergy()-33,48.1      -0.9929757 -9.244e-01 -9.668e-01
## fBodyGyro-bandsEnergy()-49,64.1      -0.9868450 -9.084e-01 -9.275e-01
## fBodyGyro-bandsEnergy()-1,24.1       -0.9440513 -8.302e-01 -7.900e-01
## fBodyGyro-bandsEnergy()-25,48.1      -0.9933216 -9.063e-01 -9.513e-01
## fBodyGyro-bandsEnergy()-1,8.2        -0.9407952 -8.934e-01 -8.218e-01
## fBodyGyro-bandsEnergy()-9,16.2       -0.9766626 -8.975e-01 -8.411e-01
## fBodyGyro-bandsEnergy()-17,24.2      -0.9799507 -8.850e-01 -8.603e-01
## fBodyGyro-bandsEnergy()-25,32.2      -0.9917532 -9.189e-01 -9.658e-01
## fBodyGyro-bandsEnergy()-33,40.2      -0.9932824 -9.381e-01 -9.670e-01
## fBodyGyro-bandsEnergy()-41,48.2      -0.9880955 -9.135e-01 -9.389e-01
## fBodyGyro-bandsEnergy()-49,56.2      -0.9837076 -9.182e-01 -9.143e-01
## fBodyGyro-bandsEnergy()-57,64.2      -0.9882536 -9.576e-01 -9.489e-01
## fBodyGyro-bandsEnergy()-1,16.2       -0.9358574 -8.643e-01 -7.773e-01
## fBodyGyro-bandsEnergy()-17,32.2      -0.9768918 -8.511e-01 -8.502e-01
## fBodyGyro-bandsEnergy()-33,48.2      -0.9918664 -9.312e-01 -9.594e-01
## fBodyGyro-bandsEnergy()-49,64.2      -0.9856843 -9.353e-01 -9.294e-01
## fBodyGyro-bandsEnergy()-1,24.2       -0.9334670 -8.495e-01 -7.595e-01
## fBodyGyro-bandsEnergy()-25,48.2      -0.9917902 -9.227e-01 -9.638e-01
## fBodyAccMag-mean()                   -0.6977329 -5.564e-01 -5.603e-01
## fBodyAccMag-std()                    -0.7339041 -6.899e-01 -6.483e-01
## fBodyAccMag-mad()                    -0.6830118 -6.092e-01 -5.753e-01
## fBodyAccMag-max()                    -0.8152117 -7.889e-01 -7.506e-01
## fBodyAccMag-min()                    -0.9384802 -8.672e-01 -8.879e-01
## fBodyAccMag-sma()                    -0.6977329 -5.564e-01 -5.603e-01
## fBodyAccMag-energy()                 -0.8979487 -7.893e-01 -8.035e-01
## fBodyAccMag-iqr()                    -0.7672872 -6.658e-01 -6.617e-01
## fBodyAccMag-entropy()                -0.3034399 -2.602e-01 -1.642e-01
## fBodyAccMag-maxInds                  -0.6919288 -7.130e-01 -7.886e-01
## fBodyAccMag-meanFreq()                0.0911072  1.158e-01  6.049e-02
## fBodyAccMag-skewness()               -0.4307938 -3.536e-01 -3.651e-01
## fBodyAccMag-kurtosis()               -0.7071906 -6.199e-01 -6.377e-01
## fBodyBodyAccJerkMag-mean()           -0.7423238 -5.761e-01 -5.846e-01
## fBodyBodyAccJerkMag-std()            -0.7501900 -6.411e-01 -5.974e-01
## fBodyBodyAccJerkMag-mad()            -0.7338542 -5.915e-01 -5.657e-01
## fBodyBodyAccJerkMag-max()            -0.7729912 -6.987e-01 -6.497e-01
## fBodyBodyAccJerkMag-min()            -0.8721814 -7.679e-01 -7.956e-01
## fBodyBodyAccJerkMag-sma()            -0.7423238 -5.761e-01 -5.846e-01
## fBodyBodyAccJerkMag-energy()         -0.9282079 -7.719e-01 -8.070e-01
## fBodyBodyAccJerkMag-iqr()            -0.7748633 -6.343e-01 -6.407e-01
## fBodyBodyAccJerkMag-entropy()        -0.4549260 -3.984e-01 -3.045e-01
## fBodyBodyAccJerkMag-maxInds          -0.8364730 -8.341e-01 -8.947e-01
## fBodyBodyAccJerkMag-meanFreq()        0.2245965  2.321e-01  8.722e-02
## fBodyBodyAccJerkMag-skewness()       -0.3389804 -4.126e-01 -2.962e-01
## fBodyBodyAccJerkMag-kurtosis()       -0.6218469 -7.070e-01 -6.179e-01
## fBodyBodyGyroMag-mean()              -0.8162866 -6.363e-01 -6.070e-01
## fBodyBodyGyroMag-std()               -0.7897777 -6.623e-01 -6.358e-01
## fBodyBodyGyroMag-mad()               -0.7874097 -6.415e-01 -5.893e-01
## fBodyBodyGyroMag-max()               -0.8131400 -7.000e-01 -7.015e-01
## fBodyBodyGyroMag-min()               -0.9392150 -8.486e-01 -8.990e-01
## fBodyBodyGyroMag-sma()               -0.8162866 -6.363e-01 -6.070e-01
## fBodyBodyGyroMag-energy()            -0.9471921 -8.069e-01 -8.239e-01
## fBodyBodyGyroMag-iqr()               -0.8367419 -6.771e-01 -6.003e-01
## fBodyBodyGyroMag-entropy()           -0.2345285 -1.121e-01  1.905e-02
## fBodyBodyGyroMag-maxInds             -0.8796844 -8.816e-01 -8.789e-01
## fBodyBodyGyroMag-meanFreq()          -0.0573697 -1.993e-02 -6.767e-02
## fBodyBodyGyroMag-skewness()          -0.2865194 -2.312e-01 -3.538e-01
## fBodyBodyGyroMag-kurtosis()          -0.6028518 -5.470e-01 -6.682e-01
## fBodyBodyGyroJerkMag-mean()          -0.8846630 -7.195e-01 -6.926e-01
## fBodyBodyGyroJerkMag-std()           -0.9022068 -7.542e-01 -6.947e-01
## fBodyBodyGyroJerkMag-mad()           -0.8858899 -7.274e-01 -6.667e-01
## fBodyBodyGyroJerkMag-max()           -0.9175907 -7.756e-01 -7.234e-01
## fBodyBodyGyroJerkMag-min()           -0.9318809 -8.288e-01 -8.298e-01
## fBodyBodyGyroJerkMag-sma()           -0.8846630 -7.195e-01 -6.926e-01
## fBodyBodyGyroJerkMag-energy()        -0.9858911 -8.845e-01 -8.886e-01
## fBodyBodyGyroJerkMag-iqr()           -0.8752651 -7.214e-01 -6.712e-01
## fBodyBodyGyroJerkMag-entropy()       -0.4390407 -3.116e-01 -1.635e-01
## fBodyBodyGyroJerkMag-maxInds         -0.8823478 -9.225e-01 -9.253e-01
## fBodyBodyGyroJerkMag-meanFreq()       0.1932315  1.286e-01  5.043e-02
## fBodyBodyGyroJerkMag-skewness()      -0.4475490 -3.010e-01 -2.581e-01
## fBodyBodyGyroJerkMag-kurtosis()      -0.7402468 -6.307e-01 -6.043e-01
## angle(tBodyAccMean,gravity)           0.0099534  2.538e-03  1.926e-03
## angle(tBodyAccJerkMean),gravityMean)  0.0169548  3.712e-03  1.106e-02
## angle(tBodyGyroMean,gravityMean)      0.0171417  3.155e-02 -6.111e-03
## angle(tBodyGyroJerkMean,gravityMean) -0.0414626  1.034e-03 -1.742e-02
## angle(X,gravityMean)                 -0.5212653 -2.977e-01 -4.291e-01
## angle(Y,gravityMean)                  0.0760076  1.516e-03  8.367e-02
## angle(Z,gravityMean)                 -0.0521704 -1.564e-01 -5.701e-02
##                                      subject_21 subject_22 subject_23
## tBodyAcc-mean()-X                      0.277467   0.274768  0.2734933
## tBodyAcc-mean()-Y                     -0.017666  -0.016827 -0.0195893
## tBodyAcc-mean()-Z                     -0.108778  -0.108670 -0.1090940
## tBodyAcc-std()-X                      -0.672324  -0.546090 -0.6225940
## tBodyAcc-std()-Y                      -0.565585  -0.491188 -0.5320785
## tBodyAcc-std()-Z                      -0.669622  -0.655090 -0.4505572
## tBodyAcc-mad()-X                      -0.688825  -0.554145 -0.6532345
## tBodyAcc-mad()-Y                      -0.573811  -0.516863 -0.5630664
## tBodyAcc-mad()-Z                      -0.673969  -0.661987 -0.4647878
## tBodyAcc-max()-X                      -0.562680  -0.465111 -0.4665469
## tBodyAcc-max()-Y                      -0.354056  -0.312729 -0.3107820
## tBodyAcc-max()-Z                      -0.619414  -0.559728 -0.4596941
## tBodyAcc-min()-X                       0.590673   0.477424  0.4754374
## tBodyAcc-min()-Y                       0.426245   0.341771  0.3696474
## tBodyAcc-min()-Z                       0.615354   0.629485  0.4536181
## tBodyAcc-sma()                        -0.615909  -0.518734 -0.5318795
## tBodyAcc-energy()-X                   -0.849604  -0.747448 -0.8402796
## tBodyAcc-energy()-Y                   -0.907082  -0.888443 -0.9097091
## tBodyAcc-energy()-Z                   -0.880015  -0.882518 -0.7222261
## tBodyAcc-iqr()-X                      -0.732644  -0.577148 -0.7113668
## tBodyAcc-iqr()-Y                      -0.672200  -0.639577 -0.6822238
## tBodyAcc-iqr()-Z                      -0.704289  -0.695146 -0.5347215
## tBodyAcc-entropy()-X                  -0.134755  -0.056267 -0.0394407
## tBodyAcc-entropy()-Y                  -0.193244  -0.132080 -0.2030100
## tBodyAcc-entropy()-Z                  -0.168658  -0.197420 -0.0825603
## tBodyAcc-arCoeff()-X,1                -0.072795  -0.057875 -0.0726039
## tBodyAcc-arCoeff()-X,2                 0.076965   0.071114  0.0852136
## tBodyAcc-arCoeff()-X,3                -0.054300  -0.116353 -0.0193205
## tBodyAcc-arCoeff()-X,4                 0.130443   0.223015  0.0578327
## tBodyAcc-arCoeff()-Y,1                 0.003136  -0.006603  0.0167049
## tBodyAcc-arCoeff()-Y,2                 0.007187   0.026274  0.0059663
## tBodyAcc-arCoeff()-Y,3                 0.151738   0.084094  0.1325179
## tBodyAcc-arCoeff()-Y,4                -0.010023   0.103033 -0.0151796
## tBodyAcc-arCoeff()-Z,1                 0.015133   0.076930  0.0149677
## tBodyAcc-arCoeff()-Z,2                 0.016145  -0.011501  0.0641585
## tBodyAcc-arCoeff()-Z,3                 0.062409   0.018055  0.0264628
## tBodyAcc-arCoeff()-Z,4                -0.079938   0.004021 -0.1072839
## tBodyAcc-correlation()-X,Y             0.008261  -0.172102 -0.0478296
## tBodyAcc-correlation()-X,Z            -0.258110  -0.221697 -0.2418667
## tBodyAcc-correlation()-Y,Z             0.115716   0.185246  0.2042912
## tGravityAcc-mean()-X                   0.645776   0.609391  0.6623247
## tGravityAcc-mean()-Y                  -0.075096   0.031510  0.0146209
## tGravityAcc-mean()-Z                   0.032185   0.235888  0.0518662
## tGravityAcc-std()-X                   -0.965587  -0.958504 -0.9643930
## tGravityAcc-std()-Y                   -0.969331  -0.957323 -0.9603189
## tGravityAcc-std()-Z                   -0.953094  -0.939081 -0.9342361
## tGravityAcc-mad()-X                   -0.966132  -0.959138 -0.9654893
## tGravityAcc-mad()-Y                   -0.970282  -0.958073 -0.9615433
## tGravityAcc-mad()-Z                   -0.954039  -0.939688 -0.9358759
## tGravityAcc-max()-X                    0.585582   0.551957  0.6029545
## tGravityAcc-max()-Y                   -0.091245   0.014962 -0.0008475
## tGravityAcc-max()-Z                    0.033152   0.238436  0.0580980
## tGravityAcc-min()-X                    0.661295   0.623327  0.6769201
## tGravityAcc-min()-Y                   -0.056828   0.044070  0.0294390
## tGravityAcc-min()-Z                    0.022296   0.223069  0.0381454
## tGravityAcc-sma()                      0.260186  -0.008371 -0.1271513
## tGravityAcc-energy()-X                 0.330873   0.367793  0.4340368
## tGravityAcc-energy()-Y                -0.690342  -0.717803 -0.8884877
## tGravityAcc-energy()-Z                -0.654544  -0.683931 -0.5911455
## tGravityAcc-iqr()-X                   -0.968150  -0.960821 -0.9680011
## tGravityAcc-iqr()-Y                   -0.973237  -0.960617 -0.9653029
## tGravityAcc-iqr()-Z                   -0.957122  -0.942310 -0.9417460
## tGravityAcc-entropy()-X               -0.508693  -0.623895 -0.5639319
## tGravityAcc-entropy()-Y               -0.914518  -0.832329 -0.8652825
## tGravityAcc-entropy()-Z               -0.867617  -0.593916 -0.8900996
## tGravityAcc-arCoeff()-X,1             -0.520381  -0.556532 -0.4804639
## tGravityAcc-arCoeff()-X,2              0.552353   0.593758  0.5154361
## tGravityAcc-arCoeff()-X,3             -0.583906  -0.630520 -0.5495900
## tGravityAcc-arCoeff()-X,4              0.615116   0.666885  0.5829798
## tGravityAcc-arCoeff()-Y,1             -0.331648  -0.387175 -0.3452232
## tGravityAcc-arCoeff()-Y,2              0.309179   0.379705  0.3179550
## tGravityAcc-arCoeff()-Y,3             -0.331054  -0.413494 -0.3336171
## tGravityAcc-arCoeff()-Y,4              0.371071   0.463450  0.3669652
## tGravityAcc-arCoeff()-Z,1             -0.417771  -0.461988 -0.3613884
## tGravityAcc-arCoeff()-Z,2              0.449109   0.493664  0.3972275
## tGravityAcc-arCoeff()-Z,3             -0.479905  -0.524952 -0.4324897
## tGravityAcc-arCoeff()-Z,4              0.507482   0.553110  0.4645620
## tGravityAcc-correlation()-X,Y          0.462162   0.140743  0.2432397
## tGravityAcc-correlation()-X,Z          0.050227  -0.197712  0.0471299
## tGravityAcc-correlation()-Y,Z         -0.043005   0.200721  0.1590718
## tBodyAccJerk-mean()-X                  0.082221   0.079103  0.0778588
## tBodyAccJerk-mean()-Y                  0.003501   0.015257  0.0200471
## tBodyAccJerk-mean()-Z                 -0.010659  -0.007229 -0.0007177
## tBodyAccJerk-std()-X                  -0.699763  -0.584964 -0.6081838
## tBodyAccJerk-std()-Y                  -0.665159  -0.560470 -0.6189812
## tBodyAccJerk-std()-Z                  -0.781824  -0.760468 -0.6030488
## tBodyAccJerk-mad()-X                  -0.699729  -0.571054 -0.6042764
## tBodyAccJerk-mad()-Y                  -0.649591  -0.565905 -0.6119655
## tBodyAccJerk-mad()-Z                  -0.780631  -0.759433 -0.5893415
## tBodyAccJerk-max()-X                  -0.718866  -0.688175 -0.6257302
## tBodyAccJerk-max()-Y                  -0.783920  -0.710571 -0.7511853
## tBodyAccJerk-max()-Z                  -0.825330  -0.847820 -0.7150217
## tBodyAccJerk-min()-X                   0.696504   0.565781  0.6037989
## tBodyAccJerk-min()-Y                   0.747578   0.604116  0.6743858
## tBodyAccJerk-min()-Z                   0.748158   0.718934  0.5699378
## tBodyAccJerk-sma()                    -0.697909  -0.612494 -0.5779998
## tBodyAccJerk-energy()-X               -0.872463  -0.789600 -0.8165812
## tBodyAccJerk-energy()-Y               -0.852313  -0.769692 -0.8360956
## tBodyAccJerk-energy()-Z               -0.932213  -0.928934 -0.8177746
## tBodyAccJerk-iqr()-X                  -0.700414  -0.542830 -0.5841634
## tBodyAccJerk-iqr()-Y                  -0.704489  -0.664677 -0.6802706
## tBodyAccJerk-iqr()-Z                  -0.799466  -0.791613 -0.6126590
## tBodyAccJerk-entropy()-X              -0.202787  -0.101869 -0.1185548
## tBodyAccJerk-entropy()-Y              -0.207488  -0.107894 -0.1382151
## tBodyAccJerk-entropy()-Z              -0.223197  -0.139638 -0.0338189
## tBodyAccJerk-arCoeff()-X,1            -0.052260  -0.047550 -0.0382971
## tBodyAccJerk-arCoeff()-X,2             0.176558   0.163326  0.1855845
## tBodyAccJerk-arCoeff()-X,3             0.072035   0.035045  0.1377247
## tBodyAccJerk-arCoeff()-X,4             0.115141   0.062413  0.0995124
## tBodyAccJerk-arCoeff()-Y,1            -0.033832  -0.071165 -0.0092689
## tBodyAccJerk-arCoeff()-Y,2             0.056213   0.080038  0.0730755
## tBodyAccJerk-arCoeff()-Y,3             0.193312   0.090944  0.2006809
## tBodyAccJerk-arCoeff()-Y,4             0.298203   0.289597  0.2677601
## tBodyAccJerk-arCoeff()-Z,1            -0.031150   0.014673 -0.0278489
## tBodyAccJerk-arCoeff()-Z,2             0.056473   0.046640  0.1394975
## tBodyAccJerk-arCoeff()-Z,3             0.004281  -0.017550  0.0262116
## tBodyAccJerk-arCoeff()-Z,4             0.155786   0.105234  0.1450302
## tBodyAccJerk-correlation()-X,Y        -0.194429  -0.168203 -0.2388494
## tBodyAccJerk-correlation()-X,Z        -0.014840   0.095136 -0.1553813
## tBodyAccJerk-correlation()-Y,Z         0.177159   0.159157  0.2723281
## tBodyGyro-mean()-X                    -0.027635  -0.008006 -0.0220890
## tBodyGyro-mean()-Y                    -0.078472  -0.094966 -0.0825973
## tBodyGyro-mean()-Z                     0.086121   0.081241  0.0746949
## tBodyGyro-std()-X                     -0.796172  -0.695919 -0.7557386
## tBodyGyro-std()-Y                     -0.765058  -0.784052 -0.5003382
## tBodyGyro-std()-Z                     -0.701642  -0.654458 -0.6096835
## tBodyGyro-mad()-X                     -0.796149  -0.699423 -0.7626742
## tBodyGyro-mad()-Y                     -0.776098  -0.789650 -0.5432670
## tBodyGyro-mad()-Z                     -0.709812  -0.662141 -0.6133378
## tBodyGyro-max()-X                     -0.695545  -0.614292 -0.6536845
## tBodyGyro-max()-Y                     -0.791924  -0.816057 -0.5604739
## tBodyGyro-max()-Z                     -0.526507  -0.503137 -0.4897843
## tBodyGyro-min()-X                      0.693839   0.633122  0.6555641
## tBodyGyro-min()-Y                      0.776037   0.791888  0.5611197
## tBodyGyro-min()-Z                      0.621309   0.552017  0.5381868
## tBodyGyro-sma()                       -0.686851  -0.630369 -0.5443775
## tBodyGyro-energy()-X                  -0.935120  -0.882505 -0.9267850
## tBodyGyro-energy()-Y                  -0.930286  -0.947536 -0.7276330
## tBodyGyro-energy()-Z                  -0.882132  -0.871530 -0.8418724
## tBodyGyro-iqr()-X                     -0.790073  -0.693405 -0.7680436
## tBodyGyro-iqr()-Y                     -0.799272  -0.801047 -0.6092553
## tBodyGyro-iqr()-Z                     -0.742748  -0.705988 -0.6537971
## tBodyGyro-entropy()-X                 -0.182286  -0.145540 -0.1285489
## tBodyGyro-entropy()-Y                 -0.108218  -0.126550 -0.0597601
## tBodyGyro-entropy()-Z                 -0.148189  -0.098400 -0.1052507
## tBodyGyro-arCoeff()-X,1               -0.158038  -0.183537 -0.0858155
## tBodyGyro-arCoeff()-X,2                0.097105   0.083421  0.0831275
## tBodyGyro-arCoeff()-X,3                0.129871   0.144842  0.0635844
## tBodyGyro-arCoeff()-X,4               -0.024063   0.002989  0.0042189
## tBodyGyro-arCoeff()-Y,1               -0.183523  -0.159357 -0.1448961
## tBodyGyro-arCoeff()-Y,2                0.143159   0.100030  0.1876131
## tBodyGyro-arCoeff()-Y,3               -0.009251  -0.035091 -0.0804030
## tBodyGyro-arCoeff()-Y,4                0.111700   0.216753  0.1326639
## tBodyGyro-arCoeff()-Z,1               -0.017466   0.019330  0.0054276
## tBodyGyro-arCoeff()-Z,2                0.029803  -0.035109 -0.0108471
## tBodyGyro-arCoeff()-Z,3               -0.021940  -0.015771  0.0259971
## tBodyGyro-arCoeff()-Z,4                0.206836   0.300228  0.1727232
## tBodyGyro-correlation()-X,Y           -0.121391  -0.339697 -0.1288253
## tBodyGyro-correlation()-X,Z           -0.123262   0.067503 -0.1211729
## tBodyGyro-correlation()-Y,Z           -0.002766  -0.144135 -0.2312996
## tBodyGyroJerk-mean()-X                -0.100558  -0.109258 -0.0966991
## tBodyGyroJerk-mean()-Y                -0.040824  -0.038462 -0.0432723
## tBodyGyroJerk-mean()-Z                -0.053386  -0.058214 -0.0621959
## tBodyGyroJerk-std()-X                 -0.792483  -0.708899 -0.7286921
## tBodyGyroJerk-std()-Y                 -0.815859  -0.859924 -0.5460436
## tBodyGyroJerk-std()-Z                 -0.812017  -0.742273 -0.7405181
## tBodyGyroJerk-mad()-X                 -0.791772  -0.710703 -0.7272741
## tBodyGyroJerk-mad()-Y                 -0.820731  -0.862650 -0.5789349
## tBodyGyroJerk-mad()-Z                 -0.811822  -0.744142 -0.7432761
## tBodyGyroJerk-max()-X                 -0.814445  -0.723691 -0.7472000
## tBodyGyroJerk-max()-Y                 -0.844667  -0.883595 -0.5773045
## tBodyGyroJerk-max()-Z                 -0.813486  -0.754743 -0.7580484
## tBodyGyroJerk-min()-X                  0.821453   0.743848  0.7401700
## tBodyGyroJerk-min()-Y                  0.853309   0.891889  0.6312667
## tBodyGyroJerk-min()-Z                  0.867576   0.811550  0.8005915
## tBodyGyroJerk-sma()                   -0.810739  -0.794268 -0.6557499
## tBodyGyroJerk-energy()-X              -0.939633  -0.900201 -0.9181206
## tBodyGyroJerk-energy()-Y              -0.955204  -0.977146 -0.7466546
## tBodyGyroJerk-energy()-Z              -0.953223  -0.917317 -0.9231386
## tBodyGyroJerk-iqr()-X                 -0.804548  -0.722330 -0.7327147
## tBodyGyroJerk-iqr()-Y                 -0.824525  -0.862775 -0.6266634
## tBodyGyroJerk-iqr()-Z                 -0.817755  -0.755889 -0.7588277
## tBodyGyroJerk-entropy()-X             -0.152024  -0.074103  0.0006580
## tBodyGyroJerk-entropy()-Y             -0.028878  -0.072478  0.1220185
## tBodyGyroJerk-entropy()-Z             -0.152192  -0.068087 -0.0665166
## tBodyGyroJerk-arCoeff()-X,1           -0.028674  -0.055186  0.0461657
## tBodyGyroJerk-arCoeff()-X,2            0.016792  -0.028972  0.0716340
## tBodyGyroJerk-arCoeff()-X,3            0.140912   0.107990  0.1454175
## tBodyGyroJerk-arCoeff()-X,4            0.190101   0.181965  0.1642961
## tBodyGyroJerk-arCoeff()-Y,1           -0.131116  -0.123822 -0.1169092
## tBodyGyroJerk-arCoeff()-Y,2            0.179823   0.128093  0.2721540
## tBodyGyroJerk-arCoeff()-Y,3            0.107391   0.041605  0.1360851
## tBodyGyroJerk-arCoeff()-Y,4            0.078332   0.060737  0.0506532
## tBodyGyroJerk-arCoeff()-Z,1            0.029199   0.055462  0.0597915
## tBodyGyroJerk-arCoeff()-Z,2            0.052152  -0.035543 -0.0004952
## tBodyGyroJerk-arCoeff()-Z,3            0.073578   0.024322  0.1118517
## tBodyGyroJerk-arCoeff()-Z,4            0.067046   0.020131  0.0302251
## tBodyGyroJerk-correlation()-X,Y        0.182990  -0.069320  0.0365179
## tBodyGyroJerk-correlation()-X,Z        0.065105   0.188520  0.0517243
## tBodyGyroJerk-correlation()-Y,Z       -0.147097  -0.171421 -0.3007902
## tBodyAccMag-mean()                    -0.620309  -0.504099 -0.5327548
## tBodyAccMag-std()                     -0.660196  -0.595954 -0.5655756
## tBodyAccMag-mad()                     -0.702039  -0.644195 -0.6204729
## tBodyAccMag-max()                     -0.628819  -0.546926 -0.5154211
## tBodyAccMag-min()                     -0.860421  -0.843014 -0.8268008
## tBodyAccMag-sma()                     -0.620309  -0.504099 -0.5327548
## tBodyAccMag-energy()                  -0.804694  -0.718387 -0.7574840
## tBodyAccMag-iqr()                     -0.754152  -0.696427 -0.6722745
## tBodyAccMag-entropy()                  0.001654   0.123953  0.1405822
## tBodyAccMag-arCoeff()1                -0.034518  -0.025749  0.0139057
## tBodyAccMag-arCoeff()2                -0.008003  -0.018252 -0.0097859
## tBodyAccMag-arCoeff()3                 0.062984   0.111201  0.0540743
## tBodyAccMag-arCoeff()4                -0.038609  -0.106125 -0.1198039
## tGravityAccMag-mean()                 -0.620309  -0.504099 -0.5327548
## tGravityAccMag-std()                  -0.660196  -0.595954 -0.5655756
## tGravityAccMag-mad()                  -0.702039  -0.644195 -0.6204729
## tGravityAccMag-max()                  -0.628819  -0.546926 -0.5154211
## tGravityAccMag-min()                  -0.860421  -0.843014 -0.8268008
## tGravityAccMag-sma()                  -0.620309  -0.504099 -0.5327548
## tGravityAccMag-energy()               -0.804694  -0.718387 -0.7574840
## tGravityAccMag-iqr()                  -0.754152  -0.696427 -0.6722745
## tGravityAccMag-entropy()               0.001654   0.123953  0.1405822
## tGravityAccMag-arCoeff()1             -0.034518  -0.025749  0.0139057
## tGravityAccMag-arCoeff()2             -0.008003  -0.018252 -0.0097859
## tGravityAccMag-arCoeff()3              0.062984   0.111201  0.0540743
## tGravityAccMag-arCoeff()4             -0.038609  -0.106125 -0.1198039
## tBodyAccJerkMag-mean()                -0.703461  -0.609773 -0.5864007
## tBodyAccJerkMag-std()                 -0.680069  -0.589823 -0.5587253
## tBodyAccJerkMag-mad()                 -0.696477  -0.607691 -0.5855634
## tBodyAccJerkMag-max()                 -0.686602  -0.609864 -0.5637110
## tBodyAccJerkMag-min()                 -0.818957  -0.761888 -0.7389129
## tBodyAccJerkMag-sma()                 -0.703461  -0.609773 -0.5864007
## tBodyAccJerkMag-energy()              -0.869361  -0.804932 -0.7886601
## tBodyAccJerkMag-iqr()                 -0.740573  -0.655230 -0.6530584
## tBodyAccJerkMag-entropy()             -0.205520  -0.089301 -0.0575363
## tBodyAccJerkMag-arCoeff()1             0.110644   0.084942  0.1289976
## tBodyAccJerkMag-arCoeff()2            -0.045195  -0.071333 -0.0597029
## tBodyAccJerkMag-arCoeff()3            -0.085536  -0.066882 -0.1026255
## tBodyAccJerkMag-arCoeff()4            -0.073192  -0.006908 -0.0548696
## tBodyGyroMag-mean()                   -0.693779  -0.637666 -0.5442080
## tBodyGyroMag-std()                    -0.761303  -0.676379 -0.5419491
## tBodyGyroMag-mad()                    -0.736910  -0.641359 -0.5251952
## tBodyGyroMag-max()                    -0.781559  -0.724225 -0.5511366
## tBodyGyroMag-min()                    -0.786199  -0.774554 -0.7109036
## tBodyGyroMag-sma()                    -0.693779  -0.637666 -0.5442080
## tBodyGyroMag-energy()                 -0.886792  -0.854106 -0.7625331
## tBodyGyroMag-iqr()                    -0.750736  -0.658394 -0.6002985
## tBodyGyroMag-entropy()                 0.189496   0.234708  0.1960555
## tBodyGyroMag-arCoeff()1                0.029532  -0.080021  0.2201696
## tBodyGyroMag-arCoeff()2               -0.108368  -0.068252 -0.2071568
## tBodyGyroMag-arCoeff()3                0.129600   0.148344  0.0963432
## tBodyGyroMag-arCoeff()4               -0.088885  -0.026900 -0.1046341
## tBodyGyroJerkMag-mean()               -0.807817  -0.794681 -0.6234126
## tBodyGyroJerkMag-std()                -0.824090  -0.826493 -0.5739429
## tBodyGyroJerkMag-mad()                -0.834180  -0.833477 -0.6169305
## tBodyGyroJerkMag-max()                -0.830012  -0.839257 -0.5778129
## tBodyGyroJerkMag-min()                -0.850235  -0.808079 -0.7465673
## tBodyGyroJerkMag-sma()                -0.807817  -0.794681 -0.6234126
## tBodyGyroJerkMag-energy()             -0.951543  -0.952956 -0.8053376
## tBodyGyroJerkMag-iqr()                -0.843878  -0.839424 -0.6794179
## tBodyGyroJerkMag-entropy()             0.008517   0.072848  0.1646559
## tBodyGyroJerkMag-arCoeff()1            0.357356   0.272314  0.4067012
## tBodyGyroJerkMag-arCoeff()2           -0.265247  -0.223813 -0.2930067
## tBodyGyroJerkMag-arCoeff()3           -0.048970  -0.069334 -0.1828671
## tBodyGyroJerkMag-arCoeff()4           -0.143710  -0.076005  0.0134625
## fBodyAcc-mean()-X                     -0.693486  -0.594930 -0.5990809
## fBodyAcc-mean()-Y                     -0.593778  -0.508173 -0.5484832
## fBodyAcc-mean()-Z                     -0.707714  -0.687321 -0.4902128
## fBodyAcc-std()-X                      -0.665350  -0.528959 -0.6338391
## fBodyAcc-std()-Y                      -0.578749  -0.515581 -0.5544717
## fBodyAcc-std()-Z                      -0.675588  -0.665517 -0.4747675
## fBodyAcc-mad()-X                      -0.670321  -0.584067 -0.5803218
## fBodyAcc-mad()-Y                      -0.580794  -0.523369 -0.5460585
## fBodyAcc-mad()-Z                      -0.681467  -0.675417 -0.4492455
## fBodyAcc-max()-X                      -0.693536  -0.533109 -0.7121407
## fBodyAcc-max()-Y                      -0.682653  -0.609094 -0.6797156
## fBodyAcc-max()-Z                      -0.702404  -0.681774 -0.5547146
## fBodyAcc-min()-X                      -0.891696  -0.826192 -0.8258334
## fBodyAcc-min()-Y                      -0.894820  -0.866766 -0.8881682
## fBodyAcc-min()-Z                      -0.926257  -0.918226 -0.8857098
## fBodyAcc-sma()                        -0.623074  -0.539563 -0.4873172
## fBodyAcc-energy()-X                   -0.849844  -0.747687 -0.8404286
## fBodyAcc-energy()-Y                   -0.759124  -0.713318 -0.7672032
## fBodyAcc-energy()-Z                   -0.865668  -0.869624 -0.6884767
## fBodyAcc-iqr()-X                      -0.727086  -0.652845 -0.5911800
## fBodyAcc-iqr()-Y                      -0.699255  -0.629901 -0.6418135
## fBodyAcc-iqr()-Z                      -0.775542  -0.770765 -0.5849423
## fBodyAcc-entropy()-X                  -0.339488  -0.223453 -0.2024740
## fBodyAcc-entropy()-Y                  -0.310400  -0.171270 -0.2174255
## fBodyAcc-entropy()-Z                  -0.301424  -0.232675 -0.0942383
## fBodyAcc-maxInds-X                    -0.789532  -0.788162 -0.7915366
## fBodyAcc-maxInds-Y                    -0.814052  -0.804154 -0.8261649
## fBodyAcc-maxInds-Z                    -0.824472  -0.793674 -0.7961125
## fBodyAcc-meanFreq()-X                 -0.230976  -0.181032 -0.2087244
## fBodyAcc-meanFreq()-Y                  0.041276   0.037199  0.0297877
## fBodyAcc-meanFreq()-Z                  0.049552   0.080630  0.0899844
## fBodyAcc-skewness()-X                 -0.032611  -0.001273 -0.1309739
## fBodyAcc-kurtosis()-X                 -0.327995  -0.296148 -0.4463808
## fBodyAcc-skewness()-Y                 -0.248179  -0.261807 -0.2460100
## fBodyAcc-kurtosis()-Y                 -0.560672  -0.585030 -0.5540051
## fBodyAcc-skewness()-Z                 -0.204347  -0.227007 -0.3160431
## fBodyAcc-kurtosis()-Z                 -0.443355  -0.472288 -0.5492165
## fBodyAcc-bandsEnergy()-1,8            -0.841023  -0.704989 -0.8546788
## fBodyAcc-bandsEnergy()-9,16           -0.910825  -0.919320 -0.8713836
## fBodyAcc-bandsEnergy()-17,24          -0.867478  -0.837562 -0.7587966
## fBodyAcc-bandsEnergy()-25,32          -0.912706  -0.768376 -0.8873376
## fBodyAcc-bandsEnergy()-33,40          -0.920533  -0.835553 -0.8923061
## fBodyAcc-bandsEnergy()-41,48          -0.927550  -0.866481 -0.8875773
## fBodyAcc-bandsEnergy()-49,56          -0.955324  -0.917594 -0.9251909
## fBodyAcc-bandsEnergy()-57,64          -0.965572  -0.945310 -0.9400567
## fBodyAcc-bandsEnergy()-1,16           -0.846813  -0.740699 -0.8461034
## fBodyAcc-bandsEnergy()-17,32          -0.860234  -0.791479 -0.7594040
## fBodyAcc-bandsEnergy()-33,48          -0.923178  -0.847160 -0.8905478
## fBodyAcc-bandsEnergy()-49,64          -0.958759  -0.926884 -0.9301736
## fBodyAcc-bandsEnergy()-1,24           -0.848283  -0.747586 -0.8398995
## fBodyAcc-bandsEnergy()-25,48          -0.900742  -0.761147 -0.8669367
## fBodyAcc-bandsEnergy()-1,8.1          -0.767703  -0.741592 -0.7800631
## fBodyAcc-bandsEnergy()-9,16.1         -0.882199  -0.868775 -0.9048547
## fBodyAcc-bandsEnergy()-17,24.1        -0.880980  -0.810582 -0.8313745
## fBodyAcc-bandsEnergy()-25,32.1        -0.912974  -0.779529 -0.8768562
## fBodyAcc-bandsEnergy()-33,40.1        -0.909067  -0.774462 -0.8990825
## fBodyAcc-bandsEnergy()-41,48.1        -0.889207  -0.835126 -0.8704652
## fBodyAcc-bandsEnergy()-49,56.1        -0.908393  -0.877034 -0.8974015
## fBodyAcc-bandsEnergy()-57,64.1        -0.959714  -0.942233 -0.9550067
## fBodyAcc-bandsEnergy()-1,16.1         -0.761417  -0.734503 -0.7825429
## fBodyAcc-bandsEnergy()-17,32.1        -0.859845  -0.753248 -0.8014717
## fBodyAcc-bandsEnergy()-33,48.1        -0.891052  -0.771907 -0.8765627
## fBodyAcc-bandsEnergy()-49,64.1        -0.927076  -0.900556 -0.9183800
## fBodyAcc-bandsEnergy()-1,24.1         -0.760971  -0.723958 -0.7715284
## fBodyAcc-bandsEnergy()-25,48.1        -0.901744  -0.765952 -0.8705155
## fBodyAcc-bandsEnergy()-1,8.2          -0.900156  -0.895707 -0.7757573
## fBodyAcc-bandsEnergy()-9,16.2         -0.872817  -0.898222 -0.7415731
## fBodyAcc-bandsEnergy()-17,24.2        -0.926770  -0.944403 -0.7613578
## fBodyAcc-bandsEnergy()-25,32.2        -0.969644  -0.942597 -0.9151525
## fBodyAcc-bandsEnergy()-33,40.2        -0.972282  -0.955615 -0.9171448
## fBodyAcc-bandsEnergy()-41,48.2        -0.943710  -0.928670 -0.8571546
## fBodyAcc-bandsEnergy()-49,56.2        -0.948162  -0.933254 -0.8735582
## fBodyAcc-bandsEnergy()-57,64.2        -0.965841  -0.964185 -0.9267706
## fBodyAcc-bandsEnergy()-1,16.2         -0.879204  -0.883840 -0.7374383
## fBodyAcc-bandsEnergy()-17,32.2        -0.942334  -0.943781 -0.8171012
## fBodyAcc-bandsEnergy()-33,48.2        -0.962928  -0.945502 -0.8957060
## fBodyAcc-bandsEnergy()-49,64.2        -0.953031  -0.941969 -0.8884462
## fBodyAcc-bandsEnergy()-1,24.2         -0.868321  -0.876455 -0.6972469
## fBodyAcc-bandsEnergy()-25,48.2        -0.967746  -0.943442 -0.9096232
## fBodyAccJerk-mean()-X                 -0.716414  -0.604253 -0.6175218
## fBodyAccJerk-mean()-Y                 -0.678615  -0.574318 -0.6282313
## fBodyAccJerk-mean()-Z                 -0.767352  -0.739702 -0.5788708
## fBodyAccJerk-std()-X                  -0.709801  -0.602458 -0.6350544
## fBodyAccJerk-std()-Y                  -0.674102  -0.576392 -0.6369776
## fBodyAccJerk-std()-Z                  -0.794923  -0.780253 -0.6275404
## fBodyAccJerk-mad()-X                  -0.663659  -0.548460 -0.5587056
## fBodyAccJerk-mad()-Y                  -0.680811  -0.574304 -0.6431628
## fBodyAccJerk-mad()-Z                  -0.781038  -0.762741 -0.6113713
## fBodyAccJerk-max()-X                  -0.750330  -0.635200 -0.7082788
## fBodyAccJerk-max()-Y                  -0.742334  -0.673141 -0.6978103
## fBodyAccJerk-max()-Z                  -0.815278  -0.805406 -0.6294102
## fBodyAccJerk-min()-X                  -0.902084  -0.848881 -0.8597507
## fBodyAccJerk-min()-Y                  -0.866664  -0.870047 -0.8302468
## fBodyAccJerk-min()-Z                  -0.896226  -0.883801 -0.8075078
## fBodyAccJerk-sma()                    -0.673735  -0.576135 -0.5382418
## fBodyAccJerk-energy()-X               -0.872304  -0.789323 -0.8163541
## fBodyAccJerk-energy()-Y               -0.852381  -0.769801 -0.8361633
## fBodyAccJerk-energy()-Z               -0.932231  -0.928959 -0.8178223
## fBodyAccJerk-iqr()-X                  -0.694011  -0.583224 -0.5798309
## fBodyAccJerk-iqr()-Y                  -0.759730  -0.656884 -0.7166667
## fBodyAccJerk-iqr()-Z                  -0.792454  -0.773842 -0.6242910
## fBodyAccJerk-entropy()-X              -0.415457  -0.293510 -0.2674071
## fBodyAccJerk-entropy()-Y              -0.392412  -0.258946 -0.3015992
## fBodyAccJerk-entropy()-Z              -0.461205  -0.394563 -0.2377998
## fBodyAccJerk-maxInds-X                -0.392059  -0.423053 -0.2943011
## fBodyAccJerk-maxInds-Y                -0.385294  -0.409969 -0.3126882
## fBodyAccJerk-maxInds-Z                -0.358137  -0.310903 -0.2720430
## fBodyAccJerk-meanFreq()-X              0.016870   0.066552  0.0173581
## fBodyAccJerk-meanFreq()-Y             -0.161814  -0.178425 -0.1246702
## fBodyAccJerk-meanFreq()-Z             -0.112817  -0.046769 -0.1125289
## fBodyAccJerk-skewness()-X             -0.337629  -0.310285 -0.3559100
## fBodyAccJerk-kurtosis()-X             -0.715217  -0.674000 -0.7470256
## fBodyAccJerk-skewness()-Y             -0.423312  -0.454587 -0.4299747
## fBodyAccJerk-kurtosis()-Y             -0.841782  -0.858330 -0.8345247
## fBodyAccJerk-skewness()-Z             -0.479129  -0.505359 -0.4212352
## fBodyAccJerk-kurtosis()-Z             -0.814183  -0.823885 -0.7370759
## fBodyAccJerk-bandsEnergy()-1,8        -0.890178  -0.759925 -0.8863748
## fBodyAccJerk-bandsEnergy()-9,16       -0.909635  -0.915702 -0.8665182
## fBodyAccJerk-bandsEnergy()-17,24      -0.881732  -0.844964 -0.7887295
## fBodyAccJerk-bandsEnergy()-25,32      -0.915746  -0.774007 -0.8891992
## fBodyAccJerk-bandsEnergy()-33,40      -0.924462  -0.835525 -0.8995299
## fBodyAccJerk-bandsEnergy()-41,48      -0.920503  -0.837672 -0.8790202
## fBodyAccJerk-bandsEnergy()-49,56      -0.954600  -0.902069 -0.9221242
## fBodyAccJerk-bandsEnergy()-57,64      -0.989381  -0.973453 -0.9640699
## fBodyAccJerk-bandsEnergy()-1,16       -0.893005  -0.838700 -0.8636636
## fBodyAccJerk-bandsEnergy()-17,32      -0.869101  -0.777584 -0.7836211
## fBodyAccJerk-bandsEnergy()-33,48      -0.916559  -0.822733 -0.8827401
## fBodyAccJerk-bandsEnergy()-49,64      -0.953333  -0.898633 -0.9165265
## fBodyAccJerk-bandsEnergy()-1,24       -0.869002  -0.811466 -0.8097592
## fBodyAccJerk-bandsEnergy()-25,48      -0.881737  -0.714043 -0.8394110
## fBodyAccJerk-bandsEnergy()-1,8.1      -0.822742  -0.774232 -0.8610322
## fBodyAccJerk-bandsEnergy()-9,16.1     -0.905532  -0.894711 -0.9210315
## fBodyAccJerk-bandsEnergy()-17,24.1    -0.855202  -0.768548 -0.7970779
## fBodyAccJerk-bandsEnergy()-25,32.1    -0.917333  -0.783904 -0.8825240
## fBodyAccJerk-bandsEnergy()-33,40.1    -0.923594  -0.807194 -0.9145063
## fBodyAccJerk-bandsEnergy()-41,48.1    -0.880693  -0.819491 -0.8594329
## fBodyAccJerk-bandsEnergy()-49,56.1    -0.924046  -0.900467 -0.9109347
## fBodyAccJerk-bandsEnergy()-57,64.1    -0.970895  -0.972787 -0.9488814
## fBodyAccJerk-bandsEnergy()-1,16.1     -0.872596  -0.851359 -0.8956682
## fBodyAccJerk-bandsEnergy()-17,32.1    -0.855373  -0.729232 -0.7965477
## fBodyAccJerk-bandsEnergy()-33,48.1    -0.886937  -0.766103 -0.8704637
## fBodyAccJerk-bandsEnergy()-49,64.1    -0.929960  -0.909594 -0.9157257
## fBodyAccJerk-bandsEnergy()-1,24.1     -0.843571  -0.789966 -0.8347580
## fBodyAccJerk-bandsEnergy()-25,48.1    -0.904511  -0.774150 -0.8763117
## fBodyAccJerk-bandsEnergy()-1,8.2      -0.903252  -0.905555 -0.7854363
## fBodyAccJerk-bandsEnergy()-9,16.2     -0.881011  -0.908059 -0.7233699
## fBodyAccJerk-bandsEnergy()-17,24.2    -0.933679  -0.946037 -0.7955383
## fBodyAccJerk-bandsEnergy()-25,32.2    -0.970895  -0.944138 -0.9171974
## fBodyAccJerk-bandsEnergy()-33,40.2    -0.975210  -0.958858 -0.9217724
## fBodyAccJerk-bandsEnergy()-41,48.2    -0.946618  -0.929317 -0.8613532
## fBodyAccJerk-bandsEnergy()-49,56.2    -0.935334  -0.912263 -0.8439885
## fBodyAccJerk-bandsEnergy()-57,64.2    -0.967758  -0.964432 -0.9219807
## fBodyAccJerk-bandsEnergy()-1,16.2     -0.863869  -0.887830 -0.6871505
## fBodyAccJerk-bandsEnergy()-17,32.2    -0.951904  -0.945137 -0.8550484
## fBodyAccJerk-bandsEnergy()-33,48.2    -0.964915  -0.947180 -0.8982773
## fBodyAccJerk-bandsEnergy()-49,64.2    -0.934949  -0.912676 -0.8430311
## fBodyAccJerk-bandsEnergy()-1,24.2     -0.894234  -0.913327 -0.7212143
## fBodyAccJerk-bandsEnergy()-25,48.2    -0.968571  -0.945359 -0.9097892
## fBodyGyro-mean()-X                    -0.752041  -0.639576 -0.6851365
## fBodyGyro-mean()-Y                    -0.759326  -0.791400 -0.4977838
## fBodyGyro-mean()-Z                    -0.709471  -0.643363 -0.6176854
## fBodyGyro-std()-X                     -0.811027  -0.714978 -0.7791971
## fBodyGyro-std()-Y                     -0.771388  -0.782046 -0.5078505
## fBodyGyro-std()-Z                     -0.728319  -0.690679 -0.6441310
## fBodyGyro-mad()-X                     -0.768278  -0.659455 -0.7223626
## fBodyGyro-mad()-Y                     -0.775898  -0.804878 -0.5166799
## fBodyGyro-mad()-Z                     -0.702786  -0.660695 -0.6111041
## fBodyGyro-max()-X                     -0.820986  -0.731099 -0.7811623
## fBodyGyro-max()-Y                     -0.841877  -0.831931 -0.6442032
## fBodyGyro-max()-Z                     -0.789549  -0.756787 -0.7007425
## fBodyGyro-min()-X                     -0.950132  -0.931977 -0.9273719
## fBodyGyro-min()-Y                     -0.920851  -0.922333 -0.8357508
## fBodyGyro-min()-Z                     -0.921265  -0.900122 -0.9068163
## fBodyGyro-sma()                       -0.729706  -0.687237 -0.5630548
## fBodyGyro-energy()-X                  -0.946798  -0.897467 -0.9360743
## fBodyGyro-energy()-Y                  -0.934772  -0.950377 -0.7246074
## fBodyGyro-energy()-Z                  -0.880397  -0.868002 -0.8356296
## fBodyGyro-iqr()-X                     -0.780285  -0.695644 -0.7011539
## fBodyGyro-iqr()-Y                     -0.786518  -0.834367 -0.5293847
## fBodyGyro-iqr()-Z                     -0.776919  -0.720755 -0.7001077
## fBodyGyro-entropy()-X                 -0.230124  -0.082166 -0.0907812
## fBodyGyro-entropy()-Y                 -0.116708  -0.124283  0.0870545
## fBodyGyro-entropy()-Z                 -0.296887  -0.163790 -0.1895224
## fBodyGyro-maxInds-X                   -0.872549  -0.882451 -0.9240143
## fBodyGyro-maxInds-Y                   -0.820999  -0.843232 -0.6873049
## fBodyGyro-maxInds-Z                   -0.807302  -0.801482 -0.8370412
## fBodyGyro-meanFreq()-X                -0.089011  -0.164138 -0.0251693
## fBodyGyro-meanFreq()-Y                -0.186458  -0.200741 -0.0592725
## fBodyGyro-meanFreq()-Z                -0.022885  -0.051630 -0.0229425
## fBodyGyro-skewness()-X                -0.213281  -0.215530 -0.1573415
## fBodyGyro-kurtosis()-X                -0.529457  -0.570614 -0.4634830
## fBodyGyro-skewness()-Y                -0.206604  -0.201603 -0.2292588
## fBodyGyro-kurtosis()-Y                -0.546097  -0.584595 -0.5753079
## fBodyGyro-skewness()-Z                -0.266404  -0.179563 -0.2121876
## fBodyGyro-kurtosis()-Z                -0.582004  -0.523664 -0.5223740
## fBodyGyro-bandsEnergy()-1,8           -0.955426  -0.909475 -0.9490607
## fBodyGyro-bandsEnergy()-9,16          -0.948208  -0.929756 -0.9287615
## fBodyGyro-bandsEnergy()-17,24         -0.939487  -0.879946 -0.9205100
## fBodyGyro-bandsEnergy()-25,32         -0.964891  -0.939944 -0.9429272
## fBodyGyro-bandsEnergy()-33,40         -0.961419  -0.928729 -0.9289946
## fBodyGyro-bandsEnergy()-41,48         -0.966535  -0.930875 -0.9389057
## fBodyGyro-bandsEnergy()-49,56         -0.976492  -0.955388 -0.9570260
## fBodyGyro-bandsEnergy()-57,64         -0.986021  -0.973378 -0.9737252
## fBodyGyro-bandsEnergy()-1,16          -0.950479  -0.904532 -0.9416466
## fBodyGyro-bandsEnergy()-17,32         -0.937004  -0.878934 -0.9127785
## fBodyGyro-bandsEnergy()-33,48         -0.959623  -0.922437 -0.9258911
## fBodyGyro-bandsEnergy()-49,64         -0.980708  -0.963348 -0.9644151
## fBodyGyro-bandsEnergy()-1,24          -0.948026  -0.899617 -0.9383089
## fBodyGyro-bandsEnergy()-25,48         -0.962988  -0.934235 -0.9373870
## fBodyGyro-bandsEnergy()-1,8.1         -0.941345  -0.938441 -0.8726045
## fBodyGyro-bandsEnergy()-9,16.1        -0.974506  -0.985935 -0.8533853
## fBodyGyro-bandsEnergy()-17,24.1       -0.967913  -0.989642 -0.7561870
## fBodyGyro-bandsEnergy()-25,32.1       -0.975991  -0.986238 -0.8860158
## fBodyGyro-bandsEnergy()-33,40.1       -0.980501  -0.983137 -0.9522278
## fBodyGyro-bandsEnergy()-41,48.1       -0.963096  -0.974038 -0.8922786
## fBodyGyro-bandsEnergy()-49,56.1       -0.963650  -0.972295 -0.8545745
## fBodyGyro-bandsEnergy()-57,64.1       -0.986200  -0.985824 -0.9344411
## fBodyGyro-bandsEnergy()-1,16.1        -0.943927  -0.949403 -0.8188703
## fBodyGyro-bandsEnergy()-17,32.1       -0.962713  -0.986144 -0.7373908
## fBodyGyro-bandsEnergy()-33,48.1       -0.976727  -0.981097 -0.9394281
## fBodyGyro-bandsEnergy()-49,64.1       -0.968474  -0.974387 -0.8693913
## fBodyGyro-bandsEnergy()-1,24.1        -0.932521  -0.948051 -0.7146449
## fBodyGyro-bandsEnergy()-25,48.1       -0.974360  -0.983559 -0.8939295
## fBodyGyro-bandsEnergy()-1,8.2         -0.893562  -0.888433 -0.8577285
## fBodyGyro-bandsEnergy()-9,16.2        -0.963340  -0.955462 -0.9460158
## fBodyGyro-bandsEnergy()-17,24.2       -0.967400  -0.954217 -0.9392209
## fBodyGyro-bandsEnergy()-25,32.2       -0.978177  -0.947697 -0.9654847
## fBodyGyro-bandsEnergy()-33,40.2       -0.981514  -0.946646 -0.9685927
## fBodyGyro-bandsEnergy()-41,48.2       -0.969486  -0.943486 -0.9547180
## fBodyGyro-bandsEnergy()-49,56.2       -0.960165  -0.936826 -0.9443088
## fBodyGyro-bandsEnergy()-57,64.2       -0.966139  -0.963879 -0.9664013
## fBodyGyro-bandsEnergy()-1,16.2        -0.886458  -0.878938 -0.8465624
## fBodyGyro-bandsEnergy()-17,32.2       -0.958352  -0.931026 -0.9253365
## fBodyGyro-bandsEnergy()-33,48.2       -0.978212  -0.945611 -0.9647475
## fBodyGyro-bandsEnergy()-49,64.2       -0.962762  -0.948588 -0.9539141
## fBodyGyro-bandsEnergy()-1,24.2        -0.882613  -0.873358 -0.8391191
## fBodyGyro-bandsEnergy()-25,48.2       -0.978189  -0.947052 -0.9652578
## fBodyAccMag-mean()                    -0.658665  -0.574333 -0.5290293
## fBodyAccMag-std()                     -0.714346  -0.673896 -0.6570489
## fBodyAccMag-mad()                     -0.670257  -0.621229 -0.5752947
## fBodyAccMag-max()                     -0.786073  -0.749911 -0.7603402
## fBodyAccMag-min()                     -0.907982  -0.863139 -0.8747610
## fBodyAccMag-sma()                     -0.658665  -0.574333 -0.5290293
## fBodyAccMag-energy()                  -0.844673  -0.820755 -0.7962641
## fBodyAccMag-iqr()                     -0.757598  -0.700988 -0.6457546
## fBodyAccMag-entropy()                 -0.328853  -0.201401 -0.1573241
## fBodyAccMag-maxInds                   -0.758621  -0.698786 -0.8259177
## fBodyAccMag-meanFreq()                 0.084651   0.103277  0.1153352
## fBodyAccMag-skewness()                -0.304361  -0.286348 -0.3600819
## fBodyAccMag-kurtosis()                -0.583876  -0.567814 -0.6300052
## fBodyBodyAccJerkMag-mean()            -0.679743  -0.585443 -0.5426633
## fBodyBodyAccJerkMag-std()             -0.683725  -0.599287 -0.5838323
## fBodyBodyAccJerkMag-mad()             -0.677440  -0.582984 -0.5443681
## fBodyBodyAccJerkMag-max()             -0.702420  -0.624684 -0.6475884
## fBodyBodyAccJerkMag-min()             -0.839118  -0.798616 -0.7650771
## fBodyBodyAccJerkMag-sma()             -0.679743  -0.585443 -0.5426633
## fBodyBodyAccJerkMag-energy()          -0.854880  -0.798730 -0.7693298
## fBodyBodyAccJerkMag-iqr()             -0.727845  -0.653314 -0.6095127
## fBodyBodyAccJerkMag-entropy()         -0.467770  -0.335386 -0.3083209
## fBodyBodyAccJerkMag-maxInds           -0.865313  -0.896553 -0.8799283
## fBodyBodyAccJerkMag-meanFreq()         0.244322   0.161936  0.2025533
## fBodyBodyAccJerkMag-skewness()        -0.320206  -0.212006 -0.3714018
## fBodyBodyAccJerkMag-kurtosis()        -0.592072  -0.511359 -0.6811847
## fBodyBodyGyroMag-mean()               -0.776473  -0.728167 -0.5346572
## fBodyBodyGyroMag-std()                -0.793159  -0.699600 -0.6322885
## fBodyBodyGyroMag-mad()                -0.778689  -0.694350 -0.5902377
## fBodyBodyGyroMag-max()                -0.815247  -0.737897 -0.6798696
## fBodyBodyGyroMag-min()                -0.911934  -0.904793 -0.8018468
## fBodyBodyGyroMag-sma()                -0.776473  -0.728167 -0.5346572
## fBodyBodyGyroMag-energy()             -0.933623  -0.893390 -0.7724710
## fBodyBodyGyroMag-iqr()                -0.801620  -0.769304 -0.5732547
## fBodyBodyGyroMag-entropy()            -0.202474  -0.108389  0.0356550
## fBodyBodyGyroMag-maxInds              -0.904726  -0.895998 -0.9032258
## fBodyBodyGyroMag-meanFreq()           -0.005719  -0.131615  0.1547232
## fBodyBodyGyroMag-skewness()           -0.274588  -0.188409 -0.3277962
## fBodyBodyGyroMag-kurtosis()           -0.588907  -0.527147 -0.6171421
## fBodyBodyGyroJerkMag-mean()           -0.826275  -0.830192 -0.5841110
## fBodyBodyGyroJerkMag-std()            -0.834950  -0.835597 -0.5937353
## fBodyBodyGyroJerkMag-mad()            -0.826912  -0.833811 -0.5556990
## fBodyBodyGyroJerkMag-max()            -0.839546  -0.830932 -0.6442628
## fBodyBodyGyroJerkMag-min()            -0.892606  -0.879450 -0.7539227
## fBodyBodyGyroJerkMag-sma()            -0.826275  -0.830192 -0.5841110
## fBodyBodyGyroJerkMag-energy()         -0.958601  -0.965667 -0.7722780
## fBodyBodyGyroJerkMag-iqr()            -0.829903  -0.832154 -0.5672953
## fBodyBodyGyroJerkMag-entropy()        -0.413263  -0.345235 -0.1331133
## fBodyBodyGyroJerkMag-maxInds          -0.901105  -0.920783 -0.9154293
## fBodyBodyGyroJerkMag-meanFreq()        0.205644   0.119561  0.1691850
## fBodyBodyGyroJerkMag-skewness()       -0.309332  -0.165095 -0.2910374
## fBodyBodyGyroJerkMag-kurtosis()       -0.612566  -0.462744 -0.6382934
## angle(tBodyAccMean,gravity)            0.012075   0.005920  0.0049925
## angle(tBodyAccJerkMean),gravityMean)  -0.014650   0.004058 -0.0112360
## angle(tBodyGyroMean,gravityMean)       0.014012  -0.008895  0.0121649
## angle(tBodyGyroJerkMean,gravityMean)   0.022089   0.022201 -0.0178096
## angle(X,gravityMean)                  -0.413916  -0.428061 -0.5037222
## angle(Y,gravityMean)                   0.128427   0.051121  0.0709911
## angle(Z,gravityMean)                  -0.019176  -0.163515 -0.0440018
##                                      subject_24 subject_25 subject_26
## tBodyAcc-mean()-X                      0.276767   0.275301   0.273037
## tBodyAcc-mean()-Y                     -0.017682  -0.019322  -0.016169
## tBodyAcc-mean()-Z                     -0.107915  -0.109629  -0.107638
## tBodyAcc-std()-X                      -0.675459  -0.716265  -0.623101
## tBodyAcc-std()-Y                      -0.582491  -0.531421  -0.585967
## tBodyAcc-std()-Z                      -0.636497  -0.647096  -0.704981
## tBodyAcc-mad()-X                      -0.696740  -0.736111  -0.654029
## tBodyAcc-mad()-Y                      -0.604195  -0.540053  -0.600976
## tBodyAcc-mad()-Z                      -0.647960  -0.633559  -0.707917
## tBodyAcc-max()-X                      -0.540884  -0.606640  -0.473773
## tBodyAcc-max()-Y                      -0.356933  -0.322077  -0.336719
## tBodyAcc-max()-Z                      -0.570815  -0.586672  -0.596438
## tBodyAcc-min()-X                       0.600295   0.602431   0.541389
## tBodyAcc-min()-Y                       0.421267   0.427103   0.433140
## tBodyAcc-min()-Z                       0.584103   0.665385   0.663426
## tBodyAcc-sma()                        -0.620086  -0.585784  -0.611438
## tBodyAcc-energy()-X                   -0.882690  -0.916699  -0.826882
## tBodyAcc-energy()-Y                   -0.930898  -0.897554  -0.925651
## tBodyAcc-energy()-Z                   -0.880900  -0.869200  -0.912694
## tBodyAcc-iqr()-X                      -0.754117  -0.773596  -0.725835
## tBodyAcc-iqr()-Y                      -0.718872  -0.647537  -0.699061
## tBodyAcc-iqr()-Z                      -0.685745  -0.620685  -0.729486
## tBodyAcc-entropy()-X                  -0.114924  -0.057334  -0.145268
## tBodyAcc-entropy()-Y                  -0.121335  -0.084020  -0.224599
## tBodyAcc-entropy()-Z                  -0.117547  -0.172081  -0.224778
## tBodyAcc-arCoeff()-X,1                -0.122616  -0.182595  -0.087063
## tBodyAcc-arCoeff()-X,2                 0.096495   0.135938   0.054306
## tBodyAcc-arCoeff()-X,3                -0.017385  -0.050636   0.017819
## tBodyAcc-arCoeff()-X,4                 0.104583   0.127591   0.088474
## tBodyAcc-arCoeff()-Y,1                -0.043959  -0.124094   0.029943
## tBodyAcc-arCoeff()-Y,2                 0.026578   0.041408  -0.016568
## tBodyAcc-arCoeff()-Y,3                 0.195614   0.211203   0.190801
## tBodyAcc-arCoeff()-Y,4                -0.088029  -0.064939  -0.026952
## tBodyAcc-arCoeff()-Z,1                -0.033458  -0.110596   0.052565
## tBodyAcc-arCoeff()-Z,2                 0.086777   0.067698   0.042306
## tBodyAcc-arCoeff()-Z,3                 0.036605   0.058453   0.041446
## tBodyAcc-arCoeff()-Z,4                -0.146007  -0.131214  -0.092815
## tBodyAcc-correlation()-X,Y            -0.106099  -0.086367  -0.222318
## tBodyAcc-correlation()-X,Z            -0.303414  -0.186830  -0.102159
## tBodyAcc-correlation()-Y,Z             0.084690  -0.023216   0.154561
## tGravityAcc-mean()-X                   0.694981   0.672387   0.615124
## tGravityAcc-mean()-Y                   0.072951   0.047160   0.108705
## tGravityAcc-mean()-Z                   0.062323   0.239226   0.234107
## tGravityAcc-std()-X                   -0.975330  -0.950017  -0.967818
## tGravityAcc-std()-Y                   -0.960898  -0.901089  -0.959714
## tGravityAcc-std()-Z                   -0.955725  -0.880682  -0.955643
## tGravityAcc-mad()-X                   -0.975986  -0.951177  -0.969099
## tGravityAcc-mad()-Y                   -0.961706  -0.903433  -0.960638
## tGravityAcc-mad()-Z                   -0.956951  -0.883050  -0.956723
## tGravityAcc-max()-X                    0.631059   0.617823   0.555454
## tGravityAcc-max()-Y                    0.055385   0.047884   0.090422
## tGravityAcc-max()-Z                    0.062929   0.256359   0.233369
## tGravityAcc-min()-X                    0.712441   0.681401   0.632244
## tGravityAcc-min()-Y                    0.087155   0.042342   0.121760
## tGravityAcc-min()-Z                    0.053239   0.211304   0.224759
## tGravityAcc-sma()                     -0.151952  -0.143691  -0.156244
## tGravityAcc-energy()-X                 0.496511   0.480075   0.442229
## tGravityAcc-energy()-Y                -0.747065  -0.741898  -0.681118
## tGravityAcc-energy()-Z                -0.787516  -0.782116  -0.798562
## tGravityAcc-iqr()-X                   -0.977484  -0.954580  -0.972618
## tGravityAcc-iqr()-Y                   -0.964222  -0.910907  -0.963613
## tGravityAcc-iqr()-Z                   -0.960764  -0.891418  -0.960384
## tGravityAcc-entropy()-X               -0.746205  -0.667030  -0.858033
## tGravityAcc-entropy()-Y               -0.901574  -0.800012  -0.911191
## tGravityAcc-entropy()-Z               -0.838932  -0.318770  -0.515741
## tGravityAcc-arCoeff()-X,1             -0.487327  -0.596887  -0.518583
## tGravityAcc-arCoeff()-X,2              0.520357   0.624214   0.551315
## tGravityAcc-arCoeff()-X,3             -0.552575  -0.651152  -0.583192
## tGravityAcc-arCoeff()-X,4              0.584042   0.677797   0.614276
## tGravityAcc-arCoeff()-Y,1             -0.366972  -0.478100  -0.336533
## tGravityAcc-arCoeff()-Y,2              0.342323   0.463063   0.318383
## tGravityAcc-arCoeff()-Y,3             -0.359549  -0.482824  -0.344498
## tGravityAcc-arCoeff()-Y,4              0.394107   0.516724   0.388537
## tGravityAcc-arCoeff()-Z,1             -0.346456  -0.536797  -0.330639
## tGravityAcc-arCoeff()-Z,2              0.371044   0.549795   0.362983
## tGravityAcc-arCoeff()-Z,3             -0.394947  -0.562130  -0.394778
## tGravityAcc-arCoeff()-Z,4              0.415659   0.571061   0.423505
## tGravityAcc-correlation()-X,Y          0.264844   0.217588  -0.023996
## tGravityAcc-correlation()-X,Z         -0.174122  -0.526083  -0.199948
## tGravityAcc-correlation()-Y,Z         -0.068226  -0.001510   0.229759
## tBodyAccJerk-mean()-X                  0.078474   0.081766   0.080874
## tBodyAccJerk-mean()-Y                  0.003969   0.006386   0.007677
## tBodyAccJerk-mean()-Z                 -0.007010  -0.010346  -0.007249
## tBodyAccJerk-std()-X                  -0.740301  -0.796823  -0.682816
## tBodyAccJerk-std()-Y                  -0.685980  -0.722503  -0.678387
## tBodyAccJerk-std()-Z                  -0.736374  -0.860669  -0.778349
## tBodyAccJerk-mad()-X                  -0.737155  -0.795715  -0.682133
## tBodyAccJerk-mad()-Y                  -0.680989  -0.704892  -0.670351
## tBodyAccJerk-mad()-Z                  -0.731182  -0.857112  -0.768237
## tBodyAccJerk-max()-X                  -0.783384  -0.817259  -0.734585
## tBodyAccJerk-max()-Y                  -0.800042  -0.830804  -0.785259
## tBodyAccJerk-max()-Z                  -0.783790  -0.877544  -0.837429
## tBodyAccJerk-min()-X                   0.719943   0.781019   0.644530
## tBodyAccJerk-min()-Y                   0.744462   0.793827   0.744929
## tBodyAccJerk-min()-Z                   0.718755   0.861460   0.769804
## tBodyAccJerk-sma()                    -0.704523  -0.781216  -0.691901
## tBodyAccJerk-energy()-X               -0.926695  -0.957203  -0.879613
## tBodyAccJerk-energy()-Y               -0.891240  -0.922668  -0.876225
## tBodyAccJerk-energy()-Z               -0.921565  -0.979316  -0.937576
## tBodyAccJerk-iqr()-X                  -0.730462  -0.788742  -0.680190
## tBodyAccJerk-iqr()-Y                  -0.742047  -0.742963  -0.728610
## tBodyAccJerk-iqr()-Z                  -0.748800  -0.863106  -0.778192
## tBodyAccJerk-entropy()-X              -0.101557  -0.123894  -0.182521
## tBodyAccJerk-entropy()-Y              -0.124945  -0.081023  -0.212931
## tBodyAccJerk-entropy()-Z              -0.128405  -0.205167  -0.193881
## tBodyAccJerk-arCoeff()-X,1            -0.106318  -0.156234  -0.067930
## tBodyAccJerk-arCoeff()-X,2             0.168739   0.159171   0.130315
## tBodyAccJerk-arCoeff()-X,3             0.039438   0.027669   0.068255
## tBodyAccJerk-arCoeff()-X,4             0.175714   0.109195   0.170672
## tBodyAccJerk-arCoeff()-Y,1            -0.068343  -0.154511  -0.012888
## tBodyAccJerk-arCoeff()-Y,2             0.055459  -0.002419   0.035961
## tBodyAccJerk-arCoeff()-Y,3             0.205651   0.127737   0.211088
## tBodyAccJerk-arCoeff()-Y,4             0.331121   0.347511   0.336823
## tBodyAccJerk-arCoeff()-Z,1            -0.063295  -0.108217  -0.007800
## tBodyAccJerk-arCoeff()-Z,2             0.148533   0.045960   0.131403
## tBodyAccJerk-arCoeff()-Z,3             0.021731  -0.022055   0.027436
## tBodyAccJerk-arCoeff()-Z,4             0.179716   0.112785   0.181178
## tBodyAccJerk-correlation()-X,Y        -0.152633  -0.084265  -0.204844
## tBodyAccJerk-correlation()-X,Z        -0.066962   0.099464   0.051987
## tBodyAccJerk-correlation()-Y,Z         0.031277  -0.068509   0.012733
## tBodyGyro-mean()-X                    -0.021258  -0.002982  -0.020660
## tBodyGyro-mean()-Y                    -0.078244  -0.083900  -0.082742
## tBodyGyro-mean()-Z                     0.084174   0.099361   0.091785
## tBodyGyro-std()-X                     -0.776199  -0.683132  -0.766674
## tBodyGyro-std()-Y                     -0.763365  -0.752261  -0.800675
## tBodyGyro-std()-Z                     -0.708252  -0.747410  -0.703347
## tBodyGyro-mad()-X                     -0.779106  -0.683743  -0.770474
## tBodyGyro-mad()-Y                     -0.778178  -0.751837  -0.809971
## tBodyGyro-mad()-Z                     -0.719926  -0.757517  -0.708875
## tBodyGyro-max()-X                     -0.682821  -0.612449  -0.662091
## tBodyGyro-max()-Y                     -0.779052  -0.813369  -0.799851
## tBodyGyro-max()-Z                     -0.548162  -0.555286  -0.540847
## tBodyGyro-min()-X                      0.676293   0.634589   0.674133
## tBodyGyro-min()-Y                      0.757612   0.799572   0.803758
## tBodyGyro-min()-Z                      0.592519   0.640300   0.597543
## tBodyGyro-sma()                       -0.680878  -0.628162  -0.691469
## tBodyGyro-energy()-X                  -0.930746  -0.891410  -0.924538
## tBodyGyro-energy()-Y                  -0.944206  -0.941305  -0.955900
## tBodyGyro-energy()-Z                  -0.912470  -0.940552  -0.905525
## tBodyGyro-iqr()-X                     -0.773933  -0.676348  -0.770737
## tBodyGyro-iqr()-Y                     -0.805215  -0.751003  -0.826880
## tBodyGyro-iqr()-Z                     -0.767130  -0.798590  -0.747730
## tBodyGyro-entropy()-X                 -0.126017  -0.092338  -0.227341
## tBodyGyro-entropy()-Y                 -0.070257  -0.082822  -0.152288
## tBodyGyro-entropy()-Z                 -0.067262  -0.015779  -0.100611
## tBodyGyro-arCoeff()-X,1               -0.204979  -0.388890  -0.095247
## tBodyGyro-arCoeff()-X,2                0.170615   0.244282   0.058243
## tBodyGyro-arCoeff()-X,3                0.088951   0.140685   0.179110
## tBodyGyro-arCoeff()-X,4               -0.081479  -0.130088  -0.079011
## tBodyGyro-arCoeff()-Y,1               -0.197162  -0.307820  -0.154637
## tBodyGyro-arCoeff()-Y,2                0.202165   0.215568   0.144934
## tBodyGyro-arCoeff()-Y,3               -0.054026  -0.098635   0.006029
## tBodyGyro-arCoeff()-Y,4                0.100147   0.194160   0.055451
## tBodyGyro-arCoeff()-Z,1               -0.114991  -0.214663  -0.026247
## tBodyGyro-arCoeff()-Z,2                0.093308   0.124750   0.018090
## tBodyGyro-arCoeff()-Z,3                0.012049   0.073871   0.036081
## tBodyGyro-arCoeff()-Z,4                0.054568  -0.021900   0.098383
## tBodyGyro-correlation()-X,Y           -0.177445  -0.310076  -0.142856
## tBodyGyro-correlation()-X,Z            0.039608   0.096780   0.031504
## tBodyGyro-correlation()-Y,Z           -0.052709  -0.149043  -0.254958
## tBodyGyroJerk-mean()-X                -0.099829  -0.108264  -0.098813
## tBodyGyroJerk-mean()-Y                -0.039075  -0.038988  -0.040476
## tBodyGyroJerk-mean()-Z                -0.055299  -0.055578  -0.055828
## tBodyGyroJerk-std()-X                 -0.764490  -0.768682  -0.732321
## tBodyGyroJerk-std()-Y                 -0.792719  -0.902628  -0.836112
## tBodyGyroJerk-std()-Z                 -0.796817  -0.831849  -0.773102
## tBodyGyroJerk-mad()-X                 -0.769595  -0.766260  -0.728076
## tBodyGyroJerk-mad()-Y                 -0.806547  -0.906290  -0.843467
## tBodyGyroJerk-mad()-Z                 -0.801968  -0.833154  -0.784303
## tBodyGyroJerk-max()-X                 -0.748280  -0.776146  -0.760001
## tBodyGyroJerk-max()-Y                 -0.810875  -0.918611  -0.857151
## tBodyGyroJerk-max()-Z                 -0.812513  -0.838571  -0.791088
## tBodyGyroJerk-min()-X                  0.784820   0.805276   0.747529
## tBodyGyroJerk-min()-Y                  0.830211   0.917640   0.863589
## tBodyGyroJerk-min()-Z                  0.834995   0.880834   0.804887
## tBodyGyroJerk-sma()                   -0.795249  -0.851564  -0.798455
## tBodyGyroJerk-energy()-X              -0.937985  -0.945207  -0.911479
## tBodyGyroJerk-energy()-Y              -0.953907  -0.991094  -0.967801
## tBodyGyroJerk-energy()-Z              -0.954144  -0.971245  -0.938171
## tBodyGyroJerk-iqr()-X                 -0.784094  -0.764924  -0.729819
## tBodyGyroJerk-iqr()-Y                 -0.826309  -0.909325  -0.851502
## tBodyGyroJerk-iqr()-Z                 -0.816579  -0.843233  -0.811480
## tBodyGyroJerk-entropy()-X             -0.037554   0.029341  -0.128924
## tBodyGyroJerk-entropy()-Y              0.067025   0.025018  -0.063277
## tBodyGyroJerk-entropy()-Z             -0.047974  -0.006057  -0.106775
## tBodyGyroJerk-arCoeff()-X,1           -0.054761  -0.215631   0.034016
## tBodyGyroJerk-arCoeff()-X,2            0.105921   0.054139   0.005735
## tBodyGyroJerk-arCoeff()-X,3            0.152407   0.105128   0.216151
## tBodyGyroJerk-arCoeff()-X,4            0.194371   0.184071   0.191906
## tBodyGyroJerk-arCoeff()-Y,1           -0.159747  -0.251444  -0.104092
## tBodyGyroJerk-arCoeff()-Y,2            0.265479   0.181635   0.221362
## tBodyGyroJerk-arCoeff()-Y,3            0.107641   0.001567   0.143029
## tBodyGyroJerk-arCoeff()-Y,4            0.110296   0.020008   0.129879
## tBodyGyroJerk-arCoeff()-Z,1           -0.038183  -0.126837   0.043975
## tBodyGyroJerk-arCoeff()-Z,2            0.090884   0.024916   0.033737
## tBodyGyroJerk-arCoeff()-Z,3            0.111497   0.158934   0.127880
## tBodyGyroJerk-arCoeff()-Z,4            0.075696   0.017246   0.065379
## tBodyGyroJerk-correlation()-X,Y       -0.010090   0.012827  -0.014669
## tBodyGyroJerk-correlation()-X,Z        0.104445   0.075545   0.058952
## tBodyGyroJerk-correlation()-Y,Z       -0.112961  -0.116503  -0.181870
## tBodyAccMag-mean()                    -0.620033  -0.583378  -0.600932
## tBodyAccMag-std()                     -0.650862  -0.659016  -0.620356
## tBodyAccMag-mad()                     -0.702763  -0.700129  -0.665278
## tBodyAccMag-max()                     -0.611938  -0.630707  -0.597043
## tBodyAccMag-min()                     -0.849064  -0.831220  -0.842427
## tBodyAccMag-sma()                     -0.620033  -0.583378  -0.600932
## tBodyAccMag-energy()                  -0.842774  -0.847109  -0.806338
## tBodyAccMag-iqr()                     -0.776277  -0.740709  -0.726290
## tBodyAccMag-entropy()                  0.106716   0.195509   0.013580
## tBodyAccMag-arCoeff()1                -0.121371  -0.201406  -0.088705
## tBodyAccMag-arCoeff()2                 0.075070   0.113763   0.027719
## tBodyAccMag-arCoeff()3                -0.015153  -0.003616   0.084716
## tBodyAccMag-arCoeff()4                 0.005966   0.023369  -0.070508
## tGravityAccMag-mean()                 -0.620033  -0.583378  -0.600932
## tGravityAccMag-std()                  -0.650862  -0.659016  -0.620356
## tGravityAccMag-mad()                  -0.702763  -0.700129  -0.665278
## tGravityAccMag-max()                  -0.611938  -0.630707  -0.597043
## tGravityAccMag-min()                  -0.849064  -0.831220  -0.842427
## tGravityAccMag-sma()                  -0.620033  -0.583378  -0.600932
## tGravityAccMag-energy()               -0.842774  -0.847109  -0.806338
## tGravityAccMag-iqr()                  -0.776277  -0.740709  -0.726290
## tGravityAccMag-entropy()               0.106716   0.195509   0.013580
## tGravityAccMag-arCoeff()1             -0.121371  -0.201406  -0.088705
## tGravityAccMag-arCoeff()2              0.075070   0.113763   0.027719
## tGravityAccMag-arCoeff()3             -0.015153  -0.003616   0.084716
## tGravityAccMag-arCoeff()4              0.005966   0.023369  -0.070508
## tBodyAccJerkMag-mean()                -0.713667  -0.783445  -0.694918
## tBodyAccJerkMag-std()                 -0.689391  -0.780452  -0.677426
## tBodyAccJerkMag-mad()                 -0.702475  -0.789339  -0.690168
## tBodyAccJerkMag-max()                 -0.704468  -0.788995  -0.690110
## tBodyAccJerkMag-min()                 -0.824584  -0.856415  -0.819080
## tBodyAccJerkMag-sma()                 -0.713667  -0.783445  -0.694918
## tBodyAccJerkMag-energy()              -0.902361  -0.950088  -0.881257
## tBodyAccJerkMag-iqr()                 -0.744423  -0.816461  -0.726049
## tBodyAccJerkMag-entropy()             -0.107134  -0.105700  -0.170933
## tBodyAccJerkMag-arCoeff()1             0.119930   0.067877   0.086689
## tBodyAccJerkMag-arCoeff()2            -0.044683   0.007480  -0.090490
## tBodyAccJerkMag-arCoeff()3            -0.180144  -0.071202  -0.059197
## tBodyAccJerkMag-arCoeff()4             0.012438  -0.113521   0.004353
## tBodyGyroMag-mean()                   -0.682447  -0.625733  -0.694598
## tBodyGyroMag-std()                    -0.742983  -0.685153  -0.751834
## tBodyGyroMag-mad()                    -0.718513  -0.648868  -0.724755
## tBodyGyroMag-max()                    -0.755329  -0.734501  -0.774578
## tBodyGyroMag-min()                    -0.759020  -0.733002  -0.776903
## tBodyGyroMag-sma()                    -0.682447  -0.625733  -0.694598
## tBodyGyroMag-energy()                 -0.897949  -0.873311  -0.897967
## tBodyGyroMag-iqr()                    -0.732348  -0.663096  -0.737276
## tBodyGyroMag-entropy()                 0.343152   0.378734   0.228224
## tBodyGyroMag-arCoeff()1                0.051443  -0.265629   0.007381
## tBodyGyroMag-arCoeff()2               -0.117744   0.139202  -0.109398
## tBodyGyroMag-arCoeff()3                0.090155   0.001225   0.149305
## tBodyGyroMag-arCoeff()4               -0.030623   0.012931  -0.078460
## tBodyGyroJerkMag-mean()               -0.791647  -0.849631  -0.798326
## tBodyGyroJerkMag-std()                -0.788998  -0.872776  -0.818279
## tBodyGyroJerkMag-mad()                -0.805463  -0.879920  -0.829671
## tBodyGyroJerkMag-max()                -0.796163  -0.877704  -0.827041
## tBodyGyroJerkMag-min()                -0.848054  -0.871498  -0.833541
## tBodyGyroJerkMag-sma()                -0.791647  -0.849631  -0.798326
## tBodyGyroJerkMag-energy()             -0.950470  -0.978839  -0.951966
## tBodyGyroJerkMag-iqr()                -0.826896  -0.885835  -0.841179
## tBodyGyroJerkMag-entropy()             0.134062   0.137350   0.009410
## tBodyGyroJerkMag-arCoeff()1            0.357845   0.129720   0.311379
## tBodyGyroJerkMag-arCoeff()2           -0.253454  -0.097717  -0.298185
## tBodyGyroJerkMag-arCoeff()3           -0.175789   0.041981  -0.060453
## tBodyGyroJerkMag-arCoeff()4           -0.015995  -0.247998  -0.012723
## fBodyAcc-mean()-X                     -0.707614  -0.748417  -0.651090
## fBodyAcc-mean()-Y                     -0.611509  -0.600028  -0.610426
## fBodyAcc-mean()-Z                     -0.655859  -0.738510  -0.724046
## fBodyAcc-std()-X                      -0.664357  -0.705224  -0.613500
## fBodyAcc-std()-Y                      -0.594677  -0.529065  -0.600275
## fBodyAcc-std()-Z                      -0.655361  -0.630225  -0.718490
## fBodyAcc-mad()-X                      -0.670700  -0.715511  -0.612523
## fBodyAcc-mad()-Y                      -0.585025  -0.553260  -0.585532
## fBodyAcc-mad()-Z                      -0.625094  -0.689499  -0.699040
## fBodyAcc-max()-X                      -0.690693  -0.728649  -0.653616
## fBodyAcc-max()-Y                      -0.720755  -0.650856  -0.729428
## fBodyAcc-max()-Z                      -0.712931  -0.608638  -0.770034
## fBodyAcc-min()-X                      -0.890574  -0.900665  -0.861073
## fBodyAcc-min()-Y                      -0.913824  -0.872288  -0.900867
## fBodyAcc-min()-Z                      -0.918008  -0.909616  -0.931406
## fBodyAcc-sma()                        -0.618175  -0.663488  -0.612037
## fBodyAcc-energy()-X                   -0.882841  -0.918994  -0.827311
## fBodyAcc-energy()-Y                   -0.821999  -0.808780  -0.809889
## fBodyAcc-energy()-Z                   -0.866234  -0.889422  -0.903146
## fBodyAcc-iqr()-X                      -0.753749  -0.794249  -0.703376
## fBodyAcc-iqr()-Y                      -0.704323  -0.757393  -0.702571
## fBodyAcc-iqr()-Z                      -0.698968  -0.839618  -0.766499
## fBodyAcc-entropy()-X                  -0.277837  -0.263265  -0.291507
## fBodyAcc-entropy()-Y                  -0.242118  -0.188672  -0.298176
## fBodyAcc-entropy()-Z                  -0.181324  -0.251950  -0.294306
## fBodyAcc-maxInds-X                    -0.748370  -0.773957  -0.796412
## fBodyAcc-maxInds-Y                    -0.834996  -0.834067  -0.778741
## fBodyAcc-maxInds-Z                    -0.829800  -0.918375  -0.739403
## fBodyAcc-meanFreq()-X                 -0.263352  -0.306657  -0.222546
## fBodyAcc-meanFreq()-Y                 -0.017608  -0.108650   0.036038
## fBodyAcc-meanFreq()-Z                  0.081258  -0.074450   0.142429
## fBodyAcc-skewness()-X                 -0.028588  -0.077799  -0.081415
## fBodyAcc-kurtosis()-X                 -0.325912  -0.404052  -0.407714
## fBodyAcc-skewness()-Y                 -0.278323  -0.217507  -0.321938
## fBodyAcc-kurtosis()-Y                 -0.601521  -0.550046  -0.632482
## fBodyAcc-skewness()-Z                 -0.306311  -0.085013  -0.382279
## fBodyAcc-kurtosis()-Z                 -0.538762  -0.336610  -0.609298
## fBodyAcc-bandsEnergy()-1,8            -0.863782  -0.901963  -0.810542
## fBodyAcc-bandsEnergy()-9,16           -0.947617  -0.974584  -0.896326
## fBodyAcc-bandsEnergy()-17,24          -0.943996  -0.958966  -0.904019
## fBodyAcc-bandsEnergy()-25,32          -0.957275  -0.972656  -0.937547
## fBodyAcc-bandsEnergy()-33,40          -0.957036  -0.972235  -0.926975
## fBodyAcc-bandsEnergy()-41,48          -0.957411  -0.971725  -0.928473
## fBodyAcc-bandsEnergy()-49,56          -0.973655  -0.980409  -0.951796
## fBodyAcc-bandsEnergy()-57,64          -0.976191  -0.979369  -0.956320
## fBodyAcc-bandsEnergy()-1,16           -0.875817  -0.914242  -0.818207
## fBodyAcc-bandsEnergy()-17,32          -0.939196  -0.956634  -0.899004
## fBodyAcc-bandsEnergy()-33,48          -0.957191  -0.972059  -0.927551
## fBodyAcc-bandsEnergy()-49,64          -0.974505  -0.980060  -0.953312
## fBodyAcc-bandsEnergy()-1,24           -0.880665  -0.917423  -0.824308
## fBodyAcc-bandsEnergy()-25,48          -0.948918  -0.967049  -0.920578
## fBodyAcc-bandsEnergy()-1,8.1          -0.831717  -0.799058  -0.831102
## fBodyAcc-bandsEnergy()-9,16.1         -0.906737  -0.905752  -0.882898
## fBodyAcc-bandsEnergy()-17,24.1        -0.906651  -0.956080  -0.907061
## fBodyAcc-bandsEnergy()-25,32.1        -0.958194  -0.972584  -0.946210
## fBodyAcc-bandsEnergy()-33,40.1        -0.943560  -0.957332  -0.941316
## fBodyAcc-bandsEnergy()-41,48.1        -0.930451  -0.943058  -0.917141
## fBodyAcc-bandsEnergy()-49,56.1        -0.939733  -0.944847  -0.930361
## fBodyAcc-bandsEnergy()-57,64.1        -0.970005  -0.961090  -0.968396
## fBodyAcc-bandsEnergy()-1,16.1         -0.823091  -0.797559  -0.810355
## fBodyAcc-bandsEnergy()-17,32.1        -0.897721  -0.949644  -0.894654
## fBodyAcc-bandsEnergy()-33,48.1        -0.932091  -0.946995  -0.925343
## fBodyAcc-bandsEnergy()-49,64.1        -0.950551  -0.949911  -0.944151
## fBodyAcc-bandsEnergy()-1,24.1         -0.821862  -0.807247  -0.810295
## fBodyAcc-bandsEnergy()-25,48.1        -0.947966  -0.963249  -0.937001
## fBodyAcc-bandsEnergy()-1,8.2          -0.908628  -0.878294  -0.937393
## fBodyAcc-bandsEnergy()-9,16.2         -0.867693  -0.959483  -0.906314
## fBodyAcc-bandsEnergy()-17,24.2        -0.909879  -0.976930  -0.920683
## fBodyAcc-bandsEnergy()-25,32.2        -0.962061  -0.991396  -0.969428
## fBodyAcc-bandsEnergy()-33,40.2        -0.971155  -0.989644  -0.977547
## fBodyAcc-bandsEnergy()-41,48.2        -0.950324  -0.978401  -0.959551
## fBodyAcc-bandsEnergy()-49,56.2        -0.949546  -0.971816  -0.960601
## fBodyAcc-bandsEnergy()-57,64.2        -0.966412  -0.961112  -0.976499
## fBodyAcc-bandsEnergy()-1,16.2         -0.884324  -0.889673  -0.919773
## fBodyAcc-bandsEnergy()-17,32.2        -0.928814  -0.982204  -0.938373
## fBodyAcc-bandsEnergy()-33,48.2        -0.963735  -0.986030  -0.971318
## fBodyAcc-bandsEnergy()-49,64.2        -0.954183  -0.968376  -0.965042
## fBodyAcc-bandsEnergy()-1,24.2         -0.869749  -0.888839  -0.906177
## fBodyAcc-bandsEnergy()-25,48.2        -0.962554  -0.989882  -0.969983
## fBodyAccJerk-mean()-X                 -0.752245  -0.804145  -0.699413
## fBodyAccJerk-mean()-Y                 -0.703642  -0.740570  -0.696726
## fBodyAccJerk-mean()-Z                 -0.719656  -0.849505  -0.769565
## fBodyAccJerk-std()-X                  -0.751378  -0.807713  -0.694315
## fBodyAccJerk-std()-Y                  -0.688280  -0.721708  -0.680358
## fBodyAccJerk-std()-Z                  -0.751629  -0.870542  -0.786049
## fBodyAccJerk-mad()-X                  -0.710049  -0.773076  -0.649097
## fBodyAccJerk-mad()-Y                  -0.697517  -0.734254  -0.689977
## fBodyAccJerk-mad()-Z                  -0.731677  -0.859086  -0.775259
## fBodyAccJerk-max()-X                  -0.793889  -0.835502  -0.737557
## fBodyAccJerk-max()-Y                  -0.748565  -0.771374  -0.741077
## fBodyAccJerk-max()-Z                  -0.778110  -0.884598  -0.802049
## fBodyAccJerk-min()-X                  -0.911787  -0.930525  -0.893812
## fBodyAccJerk-min()-Y                  -0.887463  -0.895105  -0.889111
## fBodyAccJerk-min()-Z                  -0.888572  -0.920761  -0.902555
## fBodyAccJerk-sma()                    -0.680389  -0.766889  -0.672651
## fBodyAccJerk-energy()-X               -0.926615  -0.957170  -0.879483
## fBodyAccJerk-energy()-Y               -0.891301  -0.922740  -0.876280
## fBodyAccJerk-energy()-Z               -0.921586  -0.979347  -0.937588
## fBodyAccJerk-iqr()-X                  -0.737482  -0.788222  -0.695634
## fBodyAccJerk-iqr()-Y                  -0.778581  -0.813173  -0.773792
## fBodyAccJerk-iqr()-Z                  -0.745041  -0.862865  -0.793431
## fBodyAccJerk-entropy()-X              -0.352377  -0.380248  -0.352453
## fBodyAccJerk-entropy()-Y              -0.341199  -0.328575  -0.367410
## fBodyAccJerk-entropy()-Z              -0.335219  -0.474109  -0.432019
## fBodyAccJerk-maxInds-X                -0.447454  -0.491051  -0.415816
## fBodyAccJerk-maxInds-Y                -0.387087  -0.517359  -0.388367
## fBodyAccJerk-maxInds-Z                -0.277690  -0.407042  -0.261122
## fBodyAccJerk-meanFreq()-X             -0.057042  -0.110793  -0.023840
## fBodyAccJerk-meanFreq()-Y             -0.231132  -0.347751  -0.168915
## fBodyAccJerk-meanFreq()-Z             -0.139771  -0.235707  -0.085046
## fBodyAccJerk-skewness()-X             -0.314902  -0.325093  -0.312419
## fBodyAccJerk-kurtosis()-X             -0.718311  -0.712983  -0.708454
## fBodyAccJerk-skewness()-Y             -0.417817  -0.358109  -0.423220
## fBodyAccJerk-kurtosis()-Y             -0.838391  -0.803368  -0.840397
## fBodyAccJerk-skewness()-Z             -0.469243  -0.493706  -0.477024
## fBodyAccJerk-kurtosis()-Z             -0.813494  -0.824524  -0.809895
## fBodyAccJerk-bandsEnergy()-1,8        -0.912101  -0.949423  -0.873595
## fBodyAccJerk-bandsEnergy()-9,16       -0.945644  -0.974097  -0.895907
## fBodyAccJerk-bandsEnergy()-17,24      -0.951870  -0.964836  -0.920110
## fBodyAccJerk-bandsEnergy()-25,32      -0.960228  -0.975157  -0.942726
## fBodyAccJerk-bandsEnergy()-33,40      -0.961495  -0.976595  -0.936131
## fBodyAccJerk-bandsEnergy()-41,48      -0.953216  -0.972418  -0.924332
## fBodyAccJerk-bandsEnergy()-49,56      -0.974981  -0.985002  -0.955610
## fBodyAccJerk-bandsEnergy()-57,64      -0.992967  -0.994922  -0.985988
## fBodyAccJerk-bandsEnergy()-1,16       -0.925883  -0.960799  -0.876795
## fBodyAccJerk-bandsEnergy()-17,32      -0.944323  -0.961179  -0.911422
## fBodyAccJerk-bandsEnergy()-33,48      -0.954896  -0.972941  -0.925972
## fBodyAccJerk-bandsEnergy()-49,64      -0.974054  -0.984281  -0.953670
## fBodyAccJerk-bandsEnergy()-1,24       -0.922268  -0.955152  -0.870827
## fBodyAccJerk-bandsEnergy()-25,48      -0.940339  -0.963488  -0.907980
## fBodyAccJerk-bandsEnergy()-1,8.1      -0.880030  -0.888440  -0.861202
## fBodyAccJerk-bandsEnergy()-9,16.1     -0.914006  -0.923534  -0.896340
## fBodyAccJerk-bandsEnergy()-17,24.1    -0.891900  -0.952265  -0.891560
## fBodyAccJerk-bandsEnergy()-25,32.1    -0.961996  -0.977459  -0.949478
## fBodyAccJerk-bandsEnergy()-33,40.1    -0.955727  -0.970702  -0.951558
## fBodyAccJerk-bandsEnergy()-41,48.1    -0.926799  -0.950271  -0.911622
## fBodyAccJerk-bandsEnergy()-49,56.1    -0.951430  -0.966715  -0.943408
## fBodyAccJerk-bandsEnergy()-57,64.1    -0.983014  -0.986859  -0.981165
## fBodyAccJerk-bandsEnergy()-1,16.1     -0.893771  -0.904391  -0.873316
## fBodyAccJerk-bandsEnergy()-17,32.1    -0.903209  -0.954549  -0.897059
## fBodyAccJerk-bandsEnergy()-33,48.1    -0.932768  -0.954974  -0.922895
## fBodyAccJerk-bandsEnergy()-49,64.1    -0.955418  -0.969260  -0.948175
## fBodyAccJerk-bandsEnergy()-1,24.1     -0.875133  -0.909440  -0.860106
## fBodyAccJerk-bandsEnergy()-25,48.1    -0.950225  -0.968499  -0.938559
## fBodyAccJerk-bandsEnergy()-1,8.2      -0.921267  -0.959054  -0.947927
## fBodyAccJerk-bandsEnergy()-9,16.2     -0.854785  -0.962014  -0.895594
## fBodyAccJerk-bandsEnergy()-17,24.2    -0.917077  -0.980625  -0.926176
## fBodyAccJerk-bandsEnergy()-25,32.2    -0.964045  -0.992931  -0.970882
## fBodyAccJerk-bandsEnergy()-33,40.2    -0.974179  -0.993083  -0.979532
## fBodyAccJerk-bandsEnergy()-41,48.2    -0.953297  -0.986473  -0.961110
## fBodyAccJerk-bandsEnergy()-49,56.2    -0.937927  -0.981833  -0.949316
## fBodyAccJerk-bandsEnergy()-57,64.2    -0.970258  -0.989140  -0.975651
## fBodyAccJerk-bandsEnergy()-1,16.2     -0.847825  -0.952992  -0.892209
## fBodyAccJerk-bandsEnergy()-17,32.2    -0.940070  -0.986671  -0.948063
## fBodyAccJerk-bandsEnergy()-33,48.2    -0.966146  -0.990630  -0.972601
## fBodyAccJerk-bandsEnergy()-49,64.2    -0.937695  -0.981518  -0.949120
## fBodyAccJerk-bandsEnergy()-1,24.2     -0.875744  -0.965921  -0.901658
## fBodyAccJerk-bandsEnergy()-25,48.2    -0.964896  -0.992053  -0.971583
## fBodyGyro-mean()-X                    -0.722607  -0.672198  -0.703110
## fBodyGyro-mean()-Y                    -0.753710  -0.813134  -0.799353
## fBodyGyro-mean()-Z                    -0.709489  -0.746832  -0.689405
## fBodyGyro-std()-X                     -0.794064  -0.690398  -0.787403
## fBodyGyro-std()-Y                     -0.771970  -0.723584  -0.803635
## fBodyGyro-std()-Z                     -0.735750  -0.771209  -0.735942
## fBodyGyro-mad()-X                     -0.744398  -0.656407  -0.724300
## fBodyGyro-mad()-Y                     -0.766875  -0.799148  -0.812974
## fBodyGyro-mad()-Z                     -0.695305  -0.729830  -0.689526
## fBodyGyro-max()-X                     -0.797508  -0.665254  -0.799753
## fBodyGyro-max()-Y                     -0.848863  -0.736338  -0.852950
## fBodyGyro-max()-Z                     -0.799270  -0.827373  -0.801052
## fBodyGyro-min()-X                     -0.945879  -0.926470  -0.945825
## fBodyGyro-min()-Y                     -0.926410  -0.929418  -0.922383
## fBodyGyro-min()-Z                     -0.927920  -0.928320  -0.922302
## fBodyGyro-sma()                       -0.716339  -0.734114  -0.725286
## fBodyGyro-energy()-X                  -0.946023  -0.903738  -0.935239
## fBodyGyro-energy()-Y                  -0.944482  -0.942018  -0.956434
## fBodyGyro-energy()-Z                  -0.910605  -0.941879  -0.903893
## fBodyGyro-iqr()-X                     -0.727957  -0.767850  -0.696885
## fBodyGyro-iqr()-Y                     -0.760664  -0.880554  -0.820448
## fBodyGyro-iqr()-Z                     -0.755747  -0.787291  -0.724438
## fBodyGyro-entropy()-X                 -0.112413  -0.093853  -0.198102
## fBodyGyro-entropy()-Y                 -0.035751  -0.115593  -0.160815
## fBodyGyro-entropy()-Z                 -0.222699  -0.191976  -0.231858
## fBodyGyro-maxInds-X                   -0.869991  -0.895029  -0.843707
## fBodyGyro-maxInds-Y                   -0.686394  -0.923969  -0.742758
## fBodyGyro-maxInds-Z                   -0.855734  -0.870163  -0.813863
## fBodyGyro-meanFreq()-X                -0.050108  -0.207601  -0.016778
## fBodyGyro-meanFreq()-Y                -0.097535  -0.349147  -0.099777
## fBodyGyro-meanFreq()-Z                -0.055641  -0.135140   0.002937
## fBodyGyro-skewness()-X                -0.248050  -0.092762  -0.283535
## fBodyGyro-kurtosis()-X                -0.563869  -0.414999  -0.595066
## fBodyGyro-skewness()-Y                -0.258367  -0.015303  -0.172432
## fBodyGyro-kurtosis()-Y                -0.592928  -0.384043  -0.526213
## fBodyGyro-skewness()-Z                -0.196213  -0.199265  -0.217430
## fBodyGyro-kurtosis()-Z                -0.510600  -0.531885  -0.530866
## fBodyGyro-bandsEnergy()-1,8           -0.956145  -0.915607  -0.949462
## fBodyGyro-bandsEnergy()-9,16          -0.942206  -0.888319  -0.918788
## fBodyGyro-bandsEnergy()-17,24         -0.925781  -0.965558  -0.907306
## fBodyGyro-bandsEnergy()-25,32         -0.970796  -0.986417  -0.965722
## fBodyGyro-bandsEnergy()-33,40         -0.963740  -0.976553  -0.950874
## fBodyGyro-bandsEnergy()-41,48         -0.966409  -0.973653  -0.954884
## fBodyGyro-bandsEnergy()-49,56         -0.973698  -0.975245  -0.971752
## fBodyGyro-bandsEnergy()-57,64         -0.983183  -0.975859  -0.986054
## fBodyGyro-bandsEnergy()-1,16          -0.950278  -0.904250  -0.940567
## fBodyGyro-bandsEnergy()-17,32         -0.928389  -0.966757  -0.911459
## fBodyGyro-bandsEnergy()-33,48         -0.961182  -0.973015  -0.947568
## fBodyGyro-bandsEnergy()-49,64         -0.977895  -0.975516  -0.978080
## fBodyGyro-bandsEnergy()-1,24          -0.947080  -0.904013  -0.936527
## fBodyGyro-bandsEnergy()-25,48         -0.967702  -0.982401  -0.960108
## fBodyGyro-bandsEnergy()-1,8.1         -0.966217  -0.908156  -0.966679
## fBodyGyro-bandsEnergy()-9,16.1        -0.967728  -0.992803  -0.976840
## fBodyGyro-bandsEnergy()-17,24.1       -0.965346  -0.995925  -0.978849
## fBodyGyro-bandsEnergy()-25,32.1       -0.977027  -0.995644  -0.982666
## fBodyGyro-bandsEnergy()-33,40.1       -0.985907  -0.995820  -0.988425
## fBodyGyro-bandsEnergy()-41,48.1       -0.974000  -0.991051  -0.978767
## fBodyGyro-bandsEnergy()-49,56.1       -0.972814  -0.988291  -0.975266
## fBodyGyro-bandsEnergy()-57,64.1       -0.988967  -0.989187  -0.987980
## fBodyGyro-bandsEnergy()-1,16.1        -0.956266  -0.933478  -0.962503
## fBodyGyro-bandsEnergy()-17,32.1       -0.960625  -0.994870  -0.974965
## fBodyGyro-bandsEnergy()-33,48.1       -0.983318  -0.994798  -0.986324
## fBodyGyro-bandsEnergy()-49,64.1       -0.976114  -0.987085  -0.977409
## fBodyGyro-bandsEnergy()-1,24.1        -0.942742  -0.936288  -0.955023
## fBodyGyro-bandsEnergy()-25,48.1       -0.977219  -0.995041  -0.982469
## fBodyGyro-bandsEnergy()-1,8.2         -0.928462  -0.953531  -0.927150
## fBodyGyro-bandsEnergy()-9,16.2        -0.954927  -0.970405  -0.947825
## fBodyGyro-bandsEnergy()-17,24.2       -0.960014  -0.973406  -0.944234
## fBodyGyro-bandsEnergy()-25,32.2       -0.988067  -0.994335  -0.977592
## fBodyGyro-bandsEnergy()-33,40.2       -0.987346  -0.992944  -0.981617
## fBodyGyro-bandsEnergy()-41,48.2       -0.982026  -0.987647  -0.970218
## fBodyGyro-bandsEnergy()-49,56.2       -0.975422  -0.979171  -0.963589
## fBodyGyro-bandsEnergy()-57,64.2       -0.982337  -0.982861  -0.976464
## fBodyGyro-bandsEnergy()-1,16.2        -0.916843  -0.945878  -0.913216
## fBodyGyro-bandsEnergy()-17,32.2       -0.956096  -0.971901  -0.935978
## fBodyGyro-bandsEnergy()-33,48.2       -0.985873  -0.991497  -0.978486
## fBodyGyro-bandsEnergy()-49,64.2       -0.978429  -0.980775  -0.969187
## fBodyGyro-bandsEnergy()-1,24.2        -0.911863  -0.942561  -0.906133
## fBodyGyro-bandsEnergy()-25,48.2       -0.987388  -0.993456  -0.977871
## fBodyAccMag-mean()                    -0.650122  -0.695020  -0.631757
## fBodyAccMag-std()                     -0.705928  -0.695368  -0.673918
## fBodyAccMag-mad()                     -0.646706  -0.664143  -0.620204
## fBodyAccMag-max()                     -0.799248  -0.776110  -0.759976
## fBodyAccMag-min()                     -0.920296  -0.895916  -0.903203
## fBodyAccMag-sma()                     -0.650122  -0.695020  -0.631757
## fBodyAccMag-energy()                  -0.868854  -0.895475  -0.831846
## fBodyAccMag-iqr()                     -0.739105  -0.792537  -0.724418
## fBodyAccMag-entropy()                 -0.234139  -0.228221  -0.289037
## fBodyAccMag-maxInds                   -0.821341  -0.778602  -0.745602
## fBodyAccMag-meanFreq()                 0.023630  -0.042642   0.088329
## fBodyAccMag-skewness()                -0.338610  -0.303983  -0.341355
## fBodyAccMag-kurtosis()                -0.630239  -0.595203  -0.617271
## fBodyBodyAccJerkMag-mean()            -0.696846  -0.779190  -0.679278
## fBodyBodyAccJerkMag-std()             -0.682447  -0.783547  -0.678026
## fBodyBodyAccJerkMag-mad()             -0.684913  -0.777401  -0.666760
## fBodyBodyAccJerkMag-max()             -0.697883  -0.797940  -0.713856
## fBodyBodyAccJerkMag-min()             -0.844555  -0.883272  -0.826638
## fBodyBodyAccJerkMag-sma()             -0.696846  -0.779190  -0.679278
## fBodyBodyAccJerkMag-energy()          -0.891742  -0.950605  -0.875550
## fBodyBodyAccJerkMag-iqr()             -0.742927  -0.811502  -0.730086
## fBodyBodyAccJerkMag-entropy()         -0.416490  -0.479202  -0.421715
## fBodyBodyAccJerkMag-maxInds           -0.852102  -0.911903  -0.866942
## fBodyBodyAccJerkMag-meanFreq()         0.198422   0.168223   0.180461
## fBodyBodyAccJerkMag-skewness()        -0.232086  -0.222649  -0.333092
## fBodyBodyAccJerkMag-kurtosis()        -0.510962  -0.506172  -0.625751
## fBodyBodyGyroMag-mean()               -0.754132  -0.754236  -0.770505
## fBodyBodyGyroMag-std()                -0.782076  -0.697213  -0.782624
## fBodyBodyGyroMag-mad()                -0.762374  -0.692485  -0.761548
## fBodyBodyGyroMag-max()                -0.808965  -0.731883  -0.812609
## fBodyBodyGyroMag-min()                -0.913794  -0.919805  -0.921756
## fBodyBodyGyroMag-sma()                -0.754132  -0.754236  -0.770505
## fBodyBodyGyroMag-energy()             -0.933617  -0.911065  -0.932473
## fBodyBodyGyroMag-iqr()                -0.774754  -0.772295  -0.782551
## fBodyBodyGyroMag-entropy()            -0.102227  -0.103162  -0.196977
## fBodyBodyGyroMag-maxInds              -0.892456  -0.889787  -0.866562
## fBodyBodyGyroMag-meanFreq()            0.019449  -0.220820  -0.012159
## fBodyBodyGyroMag-skewness()           -0.317891  -0.209519  -0.264928
## fBodyBodyGyroMag-kurtosis()           -0.616326  -0.541921  -0.568793
## fBodyBodyGyroJerkMag-mean()           -0.795019  -0.875971  -0.823865
## fBodyBodyGyroJerkMag-std()            -0.796157  -0.877715  -0.823991
## fBodyBodyGyroJerkMag-mad()            -0.789933  -0.863978  -0.813221
## fBodyBodyGyroJerkMag-max()            -0.796663  -0.888588  -0.840184
## fBodyBodyGyroJerkMag-min()            -0.886086  -0.936421  -0.895828
## fBodyBodyGyroJerkMag-sma()            -0.795019  -0.875971  -0.823865
## fBodyBodyGyroJerkMag-energy()         -0.951277  -0.983918  -0.960312
## fBodyBodyGyroJerkMag-iqr()            -0.795966  -0.857872  -0.824025
## fBodyBodyGyroJerkMag-entropy()        -0.301067  -0.357418  -0.388144
## fBodyBodyGyroJerkMag-maxInds          -0.901679  -0.910118  -0.898688
## fBodyBodyGyroJerkMag-meanFreq()        0.161740   0.047148   0.147534
## fBodyBodyGyroJerkMag-skewness()       -0.237735  -0.301955  -0.287865
## fBodyBodyGyroJerkMag-kurtosis()       -0.546802  -0.613265  -0.613877
## angle(tBodyAccMean,gravity)           -0.002317  -0.001222   0.021668
## angle(tBodyAccJerkMean),gravityMean)  -0.012478   0.047037   0.016865
## angle(tBodyGyroMean,gravityMean)      -0.013983  -0.026690  -0.017591
## angle(tBodyGyroJerkMean,gravityMean)  -0.003003   0.022386  -0.011625
## angle(X,gravityMean)                  -0.545994  -0.512419  -0.482704
## angle(Y,gravityMean)                   0.019867   0.030739  -0.010055
## angle(Z,gravityMean)                  -0.031231  -0.159471  -0.149816
##                                      subject_27 subject_28 subject_29
## tBodyAcc-mean()-X                     0.2772646  0.2775326  0.2791115
## tBodyAcc-mean()-Y                    -0.0167969 -0.0191721 -0.0184720
## tBodyAcc-mean()-Z                    -0.1108483 -0.1097109 -0.1086756
## tBodyAcc-std()-X                     -0.6609761 -0.6490404 -0.5742954
## tBodyAcc-std()-Y                     -0.6304605 -0.5736519 -0.5984003
## tBodyAcc-std()-Z                     -0.6832153 -0.6858214 -0.6064613
## tBodyAcc-mad()-X                     -0.6807414 -0.6701989 -0.6031417
## tBodyAcc-mad()-Y                     -0.6360066 -0.5896923 -0.6166673
## tBodyAcc-mad()-Z                     -0.6842832 -0.6981801 -0.6090895
## tBodyAcc-max()-X                     -0.5199101 -0.5127312 -0.4209480
## tBodyAcc-max()-Y                     -0.3641342 -0.3433623 -0.3315218
## tBodyAcc-max()-Z                     -0.6306002 -0.6198065 -0.4846989
## tBodyAcc-min()-X                      0.5935542  0.5694896  0.5369954
## tBodyAcc-min()-Y                      0.4714906  0.4032100  0.4289037
## tBodyAcc-min()-Z                      0.6259523  0.6128427  0.6343665
## tBodyAcc-sma()                       -0.6319659 -0.6158610 -0.5609460
## tBodyAcc-energy()-X                  -0.8521233 -0.8467817 -0.7905981
## tBodyAcc-energy()-Y                  -0.9391704 -0.9248253 -0.9310821
## tBodyAcc-energy()-Z                  -0.8952135 -0.9075162 -0.8404759
## tBodyAcc-iqr()-X                     -0.7219792 -0.7155178 -0.6751887
## tBodyAcc-iqr()-Y                     -0.7146022 -0.6900602 -0.7076371
## tBodyAcc-iqr()-Z                     -0.7062670 -0.7394305 -0.6522671
## tBodyAcc-entropy()-X                 -0.1834447 -0.1073814 -0.1949413
## tBodyAcc-entropy()-Y                 -0.2475606 -0.1258495 -0.2462218
## tBodyAcc-entropy()-Z                 -0.1942241 -0.1177329 -0.2814468
## tBodyAcc-arCoeff()-X,1               -0.0614459 -0.1118489 -0.0279392
## tBodyAcc-arCoeff()-X,2                0.0770951  0.1112651  0.0456685
## tBodyAcc-arCoeff()-X,3               -0.0270967 -0.0358876 -0.0358757
## tBodyAcc-arCoeff()-X,4                0.1841453  0.1034679  0.2119129
## tBodyAcc-arCoeff()-Y,1                0.0477652 -0.0805336  0.1010140
## tBodyAcc-arCoeff()-Y,2                0.0077740  0.0385760 -0.0309368
## tBodyAcc-arCoeff()-Y,3                0.1466044  0.1789898  0.1528446
## tBodyAcc-arCoeff()-Y,4               -0.0110525 -0.0564570  0.0410578
## tBodyAcc-arCoeff()-Z,1                0.0784326  0.0206774  0.1428990
## tBodyAcc-arCoeff()-Z,2                0.0118460  0.0182651 -0.0474858
## tBodyAcc-arCoeff()-Z,3                0.0410821  0.0208612  0.0042750
## tBodyAcc-arCoeff()-Z,4               -0.0347064 -0.0185729  0.0316276
## tBodyAcc-correlation()-X,Y           -0.1738753  0.0050208 -0.2435359
## tBodyAcc-correlation()-X,Z           -0.2290664 -0.2552699 -0.0770947
## tBodyAcc-correlation()-Y,Z            0.2106140  0.0249845  0.1831951
## tGravityAcc-mean()-X                  0.6272301  0.6237679  0.6830676
## tGravityAcc-mean()-Y                  0.0322424 -0.1475778  0.1154898
## tGravityAcc-mean()-Z                  0.1411687 -0.0469931  0.2082154
## tGravityAcc-std()-X                  -0.9746202 -0.9738733 -0.9732829
## tGravityAcc-std()-Y                  -0.9725052 -0.9603656 -0.9646432
## tGravityAcc-std()-Z                  -0.9592004 -0.9462256 -0.9416218
## tGravityAcc-mad()-X                  -0.9752392 -0.9744186 -0.9738884
## tGravityAcc-mad()-Y                  -0.9732799 -0.9614721 -0.9652537
## tGravityAcc-mad()-Z                  -0.9597905 -0.9470565 -0.9429278
## tGravityAcc-max()-X                   0.5638178  0.5600241  0.6188608
## tGravityAcc-max()-Y                   0.0121125 -0.1594932  0.0947456
## tGravityAcc-max()-Z                   0.1403843 -0.0425019  0.2112950
## tGravityAcc-min()-X                   0.6459183  0.6419034  0.6991106
## tGravityAcc-min()-Y                   0.0496807 -0.1312448  0.1293973
## tGravityAcc-min()-Z                   0.1334281 -0.0569336  0.1960538
## tGravityAcc-sma()                    -0.0866428 -0.0154805 -0.2810484
## tGravityAcc-energy()-X                0.4227335  0.4185829  0.4770455
## tGravityAcc-energy()-Y               -0.8061727 -0.8333469 -0.7065329
## tGravityAcc-energy()-Z               -0.6414358 -0.6021274 -0.8278496
## tGravityAcc-iqr()-X                  -0.9770905 -0.9760540 -0.9754151
## tGravityAcc-iqr()-Y                  -0.9758223 -0.9649867 -0.9677166
## tGravityAcc-iqr()-Z                  -0.9621656 -0.9504980 -0.9482111
## tGravityAcc-entropy()-X              -0.7909282 -0.6881099 -0.7816531
## tGravityAcc-entropy()-Y              -0.9200428 -0.9261524 -0.9056611
## tGravityAcc-entropy()-Z              -0.8429871 -0.8672043 -0.4704234
## tGravityAcc-arCoeff()-X,1            -0.4651446 -0.4954534 -0.4940950
## tGravityAcc-arCoeff()-X,2             0.5048707  0.5332144  0.5322024
## tGravityAcc-arCoeff()-X,3            -0.5439597 -0.5703621 -0.5697951
## tGravityAcc-arCoeff()-X,4             0.5824589  0.6069514  0.6069304
## tGravityAcc-arCoeff()-Y,1            -0.2532447 -0.4008770 -0.2715072
## tGravityAcc-arCoeff()-Y,2             0.2238086  0.3818807  0.2492721
## tGravityAcc-arCoeff()-Y,3            -0.2434551 -0.4026077 -0.2754033
## tGravityAcc-arCoeff()-Y,4             0.2832545  0.4394755  0.3211600
## tGravityAcc-arCoeff()-Z,1            -0.3681037 -0.4692692 -0.4583565
## tGravityAcc-arCoeff()-Z,2             0.4051118  0.4924378  0.4810840
## tGravityAcc-arCoeff()-Z,3            -0.4416596 -0.5151809 -0.5032740
## tGravityAcc-arCoeff()-Z,4             0.4751233  0.5347961  0.5222565
## tGravityAcc-correlation()-X,Y         0.1496348  0.5267618 -0.1234000
## tGravityAcc-correlation()-X,Z        -0.0514666 -0.0919518 -0.2885349
## tGravityAcc-correlation()-Y,Z         0.2033537 -0.1346314  0.3156760
## tBodyAccJerk-mean()-X                 0.0768320  0.0807263  0.0788382
## tBodyAccJerk-mean()-Y                 0.0061771  0.0138224  0.0090016
## tBodyAccJerk-mean()-Z                -0.0049500  0.0008242 -0.0035529
## tBodyAccJerk-std()-X                 -0.7005500 -0.6808137 -0.6234564
## tBodyAccJerk-std()-Y                 -0.6747923 -0.6516198 -0.6354998
## tBodyAccJerk-std()-Z                 -0.7836321 -0.8008706 -0.7937468
## tBodyAccJerk-mad()-X                 -0.6954695 -0.6758500 -0.6318733
## tBodyAccJerk-mad()-Y                 -0.6607366 -0.6355215 -0.6244563
## tBodyAccJerk-mad()-Z                 -0.7772497 -0.7938472 -0.7963121
## tBodyAccJerk-max()-X                 -0.7495973 -0.7384580 -0.6884993
## tBodyAccJerk-max()-Y                 -0.7960079 -0.7658959 -0.7802210
## tBodyAccJerk-max()-Z                 -0.8509938 -0.8529246 -0.8475542
## tBodyAccJerk-min()-X                  0.6859736  0.6558782  0.5804051
## tBodyAccJerk-min()-Y                  0.7351090  0.7198226  0.6718056
## tBodyAccJerk-min()-Z                  0.7548166  0.7736426  0.7425544
## tBodyAccJerk-sma()                   -0.6979997 -0.6886156 -0.6678568
## tBodyAccJerk-energy()-X              -0.8850034 -0.8755105 -0.8363599
## tBodyAccJerk-energy()-Y              -0.8694870 -0.8569619 -0.8449228
## tBodyAccJerk-energy()-Z              -0.9400668 -0.9520026 -0.9479782
## tBodyAccJerk-iqr()-X                 -0.6858168 -0.6628751 -0.6409945
## tBodyAccJerk-iqr()-Y                 -0.7158800 -0.6843747 -0.6815729
## tBodyAccJerk-iqr()-Z                 -0.7928396 -0.8007694 -0.8186825
## tBodyAccJerk-entropy()-X             -0.1744416 -0.0939226 -0.1763552
## tBodyAccJerk-entropy()-Y             -0.1989267 -0.1104393 -0.1480743
## tBodyAccJerk-entropy()-Z             -0.1971492 -0.1332573 -0.1991701
## tBodyAccJerk-arCoeff()-X,1           -0.0854414 -0.0952353 -0.0513480
## tBodyAccJerk-arCoeff()-X,2            0.1641928  0.1815763  0.1404289
## tBodyAccJerk-arCoeff()-X,3            0.0393446  0.0890967  0.0482901
## tBodyAccJerk-arCoeff()-X,4            0.1694144  0.1109838  0.1414904
## tBodyAccJerk-arCoeff()-Y,1            0.0038432 -0.1124114  0.0361173
## tBodyAccJerk-arCoeff()-Y,2            0.0923493  0.0457396  0.0795384
## tBodyAccJerk-arCoeff()-Y,3            0.2292912  0.1515175  0.1855005
## tBodyAccJerk-arCoeff()-Y,4            0.2907200  0.3293399  0.3475466
## tBodyAccJerk-arCoeff()-Z,1            0.0043911 -0.0356472  0.0773286
## tBodyAccJerk-arCoeff()-Z,2            0.0914577  0.0612390  0.0565501
## tBodyAccJerk-arCoeff()-Z,3            0.0072640 -0.0400398 -0.0303147
## tBodyAccJerk-arCoeff()-Z,4            0.1682787  0.1375326  0.1341608
## tBodyAccJerk-correlation()-X,Y       -0.1179139 -0.1388929 -0.1724238
## tBodyAccJerk-correlation()-X,Z        0.0474534  0.0454031  0.2390719
## tBodyAccJerk-correlation()-Y,Z        0.1261508  0.1033893  0.0786830
## tBodyGyro-mean()-X                   -0.0608888 -0.0644964 -0.0101832
## tBodyGyro-mean()-Y                   -0.0552178 -0.0471474 -0.0882883
## tBodyGyro-mean()-Z                    0.1089471  0.1008403  0.0881626
## tBodyGyro-std()-X                    -0.7958536 -0.7402766 -0.7346993
## tBodyGyro-std()-Y                    -0.8020487 -0.7412855 -0.6345692
## tBodyGyro-std()-Z                    -0.6741285 -0.6697897 -0.7138646
## tBodyGyro-mad()-X                    -0.7970536 -0.7500207 -0.7480222
## tBodyGyro-mad()-Y                    -0.8159761 -0.7521812 -0.6357290
## tBodyGyro-mad()-Z                    -0.6818637 -0.6714316 -0.7229271
## tBodyGyro-max()-X                    -0.7316959 -0.6487414 -0.6335551
## tBodyGyro-max()-Y                    -0.8217443 -0.7663644 -0.7491790
## tBodyGyro-max()-Z                    -0.5061991 -0.5022511 -0.5211453
## tBodyGyro-min()-X                     0.6850172  0.6298521  0.6543460
## tBodyGyro-min()-Y                     0.7780764  0.7725190  0.7427950
## tBodyGyro-min()-Z                     0.5909799  0.6148114  0.6015272
## tBodyGyro-sma()                      -0.6899065 -0.6448911 -0.6059952
## tBodyGyro-energy()-X                 -0.9273986 -0.9134091 -0.8916657
## tBodyGyro-energy()-Y                 -0.9513209 -0.9251203 -0.8441444
## tBodyGyro-energy()-Z                 -0.8758990 -0.8848490 -0.9143554
## tBodyGyro-iqr()-X                    -0.7972881 -0.7596610 -0.7746947
## tBodyGyro-iqr()-Y                    -0.8394910 -0.7753015 -0.6326105
## tBodyGyro-iqr()-Z                    -0.7245925 -0.7112127 -0.7606685
## tBodyGyro-entropy()-X                -0.2799249 -0.1317929 -0.2136072
## tBodyGyro-entropy()-Y                -0.1232051 -0.0232713 -0.2234392
## tBodyGyro-entropy()-Z                -0.1325612 -0.0807411 -0.1405738
## tBodyGyro-arCoeff()-X,1              -0.1093310 -0.2744817 -0.0906895
## tBodyGyro-arCoeff()-X,2               0.0447118  0.1723939  0.0638750
## tBodyGyro-arCoeff()-X,3               0.1985595  0.1308518  0.1751647
## tBodyGyro-arCoeff()-X,4              -0.0858382 -0.0641489 -0.0596869
## tBodyGyro-arCoeff()-Y,1              -0.0791041 -0.2704441 -0.1605593
## tBodyGyro-arCoeff()-Y,2               0.0774403  0.1976180  0.0713005
## tBodyGyro-arCoeff()-Y,3               0.0095547 -0.0467308  0.0245962
## tBodyGyro-arCoeff()-Y,4               0.1647723  0.1604136  0.2003129
## tBodyGyro-arCoeff()-Z,1              -0.0009197 -0.1506607  0.0191780
## tBodyGyro-arCoeff()-Z,2               0.0096876  0.1320450 -0.0191812
## tBodyGyro-arCoeff()-Z,3              -0.0171226 -0.0736535  0.0231991
## tBodyGyro-arCoeff()-Z,4               0.2121431  0.1976265  0.2099327
## tBodyGyro-correlation()-X,Y          -0.1988113 -0.1083359 -0.1040208
## tBodyGyro-correlation()-X,Z           0.1079043  0.1173937  0.0806216
## tBodyGyro-correlation()-Y,Z          -0.2133028 -0.0501203 -0.1308758
## tBodyGyroJerk-mean()-X               -0.0893066 -0.0881214 -0.1007078
## tBodyGyroJerk-mean()-Y               -0.0450414 -0.0447973 -0.0464322
## tBodyGyroJerk-mean()-Z               -0.0586255 -0.0607681 -0.0527860
## tBodyGyroJerk-std()-X                -0.8210758 -0.7205157 -0.7361177
## tBodyGyroJerk-std()-Y                -0.8373202 -0.8250388 -0.8536396
## tBodyGyroJerk-std()-Z                -0.7829456 -0.7697560 -0.7702213
## tBodyGyroJerk-mad()-X                -0.8186925 -0.7211376 -0.7342960
## tBodyGyroJerk-mad()-Y                -0.8448421 -0.8344695 -0.8548897
## tBodyGyroJerk-mad()-Z                -0.7879648 -0.7782129 -0.7717813
## tBodyGyroJerk-max()-X                -0.8294093 -0.7209003 -0.7633245
## tBodyGyroJerk-max()-Y                -0.8506328 -0.8451894 -0.8754878
## tBodyGyroJerk-max()-Z                -0.7736541 -0.7508442 -0.7699915
## tBodyGyroJerk-min()-X                 0.8444695  0.7437665  0.7580817
## tBodyGyroJerk-min()-Y                 0.8796505  0.8577643  0.8965629
## tBodyGyroJerk-min()-Z                 0.8446476  0.8273868  0.8251057
## tBodyGyroJerk-sma()                  -0.8248188 -0.7907207 -0.8030158
## tBodyGyroJerk-energy()-X             -0.9602163 -0.9108886 -0.9201189
## tBodyGyroJerk-energy()-Y             -0.9634379 -0.9623187 -0.9748114
## tBodyGyroJerk-energy()-Z             -0.9383346 -0.9378470 -0.9382450
## tBodyGyroJerk-iqr()-X                -0.8250511 -0.7291577 -0.7406843
## tBodyGyroJerk-iqr()-Y                -0.8553508 -0.8465469 -0.8528761
## tBodyGyroJerk-iqr()-Z                -0.8049715 -0.7995996 -0.7838473
## tBodyGyroJerk-entropy()-X            -0.1912923  0.0342894 -0.1082892
## tBodyGyroJerk-entropy()-Y            -0.1277371  0.0651625 -0.1715537
## tBodyGyroJerk-entropy()-Z            -0.1488826 -0.0001367 -0.1026672
## tBodyGyroJerk-arCoeff()-X,1           0.0305793 -0.1308763  0.0289765
## tBodyGyroJerk-arCoeff()-X,2          -0.0238200  0.0386658  0.0204541
## tBodyGyroJerk-arCoeff()-X,3           0.1989647  0.1121337  0.1844006
## tBodyGyroJerk-arCoeff()-X,4           0.1915973  0.1994961  0.2305875
## tBodyGyroJerk-arCoeff()-Y,1          -0.0580008 -0.2273590 -0.1275246
## tBodyGyroJerk-arCoeff()-Y,2           0.1698958  0.1811566  0.0761041
## tBodyGyroJerk-arCoeff()-Y,3           0.0986908  0.0420309  0.0722875
## tBodyGyroJerk-arCoeff()-Y,4           0.1593866  0.0647453  0.0868171
## tBodyGyroJerk-arCoeff()-Z,1           0.0464327 -0.1078992  0.0496560
## tBodyGyroJerk-arCoeff()-Z,2           0.0305232  0.0926303  0.0130199
## tBodyGyroJerk-arCoeff()-Z,3           0.0831482  0.0509117  0.0512655
## tBodyGyroJerk-arCoeff()-Z,4           0.0222849 -0.0119700  0.1243204
## tBodyGyroJerk-correlation()-X,Y       0.0187321  0.1166695  0.0695980
## tBodyGyroJerk-correlation()-X,Z       0.1391614  0.0770169  0.0030363
## tBodyGyroJerk-correlation()-Y,Z      -0.1372401 -0.2360379 -0.0825718
## tBodyAccMag-mean()                   -0.6279477 -0.6100309 -0.5535856
## tBodyAccMag-std()                    -0.6778742 -0.6358212 -0.5790672
## tBodyAccMag-mad()                    -0.7245704 -0.6845716 -0.6332035
## tBodyAccMag-max()                    -0.6420355 -0.6060741 -0.5533737
## tBodyAccMag-min()                    -0.8701194 -0.8678546 -0.8284571
## tBodyAccMag-sma()                    -0.6279477 -0.6100309 -0.5535856
## tBodyAccMag-energy()                 -0.8280672 -0.8194867 -0.7629561
## tBodyAccMag-iqr()                    -0.7805910 -0.7404265 -0.7005693
## tBodyAccMag-entropy()                -0.0435213  0.1434015 -0.0133068
## tBodyAccMag-arCoeff()1                0.0296172 -0.1166815  0.0213714
## tBodyAccMag-arCoeff()2               -0.0423856  0.0534296 -0.0538379
## tBodyAccMag-arCoeff()3                0.0929265  0.0577713  0.0939323
## tBodyAccMag-arCoeff()4               -0.1037916 -0.0530375 -0.0486612
## tGravityAccMag-mean()                -0.6279477 -0.6100309 -0.5535856
## tGravityAccMag-std()                 -0.6778742 -0.6358212 -0.5790672
## tGravityAccMag-mad()                 -0.7245704 -0.6845716 -0.6332035
## tGravityAccMag-max()                 -0.6420355 -0.6060741 -0.5533737
## tGravityAccMag-min()                 -0.8701194 -0.8678546 -0.8284571
## tGravityAccMag-sma()                 -0.6279477 -0.6100309 -0.5535856
## tGravityAccMag-energy()              -0.8280672 -0.8194867 -0.7629561
## tGravityAccMag-iqr()                 -0.7805910 -0.7404265 -0.7005693
## tGravityAccMag-entropy()             -0.0435213  0.1434015 -0.0133068
## tGravityAccMag-arCoeff()1             0.0296172 -0.1166815  0.0213714
## tGravityAccMag-arCoeff()2            -0.0423856  0.0534296 -0.0538379
## tGravityAccMag-arCoeff()3             0.0929265  0.0577713  0.0939323
## tGravityAccMag-arCoeff()4            -0.1037916 -0.0530375 -0.0486612
## tBodyAccJerkMag-mean()               -0.7018074 -0.6894294 -0.6645381
## tBodyAccJerkMag-std()                -0.6960034 -0.6877034 -0.6204720
## tBodyAccJerkMag-mad()                -0.7047358 -0.7035495 -0.6472088
## tBodyAccJerkMag-max()                -0.7142412 -0.6897604 -0.6280337
## tBodyAccJerkMag-min()                -0.8163911 -0.8005065 -0.7837545
## tBodyAccJerkMag-sma()                -0.7018074 -0.6894294 -0.6645381
## tBodyAccJerkMag-energy()             -0.8833721 -0.8803963 -0.8556763
## tBodyAccJerkMag-iqr()                -0.7398728 -0.7450001 -0.7159360
## tBodyAccJerkMag-entropy()            -0.1863769 -0.0859580 -0.1585360
## tBodyAccJerkMag-arCoeff()1            0.1160555  0.1101834  0.0909664
## tBodyAccJerkMag-arCoeff()2           -0.0351626 -0.0433686 -0.0564478
## tBodyAccJerkMag-arCoeff()3           -0.0893583 -0.1087993 -0.0592087
## tBodyAccJerkMag-arCoeff()4           -0.0969437 -0.0505930 -0.0447853
## tBodyGyroMag-mean()                  -0.6940160 -0.6485386 -0.6022290
## tBodyGyroMag-std()                   -0.7547133 -0.7109568 -0.6537323
## tBodyGyroMag-mad()                   -0.7324918 -0.6807075 -0.6225034
## tBodyGyroMag-max()                   -0.7780363 -0.7354577 -0.7011490
## tBodyGyroMag-min()                   -0.7823633 -0.7715736 -0.7264509
## tBodyGyroMag-sma()                   -0.6940160 -0.6485386 -0.6022290
## tBodyGyroMag-energy()                -0.8908498 -0.8683424 -0.8153430
## tBodyGyroMag-iqr()                   -0.7569265 -0.6945240 -0.6564766
## tBodyGyroMag-entropy()                0.1500399  0.3472131 -0.0001391
## tBodyGyroMag-arCoeff()1               0.0694767 -0.1262586 -0.0538060
## tBodyGyroMag-arCoeff()2              -0.1667163 -0.0012921 -0.0546548
## tBodyGyroMag-arCoeff()3               0.1841878  0.1164158  0.1276356
## tBodyGyroMag-arCoeff()4              -0.1035648 -0.0645201 -0.0762147
## tBodyGyroJerkMag-mean()              -0.8230677 -0.7892949 -0.8022939
## tBodyGyroJerkMag-std()               -0.8372129 -0.8057384 -0.8401564
## tBodyGyroJerkMag-mad()               -0.8467575 -0.8159976 -0.8468635
## tBodyGyroJerkMag-max()               -0.8440487 -0.8148099 -0.8484118
## tBodyGyroJerkMag-min()               -0.8395977 -0.8338965 -0.8257739
## tBodyGyroJerkMag-sma()               -0.8230677 -0.7892949 -0.8022939
## tBodyGyroJerkMag-energy()            -0.9592253 -0.9481807 -0.9583964
## tBodyGyroJerkMag-iqr()               -0.8542333 -0.8259982 -0.8518689
## tBodyGyroJerkMag-entropy()           -0.0497640  0.1816237 -0.0419772
## tBodyGyroJerkMag-arCoeff()1           0.3563342  0.1747419  0.2814319
## tBodyGyroJerkMag-arCoeff()2          -0.2813912 -0.1701474 -0.2188680
## tBodyGyroJerkMag-arCoeff()3          -0.0337431  0.0334948  0.0143522
## tBodyGyroJerkMag-arCoeff()4          -0.1343601 -0.1590348 -0.2086465
## fBodyAcc-mean()-X                    -0.6814548 -0.6541565 -0.5799010
## fBodyAcc-mean()-Y                    -0.6412678 -0.5849325 -0.5876863
## fBodyAcc-mean()-Z                    -0.7154829 -0.7151345 -0.6805477
## fBodyAcc-std()-X                     -0.6546594 -0.6478072 -0.5727879
## fBodyAcc-std()-Y                     -0.6495067 -0.5951105 -0.6309788
## fBodyAcc-std()-Z                     -0.6921308 -0.6957673 -0.6025509
## fBodyAcc-mad()-X                     -0.6548951 -0.6295257 -0.5479675
## fBodyAcc-mad()-Y                     -0.6373681 -0.5664447 -0.6069820
## fBodyAcc-mad()-Z                     -0.6941663 -0.6913888 -0.6463597
## fBodyAcc-max()-X                     -0.6897574 -0.6948737 -0.6461823
## fBodyAcc-max()-Y                     -0.7590926 -0.7374856 -0.7475733
## fBodyAcc-max()-Z                     -0.7201622 -0.7387523 -0.5991757
## fBodyAcc-min()-X                     -0.8801462 -0.8561095 -0.8359796
## fBodyAcc-min()-Y                     -0.9115108 -0.8994550 -0.8769328
## fBodyAcc-min()-Z                     -0.9302726 -0.9255577 -0.9188858
## fBodyAcc-sma()                       -0.6341097 -0.6027737 -0.5539592
## fBodyAcc-energy()-X                  -0.8521313 -0.8469383 -0.7908018
## fBodyAcc-energy()-Y                  -0.8421230 -0.8056931 -0.8218593
## fBodyAcc-energy()-Z                  -0.8825991 -0.8973092 -0.8215767
## fBodyAcc-iqr()-X                     -0.7059216 -0.6755184 -0.6254571
## fBodyAcc-iqr()-Y                     -0.7053231 -0.6689893 -0.6729795
## fBodyAcc-iqr()-Z                     -0.7828048 -0.7821351 -0.7857540
## fBodyAcc-entropy()-X                 -0.3172766 -0.2416983 -0.2481144
## fBodyAcc-entropy()-Y                 -0.3137012 -0.1933483 -0.2708511
## fBodyAcc-entropy()-Z                 -0.3086218 -0.2207977 -0.2917498
## fBodyAcc-maxInds-X                   -0.7024708 -0.7691268 -0.7089272
## fBodyAcc-maxInds-Y                   -0.7475177 -0.8291449 -0.7505814
## fBodyAcc-maxInds-Z                   -0.7784370 -0.8397100 -0.8544275
## fBodyAcc-meanFreq()-X                -0.1703043 -0.2178947 -0.1653508
## fBodyAcc-meanFreq()-Y                 0.0959656 -0.0652270  0.1280770
## fBodyAcc-meanFreq()-Z                 0.1332137  0.0189879  0.0886271
## fBodyAcc-skewness()-X                -0.1752855 -0.1609981 -0.2356511
## fBodyAcc-kurtosis()-X                -0.4993875 -0.4893653 -0.5900426
## fBodyAcc-skewness()-Y                -0.3513702 -0.2451833 -0.3683194
## fBodyAcc-kurtosis()-Y                -0.6599805 -0.5646393 -0.6707463
## fBodyAcc-skewness()-Z                -0.3671779 -0.2890716 -0.3029831
## fBodyAcc-kurtosis()-Z                -0.5980716 -0.5416036 -0.5386203
## fBodyAcc-bandsEnergy()-1,8           -0.8427378 -0.8366704 -0.7748177
## fBodyAcc-bandsEnergy()-9,16          -0.9033388 -0.9061499 -0.8773139
## fBodyAcc-bandsEnergy()-17,24         -0.9057855 -0.8929777 -0.8527065
## fBodyAcc-bandsEnergy()-25,32         -0.9244365 -0.9028704 -0.8699290
## fBodyAcc-bandsEnergy()-33,40         -0.9308929 -0.9218893 -0.8889584
## fBodyAcc-bandsEnergy()-41,48         -0.9313130 -0.9209125 -0.8943800
## fBodyAcc-bandsEnergy()-49,56         -0.9565664 -0.9513141 -0.9254475
## fBodyAcc-bandsEnergy()-57,64         -0.9624248 -0.9542932 -0.9340655
## fBodyAcc-bandsEnergy()-1,16          -0.8459779 -0.8419611 -0.7840852
## fBodyAcc-bandsEnergy()-17,32         -0.8966061 -0.8791783 -0.8347891
## fBodyAcc-bandsEnergy()-33,48         -0.9310649 -0.9215377 -0.8910049
## fBodyAcc-bandsEnergy()-49,64         -0.9585300 -0.9523127 -0.9283360
## fBodyAcc-bandsEnergy()-1,24          -0.8502304 -0.8455888 -0.7889641
## fBodyAcc-bandsEnergy()-25,48         -0.9129091 -0.8929315 -0.8547297
## fBodyAcc-bandsEnergy()-1,8.1         -0.8623431 -0.8477980 -0.8588485
## fBodyAcc-bandsEnergy()-9,16.1        -0.9290186 -0.8595022 -0.8944552
## fBodyAcc-bandsEnergy()-17,24.1       -0.8605332 -0.8844589 -0.8713505
## fBodyAcc-bandsEnergy()-25,32.1       -0.9033720 -0.9359595 -0.8632537
## fBodyAcc-bandsEnergy()-33,40.1       -0.9293038 -0.9251083 -0.8599631
## fBodyAcc-bandsEnergy()-41,48.1       -0.9227404 -0.9018941 -0.8682302
## fBodyAcc-bandsEnergy()-49,56.1       -0.9350427 -0.9189096 -0.8957939
## fBodyAcc-bandsEnergy()-57,64.1       -0.9766805 -0.9625411 -0.9511767
## fBodyAcc-bandsEnergy()-1,16.1        -0.8580208 -0.8111123 -0.8375616
## fBodyAcc-bandsEnergy()-17,32.1       -0.8373119 -0.8698505 -0.8361683
## fBodyAcc-bandsEnergy()-33,48.1       -0.9187112 -0.9076460 -0.8471091
## fBodyAcc-bandsEnergy()-49,64.1       -0.9505054 -0.9346894 -0.9157821
## fBodyAcc-bandsEnergy()-1,24.1        -0.8456496 -0.8070006 -0.8288601
## fBodyAcc-bandsEnergy()-25,48.1       -0.9032448 -0.9239118 -0.8512892
## fBodyAcc-bandsEnergy()-1,8.2         -0.9029661 -0.9131304 -0.8092361
## fBodyAcc-bandsEnergy()-9,16.2        -0.9196003 -0.9249528 -0.9341005
## fBodyAcc-bandsEnergy()-17,24.2       -0.9292645 -0.9540679 -0.9640427
## fBodyAcc-bandsEnergy()-25,32.2       -0.9707872 -0.9725506 -0.9616187
## fBodyAcc-bandsEnergy()-33,40.2       -0.9690680 -0.9718505 -0.9527980
## fBodyAcc-bandsEnergy()-41,48.2       -0.9475262 -0.9499613 -0.9380863
## fBodyAcc-bandsEnergy()-49,56.2       -0.9519053 -0.9560475 -0.9446847
## fBodyAcc-bandsEnergy()-57,64.2       -0.9646959 -0.9734289 -0.9630482
## fBodyAcc-bandsEnergy()-1,16.2        -0.8965361 -0.9063875 -0.8262830
## fBodyAcc-bandsEnergy()-17,32.2       -0.9443388 -0.9607961 -0.9631974
## fBodyAcc-bandsEnergy()-33,48.2       -0.9613152 -0.9642048 -0.9456673
## fBodyAcc-bandsEnergy()-49,64.2       -0.9553402 -0.9608941 -0.9497291
## fBodyAcc-bandsEnergy()-1,24.2        -0.8855524 -0.9002058 -0.8250341
## fBodyAcc-bandsEnergy()-25,48.2       -0.9681027 -0.9701872 -0.9570864
## fBodyAccJerk-mean()-X                -0.7145547 -0.6867238 -0.6298759
## fBodyAccJerk-mean()-Y                -0.6945097 -0.6707181 -0.6412891
## fBodyAccJerk-mean()-Z                -0.7685745 -0.7790617 -0.7684339
## fBodyAccJerk-std()-X                 -0.7128580 -0.7040734 -0.6515642
## fBodyAccJerk-std()-Y                 -0.6757448 -0.6548559 -0.6555261
## fBodyAccJerk-std()-Z                 -0.7973034 -0.8217155 -0.8182928
## fBodyAccJerk-mad()-X                 -0.6653496 -0.6410887 -0.5776030
## fBodyAccJerk-mad()-Y                 -0.6914159 -0.6682893 -0.6532856
## fBodyAccJerk-mad()-Z                 -0.7865115 -0.8043611 -0.7975199
## fBodyAccJerk-max()-X                 -0.7438033 -0.7617967 -0.7294233
## fBodyAccJerk-max()-Y                 -0.7219285 -0.7175226 -0.7288482
## fBodyAccJerk-max()-Z                 -0.8088726 -0.8425056 -0.8434880
## fBodyAccJerk-min()-X                 -0.9093701 -0.8785903 -0.8695774
## fBodyAccJerk-min()-Y                 -0.8875895 -0.8729382 -0.8631022
## fBodyAccJerk-min()-Z                 -0.8887048 -0.8849923 -0.9049240
## fBodyAccJerk-sma()                   -0.6786059 -0.6617632 -0.6213663
## fBodyAccJerk-energy()-X              -0.8848760 -0.8753698 -0.8362004
## fBodyAccJerk-energy()-Y              -0.8695217 -0.8570327 -0.8450106
## fBodyAccJerk-energy()-Z              -0.9400900 -0.9520210 -0.9480020
## fBodyAccJerk-iqr()-X                 -0.6958867 -0.6567015 -0.5998765
## fBodyAccJerk-iqr()-Y                 -0.7723968 -0.7593729 -0.7185645
## fBodyAccJerk-iqr()-Z                 -0.7953443 -0.7990220 -0.7882474
## fBodyAccJerk-entropy()-X             -0.3723873 -0.3238617 -0.2847316
## fBodyAccJerk-entropy()-Y             -0.3807987 -0.3126371 -0.3188423
## fBodyAccJerk-entropy()-Z             -0.4446818 -0.4067335 -0.4267403
## fBodyAccJerk-maxInds-X               -0.4614894 -0.3864921 -0.4640698
## fBodyAccJerk-maxInds-Y               -0.3125532 -0.4231414 -0.3240698
## fBodyAccJerk-maxInds-Z               -0.3184043 -0.3624084 -0.2898837
## fBodyAccJerk-meanFreq()-X            -0.0104617 -0.0342097  0.0107764
## fBodyAccJerk-meanFreq()-Y            -0.1159221 -0.2775631 -0.0815611
## fBodyAccJerk-meanFreq()-Z            -0.0681592 -0.1260610 -0.0095265
## fBodyAccJerk-skewness()-X            -0.2931708 -0.3664098 -0.3947956
## fBodyAccJerk-kurtosis()-X            -0.6794387 -0.7560475 -0.7706994
## fBodyAccJerk-skewness()-Y            -0.3977469 -0.3935634 -0.4618062
## fBodyAccJerk-kurtosis()-Y            -0.8109682 -0.8217651 -0.8605195
## fBodyAccJerk-skewness()-Z            -0.4690157 -0.5250038 -0.5525572
## fBodyAccJerk-kurtosis()-Z            -0.7975012 -0.8366509 -0.8554282
## fBodyAccJerk-bandsEnergy()-1,8       -0.8898518 -0.8851725 -0.8448933
## fBodyAccJerk-bandsEnergy()-9,16      -0.9055595 -0.9060984 -0.8846823
## fBodyAccJerk-bandsEnergy()-17,24     -0.9180710 -0.9045579 -0.8734435
## fBodyAccJerk-bandsEnergy()-25,32     -0.9268455 -0.9086217 -0.8776240
## fBodyAccJerk-bandsEnergy()-33,40     -0.9380114 -0.9313551 -0.9004393
## fBodyAccJerk-bandsEnergy()-41,48     -0.9256462 -0.9164294 -0.8861424
## fBodyAccJerk-bandsEnergy()-49,56     -0.9579540 -0.9515287 -0.9321573
## fBodyAccJerk-bandsEnergy()-57,64     -0.9893639 -0.9845467 -0.9829304
## fBodyAccJerk-bandsEnergy()-1,16      -0.8902457 -0.8885006 -0.8567753
## fBodyAccJerk-bandsEnergy()-17,32     -0.9028199 -0.8840813 -0.8457567
## fBodyAccJerk-bandsEnergy()-33,48     -0.9277765 -0.9195124 -0.8862823
## fBodyAccJerk-bandsEnergy()-49,64     -0.9566259 -0.9493806 -0.9300322
## fBodyAccJerk-bandsEnergy()-1,24      -0.8807876 -0.8741912 -0.8368695
## fBodyAccJerk-bandsEnergy()-25,48     -0.8974692 -0.8784617 -0.8332459
## fBodyAccJerk-bandsEnergy()-1,8.1     -0.9104210 -0.8837718 -0.8969201
## fBodyAccJerk-bandsEnergy()-9,16.1    -0.9321370 -0.8728240 -0.9125240
## fBodyAccJerk-bandsEnergy()-17,24.1   -0.8282339 -0.8710803 -0.8435594
## fBodyAccJerk-bandsEnergy()-25,32.1   -0.9089357 -0.9413316 -0.8674866
## fBodyAccJerk-bandsEnergy()-33,40.1   -0.9391170 -0.9378269 -0.8808068
## fBodyAccJerk-bandsEnergy()-41,48.1   -0.9120949 -0.8992478 -0.8585092
## fBodyAccJerk-bandsEnergy()-49,56.1   -0.9404402 -0.9294027 -0.9154793
## fBodyAccJerk-bandsEnergy()-57,64.1   -0.9718085 -0.9787094 -0.9677745
## fBodyAccJerk-bandsEnergy()-1,16.1    -0.9173696 -0.8573048 -0.8964039
## fBodyAccJerk-bandsEnergy()-17,32.1   -0.8317350 -0.8782743 -0.8233761
## fBodyAccJerk-bandsEnergy()-33,48.1   -0.9129756 -0.9064394 -0.8426534
## fBodyAccJerk-bandsEnergy()-49,64.1   -0.9444013 -0.9356268 -0.9220804
## fBodyAccJerk-bandsEnergy()-1,24.1    -0.8642624 -0.8394412 -0.8557614
## fBodyAccJerk-bandsEnergy()-25,48.1   -0.9092932 -0.9270966 -0.8561418
## fBodyAccJerk-bandsEnergy()-1,8.2     -0.9084903 -0.9336770 -0.9149067
## fBodyAccJerk-bandsEnergy()-9,16.2    -0.9212903 -0.9317493 -0.9392202
## fBodyAccJerk-bandsEnergy()-17,24.2   -0.9333765 -0.9564018 -0.9650397
## fBodyAccJerk-bandsEnergy()-25,32.2   -0.9721326 -0.9726709 -0.9617398
## fBodyAccJerk-bandsEnergy()-33,40.2   -0.9717875 -0.9742638 -0.9569964
## fBodyAccJerk-bandsEnergy()-41,48.2   -0.9513868 -0.9521118 -0.9428093
## fBodyAccJerk-bandsEnergy()-49,56.2   -0.9427082 -0.9440382 -0.9357824
## fBodyAccJerk-bandsEnergy()-57,64.2   -0.9693141 -0.9770498 -0.9858004
## fBodyAccJerk-bandsEnergy()-1,16.2    -0.9001934 -0.9180856 -0.9178134
## fBodyAccJerk-bandsEnergy()-17,32.2   -0.9523543 -0.9643853 -0.9634552
## fBodyAccJerk-bandsEnergy()-33,48.2   -0.9637390 -0.9658519 -0.9498349
## fBodyAccJerk-bandsEnergy()-49,64.2   -0.9421239 -0.9442719 -0.9374403
## fBodyAccJerk-bandsEnergy()-1,24.2    -0.9101325 -0.9338447 -0.9396435
## fBodyAccJerk-bandsEnergy()-25,48.2   -0.9688607 -0.9700177 -0.9570883
## fBodyGyro-mean()-X                   -0.7685057 -0.6743567 -0.6857474
## fBodyGyro-mean()-Y                   -0.7954340 -0.7470679 -0.7359723
## fBodyGyro-mean()-Z                   -0.7027885 -0.6735139 -0.6892214
## fBodyGyro-std()-X                    -0.8062884 -0.7620310 -0.7525678
## fBodyGyro-std()-Y                    -0.8087918 -0.7408195 -0.5888580
## fBodyGyro-std()-Z                    -0.6971473 -0.7002913 -0.7491632
## fBodyGyro-mad()-X                    -0.7804489 -0.6933557 -0.7054103
## fBodyGyro-mad()-Y                    -0.8173628 -0.7541275 -0.7076966
## fBodyGyro-mad()-Z                    -0.6968906 -0.6689181 -0.6995069
## fBodyGyro-max()-X                    -0.7957763 -0.7774874 -0.7498324
## fBodyGyro-max()-Y                    -0.8542725 -0.8022063 -0.5993382
## fBodyGyro-max()-Z                    -0.7272478 -0.7503077 -0.8073943
## fBodyGyro-min()-X                    -0.9539890 -0.9369008 -0.9369966
## fBodyGyro-min()-Y                    -0.9215768 -0.9190660 -0.9130047
## fBodyGyro-min()-Z                    -0.9282065 -0.9146700 -0.9152399
## fBodyGyro-sma()                      -0.7506996 -0.6869233 -0.6897969
## fBodyGyro-energy()-X                 -0.9463514 -0.9292005 -0.9079038
## fBodyGyro-energy()-Y                 -0.9529915 -0.9276285 -0.8432868
## fBodyGyro-energy()-Z                 -0.8753703 -0.8812481 -0.9113798
## fBodyGyro-iqr()-X                    -0.8011915 -0.6982604 -0.7162778
## fBodyGyro-iqr()-Y                    -0.8214895 -0.7758556 -0.8438626
## fBodyGyro-iqr()-Z                    -0.7606161 -0.7161585 -0.7266401
## fBodyGyro-entropy()-X                -0.2561323 -0.0373740 -0.1911458
## fBodyGyro-entropy()-Y                -0.1878362 -0.0203529 -0.2392716
## fBodyGyro-entropy()-Z                -0.2778197 -0.1459946 -0.2275793
## fBodyGyro-maxInds-X                  -0.8781915 -0.8719023 -0.8362403
## fBodyGyro-maxInds-Y                  -0.7421071 -0.8763722 -0.8555889
## fBodyGyro-maxInds-Z                  -0.7925532 -0.7894927 -0.7973136
## fBodyGyro-meanFreq()-X               -0.0891654 -0.1516443  0.0020104
## fBodyGyro-meanFreq()-Y               -0.0526593 -0.2706132 -0.2539400
## fBodyGyro-meanFreq()-Z               -0.0070833 -0.0896917  0.0203516
## fBodyGyro-skewness()-X               -0.1470259 -0.2177340 -0.2618330
## fBodyGyro-kurtosis()-X               -0.4639054 -0.5393809 -0.5654091
## fBodyGyro-skewness()-Y               -0.2615380 -0.2302369 -0.0435102
## fBodyGyro-kurtosis()-Y               -0.6165687 -0.6029248 -0.3813740
## fBodyGyro-skewness()-Z               -0.0947995 -0.1898580 -0.1985671
## fBodyGyro-kurtosis()-Z               -0.3817459 -0.4968816 -0.5056561
## fBodyGyro-bandsEnergy()-1,8          -0.9510481 -0.9467816 -0.9194291
## fBodyGyro-bandsEnergy()-9,16         -0.9624912 -0.8848801 -0.9143328
## fBodyGyro-bandsEnergy()-17,24        -0.9583071 -0.9335022 -0.9343344
## fBodyGyro-bandsEnergy()-25,32        -0.9810248 -0.9632229 -0.9538753
## fBodyGyro-bandsEnergy()-33,40        -0.9697437 -0.9506255 -0.9306329
## fBodyGyro-bandsEnergy()-41,48        -0.9682893 -0.9468290 -0.9492598
## fBodyGyro-bandsEnergy()-49,56        -0.9784935 -0.9634426 -0.9662144
## fBodyGyro-bandsEnergy()-57,64        -0.9853883 -0.9764161 -0.9806375
## fBodyGyro-bandsEnergy()-1,16         -0.9484448 -0.9330909 -0.9116480
## fBodyGyro-bandsEnergy()-17,32        -0.9587247 -0.9315097 -0.9283651
## fBodyGyro-bandsEnergy()-33,48        -0.9661102 -0.9441156 -0.9312433
## fBodyGyro-bandsEnergy()-49,64        -0.9815443 -0.9691832 -0.9725964
## fBodyGyro-bandsEnergy()-1,24         -0.9470535 -0.9306091 -0.9095794
## fBodyGyro-bandsEnergy()-25,48        -0.9765131 -0.9573065 -0.9468393
## fBodyGyro-bandsEnergy()-1,8.1        -0.9611261 -0.9276576 -0.7508429
## fBodyGyro-bandsEnergy()-9,16.1       -0.9776644 -0.9642886 -0.9776269
## fBodyGyro-bandsEnergy()-17,24.1      -0.9817149 -0.9789350 -0.9926743
## fBodyGyro-bandsEnergy()-25,32.1      -0.9732229 -0.9837018 -0.9907025
## fBodyGyro-bandsEnergy()-33,40.1      -0.9774843 -0.9840209 -0.9911530
## fBodyGyro-bandsEnergy()-41,48.1      -0.9641225 -0.9678615 -0.9770461
## fBodyGyro-bandsEnergy()-49,56.1      -0.9686294 -0.9647528 -0.9725055
## fBodyGyro-bandsEnergy()-57,64.1      -0.9884606 -0.9842189 -0.9793919
## fBodyGyro-bandsEnergy()-1,16.1       -0.9592997 -0.9280652 -0.8176839
## fBodyGyro-bandsEnergy()-17,32.1      -0.9747891 -0.9753593 -0.9903326
## fBodyGyro-bandsEnergy()-33,48.1      -0.9745105 -0.9805393 -0.9881658
## fBodyGyro-bandsEnergy()-49,64.1      -0.9729535 -0.9683911 -0.9717476
## fBodyGyro-bandsEnergy()-1,24.1       -0.9534273 -0.9230951 -0.8272305
## fBodyGyro-bandsEnergy()-25,48.1      -0.9715506 -0.9814464 -0.9891863
## fBodyGyro-bandsEnergy()-1,8.2        -0.8911292 -0.8991591 -0.9339566
## fBodyGyro-bandsEnergy()-9,16.2       -0.9609985 -0.9594180 -0.9489308
## fBodyGyro-bandsEnergy()-17,24.2      -0.9547158 -0.9449201 -0.9554446
## fBodyGyro-bandsEnergy()-25,32.2      -0.9754524 -0.9752910 -0.9685471
## fBodyGyro-bandsEnergy()-33,40.2      -0.9755942 -0.9819425 -0.9747752
## fBodyGyro-bandsEnergy()-41,48.2      -0.9709709 -0.9731737 -0.9649967
## fBodyGyro-bandsEnergy()-49,56.2      -0.9689813 -0.9652306 -0.9599762
## fBodyGyro-bandsEnergy()-57,64.2      -0.9817797 -0.9753875 -0.9768347
## fBodyGyro-bandsEnergy()-1,16.2       -0.8833584 -0.8904686 -0.9200618
## fBodyGyro-bandsEnergy()-17,32.2      -0.9449374 -0.9355182 -0.9422897
## fBodyGyro-bandsEnergy()-33,48.2      -0.9742676 -0.9795209 -0.9720560
## fBodyGyro-bandsEnergy()-49,64.2      -0.9745458 -0.9696467 -0.9673059
## fBodyGyro-bandsEnergy()-1,24.2       -0.8778241 -0.8835846 -0.9144528
## fBodyGyro-bandsEnergy()-25,48.2      -0.9750867 -0.9766053 -0.9696377
## fBodyAccMag-mean()                   -0.6671858 -0.6287632 -0.5892940
## fBodyAccMag-std()                    -0.7348831 -0.6969940 -0.6393142
## fBodyAccMag-mad()                    -0.6824177 -0.6348091 -0.5877597
## fBodyAccMag-max()                    -0.8127272 -0.7857300 -0.7249796
## fBodyAccMag-min()                    -0.9153224 -0.9065115 -0.9063864
## fBodyAccMag-sma()                    -0.6671858 -0.6287632 -0.5892940
## fBodyAccMag-energy()                 -0.8694380 -0.8485753 -0.7984880
## fBodyAccMag-iqr()                    -0.7512061 -0.7172328 -0.7067141
## fBodyAccMag-entropy()                -0.3330916 -0.2092960 -0.2699427
## fBodyAccMag-maxInds                  -0.6999266 -0.7681892 -0.7129110
## fBodyAccMag-meanFreq()                0.1917813  0.0179949  0.1627653
## fBodyAccMag-skewness()               -0.4333133 -0.3230024 -0.4162518
## fBodyAccMag-kurtosis()               -0.6978278 -0.6146264 -0.6845311
## fBodyBodyAccJerkMag-mean()           -0.6885728 -0.6754287 -0.6098799
## fBodyBodyAccJerkMag-std()            -0.7075314 -0.7064158 -0.6364345
## fBodyBodyAccJerkMag-mad()            -0.6840953 -0.6817580 -0.5959713
## fBodyBodyAccJerkMag-max()            -0.7421147 -0.7421547 -0.7003654
## fBodyBodyAccJerkMag-min()            -0.8195910 -0.8244560 -0.8005113
## fBodyBodyAccJerkMag-sma()            -0.6885728 -0.6754287 -0.6098799
## fBodyBodyAccJerkMag-energy()         -0.8821193 -0.8829672 -0.8325685
## fBodyBodyAccJerkMag-iqr()            -0.7344901 -0.7302056 -0.6690284
## fBodyBodyAccJerkMag-entropy()        -0.4460325 -0.4016570 -0.3627161
## fBodyBodyAccJerkMag-maxInds          -0.8559608 -0.8988615 -0.8624031
## fBodyBodyAccJerkMag-meanFreq()        0.2467422  0.1736104  0.2274508
## fBodyBodyAccJerkMag-skewness()       -0.3426200 -0.2946482 -0.4249405
## fBodyBodyAccJerkMag-kurtosis()       -0.6316413 -0.6125220 -0.7219683
## fBodyBodyGyroMag-mean()              -0.7859536 -0.7379081 -0.7220184
## fBodyBodyGyroMag-std()               -0.7778104 -0.7437846 -0.6714543
## fBodyBodyGyroMag-mad()               -0.7775862 -0.7186111 -0.6647091
## fBodyBodyGyroMag-max()               -0.7971852 -0.7801983 -0.7135355
## fBodyBodyGyroMag-min()               -0.9030655 -0.9147943 -0.9082946
## fBodyBodyGyroMag-sma()               -0.7859536 -0.7379081 -0.7220184
## fBodyBodyGyroMag-energy()            -0.9285054 -0.9175093 -0.8605122
## fBodyBodyGyroMag-iqr()               -0.8243702 -0.7449048 -0.7582851
## fBodyBodyGyroMag-entropy()           -0.2580820 -0.0505363 -0.2137630
## fBodyBodyGyroMag-maxInds             -0.8690671 -0.9007921 -0.8704532
## fBodyBodyGyroMag-meanFreq()           0.0114867 -0.1229998 -0.0446469
## fBodyBodyGyroMag-skewness()          -0.2270743 -0.3006782 -0.3057916
## fBodyBodyGyroMag-kurtosis()          -0.5396754 -0.6211676 -0.6109081
## fBodyBodyGyroJerkMag-mean()          -0.8375860 -0.8068822 -0.8404642
## fBodyBodyGyroJerkMag-std()           -0.8482600 -0.8184485 -0.8514624
## fBodyBodyGyroJerkMag-mad()           -0.8336879 -0.8014810 -0.8360454
## fBodyBodyGyroJerkMag-max()           -0.8589768 -0.8361676 -0.8738354
## fBodyBodyGyroJerkMag-min()           -0.9073378 -0.8864218 -0.9049329
## fBodyBodyGyroJerkMag-sma()           -0.8375860 -0.8068822 -0.8404642
## fBodyBodyGyroJerkMag-energy()        -0.9639170 -0.9563096 -0.9703621
## fBodyBodyGyroJerkMag-iqr()           -0.8331036 -0.8054797 -0.8352307
## fBodyBodyGyroJerkMag-entropy()       -0.4262272 -0.2699304 -0.4123327
## fBodyBodyGyroJerkMag-maxInds         -0.8753799 -0.9232112 -0.8446844
## fBodyBodyGyroJerkMag-meanFreq()       0.2036850 -0.0020092  0.2124341
## fBodyBodyGyroJerkMag-skewness()      -0.3588349 -0.2790549 -0.4431098
## fBodyBodyGyroJerkMag-kurtosis()      -0.6579910 -0.6209423 -0.7381394
## angle(tBodyAccMean,gravity)           0.0010276  0.0051397  0.0084320
## angle(tBodyAccJerkMean),gravityMean)  0.0165222 -0.0090114 -0.0044513
## angle(tBodyGyroMean,gravityMean)      0.0551371  0.0480755 -0.0431070
## angle(tBodyGyroJerkMean,gravityMean) -0.0548552 -0.0015049 -0.0009468
## angle(X,gravityMean)                 -0.4642141 -0.4373694 -0.5607222
## angle(Y,gravityMean)                  0.0548381  0.1827437 -0.0159365
## angle(Z,gravityMean)                 -0.0984577  0.0624075 -0.1310568
##                                      subject_30
## tBodyAcc-mean()-X                     0.2763058
## tBodyAcc-mean()-Y                    -0.0175856
## tBodyAcc-mean()-Z                    -0.1058936
## tBodyAcc-std()-X                     -0.6158908
## tBodyAcc-std()-Y                     -0.5190474
## tBodyAcc-std()-Z                     -0.5226433
## tBodyAcc-mad()-X                     -0.6519641
## tBodyAcc-mad()-Y                     -0.5331076
## tBodyAcc-mad()-Z                     -0.5108983
## tBodyAcc-max()-X                     -0.4157876
## tBodyAcc-max()-Y                     -0.3057758
## tBodyAcc-max()-Z                     -0.5034790
## tBodyAcc-min()-X                      0.5454269
## tBodyAcc-min()-Y                      0.4120239
## tBodyAcc-min()-Z                      0.5668373
## tBodyAcc-sma()                       -0.5344890
## tBodyAcc-energy()-X                  -0.8512369
## tBodyAcc-energy()-Y                  -0.9184470
## tBodyAcc-energy()-Z                  -0.8069710
## tBodyAcc-iqr()-X                     -0.7320056
## tBodyAcc-iqr()-Y                     -0.6439541
## tBodyAcc-iqr()-Z                     -0.5085343
## tBodyAcc-entropy()-X                 -0.1202457
## tBodyAcc-entropy()-Y                 -0.1164277
## tBodyAcc-entropy()-Z                 -0.1554481
## tBodyAcc-arCoeff()-X,1               -0.1769264
## tBodyAcc-arCoeff()-X,2                0.1302406
## tBodyAcc-arCoeff()-X,3               -0.0778015
## tBodyAcc-arCoeff()-X,4                0.2122826
## tBodyAcc-arCoeff()-Y,1               -0.0823364
## tBodyAcc-arCoeff()-Y,2                0.0418731
## tBodyAcc-arCoeff()-Y,3                0.1411538
## tBodyAcc-arCoeff()-Y,4                0.0356406
## tBodyAcc-arCoeff()-Z,1               -0.0156962
## tBodyAcc-arCoeff()-Z,2                0.0262894
## tBodyAcc-arCoeff()-Z,3               -0.0120748
## tBodyAcc-arCoeff()-Z,4                0.0145665
## tBodyAcc-correlation()-X,Y           -0.1434001
## tBodyAcc-correlation()-X,Z           -0.2125725
## tBodyAcc-correlation()-Y,Z           -0.0731762
## tGravityAcc-mean()-X                  0.6968582
## tGravityAcc-mean()-Y                  0.0512698
## tGravityAcc-mean()-Z                  0.1843432
## tGravityAcc-std()-X                  -0.9743191
## tGravityAcc-std()-Y                  -0.9522883
## tGravityAcc-std()-Z                  -0.9294326
## tGravityAcc-mad()-X                  -0.9753106
## tGravityAcc-mad()-Y                  -0.9537172
## tGravityAcc-mad()-Z                  -0.9312310
## tGravityAcc-max()-X                   0.6326974
## tGravityAcc-max()-Y                   0.0368179
## tGravityAcc-max()-Z                   0.1909083
## tGravityAcc-min()-X                   0.7126966
## tGravityAcc-min()-Y                   0.0627418
## tGravityAcc-min()-Z                   0.1694619
## tGravityAcc-sma()                    -0.2711525
## tGravityAcc-energy()-X                0.4903122
## tGravityAcc-energy()-Y               -0.7517691
## tGravityAcc-energy()-Z               -0.7884314
## tGravityAcc-iqr()-X                  -0.9778344
## tGravityAcc-iqr()-Y                  -0.9577243
## tGravityAcc-iqr()-Z                  -0.9364218
## tGravityAcc-entropy()-X              -0.7743309
## tGravityAcc-entropy()-Y              -0.9048547
## tGravityAcc-entropy()-Z              -0.5732200
## tGravityAcc-arCoeff()-X,1            -0.5675118
## tGravityAcc-arCoeff()-X,2             0.6044844
## tGravityAcc-arCoeff()-X,3            -0.6408037
## tGravityAcc-arCoeff()-X,4             0.6765330
## tGravityAcc-arCoeff()-Y,1            -0.4505077
## tGravityAcc-arCoeff()-Y,2             0.4385415
## tGravityAcc-arCoeff()-Y,3            -0.4633467
## tGravityAcc-arCoeff()-Y,4             0.5028561
## tGravityAcc-arCoeff()-Z,1            -0.4985175
## tGravityAcc-arCoeff()-Z,2             0.5161587
## tGravityAcc-arCoeff()-Z,3            -0.5331195
## tGravityAcc-arCoeff()-Z,4             0.5467090
## tGravityAcc-correlation()-X,Y         0.2299732
## tGravityAcc-correlation()-X,Z        -0.3500159
## tGravityAcc-correlation()-Y,Z        -0.1507812
## tBodyAccJerk-mean()-X                 0.0734799
## tBodyAccJerk-mean()-Y                 0.0073044
## tBodyAccJerk-mean()-Z                -0.0006539
## tBodyAccJerk-std()-X                 -0.6790073
## tBodyAccJerk-std()-Y                 -0.6607706
## tBodyAccJerk-std()-Z                 -0.7816445
## tBodyAccJerk-mad()-X                 -0.6925235
## tBodyAccJerk-mad()-Y                 -0.6446890
## tBodyAccJerk-mad()-Z                 -0.7808383
## tBodyAccJerk-max()-X                 -0.6936712
## tBodyAccJerk-max()-Y                 -0.7672533
## tBodyAccJerk-max()-Z                 -0.8091071
## tBodyAccJerk-min()-X                  0.6340674
## tBodyAccJerk-min()-Y                  0.7447494
## tBodyAccJerk-min()-Z                  0.7708993
## tBodyAccJerk-sma()                   -0.6935110
## tBodyAccJerk-energy()-X              -0.8946922
## tBodyAccJerk-energy()-Y              -0.8806770
## tBodyAccJerk-energy()-Z              -0.9483704
## tBodyAccJerk-iqr()-X                 -0.7076882
## tBodyAccJerk-iqr()-Y                 -0.6908543
## tBodyAccJerk-iqr()-Z                 -0.7963716
## tBodyAccJerk-entropy()-X             -0.0691079
## tBodyAccJerk-entropy()-Y             -0.0669564
## tBodyAccJerk-entropy()-Z             -0.1336411
## tBodyAccJerk-arCoeff()-X,1           -0.1820801
## tBodyAccJerk-arCoeff()-X,2            0.1363353
## tBodyAccJerk-arCoeff()-X,3           -0.0140459
## tBodyAccJerk-arCoeff()-X,4            0.1065857
## tBodyAccJerk-arCoeff()-Y,1           -0.1324455
## tBodyAccJerk-arCoeff()-Y,2            0.0333724
## tBodyAccJerk-arCoeff()-Y,3            0.0919502
## tBodyAccJerk-arCoeff()-Y,4            0.3164789
## tBodyAccJerk-arCoeff()-Z,1           -0.0561388
## tBodyAccJerk-arCoeff()-Z,2            0.0526901
## tBodyAccJerk-arCoeff()-Z,3           -0.0899375
## tBodyAccJerk-arCoeff()-Z,4            0.1217940
## tBodyAccJerk-correlation()-X,Y       -0.1281697
## tBodyAccJerk-correlation()-X,Z        0.0022959
## tBodyAccJerk-correlation()-Y,Z        0.0210015
## tBodyGyro-mean()-X                   -0.0354229
## tBodyGyro-mean()-Y                   -0.0717482
## tBodyGyro-mean()-Z                    0.0834545
## tBodyGyro-std()-X                    -0.6710058
## tBodyGyro-std()-Y                    -0.5389907
## tBodyGyro-std()-Z                    -0.5897834
## tBodyGyro-mad()-X                    -0.6763163
## tBodyGyro-mad()-Y                    -0.5432899
## tBodyGyro-mad()-Z                    -0.6195875
## tBodyGyro-max()-X                    -0.6354637
## tBodyGyro-max()-Y                    -0.6606460
## tBodyGyro-max()-Z                    -0.4945314
## tBodyGyro-min()-X                     0.6103250
## tBodyGyro-min()-Y                     0.7023967
## tBodyGyro-min()-Z                     0.4638589
## tBodyGyro-sma()                      -0.5066614
## tBodyGyro-energy()-X                 -0.8837238
## tBodyGyro-energy()-Y                 -0.7974114
## tBodyGyro-energy()-Z                 -0.8552873
## tBodyGyro-iqr()-X                    -0.6830062
## tBodyGyro-iqr()-Y                    -0.5560337
## tBodyGyro-iqr()-Z                    -0.7155705
## tBodyGyro-entropy()-X                -0.1097149
## tBodyGyro-entropy()-Y                -0.1558423
## tBodyGyro-entropy()-Z                 0.0356349
## tBodyGyro-arCoeff()-X,1              -0.2934064
## tBodyGyro-arCoeff()-X,2               0.1451779
## tBodyGyro-arCoeff()-X,3               0.1671715
## tBodyGyro-arCoeff()-X,4              -0.0826839
## tBodyGyro-arCoeff()-Y,1              -0.2961750
## tBodyGyro-arCoeff()-Y,2               0.1984934
## tBodyGyro-arCoeff()-Y,3              -0.1080143
## tBodyGyro-arCoeff()-Y,4               0.2539495
## tBodyGyro-arCoeff()-Z,1              -0.2023670
## tBodyGyro-arCoeff()-Z,2               0.1289469
## tBodyGyro-arCoeff()-Z,3              -0.0721666
## tBodyGyro-arCoeff()-Z,4               0.2668113
## tBodyGyro-correlation()-X,Y          -0.3058265
## tBodyGyro-correlation()-X,Z          -0.0668037
## tBodyGyro-correlation()-Y,Z          -0.1243784
## tBodyGyroJerk-mean()-X               -0.0926769
## tBodyGyroJerk-mean()-Y               -0.0412904
## tBodyGyroJerk-mean()-Z               -0.0493556
## tBodyGyroJerk-std()-X                -0.7806364
## tBodyGyroJerk-std()-Y                -0.7989481
## tBodyGyroJerk-std()-Z                -0.7632285
## tBodyGyroJerk-mad()-X                -0.7761346
## tBodyGyroJerk-mad()-Y                -0.8093001
## tBodyGyroJerk-mad()-Z                -0.7677344
## tBodyGyroJerk-max()-X                -0.8018501
## tBodyGyroJerk-max()-Y                -0.8218554
## tBodyGyroJerk-max()-Z                -0.7595186
## tBodyGyroJerk-min()-X                 0.8203453
## tBodyGyroJerk-min()-Y                 0.8480878
## tBodyGyroJerk-min()-Z                 0.8321099
## tBodyGyroJerk-sma()                  -0.7905792
## tBodyGyroJerk-energy()-X             -0.9496407
## tBodyGyroJerk-energy()-Y             -0.9588948
## tBodyGyroJerk-energy()-Z             -0.9442718
## tBodyGyroJerk-iqr()-X                -0.7788681
## tBodyGyroJerk-iqr()-Y                -0.8221033
## tBodyGyroJerk-iqr()-Z                -0.7829604
## tBodyGyroJerk-entropy()-X            -0.0351418
## tBodyGyroJerk-entropy()-Y            -0.0022504
## tBodyGyroJerk-entropy()-Z             0.0327257
## tBodyGyroJerk-arCoeff()-X,1          -0.1328194
## tBodyGyroJerk-arCoeff()-X,2          -0.0195935
## tBodyGyroJerk-arCoeff()-X,3           0.1163589
## tBodyGyroJerk-arCoeff()-X,4           0.1619880
## tBodyGyroJerk-arCoeff()-Y,1          -0.2547208
## tBodyGyroJerk-arCoeff()-Y,2           0.1597050
## tBodyGyroJerk-arCoeff()-Y,3          -0.0273131
## tBodyGyroJerk-arCoeff()-Y,4           0.0412405
## tBodyGyroJerk-arCoeff()-Z,1          -0.1762931
## tBodyGyroJerk-arCoeff()-Z,2           0.0420999
## tBodyGyroJerk-arCoeff()-Z,3          -0.0385499
## tBodyGyroJerk-arCoeff()-Z,4           0.0420451
## tBodyGyroJerk-correlation()-X,Y       0.0300063
## tBodyGyroJerk-correlation()-X,Z       0.0134707
## tBodyGyroJerk-correlation()-Y,Z       0.0041961
## tBodyAccMag-mean()                   -0.5381312
## tBodyAccMag-std()                    -0.5881581
## tBodyAccMag-mad()                    -0.6534407
## tBodyAccMag-max()                    -0.5292430
## tBodyAccMag-min()                    -0.8026931
## tBodyAccMag-sma()                    -0.5381312
## tBodyAccMag-energy()                 -0.7928385
## tBodyAccMag-iqr()                    -0.7343132
## tBodyAccMag-entropy()                 0.1815794
## tBodyAccMag-arCoeff()1               -0.1572098
## tBodyAccMag-arCoeff()2                0.0755087
## tBodyAccMag-arCoeff()3                0.0246006
## tBodyAccMag-arCoeff()4                0.0156357
## tGravityAccMag-mean()                -0.5381312
## tGravityAccMag-std()                 -0.5881581
## tGravityAccMag-mad()                 -0.6534407
## tGravityAccMag-max()                 -0.5292430
## tGravityAccMag-min()                 -0.8026931
## tGravityAccMag-sma()                 -0.5381312
## tGravityAccMag-energy()              -0.7928385
## tGravityAccMag-iqr()                 -0.7343132
## tGravityAccMag-entropy()              0.1815794
## tGravityAccMag-arCoeff()1            -0.1572098
## tGravityAccMag-arCoeff()2             0.0755087
## tGravityAccMag-arCoeff()3             0.0246006
## tGravityAccMag-arCoeff()4             0.0156357
## tBodyAccJerkMag-mean()               -0.6970501
## tBodyAccJerkMag-std()                -0.6589721
## tBodyAccJerkMag-mad()                -0.6857656
## tBodyAccJerkMag-max()                -0.6578106
## tBodyAccJerkMag-min()                -0.8227821
## tBodyAccJerkMag-sma()                -0.6970501
## tBodyAccJerkMag-energy()             -0.8946156
## tBodyAccJerkMag-iqr()                -0.7460024
## tBodyAccJerkMag-entropy()            -0.0294630
## tBodyAccJerkMag-arCoeff()1            0.0020616
## tBodyAccJerkMag-arCoeff()2            0.0510939
## tBodyAccJerkMag-arCoeff()3           -0.0777405
## tBodyAccJerkMag-arCoeff()4           -0.0613267
## tBodyGyroMag-mean()                  -0.5100328
## tBodyGyroMag-std()                   -0.5737794
## tBodyGyroMag-mad()                   -0.5194921
## tBodyGyroMag-max()                   -0.6372557
## tBodyGyroMag-min()                   -0.6602634
## tBodyGyroMag-sma()                   -0.5100328
## tBodyGyroMag-energy()                -0.7707278
## tBodyGyroMag-iqr()                   -0.5252116
## tBodyGyroMag-entropy()                0.1425452
## tBodyGyroMag-arCoeff()1              -0.1867404
## tBodyGyroMag-arCoeff()2               0.0422556
## tBodyGyroMag-arCoeff()3               0.0463430
## tBodyGyroMag-arCoeff()4               0.0486629
## tBodyGyroJerkMag-mean()              -0.7858709
## tBodyGyroJerkMag-std()               -0.8103985
## tBodyGyroJerkMag-mad()               -0.8232565
## tBodyGyroJerkMag-max()               -0.8180273
## tBodyGyroJerkMag-min()               -0.8106456
## tBodyGyroJerkMag-sma()               -0.7858709
## tBodyGyroJerkMag-energy()            -0.9548390
## tBodyGyroJerkMag-iqr()               -0.8331523
## tBodyGyroJerkMag-entropy()            0.1667388
## tBodyGyroJerkMag-arCoeff()1           0.1596688
## tBodyGyroJerkMag-arCoeff()2          -0.1292942
## tBodyGyroJerkMag-arCoeff()3          -0.0309402
## tBodyGyroJerkMag-arCoeff()4          -0.1422137
## fBodyAcc-mean()-X                    -0.6356501
## fBodyAcc-mean()-Y                    -0.5584900
## fBodyAcc-mean()-Z                    -0.6349585
## fBodyAcc-std()-X                     -0.6092389
## fBodyAcc-std()-Y                     -0.5313215
## fBodyAcc-std()-Z                     -0.5065704
## fBodyAcc-mad()-X                     -0.5942368
## fBodyAcc-mad()-Y                     -0.5335011
## fBodyAcc-mad()-Z                     -0.5837716
## fBodyAcc-max()-X                     -0.6607854
## fBodyAcc-max()-Y                     -0.6726271
## fBodyAcc-max()-Z                     -0.4747142
## fBodyAcc-min()-X                     -0.8751382
## fBodyAcc-min()-Y                     -0.8892092
## fBodyAcc-min()-Z                     -0.9067189
## fBodyAcc-sma()                       -0.5580711
## fBodyAcc-energy()-X                  -0.8514899
## fBodyAcc-energy()-Y                  -0.7919402
## fBodyAcc-energy()-Z                  -0.7860259
## fBodyAcc-iqr()-X                     -0.6679445
## fBodyAcc-iqr()-Y                     -0.6900526
## fBodyAcc-iqr()-Z                     -0.7639690
## fBodyAcc-entropy()-X                 -0.1498670
## fBodyAcc-entropy()-Y                 -0.1463428
## fBodyAcc-entropy()-Z                 -0.1701257
## fBodyAcc-maxInds-X                   -0.7702350
## fBodyAcc-maxInds-Y                   -0.8275022
## fBodyAcc-maxInds-Z                   -0.8917453
## fBodyAcc-meanFreq()-X                -0.3027754
## fBodyAcc-meanFreq()-Y                -0.0844209
## fBodyAcc-meanFreq()-Z                -0.0415481
## fBodyAcc-skewness()-X                -0.1835163
## fBodyAcc-kurtosis()-X                -0.5435993
## fBodyAcc-skewness()-Y                -0.2946493
## fBodyAcc-kurtosis()-Y                -0.6410127
## fBodyAcc-skewness()-Z                -0.1458322
## fBodyAcc-kurtosis()-Z                -0.3938124
## fBodyAcc-bandsEnergy()-1,8           -0.8324822
## fBodyAcc-bandsEnergy()-9,16          -0.9247341
## fBodyAcc-bandsEnergy()-17,24         -0.9211455
## fBodyAcc-bandsEnergy()-25,32         -0.9198032
## fBodyAcc-bandsEnergy()-33,40         -0.9376304
## fBodyAcc-bandsEnergy()-41,48         -0.9342182
## fBodyAcc-bandsEnergy()-49,56         -0.9596372
## fBodyAcc-bandsEnergy()-57,64         -0.9676381
## fBodyAcc-bandsEnergy()-1,16          -0.8440888
## fBodyAcc-bandsEnergy()-17,32         -0.9084031
## fBodyAcc-bandsEnergy()-33,48         -0.9363659
## fBodyAcc-bandsEnergy()-49,64         -0.9623189
## fBodyAcc-bandsEnergy()-1,24          -0.8495673
## fBodyAcc-bandsEnergy()-25,48         -0.9121516
## fBodyAcc-bandsEnergy()-1,8.1         -0.7924993
## fBodyAcc-bandsEnergy()-9,16.1        -0.9023341
## fBodyAcc-bandsEnergy()-17,24.1       -0.9113982
## fBodyAcc-bandsEnergy()-25,32.1       -0.9313895
## fBodyAcc-bandsEnergy()-33,40.1       -0.9189474
## fBodyAcc-bandsEnergy()-41,48.1       -0.9107627
## fBodyAcc-bandsEnergy()-49,56.1       -0.9259910
## fBodyAcc-bandsEnergy()-57,64.1       -0.9600831
## fBodyAcc-bandsEnergy()-1,16.1        -0.7907753
## fBodyAcc-bandsEnergy()-17,32.1       -0.8945607
## fBodyAcc-bandsEnergy()-33,48.1       -0.9065452
## fBodyAcc-bandsEnergy()-49,64.1       -0.9379748
## fBodyAcc-bandsEnergy()-1,24.1        -0.7931663
## fBodyAcc-bandsEnergy()-25,48.1       -0.9201883
## fBodyAcc-bandsEnergy()-1,8.2         -0.7678840
## fBodyAcc-bandsEnergy()-9,16.2        -0.9211969
## fBodyAcc-bandsEnergy()-17,24.2       -0.9548014
## fBodyAcc-bandsEnergy()-25,32.2       -0.9706697
## fBodyAcc-bandsEnergy()-33,40.2       -0.9644385
## fBodyAcc-bandsEnergy()-41,48.2       -0.9373864
## fBodyAcc-bandsEnergy()-49,56.2       -0.9426158
## fBodyAcc-bandsEnergy()-57,64.2       -0.9516396
## fBodyAcc-bandsEnergy()-1,16.2        -0.7890649
## fBodyAcc-bandsEnergy()-17,32.2       -0.9605825
## fBodyAcc-bandsEnergy()-33,48.2       -0.9549238
## fBodyAcc-bandsEnergy()-49,64.2       -0.9448422
## fBodyAcc-bandsEnergy()-1,24.2        -0.7872246
## fBodyAcc-bandsEnergy()-25,48.2       -0.9661962
## fBodyAccJerk-mean()-X                -0.6853078
## fBodyAccJerk-mean()-Y                -0.6716737
## fBodyAccJerk-mean()-Z                -0.7554322
## fBodyAccJerk-std()-X                 -0.7018792
## fBodyAccJerk-std()-Y                 -0.6726220
## fBodyAccJerk-std()-Z                 -0.8071849
## fBodyAccJerk-mad()-X                 -0.6341541
## fBodyAccJerk-mad()-Y                 -0.6756631
## fBodyAccJerk-mad()-Z                 -0.7842183
## fBodyAccJerk-max()-X                 -0.7697897
## fBodyAccJerk-max()-Y                 -0.7418137
## fBodyAccJerk-max()-Z                 -0.8352097
## fBodyAccJerk-min()-X                 -0.8872040
## fBodyAccJerk-min()-Y                 -0.8674751
## fBodyAccJerk-min()-Z                 -0.8966873
## fBodyAccJerk-sma()                   -0.6523156
## fBodyAccJerk-energy()-X              -0.8945678
## fBodyAccJerk-energy()-Y              -0.8807527
## fBodyAccJerk-energy()-Z              -0.9484057
## fBodyAccJerk-iqr()-X                 -0.6484980
## fBodyAccJerk-iqr()-Y                 -0.7492307
## fBodyAccJerk-iqr()-Z                 -0.7743040
## fBodyAccJerk-entropy()-X             -0.2314451
## fBodyAccJerk-entropy()-Y             -0.2619432
## fBodyAccJerk-entropy()-Z             -0.3450030
## fBodyAccJerk-maxInds-X               -0.5238642
## fBodyAccJerk-maxInds-Y               -0.4881462
## fBodyAccJerk-maxInds-Z               -0.3851697
## fBodyAccJerk-meanFreq()-X            -0.1316500
## fBodyAccJerk-meanFreq()-Y            -0.2941483
## fBodyAccJerk-meanFreq()-Z            -0.1686047
## fBodyAccJerk-skewness()-X            -0.3946840
## fBodyAccJerk-kurtosis()-X            -0.7775715
## fBodyAccJerk-skewness()-Y            -0.4209676
## fBodyAccJerk-kurtosis()-Y            -0.8427028
## fBodyAccJerk-skewness()-Z            -0.5633951
## fBodyAccJerk-kurtosis()-Z            -0.8642549
## fBodyAccJerk-bandsEnergy()-1,8       -0.8899824
## fBodyAccJerk-bandsEnergy()-9,16      -0.9227051
## fBodyAccJerk-bandsEnergy()-17,24     -0.9306978
## fBodyAccJerk-bandsEnergy()-25,32     -0.9212607
## fBodyAccJerk-bandsEnergy()-33,40     -0.9401376
## fBodyAccJerk-bandsEnergy()-41,48     -0.9252842
## fBodyAccJerk-bandsEnergy()-49,56     -0.9579428
## fBodyAccJerk-bandsEnergy()-57,64     -0.9880014
## fBodyAccJerk-bandsEnergy()-1,16      -0.9012958
## fBodyAccJerk-bandsEnergy()-17,32     -0.9103839
## fBodyAccJerk-bandsEnergy()-33,48     -0.9290556
## fBodyAccJerk-bandsEnergy()-49,64     -0.9563515
## fBodyAccJerk-bandsEnergy()-1,24      -0.8944759
## fBodyAccJerk-bandsEnergy()-25,48     -0.8942058
## fBodyAccJerk-bandsEnergy()-1,8.1     -0.8678213
## fBodyAccJerk-bandsEnergy()-9,16.1    -0.9107902
## fBodyAccJerk-bandsEnergy()-17,24.1   -0.8967119
## fBodyAccJerk-bandsEnergy()-25,32.1   -0.9349101
## fBodyAccJerk-bandsEnergy()-33,40.1   -0.9339600
## fBodyAccJerk-bandsEnergy()-41,48.1   -0.9093366
## fBodyAccJerk-bandsEnergy()-49,56.1   -0.9451428
## fBodyAccJerk-bandsEnergy()-57,64.1   -0.9767436
## fBodyAccJerk-bandsEnergy()-1,16.1    -0.8879793
## fBodyAccJerk-bandsEnergy()-17,32.1   -0.8939505
## fBodyAccJerk-bandsEnergy()-33,48.1   -0.9076022
## fBodyAccJerk-bandsEnergy()-49,64.1   -0.9491332
## fBodyAccJerk-bandsEnergy()-1,24.1    -0.8730396
## fBodyAccJerk-bandsEnergy()-25,48.1   -0.9235164
## fBodyAccJerk-bandsEnergy()-1,8.2     -0.9176474
## fBodyAccJerk-bandsEnergy()-9,16.2    -0.9228709
## fBodyAccJerk-bandsEnergy()-17,24.2   -0.9593549
## fBodyAccJerk-bandsEnergy()-25,32.2   -0.9715746
## fBodyAccJerk-bandsEnergy()-33,40.2   -0.9685771
## fBodyAccJerk-bandsEnergy()-41,48.2   -0.9441620
## fBodyAccJerk-bandsEnergy()-49,56.2   -0.9405587
## fBodyAccJerk-bandsEnergy()-57,64.2   -0.9757271
## fBodyAccJerk-bandsEnergy()-1,16.2    -0.9047972
## fBodyAccJerk-bandsEnergy()-17,32.2   -0.9653584
## fBodyAccJerk-bandsEnergy()-33,48.2   -0.9591002
## fBodyAccJerk-bandsEnergy()-49,64.2   -0.9408188
## fBodyAccJerk-bandsEnergy()-1,24.2    -0.9299766
## fBodyAccJerk-bandsEnergy()-25,48.2   -0.9666995
## fBodyGyro-mean()-X                   -0.6674182
## fBodyGyro-mean()-Y                   -0.6299107
## fBodyGyro-mean()-Z                   -0.6156993
## fBodyGyro-std()-X                    -0.6768020
## fBodyGyro-std()-Y                    -0.4963104
## fBodyGyro-std()-Z                    -0.6202534
## fBodyGyro-mad()-X                    -0.6588265
## fBodyGyro-mad()-Y                    -0.6027871
## fBodyGyro-mad()-Z                    -0.5755447
## fBodyGyro-max()-X                    -0.6394219
## fBodyGyro-max()-Y                    -0.5705652
## fBodyGyro-max()-Z                    -0.7273431
## fBodyGyro-min()-X                    -0.9232921
## fBodyGyro-min()-Y                    -0.8663477
## fBodyGyro-min()-Z                    -0.8982067
## fBodyGyro-sma()                      -0.6166939
## fBodyGyro-energy()-X                 -0.8942352
## fBodyGyro-energy()-Y                 -0.7971242
## fBodyGyro-energy()-Z                 -0.8455477
## fBodyGyro-iqr()-X                    -0.7640441
## fBodyGyro-iqr()-Y                    -0.7555746
## fBodyGyro-iqr()-Z                    -0.7312341
## fBodyGyro-entropy()-X                -0.1020808
## fBodyGyro-entropy()-Y                 0.0018771
## fBodyGyro-entropy()-Z                -0.1202731
## fBodyGyro-maxInds-X                  -0.9235857
## fBodyGyro-maxInds-Y                  -0.9002779
## fBodyGyro-maxInds-Z                  -0.8100297
## fBodyGyro-meanFreq()-X               -0.2317099
## fBodyGyro-meanFreq()-Y               -0.3611228
## fBodyGyro-meanFreq()-Z               -0.2017057
## fBodyGyro-skewness()-X                0.0070131
## fBodyGyro-kurtosis()-X               -0.3116891
## fBodyGyro-skewness()-Y               -0.1087003
## fBodyGyro-kurtosis()-Y               -0.5083848
## fBodyGyro-skewness()-Z               -0.2212017
## fBodyGyro-kurtosis()-Z               -0.5852103
## fBodyGyro-bandsEnergy()-1,8          -0.8980177
## fBodyGyro-bandsEnergy()-9,16         -0.9411327
## fBodyGyro-bandsEnergy()-17,24        -0.9536373
## fBodyGyro-bandsEnergy()-25,32        -0.9817082
## fBodyGyro-bandsEnergy()-33,40        -0.9708038
## fBodyGyro-bandsEnergy()-41,48        -0.9681723
## fBodyGyro-bandsEnergy()-49,56        -0.9701009
## fBodyGyro-bandsEnergy()-57,64        -0.9751916
## fBodyGyro-bandsEnergy()-1,16         -0.8954097
## fBodyGyro-bandsEnergy()-17,32        -0.9552474
## fBodyGyro-bandsEnergy()-33,48        -0.9667975
## fBodyGyro-bandsEnergy()-49,64        -0.9723535
## fBodyGyro-bandsEnergy()-1,24         -0.8946732
## fBodyGyro-bandsEnergy()-25,48        -0.9772051
## fBodyGyro-bandsEnergy()-1,8.1        -0.6916431
## fBodyGyro-bandsEnergy()-9,16.1       -0.9654231
## fBodyGyro-bandsEnergy()-17,24.1      -0.9830223
## fBodyGyro-bandsEnergy()-25,32.1      -0.9802737
## fBodyGyro-bandsEnergy()-33,40.1      -0.9788818
## fBodyGyro-bandsEnergy()-41,48.1      -0.9615608
## fBodyGyro-bandsEnergy()-49,56.1      -0.9540031
## fBodyGyro-bandsEnergy()-57,64.1      -0.9643953
## fBodyGyro-bandsEnergy()-1,16.1       -0.7698858
## fBodyGyro-bandsEnergy()-17,32.1      -0.9781461
## fBodyGyro-bandsEnergy()-33,48.1      -0.9751092
## fBodyGyro-bandsEnergy()-49,64.1      -0.9522462
## fBodyGyro-bandsEnergy()-1,24.1       -0.7782183
## fBodyGyro-bandsEnergy()-25,48.1      -0.9771245
## fBodyGyro-bandsEnergy()-1,8.2        -0.8608252
## fBodyGyro-bandsEnergy()-9,16.2       -0.9494295
## fBodyGyro-bandsEnergy()-17,24.2      -0.9682908
## fBodyGyro-bandsEnergy()-25,32.2      -0.9862175
## fBodyGyro-bandsEnergy()-33,40.2      -0.9825437
## fBodyGyro-bandsEnergy()-41,48.2      -0.9736762
## fBodyGyro-bandsEnergy()-49,56.2      -0.9650315
## fBodyGyro-bandsEnergy()-57,64.2      -0.9687841
## fBodyGyro-bandsEnergy()-1,16.2       -0.8506520
## fBodyGyro-bandsEnergy()-17,32.2      -0.9630934
## fBodyGyro-bandsEnergy()-33,48.2      -0.9800976
## fBodyGyro-bandsEnergy()-49,64.2      -0.9666632
## fBodyGyro-bandsEnergy()-1,24.2       -0.8470956
## fBodyGyro-bandsEnergy()-25,48.2      -0.9843206
## fBodyAccMag-mean()                   -0.6003721
## fBodyAccMag-std()                    -0.6465228
## fBodyAccMag-mad()                    -0.5786732
## fBodyAccMag-max()                    -0.7605284
## fBodyAccMag-min()                    -0.9110702
## fBodyAccMag-sma()                    -0.6003721
## fBodyAccMag-energy()                 -0.8390129
## fBodyAccMag-iqr()                    -0.7035745
## fBodyAccMag-entropy()                -0.1487092
## fBodyAccMag-maxInds                  -0.8327181
## fBodyAccMag-meanFreq()               -0.0301197
## fBodyAccMag-skewness()               -0.3843592
## fBodyAccMag-kurtosis()               -0.6870262
## fBodyBodyAccJerkMag-mean()           -0.6563397
## fBodyBodyAccJerkMag-std()            -0.6646003
## fBodyBodyAccJerkMag-mad()            -0.6392074
## fBodyBodyAccJerkMag-max()            -0.7054202
## fBodyBodyAccJerkMag-min()            -0.8305209
## fBodyBodyAccJerkMag-sma()            -0.6563397
## fBodyBodyAccJerkMag-energy()         -0.8784617
## fBodyBodyAccJerkMag-iqr()            -0.7005495
## fBodyBodyAccJerkMag-entropy()        -0.3236356
## fBodyBodyAccJerkMag-maxInds          -0.8963073
## fBodyBodyAccJerkMag-meanFreq()        0.0817046
## fBodyBodyAccJerkMag-skewness()       -0.2602617
## fBodyBodyAccJerkMag-kurtosis()       -0.5758008
## fBodyBodyGyroMag-mean()              -0.6696005
## fBodyBodyGyroMag-std()               -0.5891927
## fBodyBodyGyroMag-mad()               -0.5972032
## fBodyBodyGyroMag-max()               -0.6080752
## fBodyBodyGyroMag-min()               -0.8951941
## fBodyBodyGyroMag-sma()               -0.6696005
## fBodyBodyGyroMag-energy()            -0.8340736
## fBodyBodyGyroMag-iqr()               -0.7123341
## fBodyBodyGyroMag-entropy()           -0.0458881
## fBodyBodyGyroMag-maxInds             -0.9184575
## fBodyBodyGyroMag-meanFreq()          -0.2050946
## fBodyBodyGyroMag-skewness()          -0.1358374
## fBodyBodyGyroMag-kurtosis()          -0.4702707
## fBodyBodyGyroJerkMag-mean()          -0.8112923
## fBodyBodyGyroJerkMag-std()           -0.8228056
## fBodyBodyGyroJerkMag-mad()           -0.8039044
## fBodyBodyGyroJerkMag-max()           -0.8374693
## fBodyBodyGyroJerkMag-min()           -0.8890414
## fBodyBodyGyroJerkMag-sma()           -0.8112923
## fBodyBodyGyroJerkMag-energy()        -0.9638938
## fBodyBodyGyroJerkMag-iqr()           -0.7988081
## fBodyBodyGyroJerkMag-entropy()       -0.2573230
## fBodyBodyGyroJerkMag-maxInds         -0.9084090
## fBodyBodyGyroJerkMag-meanFreq()       0.0433051
## fBodyBodyGyroJerkMag-skewness()      -0.2811060
## fBodyBodyGyroJerkMag-kurtosis()      -0.6080083
## angle(tBodyAccMean,gravity)           0.0082934
## angle(tBodyAccJerkMean),gravityMean)  0.0170044
## angle(tBodyGyroMean,gravityMean)      0.0231790
## angle(tBodyGyroJerkMean,gravityMean) -0.0220331
## angle(X,gravityMean)                 -0.5636835
## angle(Y,gravityMean)                  0.0347384
## angle(Z,gravityMean)                 -0.1180557
```

