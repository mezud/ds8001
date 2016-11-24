
# If you do not have caTools package installed, run
# install.packages("caTools")

library(caTools)

x <- c(1, 1e20, 1e40, -1e40, -1e20, -1)

# xxx_exact functions compute the values exactly (but are slower)

# We expect to get 0 as we sum up all the values in x, right?
sum(x) 
sumexact(x)

# Let's take a look at what is happening.
# Cumulative sum can help us understand the problem
cumsum(x)
cumsumexact(x)

# But is this a problem only when dealing with a combination of small and large numbers? 
# Not really... R by default prints 7 digits of a number:
getOption("digits")

# Now let's do a simple arithmetic example:
0.1
0.2
0.1 + 0.2

# So far the results are what we expect. Let's change the number of digits to 22:
options(digits=22)
# and repeat the calculations:
0.1
0.2
0.1 + 0.2

# Surprise! This happens because 0.1 in binary is an infinitely repeating fraction:
# 0.00011001100110011... and 0.2 is given by # 0.00110011001100110...
# This is similar to representing 1/3 in decimal -- we will get an infinite sequence 0.333...

# What happened here is the conversion:
# rational decimal  ->  irrational binary  ->  irrational decimal 

# On the other hand 0.125 = 1/8 = 2^-3 is represented in binary exactly by 0.001 
# and 0.250 = 1/4 = 2^-2 and is represented in binary exactly by 0.01
0.125
0.250
0.125 + 0.250

# Here we stay within the realm of rational numbers:
# rational decimal  ->  rational binary  ->  rational decimal 
