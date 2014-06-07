## Plot 3

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

subdata$Date <- x

sm1 <- as.character(subdata$Sub_metering_1) 
subdata$Sub_metering_1 <- as.numeric(sm1)
sm2 <- as.character(subdata$Sub_metering_2) 
subdata$Sub_metering_2 <- as.numeric(sm2)
sm3 <- as.character(subdata$Sub_metering_3) 
subdata$Sub_metering_3 <- as.numeric(sm3)

png(file = "plot3.png") 
with(subdata, plot(Date, Sub_metering_1, xlab="", ylab="", type="n"))
with(subdata, lines(Date, Sub_metering_1, xlab="", ylab="", type="l", col="black"))
with(subdata, lines(Date, Sub_metering_2, xlab="", ylab="", type="l", col="red"))
with(subdata, lines(Date, Sub_metering_3, xlab="", ylab="", type="l", col="blue"))
legend("topright", col = c("black", "red", "blue"), lty=c(1,1,1),
       legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))
title(ylab="Energy sub metering", line=2)
dev.off()
########################################################################################