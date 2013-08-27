
#####

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

load.fun(ff)
load.fun(ffbase)

load.fun(multicore)
load.fun(snowfall)
load.fun(Rmpi)

#####

getOption("fftempdir")
getOption("ffextension")
getOption("ffdrop")
getOption("fffinonexit")
getOption("ffpagesize")
getOption("ffcaching")    #=="mmnoflush" -- consider "ffeachflush" if your system stalls on large writes
getOption("ffbatchbytes") #==16777216    -- consider a different value for tuning your system
getOption("ffmaxbytes")   #==536870912   -- consider a different value for tuning your system
options(ffmaxbytes=1073741824) #use 1G instead

#####

#small example merging 2 ffdf into 1
a<-as.ffdf(data.frame(a=Sys.time(), x=1:1000, y=1001:2000, z=Sys.time()))
b<-as.ffdf(data.frame(a=Sys.time(), x=1:1000, y=1001:2000, z=Sys.time()))
c<-ffdfappend(a, b)

#####

dir="/some/path"
namepattern="*.csv"
name1=paste(dir, "2013-07-22.csv", sep="/")
name2=paste(dir, "2013-07-23.csv", sep="/")

#larger example merging 2 files
data1<-read.csv.ffdf (file=name1, sep=",", header=T, colClasses=c(Bytes="numeric"))
data2<-read.csv.ffdf (file=name2, sep=",", header=T, colClasses=c(Bytes="numeric"))
#for some unknown reason, these files need 1 column removed.  Doesnt matter which as long as 1 is removed
data1<-as.ffdf(data1[,!(names(data1) %in% c("YYYY", "MM", "DD"))])
data2<-as.ffdf(data2[,!(names(data2) %in% c("YYYY", "MM", "DD"))])
data3<-ffdfappend(data1, data2)


multimerge = function (path, namepattern) {
  files<-list.files (path=dir, pattern=namepattern, full.names=TRUE, recursive=FALSE)
  datalist<-lapply (files, function(x){read.csv.ffdf (file=x, sep=",", header=T, colClasses=c("Bytes"="numeric"))})
  Reduce (function (x,y) { merge(x,y) }, datalist)
}
#data=multimerge (dir, namepattern)

#####

#example of saving and loading ffdf data
save.ffdf(data, dir="/Users/tkmawt6/Code/R/data")
data=""
load.ffdf(dir="/Users/tkmawt6/Code/R/data")


