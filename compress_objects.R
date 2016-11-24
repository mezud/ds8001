# Get memory footprint of an object
get_object_size <- function(obj){
  format(object.size(obj), unit = "auto")
}

# Let's get a dataset
attach(iris) 

# It is small (150 rows)
iris.row.count <- nrow(iris) 
iris.row.count

# and consumes minimal amount of space (6.9 Kb)
get_object_size(iris)

# Note that memory values may vary a bit, depending on the platform and R's release

# So let's resample it to a million rows.
# It is a naive and not very practical approach, but it will serve our purpose.
dat <- iris[ sample(iris.row.count, 1E6, replace = TRUE), ]  

# Now it becomes more interesting: the size is 89.9 Mb:
get_object_size(dat)

# Let build linear model to predict petal length:
dat.lm <- lm(Petal.Length ~ Petal.Width, data = dat)


# If we are to use this model for prediction,
# all we need is the values of a and b in Petal.Length = a + b * Petal.Width
# However the model stores a lot of other object  (283.5 Mb), that are useful 
# for model analysis but not for prediction:
get_object_size(dat.lm)

# The model contains a number of attributes:
names(dat.lm)

# And many of them consume a lot of space:
for(name in names(dat.lm)){
  print( paste(name, get_object_size(dat.lm[[name]])))
}

# Conceptually, for predictions we need only coefficients, 
# so let's try to get rid of the attributes.

#Let's clone the linear models (so that we do not brake anything) and see if can shrink it:
dat.lm.compressed <- dat.lm
  
#Let's get rid of large attributes:
dat.lm.compressed$fitted.values <- NULL
dat.lm.compressed$residuals <- NULL
dat.lm.compressed$effects <- NULL
dat.lm.compressed$model <- NULL

# Note that predict() needs qr -- cannot get rid of it, 
# see what happens if you uncomment the line below
# dat.lm.compressed$qr <- NULL

# However we can remove
dat.lm.compressed$qr$qr <- NULL

# The model still gives the correct output:
sum(abs(predict(dat.lm.compressed, dat) - predict(dat.lm, dat)))

# And we just reduced memory footprint by 99.997%: 
dat.lm.size <- as.numeric(object.size(dat.lm))
dat.lm.compressed.szie <-  as.numeric(object.size(dat.lm.compressed))
round (( dat.lm.size - dat.lm.compressed.szie ) / dat.lm.size * 100, 4)

# The same approach can be used for other R objects
