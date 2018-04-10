---
title: 'Olympic history (part 1): scraping data from sports-reference.com'
date: "2018-04-10"
layout: post
tags: R olympics sports tidyverse
comment: yes
---



This is the first in a series of posts analyzing data on the modern Olympic Games, which comprises all of the Olympics from Athens 1986 to Sochi 2014 (data was not available for more recent Olympics at the time I compiled this data in September 2016). In this post, I introduce the dataset and the methods I used to collect it. In subsequent posts, I analyze historical trends in this data using methods from the `tidyverse` R package, as described in the book [R for Data Science](http://r4ds.had.co.nz/) by Garrett Grolemund and Hadley Wickham. I've been wanting to familiarize myself with `tidyverse` for a while now, and this data exploration is mostly an excuse to do that. 

Surprisingly, the International Olympic Committee (IOC) does not maintain an organized database about the Olympics. However, a detailed [database](http://www.olympedia.org/) was developed and maintained by independent enthusiasts of Olympic history, and this data was made available on <www.sports-reference.com>. However, as explained in this [blog post](http://olympstats.com/2016/08/21/the-olymadmen-and-olympstats-and-sports-reference/), the IOC recently recognized the value of maintaining an Olympic database and partnered with the creators of the sports-reference database to transfer the data to an official IOC Olympic Statistical Database. When exactly that will happen and how much of the data will be publicly accessible is unclear, so I decided to scrape this dataset before it disappears! 

Below is the code I used to scrape data from the individual athlete pages from sports-reference. Note that I omit many data cleaning steps that occurred in between the initial data scraping and the final clean dataset I analyze in subsequent posts. I omit these steps because they are tedious and many steps were done 'manually'. 


```r
# Load packages
library("RCurl")
library("XML")
library("data.table") 

# Identify relevant nodes in the athlete directory
athlete_url <- getURL("http://www.sports-reference.com/olympics/athletes/")
athlete_xml <- htmlParse(athlete_url, asText=TRUE)
athlete_paths <- xpathSApply(athlete_xml, '//td/a', xmlGetAttr, 'href')
athlete_links <- paste('http://www.sports-reference.com/', athlete_paths, sep="")
length(athlete_links) # 452 pages

# Visit athlete directory pages and identify individual athlete pages
individual_links <- c()
system.time(for (i in 1:length(athlete_links)) {
  individual_url <- getURL(athlete_links[i])
  individual_xml <- htmlParse(individual_url, asText=TRUE)
  individual_paths <- xpathSApply(individual_xml, '//*[(@id = "page_content")]//a', xmlGetAttr, 'href')
  individual_links_new <- paste('http://www.sports-reference.com/', individual_paths, sep="")
  individual_links <- c(individual_links, individual_links_new)
  print(i)
}) # took about ~7.5 minutes
length(individual_links)  # 128415

# Extract data table for each individual athlete page into a list (takes ~1 sec per athlete)
athlete_data <- list()
for (i in 1:length(individual_links)) {
  data_url <- getURL(individual_links[i])
  data_xml <- htmlParse(data_url, asText=TRUE)
  tab <- readHTMLTable(data_xml)$results[-10]
  name <- xpathSApply(data_xml, '//*[@id="info_box"]/h1', xmlValue)
  infobox <- strsplit(xpathSApply(data_xml, '//*[@id="info_box"]/p', xmlValue), '\n')[[1]]
  sex <- ifelse(length(grep("Female", infobox))==0, "M", "F")
  born <- grep("Born:", infobox)
  birthplace <- ifelse(length(born)==1, substring(tail(strsplit(infobox[born], ',')[[1]], 1), 2), NA)
  if (!is.null(tab)) {
    athlete_data[[i]] <- data.table(Name=name, Sex=sex, Birthplace=birthplace, tab)
  } else {athlete_data[[i]] <- NA}
  print(i)
}

# Check data
length(athlete_data) # should be 128415 athletes
unique(unlist(lapply(athlete_data, ncol))) # should be 12 columns for all athletes (NAs excluded)
complete_cases <- unlist(lapply(athlete_data, is.data.frame))
missing_cases <- individual_links[!complete_cases] # visit these pages to see what's up, fix data manually where needed 

# Combine results into a single athlete-event table
athlete_data <- athlete_data[complete_cases] # drop cases with missing data
athlete_data <- rbindlist(athlete_data, use.names=TRUE)

# Many names are messed up due to problematic character encoding... a huge headache
# As an imperfect solution, I replace all non-ASCII characters with '?'
# This would be a problem if I cared about getting athletes' names right, but luckily I don't 
athlete_data$name <- sapply(athlete_data$name, gsub, pattern="[^\x01-\x7f]", replacement="?")

# Check easy variables for unexpected values
table(athlete_data$Sex, useNA="always") # good
table(athlete_data$Age, useNA="always") # good
table(athlete_data$City, useNA="always") # good
table(athlete_data$Sport, useNA="always") # good
table(athlete_data$NOC, useNA="always") # good
table(athlete_data$Medal, useNA="always") # good
table(athlete_data$Year, useNA="always") # some are missing, not sure why... fix manually
table(athlete_data$Season, useNA="always") # good
```

The final dataset contains 10 columns and 257,430 rows. Below, I use `tidyverse` methods to read the cleaned version of the dataset into R and compute some simple summary statistics for each column.


```r
# load tidyverse
library("tidyverse")

# load clean data as a tibble
athlete_events <- read_csv("~/Desktop/GitHub/Olympic_history/athlete_events.csv",
                           col_types = cols(
                             Name = col_character(),
                             Sex = col_factor(levels = c("M","F")),
                             Birthplace = col_character(),
                             Age =  col_integer(),
                             City = col_character(),
                             Sport = col_character(),
                             NOC = col_character(),
                             Medal = col_factor(levels = c("Bronze","Silver","Gold")),
                             Year = col_integer(),
                             Season = col_factor(levels = c("Summer","Winter"))
                           ))
```

Now for some summary statistics: 


```r
# Number of unique athletes in the dataset
athlete_events %>% select(Name) %>% unique %>% nrow
```

```
>  [1] 125912
```


```r
# Number of male (M) and female(F) athletes in the dataset
table(athlete_events$Sex)
```

```
>  
>       M      F 
>  189142  68288
```


```r
# Number of athltes with a known birthplace in the dataset
athlete_events %>% select(Name, Birthplace) %>% .[complete.cases(.),] %>% unique %>% nrow
```

```
>  [1] 98335
```


```r
# Age of the youngest and oldest Olympians in history
range(athlete_events$Age, na.rm=TRUE)
```

```
>  [1] 10 96
```


```r
# Number of different cities the Olympics have been held in
athlete_events %>% select(City) %>% unique %>% nrow
```

```
>  [1] 41
```


```r
# Number of different sports that have been played in the Olympics
athlete_events %>% select(Sport) %>% unique %>% nrow
```

```
>  [1] 65
```


```r
# Number of different nations that have appeared in the Olympics
athlete_events %>% select(NOC) %>% unique %>% nrow
```

```
>  [1] 227
```


```r
# Number of medals that have been awarded in the Olympics
athlete_events %>% select(Medal) %>% table 
```

```
>  .
>  Bronze Silver   Gold 
>   12592  12467  12715
```


```r
# Number of years in which the Olympics was held
athlete_events %>% select(Year) %>% unique %>% nrow 
```

```
>  [1] 34
```

```r
# Number of Summer and Winter games
athlete_events %>% select(Year, Season) %>% unique %>% select(Season) %>% table
```

```
>  .
>  Summer Winter 
>      28     22
```

You might notice that although there are 28 Summer Olympics and 22 Winter Olympics, there are only 34 years in which the Olympics was held. This is explained by the fact that the Summer and Winter Olympics were held in the same year until 1992. There are fewer Winter Olympics than Summer Olympics because winter sports were not included in the Olympics until 1924.

This is a pretty rich dataset to play around with, although I have one major regret: I didn't have the foresight to include an 'event' variable in the dataset. I included a 'sport' variable, but a lot of sports are divided into many different events, and it would have been interesting to look at the history of how events were added and removed from the Games (adding and removing entire sports is much less common). 

Up next: I will look at historical trends in international participation and medalling. 

**Footnotes**

For a comprehensive history of the modern Olympics, I recommend ['Politics, Power, and the Olympic Games'](https://www.amazon.com/Power-Politics-Olympic-Games-Alfred/dp/0880119586/ref=sr_1_1?ie=UTF8&qid=1523105541&sr=8-1&keywords=politics+power+olympic+games) by Alfred Senn. It's a bit dry, but very thorough.
