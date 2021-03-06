#http://cran.r-project.org/web/packages/snowfall/vignettes/snowfall.pdf


#####

#OpenMPI  http://www.open-mpi.org/
#https://sites.google.com/site/dwhipp/tutorials/installing-open-mpi-on-mac-os-x
#mkdir ~/Code/openmpi
#cd ~/Code/openmpi
#wget http://www.open-mpi.org/software/ompi/v1.6/downloads/openmpi-1.6.5.tar.gz
#tar -xzf openmpi-1.6.5.tar.gz
#cd openmpi-1.6.5
#./configure --prefix=/usr/local
#make all
#sudo make install


#####
#Install openmpi and Rmpi

#http://www.stats.uwo.ca/faculty/yu/Rmpi/
#ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
#brew doctor
brew install gfortran
brew install open-mpi

R
install.packages("Rmpi", type="source")

#test the install
library(Rmpi)
mpi.spawn.Rslaves()
mpi.iparReplicate(100, mean(rnorm(1000000)))
mpi.close.Rslaves()
q()

#http://www.stats.uwo.ca/faculty/yu/Rmpi/
#Under OpenMPI (now MPICH2 as well), R slaves will use 100% CPU time while waiting for master's instructions. 
#This is mainly caused by OpenMPI's blocking call implementations. Under LAM R slaves use 0% CPU time while waiting. 
#However, staring from Rmpi 0.6-1, you can use mpi.spawn.Rslaves() without this issue since nonblock procedure is used as default..


#####
#install snow and snowfall

R
install.packages("snow", type = "source")
install.packages("snowfall", type = "source")

#test the install
library("snowfall")
sfInit(parallel=TRUE, cpus=8, type="MPI")
system.time(a<-sfLapply( 1:700, exp ))
sfStop()
q()


#####

#use this to detect the number of CPUs automatically:
require(multicore)
sfInit(parallel=T, type="MPI", cpus=multicore:::detectCores())
sfStop()

#note that each instance of R is independant of all others
#this means you must load require packaged each time a new instance starts
#this also means that links to ffdf files are removed after the R instance ends(!)

#####


#example of a way to test performance with varying levels of parallism
#note:  not working in the current example
num <- 10
for (j in 1:4){
  sfInit(parallel = TRUE, type="MPI", cpus = j)
  sfExport(list = c("trainset", "targettrain"))
  sfClusterEval(library(glmnet))
  sfClusterSetupRNG()
  cat(system.time(lambdas <- sfClusterApplyLB(1:num, fi)))
  flush.console()
  sfStop()
}

