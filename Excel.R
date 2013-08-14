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

# A couple specifics on this date conversion:
# Microsoft Excel reports dates as serial numbers from 01-Jan-1900.
# However, a known bug is that MS Excel assumes the year 1900 to be
# a leap year (which it was not). Also there are some errors in
# how leap seconds are aggregated.
#
# Together, the origin parameter must be specified to account for a
# two day offset
as.Date(40557.0, origin="1899-12-30")

#x = 3 # Say you want columns 1-3 as factors, the rest numeric
#data = read.xlsx2(filename, page, colClasses = c( rep("character", x), rep("numeric", ncol(data)-x+1) ) )

data <- read.xlsx2(filename, sheetIndex=page, sheetName=NULL, startRow=1, endRow=NULL, as.data.frame=TRUE, header=TRUE)

# list the column names and positions
coln(data)


#select the 1st column
dates <- data[,1]


as.Date(dates, origin="1899-12-30")


