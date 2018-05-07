#INTRO TO R
# 

getwd() #show your working directory
list.files() #list all the files in your working directory
a<-5 #assign a value to a
a #show what is inside a
A #note R is case-sensitive
b=10 #this works for assigning too
b #see, I told you
a*5 #show the value a*5 - note it's not assigning to anything
c<-a*5 #assign that a * 5 to a new variable c
c #show C
c==a #is c equal to a?
c!=13 #is c not equal to 13?
d<-(c!=13) #assign the result of "is c not equal to 13" to new variable d
d #show me what's in d
rm(a) #delete a from the environment
rm(a,b,c,d) #delete a through d from the environment
?rm #show the help files for the rm function

rep(1:2,10) #repeat 1,2 10 times - note we're not assigning anything here
hist(rep(1:2,10)) #show the histogram of that repeat
rnorm(10,0,1) #randomly draw 10 values from a unit normal distribution
?rnorm #show the rnorm help file
hist(rnorm(1000,0,1)) #show a histogram of 1,000 random values from unit normal dist.
cor(rnorm(1000,0,1),rnorm(1000,0,1)) #calculate the correlation of 2 random vectors with n=1,000

# this is how to create 2 random vectors with a specific correlation
r <- .5 #set the value for r (i.e., the x-y correlation)
x <- rnorm(10000,0,1) #create x with n = 10,000
y <- r*x + sqrt(1-r**2)*rnorm(10000,0,1) #compute y such that the x-y correlation equals r
cor(x,y) #what's the resulting correlation?


#Data elements
data <- data.frame(x=x,y=y)#example of a dataframe (i.e., spreadsheet)
View(data)

listed.example <- list('Apples','Oranges','Pears') #example of a list
listed.example
c('Apples','Oranges','Pears')#example of a vector (a more restrictive kind of list)

nested.list <- list(list('Apples','Oranges','Pears'),list('Peppers','Onions','Cucumbers'),list(10,20,30))#nested list example
nested.list
names(nested.list) <- c('fruit','vegetables','quantity')

listed.example <- list(c('Apples','Oranges','Pears'),c('Peppers','Onions','Cucumbers'),c(10,20,30))#list of vectors
listed.example

# LOOPS
#one way to loop
for (i in 1:10)
{
  print(paste("The number is",i))
}

#a second, faster, way to loop - the apply family (see ?apply)
sapply(1:10,function(i) print(paste("The number is",i)))

#let's put it together and build a madeup dataset
n <- 10000
rx1 <- .2
rx2 <- .4
rx3 <- .5

y <- rnorm(n,0,1)

x1 <- rx1*y + sqrt(1-rx1**2)*rnorm(n,0,1)
x2 <- rx2*y + sqrt(1-rx2**2)*rnorm(n,0,1)
x3 <- rx3*y + sqrt(1-rx3**2)*rnorm(n,0,1)


  
#THE END --------------