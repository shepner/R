
#install/update required packages
load.fun <- function(x) {
  x <- as.character(substitute(x))
  if(isTRUE(x %in% .packages(all.available=TRUE))) {
    eval(parse(text=paste("require(", x, ")", sep="")))
  } else {
    update.packages() # recommended before installing so that dependencies are the latest version
    eval(parse(text=paste("install.packages('", x, "')", sep="")))
    eval(parse(text=paste("require(", x, ")", sep="")))
  }
}

load.fun(xlsx)
load.fun(chron)
load.fun(Rmpi)
load.fun(snowfall)

################

coln = function(x) {
  y = rbind(seq(1, ncol(x)))
  colnames(y) = colnames(x)
  rownames(y) = "col.number"
  return(y)
}

################

setwd("/Users/shepner/Downloads")
filename="BodyComp.xlsx"
page=1

data <- read.xlsx2(filename, sheetIndex=page, sheetName=NULL, startRow=1, endRow=NULL, as.data.frame=TRUE, header=TRUE, colClasses=c(
  Date="numeric", 
  Time="numeric",
  Weight..lb.="numeric",
  Neck..in.="numeric",
  Navel..in.="numeric",
  Height..in.="numeric"
))

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
#same with weight
data<-subset(data, data$Weight..lb. >= 0)

#replace the "NaN" time entries with 0
data$Time <- as.numeric(lapply(data$Time, function(x) ifelse(is.nan(x),0,x)))

#R has some very mathmatically correct but annoying rounding behaviour.  Shift everything to whole numbers to avoid when adding fractionals
#It also has some annoying (but likely mathmatically correct) behavior about in what order to perform operations so dont make assumptions
#This also doesnt work in various ways if non-numeric data is present (including NA and NaN)
data$DateTime <- ((data$Date*1e8) + (data$Time*1e8))/1e8

#convert excel time to date time format (Could be shortened but this is showing the steps)
excelorig=chron("12/30/1899") #Use this for the origin of time in excel
data$DateTime <- (excelorig + data$DateTime)
data$DateTime <- substr(as.character(data$DateTime),2,18)

#this works for just the date field
data$DateTranslate <- as.Date(data$Date, origin=excelorig)

#Converting just the time field has issues
#data$TimeTranslate <- lapply(data$Time, function(x) substr((as.POSIXct(as.Date("1970-01-01 00:00", tzone="CST6CDT"))+3600*5 + 3600*24*x), 12, 19))

################

sfInit(parallel=TRUE, cpus=5, type="MPI")

#unit conversions
data$Weight..kg.<-as.numeric(sfLapply(data$Weight..lb., function(x) { x * 0.453592 }))
data$Neck..cm.<-as.numeric(sfLapply(data$Neck..in., function(x) { x * 2.54 }))
data$Navel..cm.<-as.numeric(sfLapply(data$Navel..in., function(x) { x * 2.54 }))
data$Height..cm.<-as.numeric(sfLapply(data$Height..in., function(x) { x * 2.54 }))
data$Age<-as.numeric(sfLapply(data$DateTranslate, function(x) { (as.Date(x) - as.Date("1969-12-05")) / 365 }))

sfStop()

################

#BMI
data$BMI<-data$Weight..kg. / ((data$Height..cm./100)^2)
gender=1 # M=1, F=0


#sfInit(parallel=TRUE, cpus=4, type="MPI")


#http://www.nerdfitness.com/blog/2012/07/02/body-fat-percentage/
#http://www.leighpeele.com/body-fat-pictures-and-percentages

#bodyfat  http://www.davedraper.com/bodyfat-calculation.html
data$bf1<-((data$Weight..lb.-(((data$Weight..lb.*1.082)+94.42) - (data$Navel..in.*4.15))) * 100) / data$Weight..lb.

#bodyfat from BMI  http://en.wikipedia.org/wiki/Body_fat_percentage

data$bf2<-(1.20 * data$BMI) + (0.23 * data$Age) - (10.8 * gender) - 5.4

#US Navy bodyfat http://www.wikihow.com/Measure-Body-Fat-Using-the-US-Navy-Method
data$bf3<-(86.010*log10(data$Navel..cm. - data$Neck..cm.)) - (70.041*log10(data$Height..cm.)) + ((-(86.010-70.041)*log10(2.54)) + 36.76)

#YMCA bodyfat http://www.doithome.com/help_inside3.html
data$bf4<-((-98.42 + 4.15*data$Navel..in. - .082 * data$Weight..lb.) / data$Weight..lb.) * 100

#sfStop()

#average out the results
data$bf<-rowMeans(data[,c("bf1", "bf2", "bf3", "bf4")], na.rm=T)

################

#Determine the ideal waist size from the most recent height measurement
#Waist to Height (ideal):  45.8%
tail(data$Height..in., n=1) * .458

################

#http://forum.bodybuilding.com/showthread.php?t=121703981&p=436716771#post436716771
#Katch-McArdle:Considered the most accurate formula for those who are relatively lean. Use ONLY if you have a good estimate of your bodyfat %.
#BMR = 370 + (21.6 x LBM)
#Where LBM = [total weight (kg) x (100 - bodyfat %)]/100
#You then multiply these by an 'activity variable' to give TEE.
#This Activity Factor[/u] is the cost of living and it is BASED ON MORE THAN JUST YOUR TRAINING.
#It also includes work/lifestyle, sport & a TEF of ~15% (an average mixed diet). Average activity variables are:
#  1.2 = Sedentary (Little or no exercise + desk job)
#1.3-1.4 = Lightly Active (Little daily activity & light exercise 1-3 days a week)
#1.5-1.6 = Moderately Active (Moderately active daily life & Moderate exercise 3-5 days a week)
#1.7-1.8 = Very Active (Physically demanding lifestyle & Hard exercise or sports 6-7 days a week)
#1.9-2.0 = Extremely Active (Hard daily exercise or sports and physical job)

data$LBM..kg.<-(data$Weight..kg. * (100 - data$bf))/100
data$BMR<-370 + (21.6 * data$LBM)
data$MR=data$BMR*1.5

################

#calculate surface area
data$SurfaceArea<-sqrt(data$Height..in. * data$Weight..lb. / 3131)

################



plot(data$DateTranslate, data$Weight..lb., "date", "weight")


