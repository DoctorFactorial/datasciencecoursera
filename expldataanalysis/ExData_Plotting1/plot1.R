setwd("/Users/Michael/datascience/expldataanalysis")
getwd()
## Plot 1 

## Read in data
data <- read.table("./data/household_power_consumption.txt", sep=";", header=T)

## Subset data
data$Date <- as.Date(data$Date, "%d/%m/%Y")
subdata <- data[data$Date >= "2007-02-01" & data$Date <= "2007-02-02", ] 
subdata <- subdata[!is.na(subdata$Global_active_power),]

subdata_gap <- as.character(subdata$Global_active_power)
subdata_gap <- as.numeric(subdata_gap)


png(file = "plot1.png") 
hist(subdata_gap,xlab="",ylab="", main="Global Active Power", col="red")
title(xlab="Global Active Power (kilowatts)", line=3)
title(ylab="Frequency", line=3)
dev.off()
########################################################################################

