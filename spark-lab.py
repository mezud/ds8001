##############################################
# Spark Lab
##############################################

# Spark is an open source big data processing framework
# Offers in memory computation, reduced disk operations: resulting in faster execution of tasks;
# Provides APIs for Java, Python, Scala, R

# Let's see some basic Spark operations. We will use Python and R

# Download Spark-box: https://drive.google.com/open?id=0B0HtI5JG2QR8SkFqV29FUXVzMTQ
# open the vm image using VMplayer or VIrtualbox
# Log in with username: user and password: user
# Go to spark-2.0.2-bin-hadoop2.7/bin directory
cd spark/spark-2.0.2-bin-hadoop2.7/bin

# Launch Spark Shell for Python,  We don't need to instantiate the "SparkContext" that 
# allows Spark driver application to access the cluster, it's basically tells our app how to access the cluster.
# A SparkContext is automatically created for us when we launch the pySpark shell, the SparkContext object is named as sc  

./pyspark

# First thing we need to know is RDD!
# Resilient Distributed Datasets (RDD) is a key-element in Spark
# It's a fault-tolerant collection of elements that can be operated in parallel. 
# There are two ways to create RDDs: 
# By parallelizing an existing collection in your driver program, or
# By referencing a dataset in an external storage system, such as a shared filesystem, HDFS or any data source offering a Hadoop 
# InputFormat.

# Converting an existing collection
nums = range(1,11)
num_dat = sc.parallelize(nums)
num_dat.collect()
# Reading from FS
txt_dat = sc.textFile("/home/user/spark/spark-2.0.0-bin-hadoop2.7/README.md")
txt_dat.collect()

# RDD supports two types of operations: Transformation and Action
# Transformation: Trasforms an existing RDD to a new RDD by applying a transformation function. For example: map(), filter()
# Action: Perfroms computation on a RDD and returns a value. For example, collect() returns
# all the elements of the dataset as an array, count() returns the number of elements in the dataset.

##############################################
# Transformations
##############################################

# map()
# Applys a function on each element of a dataset, and returns a new RDD

# map: example 1, squaring each data point
num_dat_mapped = num_dat.map(lambda x : x*x)

# map: example 2, tokenization of words from sentence (Tokenization is a NLP term, it's the process of breaking a stream of text up into words)
txt_dat_mapped = txt_dat.map(lambda line : line.split(" "))
txt_dat_mapped.collect()

# map: example 3, transforming RDD to (key,value) pair RDD i.e. (word,wordLength), using transformation: map
dummy_dat = sc.parallelize(["ryerson", "university", "data",  "science"])
dummy_dat_mapped = dummy_dat.map(lambda x : (x,len(x)))

# flatMap()
# Similar to map; however, returns simplified or flattened object (i.e. a list rather than a list of lists) 
txt_dat_mapped = txt_dat.flatMap(lambda line : line.split(" "))
dummy_dat_fMapped = dummy_dat.flatMap(lambda x : (x,len(x)))

# filter()
# Applys a function on each element of the dataset and filters out elements for which the function returns 1

# filter: example 1, filter out odd numbers
num_dat_filtered = num_dat.filter(lambda x : x%2==0)
num_dat_filtered.collect()

# filter: example 2, filter out lines without "spark"
txt_dat_filtered = txt_dat.filter(lambda line: 'spark' in line)
txt_dat_filtered.count()

## Transformations on Key-Value data

	# Spark has transformation functions, designed specially for key-value pair data.
	# Let's, look at the following grocery store data, let's assume that the store
	# records number of breads or milks bought by each customer in a day.
	# We want to know how many times each item is purchased in a day.

grocery_dat = sc.parallelize([('bread',1)
 							 ,('bread',2)
 							 ,('milk',1)
 							 ,('milk',5)
 							 ,('milk',0)
 							 ,('bread',1)	
 							 ])
# reduceByKey(), values for each key are aggregated using the given reduce function 

per_item_purchased = grocery_dat.reduceByKey(lambda sum,val:sum+val)
per_item_purchased.collect()

# groupBy

prog_dat = sc.parallelize(["Assembly","C","C++","ASP.NET","Java","Bash","Javascript","Cython","Batch","PHP","Perl"])
prog_dat_grouped = prog_dat.groupBy(lambda chars : chars[0])
for i in prog_dat_grouped.collect():
	print(i[0]+":")
	for j in i[1]:
		print(j)

##############################################
# Actions
##############################################

# take(), Returns an array with the first n elements of the dataset.
prog_dat.take(3)
txt_dat.take(5)

# reduce(), Aggregates the elements of the dataset using a function 
# Below, we summed the elements using reduce()
num_dat.reduce(lambda x,y : x+y)

# Going back to the old example, let's get the total number of items purchased in that grocery store using reduce()
total_item_purchased = grocery_dat.flatMap(lambda x: [x[1]]).reduce(lambda a,b : a+b)
print(total_item_purchased)

# collect()
# Already used above

# count()
# Already used above

##############################################
# Variables Sharing
##############################################

# Broadcast Variables
# sometimes, we want to share a read-only varible with all workers, i.e. a matrix
# Normally, the varible is sent to each parallel operation, this is costly, 
# for example, a 100000000 * 1000000000 matrix (when the variable is very large)
# A remedy is to create broadcast variables
var = [1, 2, 3]
broadcastVar = sc.broadcast(var)
broadcastVar.value

# Accumulators 
# These are variables that are only “added” (i.e. counters)
# to through an associative and commutative operation (i.e. a+b=b+a)
accum = sc.accumulator(0)
sc.parallelize([1, 2, 3, 4]).foreach(lambda x: accum.add(x))
accum.value

##############################################
# Spark with R
##############################################

# Spark provides an R interface, all spark operations are not supported yet
library(sparklyr)
library(dplyr)
sc <- spark_connect(master = "local")

# Read Data
flights_tbl <- copy_to(sc, nycflights13::flights, "flights")

# filter
flights_tbl %>% filter(dep_delay == 2)

##############################################
# Reference
##############################################
# http://spark.apache.org/docs/latest/programming-guide.html#rdd-operations