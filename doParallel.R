library(doParallel)
library(foreach)

#####

cl <- makeCluster(2)
registerDoParallel(cl)
foreach(i=1:300000) %dopar% sqrt(i)

#####

#parallel execution on 3 cores (dopar)
x <- iris[which(iris[,5] != "setosa"), c(1,5)]
trials <- 10000
ptime <- system.time( {
  r <- foreach(icount(trials), .combine=cbind) %dopar% {
    ind <- sample(100, 100, replace=TRUE)
    result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
    coefficients(result1)
  }
} ) [3]

#serial execution (do)
stime <- system.time( {
  r <- foreach(icount(trials), .combine=cbind) %do% {
    ind <- sample(100, 100, replace=TRUE)
    result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
    coefficients(result1)
  }
} ) [3]

ptime
stime

#####

#returns how many workers foreach will use
getDoParWorkers()
#name of registered backend
getDoParName()
#ver of registered backend
getDoParVersion()
#stop cluster
stopCluster(cl)

#####


#parallel load comparison
dir="data/device"
namepattern="*.csv"
files<-list.files (path=dir, pattern=namepattern, full.names=TRUE, recursive=FALSE)
colClassesDefinitions<-c(
  "Date"="POSIXct",
  "YYYY"="integer",
  "MM"="integer",
  "DD"="integer",
  "hh"="integer",
  "Events"="integer",
  "Bytes"="double",
  "AvgEPS"="numeric",
  "Percent"="numeric"
) #something in here really slows down the laod

load.fun(ff)
load.fun(ffbase)
options(ffmaxbytes=1073741824) #use 1G instead

library(rbenchmark)
benchmark(replications = 10, order = "user.self",
          LAPPLY = {
            readdata<-function(x) {
              td<-read.csv.ffdf (file=x, sep=",", header=T, colClasses=colClassesDefinitions)
              return(td)
            }
            data1<-lapply(files, readdata)
            Reduce(function (x,y) { ffdfappend(x,y) }, data1)
          },
          FOREACH = {
            library(doParallel)
            registerDoParallel(cores = 2)
            library(foreach)
            data2 <- foreach(i = files, .combine = rbind) %dopar% read.csv.ffdf (file=i, sep=",", header=T, colClasses=colClassesDefinitions)
          }
)

library(compare)
all.equal(data1, data2)



