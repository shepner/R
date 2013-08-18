
coln = function(x) {
  y = rbind(seq(1, ncol(x)))
  colnames(y) = colnames(x)
  rownames(y) = "col.number"
  return(y)
}

################

setwd("/Users/shepner/Code/R/R")
filename="BodyComp.xlsx"
page=1

require(xlsx)
data <- read.xlsx2(filename, sheetIndex=page, sheetName=NULL, startRow=1, endRow=NULL, as.data.frame=TRUE, header=TRUE, colClasses=c(Date="numeric", Time="numeric"))

# list the column names and positions
#coln(data)

#select the 1st column to get the date values if you happen to know they are in that location
#data[,1]
#this directly selects the date column
#data$Date

#get rid of the comments as we dont need them
data$Comments <- NULL
#this would work for multiple columns
#data <- data[,!(names(data) %in% c("Comments"))]

#keep only rows with valid Dates
data<-subset(data, data$Date >= 0)

#replace the "NaN" time entries with 0
data$Time <- as.numeric(lapply(data$Time, function(x) ifelse(is.nan(x),0,x)))

#R has some very mathmatically correct but annoying rounding behaviour.  Shift everything to whole numbers to avoid when adding fractionals
#It also has some annoying (but likely mathmatically correct) behavior about in what order to perform operations so dont make assumptions
#This also doesnt work in various ways if non-numeric data is present (including NA and NaN)
data$DateTime <- ((data$Date*1e8) + (data$Time*1e8))/1e8

#convert excel time to date time format (Could be shortened but this is showing the steps)
library(chron)
data$DateTime <- (excelorig + data$DateTime)
data$DateTime <- substr(as.character(data$DateTime),2,18)

excelorig=chron("12/30/1899") #Use this for the origin of time in excel
#this works for just the date field
data$DateTranslate <- as.Date(data$Date, origin=excelorig)

#Converting just the time field has issues
#data$TimeTranslate <- lapply(data$Time, function(x) substr((as.POSIXct(as.Date("1970-01-01 00:00", tzone="CST6CDT"))+3600*5 + 3600*24*x), 12, 19))
