
## Plot 2

## Read in data
data <- read.table("./data/household_power_consumption.txt", sep=";", header=T)

## Subset data
subdata <- data[data$Date >= "2007-02-01" & data$Date <= "2007-02-02", ] 
subdata <- subdata[!is.na(subdata$Global_active_power),]

subdata_gap <- as.character(subdata$Global_active_power)
subdata_gap <- as.numeric(subdata_char)

## Set x-axis
a <- subdata$Date
b <- subdata$Time
c <- paste(a, b)
x <- strptime(c, "%Y-%m-%d %H:%M:%S")

## Plot line graph
png(file = "plot2.png") 
plot(x, subdata_gap, type="l", xlab="",ylab="")
title(ylab="Global Active Power (kilowatts)", line=3)
dev.off()
########################################################################################