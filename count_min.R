set.seed(12345)

#the number of samples
sample_count <- 100000 # what happens if you increase or decrease sample count?

#controls the number of distinct elements
level_of_variability <- 90 # try 10, 50, 100, 200, 500, 1000

# generate sample dataset
dataset <- round(rexp(sample_count)*level_of_variability)

#setup sketch
w <- 200 # sketch width
d <- 3   # sketch depth (height)

#create matrix for storing counters
sketch <- matrix(data = 0, nrow = d, ncol = w)

#initialize hash functions
hash.max_val <- 15485863 # has to be a large prime but given that R's largest integer is 2^31-1, have to be small, otherwise we will face serious roundoff
hash.a <- as.double(sample.int(hash.max_val, d)) #converting to double to avoid overflow in hash, may lead to round-off
hash.b <- as.double(sample.int(hash.max_val, d)) #converting to double to avoid overflow in hash, may lead to round-off

hash <- function(x){
  # Hash function is adopted from Cormode G, Muthukrishnan S., Approximating Data with the Count-Min Data Structure, 2011
  # http://dimacs.rutgers.edu/~graham/pubs/papers/cmsoft.pdf
  # This is a simple and not a very good hash function
  ((hash.a * x + hash.b) %% hash.max_val) %% w + 1
}

#populate sketch structure
for(val in dataset){
  w.ind <- hash( val )
  for(i in 1:d){
    sketch[i, w.ind[i]] <- sketch[i, w.ind[i]] + 1
  }
}

#get the smallest element estimates for every distinct element
my.val <- c()
my.cnt <- c()
for(val in sort(unique(dataset))){
  freq <- .Machine$integer.max
  w.ind <- hash( val )
  for(i in 1:d){
    freq <- min(sketch[i, w.ind[i]], freq)
  }
  my.val <- c(my.val, val) #note that concatenations of vectors in inefficient, speed up by pre-allocating space
  my.cnt <- c(my.cnt, freq)
}

hist(rep(my.val, my.cnt ), col=rgb(0,0,1,0.5)
     , xlab = ""
     , sub = paste("Distinct elements count =", length(unique(dataset)))
     , main = "" 
)
hist(dataset, col=rgb(1,0,0,0.5), add = T)
legend("topright", c("Estimated", "Actual"), col = c(rgb(0,0,1,0.5), rgb(1,0,0,0.5)), pch = 15)
box()

