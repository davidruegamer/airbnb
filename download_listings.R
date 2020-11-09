library(lubridate)
library(dplyr)
library(tidyr)
library(readr)
library(R.utils)

if(!dir.exists("data"))
  dir.create("data")
if(!dir.exists("data/metadata"))
  dir.create("data/metadata")

url <- "http://insideairbnb.com/get-the-data.html"

# Get data
content <- readLines(url)
data <- content[grepl("http\\://data\\.insideairbnb.com/.*/data/listings\\.csv\\.gz", content)]
data <- gsub(".*<a href.*(http\\:.*data/listings.csv.gz).*", "\\1", data)
# => this is the data for downlaoding

# Get locations
location <- data.frame(apply(t(sapply(data, function(x){ 
  y <- strsplit(gsub(".*\\.com/(.*)/20.*/data/listings\\.csv\\.gz","\\1",x),"/")[[1]]
  return(c(y,rep(NA,3-length(y))))
})),2,as.character))
colnames(location) <- paste0("geo", 1:3)
## some descriptives
table(location$geo1)
sum(is.na(location$geo1))
table(location$geo2)
sum(is.na(location$geo2))
table(location$geo3)
sum(is.na(location$geo3))
location %>% filter(is.na(geo3)) %>% select(geo1,geo2,geo3)
location$geo3 <- as.character(location$geo3)
location[location$geo1=="ireland" & is.na(location$geo3),"geo3"] <- "ireland" # for download 

# Get dates
dates <- as.Date(gsub(".*/(20.*)/data/listings.csv.gz","\\1", data))
## descriptives
summary(dates)
barplot(table(dates))

# Select most recent
recent_locations <- cbind(location, date=dates) %>% 
  group_by(geo1,geo2,geo3) %>% 
  slice(which.max(date))
recent_locations %>% head()
rloc <- recent_locations
rloc$geo3[rloc$geo3=="ireland"] <- NA
rloc$geo_id <- 1:nrow(rloc)
write_csv(rloc, path="data/metadata/locations.csv")
# compile data to be downloaded and download

recent_url_parts <- paste0(recent_locations$geo3, "/", recent_locations$date)
these_parts <- paste(recent_url_parts, collapse = "|")
links <- data[grepl(these_parts, data)]
link_locations <- gsub("/","_",(gsub(".*\\.com/(.*)/20.*/data/listings\\.csv\\.gz","\\1",links)))

for(i in 1:length(link_locations)){
  
  filename <- paste0("./data/", link_locations[i], "listings.csv.gz")
  download.file(links[i], destfile = filename)
  gunzip(filename, remove=TRUE)
  
}
