require(xlsx)

coln = function(x) {
  y = rbind(seq(1, ncol(x)))
  colnames(y) = colnames(x)
  rownames(y) = "col.number"
  return(y)
}

################

setwd("/Users/shepner/Code/R/Excel")
filename="BodyComp.xlsx"
page=1

data = read.xlsx2(filename, page)
coln(data)

x = 3 # Say you want columns 1-3 as factors, the rest numeric
#data = read.xlsx2(filename, page, colClasses = c( rep("character", x), rep("numeric", ncol(data)-x+1) ) )

data <- read.xlsx2(filename, sheetIndex=1, sheetName=NULL, startRow=1, endRow=NULL, as.data.frame=TRUE, header=TRUE)

filenames <- list.files(pattern=".xls")
#do.call("rbind", lapply(filenames, read.xlsx2, sheetIndex=1, colIndex=6, header=TRUE, startrow=2, FILENAMEVAR=filenames));

#lapply(filenames, function(x) read.xlsx2(file=x, sheetIndex=1, colIndex=6, header=TRUE, startRow=2, FILENAMEVAR=x))

#select the 3rd column
dates <- data[,1]
#as.POSIXct(dates, format = "%d/%m/%y %H:%M") 
#as.POSIXct(dates, format = "%d/%m/%y") 
#as.numeric(as.POSIXct(39965.004,origin=as.Date("1970-1-1")))
#as.POSIXct(dates, origin=as.Date("1970-1-1"))

#library(chron)
#convert excel time to date time format
#etime = 39965.0004549653
#orig =chron("12/30/1899"); #  "origin" of excel time.
#date.time = orig + etime;
#date.time = orig + dates;
#substr(as.character(date.time), 2, 18) #  as character without parentheses.

as.Date(40557.0, origin="1899-12-30")
as.Date(dates, origin="1899-12-30")
# A couple specifics on this date conversion:
# Microsoft Excel reports dates as serial numbers from 01-Jan-1900.
# However, a known bug is that MS Excel assumes the year 1900 to be
# a leap year (which it was not). Also there are some errors in
# how leap seconds are aggregated.
#
# Together, the origin parameter must be specified to account for a
# two day offset

za

