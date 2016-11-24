# Vectorized functions can operate on a whole vector of values at the same time
# Looping over all values in R is slower than using vectorized functions
# Let's take a look at the following example 

# Creating two vectors of 10,000 values (by sampling a value with 1 to 10, 10,000 times)
set.seed(123)
sampleLength <- 10000
a <- sample(1:10,sampleLength,replace = T)
set.seed(123)
b <- sample(1:10,sampleLength,replace = T)

# Let's add the two vectors using non-vectorized and vectorized approach

# The following function goes over each value in the vectors (using a loop) and adds them one by one
add2vec <- function(x,y){
  result_nv <- 0
  for(i in 1:length(x)){
    result_nv[i] <- x[i] + y[i]
  }
  return(result_nv)
}

# The '+' operator in R is vectorized. 
# Let's see how much time is needed to add the two vectors using vectorized: '+' and  non-vectorized:'add2vec
system.time(result <- a+b)
system.time(result_nv <- add2vec(a,b))

# The added vector is same in both cases above, we can confirm this by 
sum(result)
sum(result_nv)

# The sum function used above is also another vectorized built-in R function. 
# It sums all the values in a vector
# Here another non-vectorized custom-built summation function
calculate_sum <- function(x){
  temp <- 0
  for(i in 1:length(x)){
    temp <- temp + x[i]
  }
  return(temp)
}

# Let's compare
system.time(calculate_sum(result))
system.time(sum(result))
# The vectorized sum is much faster

# There are several drawbacks of using for (like) loops, such as 
# Looping is slower in R
# Objects used in a for loop can change an existing R object.
# Take a look at the example below, the for loop changes a logical obj to numeric

i <- TRUE
i
for(i in 1:5){
  print(i)
}
i

# Vectorized functions can be used in stead of looping when applicable, In addition,
# There is another looping mechanism in R that is as fast as for loop (often faster) called 
# Apply family of functions which requires less complex coding, let's try an example

# First, loading our data.
dat <- iris[1:10,1:4]
dat
# If we want the sum of each column, we can write a for loop like below:
res <- NULL
for(i in 1:ncol(dat)){
  res[colnames(dat)[i]] <- sum(dat[,i])
}
res
# However, the same thing can be done with 'apply' in a far more simple way
apply(dat,MARGIN = 2,sum)

# Let's say we want to square all the values. A for loop which will do this:
for(i in 1:nrow(dat)){
  for(j in 1:ncol(dat)){
    dat[i,j] <- dat[i,j]*dat[i,j]
  }
}
dat

dat <- iris[1:10,1:4]

# However, the same thing can be done with 'lapply' in a far more simple way
lapply(dat,function(x)x*x)
as.data.frame(lapply(dat,function(x)x*x))

# 'sapply' does the same but returns the results in the simplest data structure
sapply(dat,function(x)x*x)
