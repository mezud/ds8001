# Using non-parallel lapply
lapply(list(1:10,11:20,21:30), function(x)2^x)

# You can parallelize the code above. 

# install.packages('parallel')
library(parallel)

# First, we need to identfy number of working cores,
# It's better to keep one core free, otherwise the system 
# will freeze until the R process is done computing.

# Calculate the number of cores
no_cores <- detectCores() - 1

# Initiate cluster or node
cl <- makeCluster(no_cores)

# Parallel version of lapply
parLapply(cl,list(1:10,11:20,21:30), function(x)2^x)

# Free resources
stopCluster(cl)


# If you are using variables and libraries, you need to specify them
# because they are out of scope for the parallel package. For example,
cl<-makeCluster(no_cores)
exponent <- 2
# passing variable to the workspace of each worker node
clusterExport(cl, "exponent")

parLapply(cl,list(1:10,11:20,21:30), function(x)x^exponent)

stopCluster(cl)

# Now let's try the foreach package. It's essentially the parallel version of the standard for loop
# install.packages('foreach')
# install.packages('doParallel')

library(foreach)
library(doParallel)

# The intilization is a little bit different
cl<-makeCluster(no_cores)
registerDoParallel(cl)

l <- 1:10

# A parallel for loop is shown below
foreach(x = 1:3
        ,.combine = cbind)  %dopar%  {
         l^x         
        }
# Free resources
stopCluster(cl)


# Let's compare the performance
# Please note that, "With small tasks, the overhead of scheduling the task and returning the result
# can be greater than the time to execute the task itself, resulting in poor performance"

# initialize 
cl<-makeCluster(no_cores)
registerDoParallel(cl)

setSize <- 10000
# Increasing the size of the experiment would yield better results for parallelization. 
# Uncomment the below code to see. It may take a while
# setSize <- 90000

# %do% sets foreach to standard sequential for loop
system.time(foreach(i=1:setSize) %do% sum(sinh(1:i)))

# %dopar% sets foreach to parallel for loop
system.time(foreach(i=1:setSize) %dopar% sum(sinh(1:i)))

# Free resources
stopCluster(cl)
