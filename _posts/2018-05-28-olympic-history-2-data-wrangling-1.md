---
title: 'Olympic history: Data wrangling (part 1)'
date: "2018-05-28"
layout: post
tags: R olympics sports
comments: yes
---



In my last post, I scraped data on 135,584 Olympic athletes from www.sports-reference.com. I saved the data in two lists containing information on each athlete in different formats. In its present form, the data is pretty useless. In this post, I demonstrate how to tidy up this data so that it can be analyzed. Feel free to follow along using the data provided in the [GitHub repo](https://github.com/rgriff23/Olympic_history) for this project.

## Set up

I will use two R packages: `tidyverse` and `data.table`. 


```r
library("tidyverse")
library("data.table")
```

Load the `scrapings.Rdata` file, which can be found in the `data` folder of the GitHub repo.


```r
load("~/Documents/GitHub/Olympic_history/data/scrapings.Rdata")
ls()
```

```
>   [1] "individual_links"   "info"    "results_table"
```

The three objects included in this Rdata file are:

1. `individual_links` - a character vector containing links to the webpages with data on each athlete (one per athlete)
2. `infobox` - a list of character vectors containing text from the "infobox" on each athlete page (one per athlete)
3. `results_table` - a list of dataframes containing the "results table" from each athlete page (one per athlete)

The results tables have varying numbers of rows since there is one row for each Olympic event the athlete participated in. For many athletes there is only one row, but for others (e.g., Michael Phelps) there are dozens of rows corresponding to multiple events in multiple Olympics. My goal is to combine the athlete-level data from `infobox` with the event-level data in `results_table`, resulting in a dataframe where each row corresponds to an athlete-event. 

## Parsing the 'infobox' list

My strategy for parsing `infobox` is to use R's `lapply` and `grep` functions to find and extract information from each element of `infobox`. Before beginning, let's create a variable to represent the number of athletes and check the list for NULL entries.


```r
# There are 135584 athletes in the database
n_athletes <- infobox %>% length 

# None of the infobox entries are NULL
infobox %>% 
  lapply(is.null) %>% 
  unlist %>% 
  sum 
```

```
>  [1] 0
```

There are no NULL entries.

Each element in `infobox` is a character vector containing a variable number of strings. These strings are sometimes empty (`""`), but the vast majority of them have the format `"Variable name: value"`. Some variables such as "Full name" and "Gender" are provided for nearly all athletes, but others are frequently missing, such as "Nickname(s)" or "Weight". A useful feature of these character vectors is that the variable name is always separated from its value by a colon and a space, so I could use that to help identify variable names in each infobox. 

There are four bits of information I want to collect from the infoboxes: Name, Sex, Height, and Weight. I describe how I extracted each of these variables below.

### Name

The name of each athlete is provided in a string that begins with `"Full name: "`. Let's check to see how many athletes are missing this information.


```r
# How many athletes are missing "Full name: "
n_athletes - (infobox %>% 
                lapply(function(x) grepl("Full name: ", x)) %>% 
                unlist %>% 
                sum)
```

```
>  [1] 0
```

Luckily there is no missing data for this variable. We can confirm that "Full name:" is *always* the first element of each infobox like this:


```r
infobox %>% 
  lapply(function(x) grep("Full name:", x)) %>% 
  unique
```

```
>  [[1]]
>  [1] 1
```

This makes things easy: we can just use `strsplit` on each element of `infobox` to split each string by the `": "`, which will result in two substrings, the first of which is "Full name" and the second of which is the athlete's name. We also need to create a dataframe (or a "tibble", since we are using `tidyverse`) to store the results of parsing `infobox`, so let's go ahead and extract the athletes' names and create the tibble, which I named `info`.


```r
# Create new tibble with one column: Name
info <- infobox %>% 
  lapply(function(x) strsplit(x[[1]], ": ")[[1]][2]) %>% 
  unlist %>% 
  tibble(Name = .)
```

Finally, let's check for NULL values to make sure we have a valid name for each athlete.


```r
# Check for NULL values
info$Name %>% is.null %>% sum
```

```
>  [1] 0
```

Great, no NULL values. Inspecting the Name column reveals that there is some messed up encoding. So far I haven't done anything to deal with the many non-ascii characters included in these names. I'm going to put that off until the next post in which I fine tune the variables. Now, let's move on to what turns out to be a slightly tricker variable: Sex.

### Sex

The reason the Sex variable (called "Gender" in the data) was just a little bit tricky to deal with is because there were some missing values. 


```r
# Create vector recording the number of times "Gender:" appears in each infobox
gender_check <- infobox %>% 
  lapply(function(x) grepl("Gender:", x)) %>% 
  lapply(sum) 

# List links for athletes that are missing Gender data
individual_links[which(gender_check==0)]
```

```
>   [1] "http://www.sports-reference.com//olympics/athletes/ba/robert-battersby-1.html" 
>   [2] "http://www.sports-reference.com//olympics/athletes/bo/grayson-bourne-1.html"   
>   [3] "http://www.sports-reference.com//olympics/athletes/ca/don-campbell-1.html"     
>   [4] "http://www.sports-reference.com//olympics/athletes/cl/rodney-clarke-1.html"    
>   [5] "http://www.sports-reference.com//olympics/athletes/co/ruddy-cornielle-1.html"  
>   [6] "http://www.sports-reference.com//olympics/athletes/du/pam-dukes-1.html"        
>   [7] "http://www.sports-reference.com//olympics/athletes/gr/eric-graveline-1.html"   
>   [8] "http://www.sports-reference.com//olympics/athletes/gr/cynthia-green-1.html"    
>   [9] "http://www.sports-reference.com//olympics/athletes/he/carol-ann-heavey-1.html" 
>  [10] "http://www.sports-reference.com//olympics/athletes/ho/jean-alix-holmand-1.html"
>  [11] "http://www.sports-reference.com//olympics/athletes/lo/chris-lori-1.html"       
>  [12] "http://www.sports-reference.com//olympics/athletes/me/bruce-merritt-1.html"    
>  [13] "http://www.sports-reference.com//olympics/athletes/mo/moosaka-1.html"          
>  [14] "http://www.sports-reference.com//olympics/athletes/pa/raymond-papa-1.html"     
>  [15] "http://www.sports-reference.com//olympics/athletes/sh/michael-shragge-1.html"  
>  [16] "http://www.sports-reference.com//olympics/athletes/va/jeff-van-de-graaf-1.html"
>  [17] "http://www.sports-reference.com//olympics/athletes/ze/robert-zedwane-1.html"
```

There are 17 athletes missing the Gender variable, which is a small enough number that it is easy to follow up on each missing value and employ some common sense to figure out whether they are male or female. For each of these athletes, their sex was obvious from some combination of their name, the events they participated in, or Google search results. Four of them were female, and the other thirteen were male. 

In light of this, I wrote a script that handles the missing values by assuming they are male. Of course, this means that those four females with missing data will be miscoded as male, so I simply made a note of who these individuals these were and recoded their Sex variable manually. Here is the script.


```r
# For every line containing "Gender:"
# Check whether sex = F or sex = M
# If "Gender:" is not found, sex = M
info <- infobox %>% 
  lapply(function(x) {
    # try to grep line containing "Gender:"
    x <- x[grep("Gender:",x)] 
    # If nothing was grepped...
    if (length(x) == 0) {
      sex <- "M"
      } else {
        # If something was grepped, try to grep "Female"
        sex <- grepl("Female",x) %>% 
          # If "Female" is present, sex=F, otherwise sex=M 
          ifelse("F","M")
      }
    return(sex)
  }) %>%
  unlist %>% 
  factor %>% 
  add_column(info, Sex = .)

# Manually fix females with missing data
info$Sex[c(30521, 42623, 47015, 81716)] <- "F"
```

Do a couple quick checks for NULL or unexpected entries. 


```r
# Check: should be no NULL entries
info$Sex %>% is.null %>% sum 
```

```
>  [1] 0
```

```r
# Check: should be only M and F 
info$Sex %>% unique 
```

```
>  [1] M F
>  Levels: F M
```

Everything looks good - we have clean data on the sex of every athlete. Now let's move on to the Height variable, which gets trickier still.  

### Height

Extracting Height presents a new challenge since we want to pull a numeric value out of a character string. For this, we need [regular expressions](https://en.wikipedia.org/wiki/Regular_expression). 

First, check for missing data and make sure every infobox has at most 1 line containing "Height:".


```r
# How many missing entries?
n_athletes - (infobox %>% 
                lapply(function(x) grepl("Height:", x)) %>% 
                lapply(sum) %>% 
                unlist %>% 
                sum) # 33923 missing
```

```
>  [1] 33923
```

```r
# Check that there are either 0 or 1 entries per infobox
infobox %>% 
  lapply(function(x) grepl("Height:", x)) %>% 
  lapply(sum) %>% 
  unique
```

```
>  [[1]]
>  [1] 1
>  
>  [[2]]
>  [1] 0
```

Running `infobox %>% lapply(function(x) x[grep("Height:", x)]) %>% unique %>% unlist` will print all of the unique lines containing "Height:", and is useful to get an overview of the format of this variable. Luckily, there is a consistent format: "Height: x-x (x cm)", where 'x' represents a number. So, we can isolate height in centimeters by extracting everything between the parentheses, and then can remove the " cm" to isolate the number. Here is a script to do this and then add the results as a new column to `info`.


```r
# For every line containing "Height:"
# grep the number between parentheses
info <- infobox %>% 
  lapply(function(x) {
    # try to grep line containing "Height:"
    x <- x[grep("Height:",x)] 
    # if something was grepped... 
    if (length(x) > 0) {
      # isolate text between the parentheses
      x <- gsub(".*\\((.*)\\).*", "\\1", x)
      # isolate number and convert to numeric
      height <- as.numeric(gsub(" cm", "", x))
    } else {
      # if nothing was grepped... 
      height <- NA
    }
    return(height)
  }) %>%
  unlist %>% 
  add_column(info, Height = .)
```

To ensure that none of the entries were somehow messed up and produced NA values, let's make sure there are the same number of missing Height entries as our initial check. 


```r
# How many missing entries?
info$Height %>% is.na %>% sum # 33923
```

```
>  [1] 33923
```

This checks out: there are the same number of NAs now as there were in our initial check.

Finally, check a histogram of the height data to make sure it is reasonable. 


```r
# Histogram of height data
hist(info$Height, main="Height (cm)") 
```

<img src="/assets/Rfigs/post_2018-05_height_hist-1.png" title="plot of chunk post_2018-05_height_hist" alt="plot of chunk post_2018-05_height_hist" style="display: block; margin: auto;" />

Everything looks good. We can now move on to our final variable of interest in `infobox`, which just so happens to be the trickiest of all the variables.

### Weight

Like Height, the weight variable requires regular expressions to extract numbers from a string. However, there is an additional challenge due to the fact that the weight variable was recorded in a variety of ways that make it impossible to extract the desired value from every infobox using a single regular expression. I will come back to this in a moment.

To begin, check for missing data and make sure that every infobox has at most 1 line containing "Weight:".


```r
# Weight (kg)
n_athletes - (infobox %>% 
                lapply(function(x) grepl("Weight:", x)) %>% 
                lapply(sum) %>% 
                unlist %>% 
                sum) # 34892 missing
```

```
>  [1] 34892
```

```r
# Check that there are either 0 or 1 entries per infobox
infobox %>% 
  lapply(function(x) grepl("Weight:", x)) %>% 
  lapply(sum) %>% 
  unique 
```

```
>  [[1]]
>  [1] 1
>  
>  [[2]]
>  [1] 0
```

Running `infobox %>% lapply(function(x) x[grep("Weight:", x)]) %>% unique %>% unlist` to print all the unique lines containing "Weight:" reveals that Weight is reported much less consistently than the Height variable. I identified 5 different formats for this variable:

1. "Weight: x lbs (x kg)"
2. "Weight: xx kg"
3. "Weight: xx-xx kg"
4. "Weight: xx, xx kg"
5. "Weight: xx, xx, xx kg"

The first format can be handled in the same way as the Height variable, but the other four require different approaches. My strategy to distinguish between these different formats is to first check if "lbs" is present in the string, and if it is I handle the string in the same way as the Height variable. If "lbs" is absent, then the next step is to split the string at each white space. For formats 2 and 3, the result of the string split will be 3 values, while format 4 results in 4 values and format 5 results in 5 values. To distinguish between formats 2 and 3, I check the second value in the split string for a "-" character. Once the format has been identified, it is easy to pick out the number(s) from the split string, and if there are multiple numbers (as is the case for formats 3, 4, and 5) they can be averaged. Here is the script. 


```r
# Pull numeric weight in kg from each infobox that has a "Weight:" line
# When multiple values are provided, I will average them
info <- infobox %>% 
  lapply(function(x) {
    # Try to grep line containing "Weight:"
    x <- x[grep("Weight:",x)] 
    if (length(x) > 0) {
      # If "lbs" is present, extract text between parentheses
      # and then isolate the number (same as for Height)
      if (length(grep("lbs", x)) == 1) {
        x <- gsub(".*\\((.*)\\).*", "\\1", x)
        weight <- as.numeric(gsub(" kg", "", x))
      } else {
        # If "lbs" is absent, split string by white space
        x <- strsplit(x, " ")[[1]]
        if (length(x) == 3) {
          weight <- strsplit(x[[2]],"-")[[1]] %>% as.numeric %>% mean
        } else if (length(x) == 4) {
          weight <- c(gsub(",","",x[2]),x[3]) %>% as.numeric %>% mean
        } else if (length(x) == 5) {
          weight <- c(gsub(",","",x[2:3]),x[4]) %>% as.numeric %>% mean
        } else weight <- -1
      }
    } else weight <- NA
    return(weight)
  }) %>%
  unlist %>% add_column(info, Weight = .)
```

```
>  Warning in function_list[[i]](value): NAs introduced by coercion
```

Hmm... this generated a warning - it appears that unexpected NAs were produced. This suggests that my function was not able to handle every entry properly. 

As with the Height data, let's count the missing entries and compare it to our initial tabulation of missing data, but in light of the warning we can expect to see extra NAs this time.


```r
# How many missing entries?
info$Weight %>% is.na %>% sum # 34892
```

```
>  [1] 34893
```

Indeed, there is one additional NA from what we expect. This indicates that one of the infoboxes containing a "Weight:" line somehow yielded an NA in our script. To find the offending infobox, we can use the following code.


```r
# Vector indicating whether there is a line with
# "Weight:" in each infobox (0 = none)
unparsed <- infobox %>%
  lapply(function(x) grepl("Weight:", x)) %>%
  lapply(sum) %>%
  unlist %>%
  as.logical
  
# Vector indicating whether the parsed weight daya
# is an NA (0 = NA)
parsed <- ifelse(is.na(info$Weight), 0, 1) 

# The sums of these vectors indicate whether there is
# 0: no "Weight:" in the infobox and my function produced NA 
# 1: "Weight:" is in the infobox but my function produced NA
# 2: "Weight:" is in the infobox and my function did not produce NA
sums <- parsed + unparsed

# There should be one "1" in this vector corresponding
# to the entry that produced an errant NA value
infobox[which(sums==1)]
```

```
>  [[1]]
>  [1] "Full name: Nicholas Jean \"Nick\" Buckfield"              
>  [2] "Gender: Male"                                             
>  [3] "Height: 6-0.5 (185 cm)"                                   
>  [4] "Weight: 77,5 kg"                                          
>  [5] "Born: June 5, 1973 in Crawley, West Sussex, Great Britain"
>  [6] ""                                                         
>  [7] "Affiliations: Crawley AC, Crawley (GBR)"                  
>  [8] "Country:  Great Britain"                                  
>  [9] "Sport: Athletics"
```

Aha... the problem is that there is no space between the comma and the second value, which is a format that my script was not prepared to handle. Since there is just one problematic entry (which is clearly the result of a typo during the original data entry), I will fix it manually rather than changing my script to handle this one case. Since it doesn't make much sense for someone to weight 5 kg, I assume the comma here is supposed to be a decimal point.


```r
# Fix the one problematic entry
info$Weight[which(sums==1)] <- 77.5 
```

Finally, check a histogram of the weight data to make sure it is reasonable. 


```r
# Histogram of weight data
hist(info$Weight, main="Weight (kg)")
```

<img src="/assets/Rfigs/post_2018-05_weight_hist-1.png" title="plot of chunk post_2018-05_weight_hist" alt="plot of chunk post_2018-05_weight_hist" style="display: block; margin: auto;" />

And we're done parsing `infobox`! We now have a dataframe, `info`, containing one row per athlete: Name, Sex, Height, and Weight. Now we can turn our attention to `results_table`, which contains the results from each athlete's participation in the Olympics. 

## Parsing the 'results_table' list

Luckily, `results_table` is incredibly easy to parse since the results tables are presented in a perfectly consistent way across all of the athlete pages. The following code confirms that there are always 10 columns in the results tables (except when the entry is NULL), and there is no variation in the names of these 10 columns.


```r
# Check number of columns
results_table %>% lapply(ncol) %>% unique 
```

```
>  [[1]]
>  [1] 10
>  
>  [[2]]
>  NULL
```

```r
# Check names of the columns
results_table %>% lapply(names) %>% unique 
```

```
>  [[1]]
>   [1] "Games" "Age"   "City"  "Sport" "Event" "Team"  "NOC"   "Rank" 
>   [9] "Medal" ""     
>  
>  [[2]]
>  NULL
```

Since there are clearly some NULL entries, let's check how many there are and then drop them from *both* `results_table` and `info`. We don't need to keep data on any athletes who didn't actually participate in events, or who lack any data on their events for some reason.


```r
# How many null entries? 
results_table %>% lapply(is.null) %>% unlist %>% sum
```

```
>  [1] 13
```

```r
# Drop these
nulls <- which(results_table %>% lapply(is.null) %>% unlist) 

# Drop NULL entries from both info and results
info <- info[-nulls,]
results_table <- results_table[-nulls]

# Check the new number of athletes
length(results_table) # 135571
```

```
>  [1] 135571
```

After dropping the athletes with missing data, there are now 135,571 athletes. 

Now, let's limit the dataframes to the variables we are interested in keeping. The final column of each dataframe is empty, so we can drop that, and I also want to drop the variable 'Rank' since it is only interesting within the context of a specific event. 


```r
# Keep columns of interest (drop 'Rank' and empty final column)
keep <- c("Games", "Age", "City", "Sport", "Event", "Team", "NOC", "Medal")
results_table <- lapply(results_table, function (x) {x[,keep]})
```

Pretty painless! Now we need to merge `info` and `results_table` into a single dataframe with each row representing an athlete-event.

## Merging 'info' and 'results_table' 

We can merge `info` (a dataframe with N rows) with `results_table` (a list of dataframes with N elements) in four steps: 


```r
# Add an ID column to the 'info' dataframe
info$ID <- as.character(1:nrow(info))

# Use the same ID variable to name the elements in 'results_table'
results_table <- setNames(results_table, info$ID)

# Use 'rbindlist' from the 'data.table' package to convert 'results_table'
# to a dataframe with the element names as an ID column
data <- rbindlist(results_table, use.names=TRUE, idcol="ID") 

# join 'info' and 'results_table' by the ID column
data <- right_join(info, data, by="ID")
```

We now have a dataframe with the structure that we want: each row is an athlete-event. 

There are a couple of tweaks I want to make before we move on to checking and cleaning up these variables. First, the Games variable is a string with the format `"Year Season"`, e.g., "2014 Sochi", but it will be useful to have separate variables for "Year" and "Season", so let's create those.


```r
# Games must be a character vector to use 'gsub'
data$Games <- data$Games %>% as.character

# Replace letters after the space with ""
data$Year <- data$Games %>% gsub(" [A-z]*", "", .) %>% as.numeric

# Replace digits before the space with ""
data$Season <- data$Games %>% gsub("[0-9]* ", "", .)
```

Finally, let's reorder the variables in a somewhat more logical way.


```r
# Reorder the variables
data <- data[,c("ID","Name","Sex","Age","Height","Weight","Team","NOC","Games","Year","Season","City","Sport","Event","Medal")]

# Check data
data %>% print(width=Inf)
```

```
>  # A tibble: 271,116 x 15
>     ID    Name                     Sex   Age   Height Weight Team          
>     <chr> <chr>                    <fct> <fct>  <dbl>  <dbl> <fct>         
>   1 1     A Dijiang                M     24       180     80 China         
>   2 2     A Lamusi                 M     23       170     60 China         
>   3 3     Gunnar Nielsen Aaby      M     24        NA     NA Denmark       
>   4 4     Edgar Lindenau Aabye     M     34        NA     NA Denmark/Sweden
>   5 5     Christine Jacoba Aaftink F     21       185     82 Netherlands   
>   6 5     Christine Jacoba Aaftink F     21       185     82 Netherlands   
>   7 5     Christine Jacoba Aaftink F     25       185     82 Netherlands   
>   8 5     Christine Jacoba Aaftink F     25       185     82 Netherlands   
>   9 5     Christine Jacoba Aaftink F     27       185     82 Netherlands   
>  10 5     Christine Jacoba Aaftink F     27       185     82 Netherlands   
>     NOC   Games        Year Season City        Sport        
>     <fct> <chr>       <dbl> <chr>  <fct>       <fct>        
>   1 CHN   1992 Summer  1992 Summer Barcelona   Basketball   
>   2 CHN   2012 Summer  2012 Summer London      Judo         
>   3 DEN   1920 Summer  1920 Summer Antwerpen   Football     
>   4 DEN   1900 Summer  1900 Summer Paris       Tug-Of-War   
>   5 NED   1988 Winter  1988 Winter Calgary     Speed Skating
>   6 NED   1988 Winter  1988 Winter Calgary     Speed Skating
>   7 NED   1992 Winter  1992 Winter Albertville Speed Skating
>   8 NED   1992 Winter  1992 Winter Albertville Speed Skating
>   9 NED   1994 Winter  1994 Winter Lillehammer Speed Skating
>  10 NED   1994 Winter  1994 Winter Lillehammer Speed Skating
>     Event                   Medal
>     <fct>                   <fct>
>   1 Men's Basketball        ""   
>   2 Men's Extra-Lightweight ""   
>   3 Men's Football          ""   
>   4 Men's Tug-Of-War        Gold 
>   5 Women's 500 metres      ""   
>   6 Women's 1,000 metres    ""   
>   7 Women's 500 metres      ""   
>   8 Women's 1,000 metres    ""   
>   9 Women's 500 metres      ""   
>  10 Women's 1,000 metres    ""   
>  # ... with 271,106 more rows
```

We aren't quite finished. The variables need to be checked for issues and some of them will require some attention. However, this post is getting pretty long, and this seems like a good stopping point since we have achieved the overarching data structure that we want. I will present the fine-tuning stuff in the next post. 

