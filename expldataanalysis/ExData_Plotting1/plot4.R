## Plot 1 

## Read in data
data <- read.table("./data/household_power_consumption.txt", sep=";", header=T)

## Subset data
data$Date <- as.Date(data$Date, "%d/%m/%Y")
subdata <- data[data$Date >= "2007-02-01" & data$Date <= "2007-02-02", ] 
subdata <- subdata[!is.na(subdata$Global_active_power),]
subdata <- subdata[!is.na(subdata$Voltage),]
subdata <- subdata[!is.na(subdata$Global_reactive_power),]

subdata_gap <- as.character(subdata$Global_active_power)
subdata$Global_active_power <- as.numeric(subdata_char)


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

str(subdata)
subdata$Voltage <- as.numeric(as.character(subdata$Voltage))
subdata$Global_reactive_power <- as.numeric(as.character(subdata$Global_reactive_power))


## Plot 4

png(file = "plot4.png") 
par(mfrow=c(2,2))
title(main = "Plot 4")
with(subdata, {
        plot(Date, Global_active_power, type="l", xlab="",ylab="")
        title(ylab="Global Active Power", line=3)
        
        plot(Date, Voltage, type="l", xlab="",ylab="")
        title(ylab="Voltage", line=3)
        title(xlab="datetime",line=3)
        
        plot(Date, Sub_metering_1, xlab="", ylab="", type="n")
        lines(Date, Sub_metering_1, xlab="", ylab="", type="l", col="black")
        lines(Date, Sub_metering_2, xlab="", ylab="", type="l", col="red")
        lines(Date, Sub_metering_3, xlab="", ylab="", type="l", col="blue")
        legend("topright", col = c("black", "red", "blue"), lty=c(1,1,1),
               legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), cex=1, bty = "n",
               fill="white",border="white")
        title(ylab="Energy sub metering", line=3)
        
        plot(Date, Global_reactive_power, type="l", xlab="",ylab="")
        title(ylab="Global_reactive_power", line=3)
        title(xlab="datetime",line=3)
})


dev.off()
