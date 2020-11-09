library(readr)
library(dplyr)
library(tidyr)
library(lubridate)
library(imager)
library(reticulate)
source_python("resize_img.py")

max_size_per_image_KB <- 500

# list csvs
data <- list.files("data", include.dirs = FALSE, full.names = T)
data <- setdiff(data, c("data/metadata", "data/pictures"))
# get locations
location <- read_csv("data/metadata/locations.csv")

# a subset of locations
subset <- 32

if(!dir.exists("data/pictures"))
  dir.create("data/pictures")

charlist_to_list <- function(entry)
  I(strsplit(gsub("\\\\", "", gsub('"',"",gsub("\\[|\\]||'","", entry))),", "))

clean_fun_dl_pic <- function(d, loc)
{
  
 d$host_url <- 
   d$host_name <- 
   d$host_thumbnail_url <- 
   d$host_picture_url <- 
   d$listing_url <- NULL
 d <- cbind(d, loc)
 d$last_scraped <- as.Date(d$last_scraped)
 d <- d %>% mutate_at(.vars = c("host_response_rate", 
                                "host_response_time", 
                                "host_acceptance_rate"),
                      funs(ifelse(. == "N/A", NA, .)))
 d$host_since <- as.Date(d$host_since)
 d$host_acceptance_rate <- as.numeric(gsub("%", "", d$host_acceptance_rate))
 d$host_verifications <- charlist_to_list(d$host_verifications)
 d$amenities <- charlist_to_list(d$amenities)
 d$price <- parse_number(d$price)
 d$calendar_last_scraped <- as.Date(d$calendar_last_scraped)
 d$first_review <- as.Date(d$first_review)
 d$last_review <- as.Date(d$last_review)
 
 # create dir to store pictures
 if(!dir.exists(paste0("data/pictures/",d$geo_id[1])))
   dir.create(paste0("data/pictures/",d$geo_id[1]))
 
 for(row in 1:nrow(d))
 {
 
   filename <- paste0("data/pictures/",
                      d$geo_id[row], "/",
                      d$id[row], ".jpg")
   download.file(pull(d[row,"picture_url"]), destfile = filename, quiet = TRUE)
   
 }
 cat("Resizing images...\r")
 resize_img(paste0(getwd(),"/data/pictures/",d$geo_id[1],"/"), tuple(1000,1000))
 
 d$picture_url <- NULL
 return(d)
 
}

for(i in 1:length(data[subset]))
{
  cat("#############################  ", i,"  #############################\r")
  this_dat <- data[subset][i]
  d <- read_csv(this_dat)
  d <- clean_fun_dl_pic(d, location[subset,][i,])
  write_csv(d, this_dat)
  
}
