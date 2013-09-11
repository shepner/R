#https://gist.github.com/jwijffels/5239198
#http://www.r-bloggers.com/massive-online-data-stream-mining-with-r/
#http://moa.cms.waikato.ac.nz/details/stream-clustering/

#Below, you can find a toy example showing streaming clustering in R based on data in an ffdf. 

#####

#Load the packages & the Data Stream Data for ffdf objects
require(devtools)
require(stream)
require(ff)
source_gist("5239198")

#####

DSD_FFDFstream <- function(x, k=NA, assignment=NULL, loop=FALSE) {
  stopifnot(is.ffdf(x))
  open(x)
  state <- new.env()
  assign("counter", 1L, envir = state) 
  l <- list(description = "FF Data Stream",
            strm = x,
            state = state,
            d = ncol(x),
            k = k,           
            assignment = assignment,
            loop = loop)
  class(l) <- c("DSD_FFDFstream","DSD_R","DSD") 
  l
}

get_points.DSD_FFDFstream <- function(x, ...){
  stream:::get_points.DSD_Wrapper(x, ...)
}

print.DSD_FFDFstream <- function(x, ...) {
  NextMethod() # calling the super classes print()
  pos <- x$state$counter
  if (pos>nrow(x$strm))
    if (!x$loop) pos <- "'end'" else pos <- 1
  cat(paste('Contains', nrow(x$strm),
            'data points - currently at position', pos,
            '- loop is', x$loop, '\n'))
}

reset_stream.DSD_FFDFstream <- function(dsd) {
  stream:::reset_stream.DSD_Wrapper(dsd)
}

#####

#Set up a data stream

myffdf <- as.ffdf(iris)
myffdf <- myffdf[c("Sepal.Length","Sepal.Width","Petal.Length","Petal.Width")]
mydatastream <- DSD_FFDFstream(x = myffdf, k = 100, loop=TRUE) 
mydatastream

#Build the streaming clustering model

#### Get some points from the data stream
get_points(mydatastream, n=5)
mydatastream

#### Cluster (first part)
myclusteringmodel <- DSC_CluStream(k = 100)
cluster(myclusteringmodel, mydatastream, 1000)
myclusteringmodel
plot(myclusteringmodel)

#### Cluster (second part)
kmeans <- DSC_Kmeans(3)
recluster(kmeans, myclusteringmodel)
plot(kmeans, mydatastream, n = 150, main = "Streaming model - with 3 clusters")
