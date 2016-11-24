# If you have a code executed multiple times (which typical for simulations, Monte Carlo analysis, etc.)
# then it becomes important to optimize pieces of code that are executed frequently

# Here is an example, take from an actual simulation in health science domain.

# Set global vars:
v1 <- 2
v2 <- 10
v3 <- 20

# Note that in the actual simulation v1, v2, and v3 are changed dynamically 
# by other pieces of code. The functions below had to be executed 1E10 times, 
# Overall simulation took around a week on a single CPU

# Here is how the original function looks like, note that each line is executed:
original <- function (x){
  y <- 0                                    
  y[x == "a"] <- v1
  y[x == "b"] <- v2 + v3*v3
  y[x == "c"] <- v1 + v3*v3
  
  return(y)
}

# Let's add if-else blocks and add multiple returns to maximize efficiency:
if_else_version <- function (x){
  if(x == "a"){ 
    return(v1)
  }else if(x == "b"){
    return(v2 + v3*v3)
  }else if(x == "c"){
    return(v1 + v3*v3)
  }else{
    return(0)
  }
}

# And now use switch/case function instead of if-else. Note that 
# R returns output of last line, so explicit return is not necessary
switch_version <- function (x){
  switch(x,
         "a" = v1,
         "b" = v2 + v3*v3,
         "c" = v1 + v3*v3,
         0)
}

# If you do not have rbenchmark package installed, run
# install.packages("rbenchmark")


# Play with different input values: "a", "b", "c", "other";
# performance will change as we have to go through different number of branches.
# Try to put the most probable values to the top in your code.
input <- "b"

library(rbenchmark)
benchmark(
  original(input),
  if_else_version(input),
  switch_version(input),
  replications = 500000,
  order="relative")

# Note that switch version is significantly more efficient (40-60% on my laptop, depending on the value of input). 
# This implementation reduced overall simulation time by 40% (~3 days).
# Note that in compiled languages switches are often more efficient than if-else, because compiler
# can try to rearrange order of statements in switch statement (https://en.wikipedia.org/wiki/Branch_table),
# but have to preserve the order for if-else statements.

# The moral of the story: pre-compiled core R functions (typically implemented in C/C++) 
# are the most efficient. This is true for other interpreted languages, such as Python.

