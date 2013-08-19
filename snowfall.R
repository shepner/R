
#http://cran.r-project.org/web/packages/snowfall/vignettes/snowfall.pdf
#OpenMPI
#snowfall
#snow
#Rmpi

library("snowfall")

sfInit(parallel=F)
#sfLapply( 1:10, exp )
sfStop()

sfInit(parallel=TRUE, cpus=2, type="SOCK", socketHosts=rep('ws01.asyla.org',2))
## Now, index 1 is calculated on CPU1, 2 on CPU2 and so on.
## Index 6 is again on CPU1.
## So the whole call is done in two steps on the 5 CPUs.
sfLapply( 1:10, exp )
sfStop()
