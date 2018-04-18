# NOTE: The crawling portions of this script have been commented out to avoid accidentally requesting more from the server than is needed. You should uncomment (i.e., remove the hashtags) to run once, then put the hashtags back to avoid accidentally repeating a server request.
#install.packages('rvest') #only run if you don't have rvest installed
library(rvest)


# STEP 1: EXTRACT HTML
# "Crawl" for the urls for each page
# Retrieve the HTML from each page
#####################
directory <- list() #set up a list
for (i in 0:5) #loop through the number 0 to 5, each time putting that number in the variable i
{
  mainurl <- paste('https://smlr.rutgers.edu/content/faculty-and-staff-directory?page=',i,sep="") #build the url by using whatever is in i as the ?page=i
  directory[[i+1]] <- read_html(mainurl) #download the html from the server, place that html as an element in the directory list
  Sys.sleep(3) #rest for 3 seconds
}


# STEP 2: PARSE HTML
#####################
# NOTE: SelectorGadget Chrome Extension is useful in this step!
# Find all the faculty page links
links <- sapply(directory,function(x) 
  x %>%
    html_nodes('#views-bootstrap-grid-1 small a:nth-child(1)') %>%
    html_attr('href')
  ) # the sapply loops over all the elements in the directory list, finding all the faculty pages, and storing the "href" attribute

links <- as.character(links) # converting from a matrix to a character vector

# Find all the faculty names
names <- sapply(directory,function(x) 
  x %>%
    html_nodes('#views-bootstrap-grid-1 small a:nth-child(1)') %>%
    html_text()
)# the sapply loops over all the elements in the directory list, finding all the faculty pages, and storing the text inside the a tag (this is the name)

names <- as.character(names) # converting from a matrix to a character vector

# Find all the <em> tags (i.e., italics)
titles <- sapply(directory,function(x) 
  x %>%
    html_nodes('em') %>%
    html_text()
)# the sapply loops over all the elements in the directory list, finding all the faculty pages, and storing the text inside the em tag (this is the title)

titles <- as.character(titles) # converting from a matrix to a character vector

# STEP 3: STRUCTURE/STORE
#####################
urls <- data.frame(name=unlist(names),link=unlist(links),title=unlist(titles)) #make a dataframe from al the lists above. The unlist command converts data from a list to a vector
View(urls)# Show the data in RStudio


# Now getting each faculty members' page
# STEP 1: EXTRACT HTML
#####################
pages <- list() #begin a pages list
for (i in 1:nrow(urls)) #loop from 1 to the number of rows in our urls data, making i <- the number each time through (i.e., 1, 2, 3,...,nrow(urls))
{
  url <- paste('https://smlr.rutgers.edu',urls[i,"link"],sep="") #the url we need is smlr.rutgers.edu PLUS whatever is in the "link" column for that faculty members' row
  pages[[i]] <- read_html(url) #read the html and put it in the pages list - note there should be the same number of elements in pages as there are rows in urls
  Sys.sleep(2)# pause to not overload the server
}

# STEP 2: PARSE HTML
#####################
# Again, use SelectorGadget to find the CSS selector that gives the education field(s)
education <- sapply(pages,function(x) 
  x %>%
    html_nodes('.field-type-text.field-label-above .field-item') %>%
    html_text()
)

# CSS selector to make a list of the bios
bios <- sapply(pages,function(x) 
  x %>%
    html_nodes('#quicktabs-faculty_staff_tabs1 p') %>%
    html_text()
)


# STEP 3: STRUCTURE/STORE HTML
#####################
# add 3 new variables to the urls dataframe
urls$ed1 <- NA
urls$ed2 <- NA
urls$ed3 <- NA

# here we're simply plugging in the elements of the education list into their appropriate places in the urls dataframe
for (row in 1:length(education)) #loop through each element in the education list, calling it row
{
  for (col in 1:3) #each time, loop from 1 to 3 (because there are up to 3 degrees listed on the pages) 
  {
    urls[row,col+3] <- as.character(education[[row]][col]) # and put them into ed1, ed2, or ed3 appropriately
  }
}

urls$bio <- NA #add a "bio" column to urls
for (row in 1:length(education)) #loop through each element in the education list, calling it row
{
  if (length(bios[[row]] > 0)) #if there actually is a bio
  {
    urls[row,'bio'] <- paste(bios[[row]],collapse=" ")#add it to the dataframe in the appropriate row.
  }
}

#Now, code who has a PhD
urls$phd <- NA #make a phd column
for (row in 1:nrow(urls)) #again loop from 1 to the num rows in urls
  {
    ed <- paste(urls[row,c('ed1','ed2','ed3')],collapse=" ") #collapse the 3 education columns into 1
    if (ed != "NA NA NA") #if there actually is any education
    {
      if (grepl("Ph.D.",ed) | grepl("Ed.D.",ed) | grepl("J.D.",ed)) #grep is looking for the patterns in the string. if Ph.D., Ed.D., or J.D. appears, this will evaluate to true
      {
        value <- 1
      }else{
        value <- 0
      }
    }else{
      value <- NA
    }
    urls[row,'phd'] <- value #actually assign the value to the dataframe
}

urls$bio_length <- apply(urls,1,function(x) nchar(x[['bio']])) #count the number of characters in each person's bio and assign it to urls as a new variable "bio_length"

plot(na.omit(urls[,c('phd','bio_length')])) #Make an x-y plot of bio lengths and the coded Ph.D. variable
t.test(bio_length ~ phd,data=urls) #run a t-test to see which group has longer bios
