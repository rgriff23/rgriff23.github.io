---
title: 'Olympic history: Data wrangling (part 2)'
date: "2018-05-28"
layout: post
tags: R olympics sports tidyverse
comments: yes
---





In my last post, I scraped data on 135,584 Olympic athletes from www.sports-reference.com, and the data was saved in two lists containing information on each athlete in different formats. In its present form, the data is pretty useless. In this post, I tidy up this data so that it can actually be analyzed. 

Normally, this part of my work flow would get buried in a file somewhere that I'd expect nobody to ever look at. However, a big part of my motivation for doing this project was learning `tidyverse`, and the data wrangling stage was one of the places where I felt the advantages of `tidyverse` the most, so I'm going to dive into the wrangling this once. If you aren't interested in the wrangling and you just want to see pretty plots about Olympic history, then stay tuned for my later posts in which I analyze the prettied-up data.

## Set up

To follow along with this code, you must start by importing the data and running the code in the [previous post](https://rgriff23.github.io/2018/05/28/olympic-history-2-data-wrangling-1.html). You'll need to load the `tidyverse` package too.

## Check variables for weird values

The dataframe we are dealing with has 15 variables. Let's take a peek:


```r
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

Now let's go through each variable in turn, check for weird values, and if we find something weird, deal with it.

'ID' is just a unique identifier for each athlete, and there are no issues there. The first variable that needs our attention is 'Name', which contains the name of each athlete. Inspecting this variable reveals widespread encoding issues. Since I'm not particularly concerned with displaying athlete's names 'correctly', but I do want to make sure that weird characters don't confuse R during analysis, I'm going to opt for a quick fix and simply replace all non-ASCII characters with a blank space. 


```r
# Remove non-ascii characters from athlete names
data$Name <- data$Name %>% iconv("UTF-8","ASCII", sub="")
```

The Sex variable seems fine: we can confirm that M and F are the only values for this variable.


```r
# Check unique values
data$Sex %>% unique
```

```
>  [1] M F
>  Levels: F M
```

Let's look at unique values for the Age variable.


```r
# Check unique values
data$Age %>% unique
```

```
>   [1] 24 23 34 21 25 27 31 33 18 26 22 30 32 28 54 20 17 43 47 29 41 45 49
>  [24] 53 57    19 38 35 16 37 15 42 46 40 36 14 39 48 52 44 55 50 71 63 51
>  [47] 58 13 60 75 65 56 64 68 84 12 72 59 61 70 74 62 67 69 73 66 11 76 88
>  [70] 96 80 10 81 77 97
>  75 Levels: 24 23 34 21 25 27 31 33 18 26 22 30 32 28 54 20 17 43 47 ... 97
```

This seems fine, but it's weird that Age is coded as a factor and not an integer. Let's fix that.


```r
# Convert Age variable to integer type
data$Age <- data$Age %>% parse_integer
```

Now that Age is coded as an integer, we can check for weird values using functions that work on numbers, which is nice. For example, let's look at the range.


```r
data$Age %>% range(na.rm=TRUE)
```

```
>  [1] 10 97
```

In case you are worried that the lower limit of 10 is a mistake, I assure you that it isn't. Not only was there a 10 year old in the 1896 Olympics, but he won a [bronze medal](https://www.topendsports.com/events/summer/oldest-youngest.htm) in gymnastics. 

The 97 year old is a weirder situation... the "athlete" in question was John Quincy Adams Ward, a sculptor whose entry was submitted [posthumously](https://www.sports-reference.com/olympics/athletes/wa/john-quincy-ward-1.html) to the 1928 Olympics. So he wasn't exactly 97 years old. He was dead. But he *would* have been 97 were he alive. 

Obviously there is an issue with this. How does one record the age of an Olympian who was dead at the time of the competition? That's not a question I imagined I would have to answer, but hey... the history of the Olympics is weird. Arguably, there is an issue with including the [Art Competitions](https://en.wikipedia.org/wiki/Art_competitions_at_the_Summer_Olympics) in this database at all, since architecture and singing are generally not considered Olympic events these days. But I'll deal with the Art Competitions in a later post. For now, we can move ahead knowing that this is not a data entry error. 

The next two variables, Height and Weight, should be fine since we already inspected them pretty carefully in the first data wrangling post. Let's double check their range.


```r
# Check range
data$Height %>% range(na.rm=TRUE)
```

```
>  [1] 127 226
```

```r
data$Weight %>% range(na.rm=TRUE)
```

```
>  [1]  25 214
```

The next variable is Team, and this one has a lot of encoding issues, just like the Name variable. I will deal with them in the same way. I don't expect this variable to be very useful in future analyses since the NOC variable gives a more consistent indicator of where athletes come from, but I'm keeping it in the data set just in case. Now let's get rid of those pesky non-ASCII characters.


```r
# Remove non-ASCII characters
data$Team <- data$Team %>% iconv("UTF-8","ASCII", sub="")
```

The NOC (National Olympic Committee) variable is a factor with 230 levels, and it seems okay. 


```r
# Check unique values
data$NOC %>% levels # 230 levels
```

```
>    [1] "CHN" "DEN" "NED" "USA" "FIN" "NOR" "ROU" "EST" "FRA" "MAR" "ESP"
>   [12] "EGY" "IRI" "BUL" "ITA" "CHA" "AZE" "SUD" "RUS" "ARG" "CUB" "BLR"
>   [23] "GRE" "CMR" "TUR" "CHI" "MEX" "URS" "NCA" "HUN" "NGR" "ALG" "KUW"
>   [34] "BRN" "PAK" "IRQ" "UAR" "LIB" "QAT" "MAS" "GER" "CAN" "IRL" "AUS"
>   [45] "RSA" "ERI" "TAN" "JOR" "TUN" "LBA" "BEL" "DJI" "PLE" "COM" "KAZ"
>   [56] "BRU" "IND" "KSA" "SYR" "MDV" "ETH" "UAE" "YAR" "INA" "PHI" "SGP"
>   [67] "UZB" "KGZ" "TJK" "EUN" "JPN" "CGO" "SUI" "BRA" "FRG" "GDR" "MON"
>   [78] "ISR" "URU" "SWE" "ISV" "SRI" "ARM" "CIV" "KEN" "BEN" "UKR" "GBR"
>   [89] "GHA" "SOM" "LAT" "NIG" "MLI" "AFG" "POL" "CRC" "PAN" "GEO" "SLO"
>  [100] "CRO" "GUY" "NZL" "POR" "PAR" "ANG" "VEN" "COL" "BAN" "PER" "ESA"
>  [111] "PUR" "UGA" "HON" "ECU" "TKM" "MRI" "SEY" "TCH" "LUX" "MTN" "CZE"
>  [122] "SKN" "TTO" "DOM" "VIN" "JAM" "LBR" "SUR" "NEP" "MGL" "AUT" "PLW"
>  [133] "LTU" "TOG" "NAM" "AHO" "ISL" "ASA" "SAM" "RWA" "DMA" "HAI" "MLT"
>  [144] "CYP" "GUI" "BIZ" "YMD" "KOR" "THA" "BER" "ANZ" "SCG" "SLE" "PNG"
>  [155] "YEM" "IOA" "OMA" "FIJ" "VAN" "MDA" "YUG" "BAH" "GUA" "SRB" "IVB"
>  [166] "MOZ" "CAF" "MAD" "MAL" "BIH" "GUM" "CAY" "SVK" "BAR" "GBS" "TLS"
>  [177] "COD" "GAB" "SMR" "LAO" "BOT" "ROT" "CAM" "PRK" "SOL" "SEN" "CPV"
>  [188] "CRT" "GEQ" "BOL" "SAA" "AND" "ANT" "ZIM" "GRN" "HKG" "LCA" "FSM"
>  [199] "MYA" "MAW" "ZAM" "RHO" "TPE" "STP" "MKD" "BOH" "TGA" "LIE" "MNE"
>  [210] "GAM" "COK" "ALB" "WIF" "SWZ" "BUR" "NBO" "BDI" "ARU" "NRU" "VNM"
>  [221] "VIE" "BHU" "MHL" "KIR" "UNK" "TUV" "NFL" "KOS" "SSD" "LES"
```

The Games variable includes an identifer for each Olympic Games in the format "Year Season". It has 52 levels, and inspecting them reveals one oddity.


```r
# Check unique values
data$Games %>% levels # 52 levels
```

```
>  NULL
```

All of the Games are either 'Summer' or 'Winter', except for one: "1956 Equestrian". We can see this more easily by inspecting the Season variable.


```r
# Check unique values
data$Season %>% levels
```

```
>  NULL
```

The reason for this is that in 1956, the Equestrian events were held 5 months earlier and in a [different city](https://en.wikipedia.org/wiki/Equestrian_at_the_1956_Summer_Olympics) than the other Summer Games events, so it became known as the 1956 Equestrian Games. However, in every other Olympics, Equestrian has been considered a part of the Summer Games, and I see no advantage to given these events such a special distinction. So let's replace "Equestrian" with "Summer" for all of these entries.


```r
# Change 'Equestrian' to 'Summer' in Games and Season variables
data$Games[data$Games == "1956 Equestrian"] <- "1956 Summer"
data$Season[data$Season == "Equestrian"] <- "Summer"
data$Season <- data$Season %>% as.factor
```

Moving on, the Year variable seems fine.


```r
# Check unique values
data$Year %>% unique # 35
```

```
>   [1] 1992 2012 1920 1900 1988 1994 1932 2002 1952 1980 2000 1996 1912 1924
>  [15] 2014 1948 1998 2006 2008 2016 2004 1960 1964 1984 1968 1972 1936 1956
>  [29] 1928 1976 2010 1906 1904 1908 1896
```

The next variable is City, and this one has a few encoding problems.


```r
# Check unique values
data$City %>% levels # 42 levels
```

```
>   [1] "Barcelona"                "London"                  
>   [3] "Antwerpen"                "Paris"                   
>   [5] "Albertville"              "Calgary"                 
>   [7] "Lillehammer"              "Los Angeles"             
>   [9] "Salt Lake City"           "Helsinki"                
>  [11] "Lake Placid"              "Sydney"                  
>  [13] "Atlanta"                  "Stockholm"               
>  [15] "Sochi"                    "Nagano"                  
>  [17] "Torino"                   "Beijing"                 
>  [19] "Rio de Janeiro"           "Athina"                  
>  [21] "Innsbruck"                "Squaw Valley"            
>  [23] "Sarajevo"                 "Ciudad de MÃ\u0083Â©xico"
>  [25] "MÃ\u0083Â¼nchen"          "Seoul"                   
>  [27] "Berlin"                   "Cortina d'Ampezzo"       
>  [29] "Oslo"                     "Melbourne"               
>  [31] "Roma"                     "Amsterdam"               
>  [33] "MontrÃ\u0083Â©al"         "Moskva"                  
>  [35] "Tokyo"                    "Vancouver"               
>  [37] "Grenoble"                 "Sapporo"                 
>  [39] "Chamonix"                 "St. Louis"               
>  [41] "Sankt Moritz"             "Garmisch-Partenkirchen"
```

In the order they appear above, the three badly-encoded cities are Mexico City, Munich, and Montreal. Let's fix those - note that we have to convert the variable to a character type in order to easily make these changes, and then change it back to a factor at the end.


```r
# Fix text encoding for cities
cities <- data$City %>% unique
problem_cities <- cities[c(24,25,33)]
correct_cities <- c("Mexico City","Munich","Montreal")
data$City <- data$City %>% as.character
data$City[data$City == problem_cities[1]]  <- correct_cities[1]
data$City[data$City == problem_cities[2]]  <- correct_cities[2]
data$City[data$City == problem_cities[3]]  <- correct_cities[3]
data$City <- data$City %>% as.factor
```

The Sport variable seems okay. It is a factor with 66 levels.


```r
data$Sport %>% levels # 66 levels
```

```
>   [1] "Basketball"                "Judo"                     
>   [3] "Football"                  "Tug-Of-War"               
>   [5] "Speed Skating"             "Cross Country Skiing"     
>   [7] "Athletics"                 "Ice Hockey"               
>   [9] "Swimming"                  "Badminton"                
>  [11] "Sailing"                   "Biathlon"                 
>  [13] "Gymnastics"                "Art Competitions"         
>  [15] "Alpine Skiing"             "Handball"                 
>  [17] "Weightlifting"             "Wrestling"                
>  [19] "Luge"                      "Water Polo"               
>  [21] "Hockey"                    "Rowing"                   
>  [23] "Bobsleigh"                 "Fencing"                  
>  [25] "Equestrianism"             "Shooting"                 
>  [27] "Boxing"                    "Taekwondo"                
>  [29] "Cycling"                   "Diving"                   
>  [31] "Canoeing"                  "Tennis"                   
>  [33] "Modern Pentathlon"         "Figure Skating"           
>  [35] "Golf"                      "Softball"                 
>  [37] "Archery"                   "Volleyball"               
>  [39] "Synchronized Swimming"     "Table Tennis"             
>  [41] "Nordic Combined"           "Baseball"                 
>  [43] "Rhythmic Gymnastics"       "Freestyle Skiing"         
>  [45] "Rugby Sevens"              "Trampolining"             
>  [47] "Beach Volleyball"          "Triathlon"                
>  [49] "Ski Jumping"               "Curling"                  
>  [51] "Snowboarding"              "Rugby"                    
>  [53] "Short Track Speed Skating" "Skeleton"                 
>  [55] "Lacrosse"                  "Polo"                     
>  [57] "Cricket"                   "Racquets"                 
>  [59] "Motorboating"              "Military Ski Patrol"      
>  [61] "Croquet"                   "Jeu De Paume"             
>  [63] "Roque"                     "Alpinism"                 
>  [65] "Basque Pelota"             "Aeronautics"
```

The Event variable has quite a few encoding problems. You can see one in the last level printed below (there's too many events to print them all).


```r
# Check unique values
data$Event %>% levels %>% head # 679 levels
```

```
>  [1] "Men's Basketball"        "Men's Extra-Lightweight"
>  [3] "Men's Football"          "Men's Tug-Of-War"       
>  [5] "Women's 1,000 metres"    "Women's 500 metres"
```

I want to get these variables right and couldn't figure out an easy way to do it, so I finally decided to do it by hand. I'm not sure if a more elegant solution is possible, but the number of issues here is small enough that it didn't seem worth it to spend much more time searching for a way to automate this. Here is how I replaced the badly-encoded Events (sorry this is a lot of text).   


```r
# Fix text encoding for events
events <- data$Event %>% unique
problem_events <- events[c(10,13,53,56,57,66,103,132,158,170,172,205,209,223,237,
                           252,276,277,288,380,400,408,416,449,455,466,470,494,
                           495,528,534,540,563,566,579,619,625,655,664,677)]
correct_events <- c("Men's 4 x 10 kilometres Relay", "Women's 4 x 100 metres Relay",
                    "Men's 4 x 100 metres Medley Relay","Men's epee, Individual",
                    "Men's epee, Team","Men's 4 x 100 metres Relay",
                    "Men's 4 x 200 metres Freestyle Relay","Men's 4 x 400 metres Relay",
                    "Women's 4 x 100 metres Medley Relay","Women's epee, Individual",
                    "Men's 4 x 100 metres Freestyle Relay","Men's 4 x 7.5 kilometres Relay",
                    "Women's 4 x 100 metres Freestyle Relay","Women's 4 x 400 metres Relay",
                    "Mixed 2 x 6 kilometres and 2 x 7.5 kilometres Relay","Women's 3 x 5 kilometres Relay",
                    "Women's 3 x 7.5 kilometres Relay","Women's 4 x 7.5 kilometres Relay",
                    "Men's 4 x 50 Yard Freestyle Relay","Women's 4 x 200 metres Freestyle Relay",
                    "Women's 4 x 6 kilometres Relay","Men's 333 metres Time Trial",
                    "Women's 4 x 5 kilometres Relay","Mixed 40 metres",
                    "Men's Kayak Relay 4 x 500 metres","Men's epee, Masters, Individual",
                    "Women's epee, Team","Men's 1/4 mile",
                    "Men's 1/2 mile","Mixed 0.5-1 Ton",
                    "Men's epee, Masters and Amateurs, Individual","Men's 4 x 250 metres Freestyle Relay",
                    "Men's Au Cordon Dore, 50 metres","Mixed 30 metres",
                    "Men's 1/3 mile","Mixed 0-0.5 Ton",
                    "Men's Dueling Pistol Au Vise 20 metres","Men's Sur La Perche a La Herse",
                    "Men's Sur La Perche a La Pyramide","Men's Au Cordon Dore, 33 metres")

# Convert to character type to allow changes
data$Event <- data$Event %>% as.character

# Loop through each problem event and replace with corrected names
for (i in 1:length(problem_events)) {
  data$Event[data$Event == problem_events[i]] <- correct_events[i]
}

# Convert back to factor type
data$Event <- data$Event %>% as.factor
```

There is one more issue I want to address related to the Event variable. Some of the 'same' Events actually correspond to different sports... for example, something like "Men's 100 meters" could correspond to running, swimming, or biking. To differentiate Events of the same name but different sports, I will replace the current Event column with a Sport-Event column that pastes together the name of the sport and the name of the event.


```r
# Paste sports and events together in new Event column
data$Event <- paste(data$Sport, data$Event) %>% as.factor
```

Finally, our last variable is Medal, which indicates whether an athlete won a gold, silver, bronze, or nothing in each event.


```r
# Check unique values
data$Medal %>% levels 
```

```
>  [1] ""       "Gold"   "Bronze" "Silver"
```

The only issue I have with this variable is that the empty character vectors should be replaced with NAs, so let's do that.


```r
# Replace "" with NA
data$Medal[data$Medal == ""] <- NA
```

And that's it! That was a bit tedious, but it is important to check all your variables for unusual values and make sure you really know your data. The cleaned up data file, `athlete_events.csv`, can be found in the `data` folder of the GitHub repo, and is also available on [Figshare](https://figshare.com/articles/Olympic_history_longitudinal_data_scraped_from_www_sports-reference_com/6121274). 

I'll be analyzing this data in future posts, so stay tuned. And if you do anything interesting with the data, let me know! 
