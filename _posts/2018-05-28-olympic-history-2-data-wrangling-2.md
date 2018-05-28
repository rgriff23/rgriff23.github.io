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

The Event variable has quite a few encoding problems. 


```r
# Check unique values
data$Event %>% levels # 679 levels
```

```
>    [1] "Men's Basketball"                                                             
>    [2] "Men's Extra-Lightweight"                                                      
>    [3] "Men's Football"                                                               
>    [4] "Men's Tug-Of-War"                                                             
>    [5] "Women's 1,000 metres"                                                         
>    [6] "Women's 500 metres"                                                           
>    [7] "Men's 10 kilometres"                                                          
>    [8] "Men's 10/15 kilometres Pursuit"                                               
>    [9] "Men's 30 kilometres"                                                          
>   [10] "Men's 4 Ã\u0083Â\u0097 10 kilometres Relay"                                   
>   [11] "Men's 50 kilometres"                                                          
>   [12] "Women's 100 metres"                                                           
>   [13] "Women's 4 Ã\u0083Â\u0097 100 metres Relay"                                    
>   [14] "Men's Ice Hockey"                                                             
>   [15] "Men's 400 metres Freestyle"                                                   
>   [16] "Men's Singles"                                                                
>   [17] "Women's Windsurfer"                                                           
>   [18] "Women's 7.5 kilometres Sprint"                                                
>   [19] "Men's 200 metres Breaststroke"                                                
>   [20] "Men's 400 metres Breaststroke"                                                
>   [21] "Men's Floor Exercise"                                                         
>   [22] "Men's Horizontal Bar"                                                         
>   [23] "Men's Horse Vault"                                                            
>   [24] "Men's Individual All-Around"                                                  
>   [25] "Men's Parallel Bars"                                                          
>   [26] "Men's Pommelled Horse"                                                        
>   [27] "Men's Rings"                                                                  
>   [28] "Men's Team All-Around"                                                        
>   [29] "Men's Shot Put"                                                               
>   [30] "Mixed Sculpturing, Unknown Event"                                             
>   [31] "Men's Combined"                                                               
>   [32] "Men's Downhill"                                                               
>   [33] "Men's Giant Slalom"                                                           
>   [34] "Men's Slalom"                                                                 
>   [35] "Men's Super G"                                                                
>   [36] "Women's Handball"                                                             
>   [37] "Women's Super-Heavyweight"                                                    
>   [38] "Men's Light-Heavyweight, Greco-Roman"                                         
>   [39] "Men's 1,500 metres"                                                           
>   [40] "Men's 500 metres"                                                             
>   [41] "Men's Team All-Around, Free System"                                           
>   [42] "Women's Singles"                                                              
>   [43] "Men's Water Polo"                                                             
>   [44] "Mixed Three Person Keelboat"                                                  
>   [45] "Women's Hockey"                                                               
>   [46] "Men's Lightweight Double Sculls"                                              
>   [47] "Men's Pole Vault"                                                             
>   [48] "Men's High Jump"                                                              
>   [49] "Men's Two Person Dinghy"                                                      
>   [50] "Men's Four"                                                                   
>   [51] "Men's 100 metres Butterfly"                                                   
>   [52] "Men's 200 metres Butterfly"                                                   
>   [53] "Men's 4 Ã\u0083Â\u0097 100 metres Medley Relay"                               
>   [54] "Women's Football"                                                             
>   [55] "Men's Ã\u0083Â\u0089pÃ\u0083Â©e, Individual"                                  
>   [56] "Men's Ã\u0083Â\u0089pÃ\u0083Â©e, Team"                                        
>   [57] "Men's Foil, Individual"                                                       
>   [58] "Men's 10,000 metres"                                                          
>   [59] "Men's 5,000 metres"                                                           
>   [60] "Mixed 8 metres"                                                               
>   [61] "Mixed Jumping, Individual"                                                    
>   [62] "Men's 15 kilometres"                                                          
>   [63] "Men's Small-Bore Rifle, Prone, 50 metres"                                     
>   [64] "Men's Rapid-Fire Pistol, 25 metres"                                           
>   [65] "Men's Trap"                                                                   
>   [66] "Men's 4 Ã\u0083Â\u0097 100 metres Relay"                                      
>   [67] "Men's Long Jump"                                                              
>   [68] "Men's Light-Welterweight"                                                     
>   [69] "Women's Javelin Throw"                                                        
>   [70] "Men's Heavyweight, Freestyle"                                                 
>   [71] "Men's Flyweight"                                                              
>   [72] "Men's Heavyweight"                                                            
>   [73] "Men's Road Race, Individual"                                                  
>   [74] "Men's Road Race, Team"                                                        
>   [75] "Men's Lightweight"                                                            
>   [76] "Men's Middleweight"                                                           
>   [77] "Men's Coxless Pairs"                                                          
>   [78] "Men's Half-Middleweight"                                                      
>   [79] "Women's Flyweight"                                                            
>   [80] "Women's Basketball"                                                           
>   [81] "Men's Platform"                                                               
>   [82] "Men's Canadian Doubles, 1,000 metres"                                         
>   [83] "Men's Canadian Doubles, 500 metres"                                           
>   [84] "Men's Kayak Fours, 1,000 metres"                                              
>   [85] "Men's Handball"                                                               
>   [86] "Women's Coxless Pairs"                                                        
>   [87] "Men's Featherweight"                                                          
>   [88] "Men's Doubles"                                                                
>   [89] "Mixed Skeet"                                                                  
>   [90] "Men's Featherweight, Freestyle"                                               
>   [91] "Mixed Two Person Heavyweight Dinghy"                                          
>   [92] "Women's Shot Put"                                                             
>   [93] "Men's Coxed Eights"                                                           
>   [94] "Women's 500 metres Time Trial"                                                
>   [95] "Women's Sprint"                                                               
>   [96] "Men's 110 metres Hurdles"                                                     
>   [97] "Mixed Trap"                                                                   
>   [98] "Women's Marathon"                                                             
>   [99] "Men's 100 metres"                                                             
>  [100] "Men's Foil, Team"                                                             
>  [101] "Men's Sabre, Team"                                                            
>  [102] "Men's 100 metres Freestyle"                                                   
>  [103] "Men's 4 Ã\u0083Â\u0097 200 metres Freestyle Relay"                            
>  [104] "Men's Individual"                                                             
>  [105] "Men's Welterweight"                                                           
>  [106] "Men's Double Sculls"                                                          
>  [107] "Men's Quadruple Sculls"                                                       
>  [108] "Men's Coxed Pairs"                                                            
>  [109] "Men's 400 metres Hurdles"                                                     
>  [110] "Men's 400 metres"                                                             
>  [111] "Men's Hammer Throw"                                                           
>  [112] "Men's 800 metres"                                                             
>  [113] "Men's Hockey"                                                                 
>  [114] "Women's Slalom"                                                               
>  [115] "Women's Single Sculls"                                                        
>  [116] "Men's 50 metres Freestyle"                                                    
>  [117] "Women's Featherweight"                                                        
>  [118] "Women's Water Polo"                                                           
>  [119] "Mixed Three-Day Event, Individual"                                            
>  [120] "Mixed Three-Day Event, Team"                                                  
>  [121] "Mixed Team"                                                                   
>  [122] "Women's Three Person Keelboat"                                                
>  [123] "Women's Road Race, Individual"                                                
>  [124] "Women's Individual"                                                           
>  [125] "Women's Softball"                                                             
>  [126] "Men's Heavyweight, Greco-Roman"                                               
>  [127] "Men's Volleyball"                                                             
>  [128] "Women's Heavyweight"                                                          
>  [129] "Women's Duet"                                                                 
>  [130] "Women's Team"                                                                 
>  [131] "Men's 4 Ã\u0083Â\u0097 400 metres Relay"                                      
>  [132] "Men's Marathon"                                                               
>  [133] "Women's 3,000 metres"                                                         
>  [134] "Women's Platform"                                                             
>  [135] "Men's Air Rifle, 10 metres"                                                   
>  [136] "Men's 200 metres"                                                             
>  [137] "Men's 100 metres Backstroke"                                                  
>  [138] "Men's Light-Heavyweight"                                                      
>  [139] "Men's Lightweight, Greco-Roman"                                               
>  [140] "Men's Sabre, Individual"                                                      
>  [141] "Men's Super-Heavyweight, Greco-Roman"                                         
>  [142] "Men's Air Pistol, 10 metres"                                                  
>  [143] "Men's Free Pistol, 50 metres"                                                 
>  [144] "Men's Coxless Fours"                                                          
>  [145] "Men's Light-Flyweight"                                                        
>  [146] "Men's Super-Heavyweight"                                                      
>  [147] "Men's Flyweight, Greco-Roman"                                                 
>  [148] "Women's Air Rifle, 10 metres"                                                 
>  [149] "Men's Middle-Heavyweight"                                                     
>  [150] "Men's Javelin Throw"                                                          
>  [151] "Women's Volleyball"                                                           
>  [152] "Men's Middleweight, Greco-Roman"                                              
>  [153] "Men's Welterweight, Greco-Roman"                                              
>  [154] "Men's 3,000 metres Steeplechase"                                              
>  [155] "Men's Middleweight, Freestyle"                                                
>  [156] "Women's 100 metres Backstroke"                                                
>  [157] "Women's 200 metres Backstroke"                                                
>  [158] "Women's 4 Ã\u0083Â\u0097 100 metres Medley Relay"                             
>  [159] "Men's Light-Heavyweight, Freestyle"                                           
>  [160] "Men's Team"                                                                   
>  [161] "Men's Bantamweight"                                                           
>  [162] "Women's 200 metres"                                                           
>  [163] "Women's Doubles"                                                              
>  [164] "Men's Skeet"                                                                  
>  [165] "Women's 50 metres Freestyle"                                                  
>  [166] "Men's Small-Bore Rifle, Three Positions, 50 metres"                           
>  [167] "Men's Triple Jump"                                                            
>  [168] "Women's Lightweight"                                                          
>  [169] "Women's Long Jump"                                                            
>  [170] "Women's Ã\u0083Â\u0089pÃ\u0083Â©e, Individual"                                
>  [171] "Men's 200 metres Freestyle"                                                   
>  [172] "Men's 4 Ã\u0083Â\u0097 100 metres Freestyle Relay"                            
>  [173] "Men's 200 metres Backstroke"                                                  
>  [174] "Men's 200 metres Individual Medley"                                           
>  [175] "Men's 400 metres Individual Medley"                                           
>  [176] "Men's Light-Middleweight"                                                     
>  [177] "Men's Bantamweight, Freestyle"                                                
>  [178] "Men's Flyweight, Freestyle"                                                   
>  [179] "Women's 5,000 metres"                                                         
>  [180] "Women's Light-Heavyweight"                                                    
>  [181] "Men's Discus Throw"                                                           
>  [182] "Men's Sprint"                                                                 
>  [183] "Men's Two"                                                                    
>  [184] "Men's Lightweight, Freestyle"                                                 
>  [185] "Men's Baseball"                                                               
>  [186] "Men's Coxed Fours"                                                            
>  [187] "Men's 100 kilometres Team Time Trial"                                         
>  [188] "Women's Group"                                                                
>  [189] "Mixed Architecture, Architectural Designs"                                    
>  [190] "Mixed Architecture, Designs For Town Planning"                                
>  [191] "Women's Balance Beam"                                                         
>  [192] "Women's Floor Exercise"                                                       
>  [193] "Women's Horse Vault"                                                          
>  [194] "Women's Individual All-Around"                                                
>  [195] "Women's Team All-Around"                                                      
>  [196] "Women's Uneven Bars"                                                          
>  [197] "Women's Springboard"                                                          
>  [198] "Women's Synchronized Springboard"                                             
>  [199] "Women's 10,000 metres"                                                        
>  [200] "Mixed 7 metres"                                                               
>  [201] "Women's Half-Middleweight"                                                    
>  [202] "Men's Decathlon"                                                              
>  [203] "Men's 10 kilometres Sprint"                                                   
>  [204] "Men's 20 kilometres"                                                          
>  [205] "Men's 4 Ã\u0083Â\u0097 7.5 kilometres Relay"                                  
>  [206] "Men's Moguls"                                                                 
>  [207] "Men's Middleweight A, Greco-Roman"                                            
>  [208] "Women's Discus Throw"                                                         
>  [209] "Women's 4 Ã\u0083Â\u0097 100 metres Freestyle Relay"                          
>  [210] "Women's 1,500 metres"                                                         
>  [211] "Women's Air Pistol, 10 metres"                                                
>  [212] "Women's Sporting Pistol, 25 metres"                                           
>  [213] "Men's Kayak Doubles, 500 metres"                                              
>  [214] "Men's Kayak Singles, 1,000 metres"                                            
>  [215] "Men's Kayak Singles, 500 metres"                                              
>  [216] "Men's Running Target, 50 metres"                                              
>  [217] "Women's Half-Heavyweight"                                                     
>  [218] "Women's Pole Vault"                                                           
>  [219] "Women's Rugby Sevens"                                                         
>  [220] "Mixed Pairs"                                                                  
>  [221] "Men's Aerials"                                                                
>  [222] "Women's Coxed Eights"                                                         
>  [223] "Women's 4 Ã\u0083Â\u0097 400 metres Relay"                                    
>  [224] "Women's Giant Slalom"                                                         
>  [225] "Women's Super G"                                                              
>  [226] "Women's 10 kilometres"                                                        
>  [227] "Women's 20 kilometres"                                                        
>  [228] "Women's 5 kilometres"                                                         
>  [229] "Men's 1,000 metres Time Trial"                                                
>  [230] "Men's Individual Pursuit, 4,000 metres"                                       
>  [231] "Men's Welterweight, Freestyle"                                                
>  [232] "Men's Bantamweight, Greco-Roman"                                              
>  [233] "Women's Lightweight Double Sculls"                                            
>  [234] "Women's 800 metres"                                                           
>  [235] "Women's Coxed Quadruple Sculls"                                               
>  [236] "Men's 12.5 kilometres Pursuit"                                                
>  [237] "Mixed 2 Ã\u0083Â\u0097 6 kilometres and 2 Ã\u0083Â\u0097 7.5 kilometres Relay"
>  [238] "Men's Kayak Singles, Slalom"                                                  
>  [239] "Women's Team Pursuit (6 laps)"                                                
>  [240] "Women's 400 metres"                                                           
>  [241] "Men's 1,000 metres"                                                           
>  [242] "Men's Beach Volleyball"                                                       
>  [243] "Women's Mountainbike, Cross-Country"                                          
>  [244] "Men's Javelin Throw, Both Hands"                                              
>  [245] "Women's Olympic Distance"                                                     
>  [246] "Women's Team Portable Apparatus"                                              
>  [247] "Men's Mountainbike, Cross-Country"                                            
>  [248] "Women's 400 metres Hurdles"                                                   
>  [249] "Men's Springboard"                                                            
>  [250] "Men's Featherweight, Greco-Roman"                                             
>  [251] "Mixed Painting"                                                               
>  [252] "Women's 3 Ã\u0083Â\u0097 5 kilometres Relay"                                  
>  [253] "Men's Open Class"                                                             
>  [254] "Women's Quadruple Sculls"                                                     
>  [255] "Men's Team All-Around, Swedish System"                                        
>  [256] "Women's Pentathlon"                                                           
>  [257] "Mixed Painting, Unknown Event"                                                
>  [258] "Men's Team Pursuit, 4,000 metres"                                             
>  [259] "Women's Middleweight"                                                         
>  [260] "Men's 1,500 metres Freestyle"                                                 
>  [261] "Women's Light-Heavyweight, Freestyle"                                         
>  [262] "Women's 100 metres Freestyle"                                                 
>  [263] "Men's Jumping, Individual"                                                    
>  [264] "Men's Jumping, Team"                                                          
>  [265] "Men's Three-Day Event, Individual"                                            
>  [266] "Men's Three-Day Event, Team"                                                  
>  [267] "Women's Combined"                                                             
>  [268] "Women's High Jump"                                                            
>  [269] "Men's Normal Hill, Individual"                                                
>  [270] "Women's Kayak Fours, 500 metres"                                              
>  [271] "Women's Ice Hockey"                                                           
>  [272] "Men's One Person Dinghy"                                                      
>  [273] "Men's Curling"                                                                
>  [274] "Mixed Literature"                                                             
>  [275] "Women's 15 kilometres"                                                        
>  [276] "Women's 3 Ã\u0083Â\u0097 7.5 kilometres Relay"                                
>  [277] "Women's 4 Ã\u0083Â\u0097 7.5 kilometres Relay"                                
>  [278] "Men's Half-Lightweight"                                                       
>  [279] "Women's Foil, Team"                                                           
>  [280] "Women's 200 metres Butterfly"                                                 
>  [281] "Women's 400 metres Individual Medley"                                         
>  [282] "Men's Standing High Jump"                                                     
>  [283] "Men's Standing Long Jump"                                                     
>  [284] "Men's 20 kilometres Walk"                                                     
>  [285] "Men's 220 yard Freestyle"                                                     
>  [286] "Men's 4 Ã\u0083Â\u0097 50 Yard Freestyle Relay"                               
>  [287] "Men's 880 yard Freestyle"                                                     
>  [288] "Men's One Mile Freestyle"                                                     
>  [289] "Men's Plunge For Distance"                                                    
>  [290] "Men's Free Rifle, Three Positions, 300 metres"                                
>  [291] "Men's Military Rifle, 200, 400, 500 and 600 metres, Team"                     
>  [292] "Men's Military Rifle, Any Position, 600 metres"                               
>  [293] "Men's Military Rifle, Prone, 300 metres"                                      
>  [294] "Men's Military Rifle, Three Positions, 300 metres"                            
>  [295] "Men's Half-Heavyweight"                                                       
>  [296] "Men's 50 kilometres Walk"                                                     
>  [297] "Women's Double Sculls"                                                        
>  [298] "Mixed 6 metres"                                                               
>  [299] "Women's 100 metres Hurdles"                                                   
>  [300] "Men's Discus Throw, Greek Style"                                              
>  [301] "Women's Curling"                                                              
>  [302] "Mixed One Person Dinghy"                                                      
>  [303] "Women's Heavyweight, Freestyle"                                               
>  [304] "Mixed Doubles"                                                                
>  [305] "Women's Foil, Individual"                                                     
>  [306] "Mixed Two Person Keelboat"                                                    
>  [307] "Men's Military Rifle, 300 metres and 600 metres, Prone, Team"                 
>  [308] "Men's Light-Flyweight, Freestyle"                                             
>  [309] "Women's Featherweight, Freestyle"                                             
>  [310] "Women's 200 metres Freestyle"                                                 
>  [311] "Women's 200 metres Individual Medley"                                         
>  [312] "Women's 400 metres Freestyle"                                                 
>  [313] "Men's Windsurfer"                                                             
>  [314] "Men's Slopestyle"                                                             
>  [315] "Men's Running Target, Double Shot"                                            
>  [316] "Men's Running Target, Single Shot"                                            
>  [317] "Men's Rugby Sevens"                                                           
>  [318] "Women's Lightweight, Freestyle"                                               
>  [319] "Men's Canadian Doubles, Slalom"                                               
>  [320] "Women's Half-Lightweight"                                                     
>  [321] "Women's Plain High"                                                           
>  [322] "Men's Dressage, Individual"                                                   
>  [323] "Men's Dressage, Team"                                                         
>  [324] "Women's Singles, Covered Courts"                                              
>  [325] "Men's Plain High"                                                             
>  [326] "Mixed Small-Bore Rifle, Prone, 50 metres"                                     
>  [327] "Mixed Small-Bore Rifle, Three Positions, 50 metres"                           
>  [328] "Women's 800 metres Freestyle"                                                 
>  [329] "Women's Two Person Dinghy"                                                    
>  [330] "Women's Downhill"                                                             
>  [331] "Men's Free Pistol, 50 metres, Team"                                           
>  [332] "Men's Free Rifle, 400, 600 and 800 metres, Team"                              
>  [333] "Men's Free Rifle, Prone, 600 metres"                                          
>  [334] "Men's Free Rifle, Three Positions, 300 metres, Team"                          
>  [335] "Men's Military Rifle, Prone, 300 metres, Team"                                
>  [336] "Men's Military Rifle, Prone, 600 metres, Team"                                
>  [337] "Men's Military Rifle, Standing, 300 metres, Team"                             
>  [338] "Men's Single Sculls"                                                          
>  [339] "Men's Tandem Sprint, 2,000 metres"                                            
>  [340] "Women's Halfpipe"                                                             
>  [341] "Women's Heptathlon"                                                           
>  [342] "Men's Points Race"                                                            
>  [343] "Women's Solo"                                                                 
>  [344] "Mixed Dressage, Individual"                                                   
>  [345] "Mixed Dressage, Team"                                                         
>  [346] "Men's 18 kilometres"                                                          
>  [347] "Men's 100 metres Breaststroke"                                                
>  [348] "Mixed Ice Dancing"                                                            
>  [349] "Mixed Free Pistol, 50 metres"                                                 
>  [350] "Women's Skiff"                                                                
>  [351] "Men's Kayak Doubles, 10,000 metres"                                           
>  [352] "Men's Olympic Distance"                                                       
>  [353] "Women's One Person Dinghy"                                                    
>  [354] "Women's 15 km Skiathlon"                                                      
>  [355] "Women's 30 kilometres"                                                        
>  [356] "Men's 17-Man Naval Rowing Boats"                                              
>  [357] "Women's Beach Volleyball"                                                     
>  [358] "Men's Lightweight Coxless Fours"                                              
>  [359] "Men's Light-Flyweight, Greco-Roman"                                           
>  [360] "Men's Canadian Singles, 1,000 metres"                                         
>  [361] "Mixed 5.5 metres"                                                             
>  [362] "Mixed Jumping, Team"                                                          
>  [363] "Men's Synchronized Platform"                                                  
>  [364] "Men's Halfpipe"                                                               
>  [365] "Women's Kayak Singles, Slalom"                                                
>  [366] "Women's 100 metres Breaststroke"                                              
>  [367] "Women's 200 metres Breaststroke"                                              
>  [368] "Men's Middleweight B, Greco-Roman"                                            
>  [369] "Men's Javelin Throw, Freestyle"                                               
>  [370] "Men's Pentathlon (Ancient)"                                                   
>  [371] "Men's Stone Throw"                                                            
>  [372] "Women's Small-Bore Rifle, Three Positions, 50 metres"                         
>  [373] "Women's 100 metres Butterfly"                                                 
>  [374] "Men's Heavyweight I"                                                          
>  [375] "Women's 3,000 metres Steeplechase"                                            
>  [376] "Men's Shot Put, Both Hands"                                                   
>  [377] "Men's Large Hill, Individual"                                                 
>  [378] "Men's Large Hill, Team"                                                       
>  [379] "Women's Trap"                                                                 
>  [380] "Women's 4 Ã\u0083Â\u0097 200 metres Freestyle Relay"                          
>  [381] "Men's 10 kilometres Walk"                                                     
>  [382] "Women's 20 kilometres Walk"                                                   
>  [383] "Women's 80 metres Hurdles"                                                    
>  [384] "Men's One Person Heavyweight Dinghy"                                          
>  [385] "Women's Aerials"                                                              
>  [386] "Mixed Painting, Paintings"                                                    
>  [387] "Mixed Doubles, Covered Courts"                                                
>  [388] "Men's Madison"                                                                
>  [389] "Mixed Sculpturing, Statues"                                                   
>  [390] "Men's Rugby"                                                                  
>  [391] "Men's Heavyweight II"                                                         
>  [392] "Women's Kayak Doubles, 500 metres"                                            
>  [393] "Men's 5,000 metres Relay"                                                     
>  [394] "Men's Individual Time Trial"                                                  
>  [395] "Men's Kayak Doubles, 1,000 metres"                                            
>  [396] "Men's Individual All-Around, 5 Events"                                        
>  [397] "Men's Super-Heavyweight, Freestyle"                                           
>  [398] "Women's 10 kilometres Pursuit"                                                
>  [399] "Women's 12.5 kilometres Mass Start"                                           
>  [400] "Women's 4 Ã\u0083Â\u0097 6 kilometres Relay"                                  
>  [401] "Women's Sabre, Team"                                                          
>  [402] "Men's Double Trap"                                                            
>  [403] "Mixed Windsurfer"                                                             
>  [404] "Women's Welterweight"                                                         
>  [405] "Mixed Free Rifle, Three Positions, 300 metres"                                
>  [406] "Men's Skeleton"                                                               
>  [407] "Mixed Rapid-Fire Pistol, 25 metres"                                           
>  [408] "Men's 333Ã¢Â\u0085Â\u0093 metres Time Trial"                                  
>  [409] "Men's Kayak Singles, 10,000 metres"                                           
>  [410] "Mixed 1-2 Ton"                                                                
>  [411] "Mixed Open"                                                                   
>  [412] "Men's Canadian Singles, Slalom"                                               
>  [413] "Mixed (Men)'s Doubles"                                                        
>  [414] "Mixed Multihull"                                                              
>  [415] "Women's 4 Ã\u0083Â\u0097 5 kilometres Relay"                                  
>  [416] "Women's 5/10 kilometres Pursuit"                                              
>  [417] "Women's 5/5 kilometres Pursuit"                                               
>  [418] "Women's Synchronized Platform"                                                
>  [419] "Women's Triple Jump"                                                          
>  [420] "Women's Skeleton"                                                             
>  [421] "Men's Four/Five"                                                              
>  [422] "Mixed Painting, Drawings And Water Colors"                                    
>  [423] "Men's Dueling Pistol, 30 metres"                                              
>  [424] "Women's BMX"                                                                  
>  [425] "Men's Kayak Doubles, 200 metres"                                              
>  [426] "Men's Sabre, Masters, Individual"                                             
>  [427] "Men's Lacrosse"                                                               
>  [428] "Women's Kayak Singles, 500 metres"                                            
>  [429] "Women's 10 kilometres Walk"                                                   
>  [430] "Mixed 12 metres"                                                              
>  [431] "Women's Extra-Lightweight"                                                    
>  [432] "Men's Synchronized Springboard"                                               
>  [433] "Men's Coxed Fours, Outriggers"                                                
>  [434] "Men's Rope Climbing"                                                          
>  [435] "Mixed Two Person Dinghy"                                                      
>  [436] "Mixed Architecture, Unknown Event"                                            
>  [437] "Men's Target Archery, 28 metres, Team"                                        
>  [438] "Men's Target Archery, 33 metres, Team"                                        
>  [439] "Men's Target Archery, 50 metres, Team"                                        
>  [440] "Women's 3,000 metres Relay"                                                   
>  [441] "Women's Moguls"                                                               
>  [442] "Men's Running Target, 10 metres"                                              
>  [443] "Men's Polo"                                                                   
>  [444] "Men's Coxed Fours, Inriggers"                                                 
>  [445] "Men's BMX"                                                                    
>  [446] "Mixed Sculpturing"                                                            
>  [447] "Men's Cross-Country, Individual"                                              
>  [448] "Men's Cross-Country, Team"                                                    
>  [449] "Mixed 40 metresÃ\u0082Â²"                                                     
>  [450] "Men's 10/10 kilometres Pursuit"                                               
>  [451] "Women's Normal Hill, Individual"                                              
>  [452] "Men's Club Swinging"                                                          
>  [453] "Men's Team Sprint"                                                            
>  [454] "Women's Kayak Singles, 200 metres"                                            
>  [455] "Men's Kayak Relay 4 Ã\u0083Â\u0097 500 metres"                                
>  [456] "Men's 3,000 metres, Team"                                                     
>  [457] "Men's Small-Bore Rifle, 50 and 100 yards, Team"                               
>  [458] "Men's Small-Bore Rifle, Disappearing Target, 25 yards"                        
>  [459] "Men's Small-Bore Rifle, Moving Target, 25 yards"                              
>  [460] "Men's Small-Bore Rifle, Prone, 50 and 100 yards"                              
>  [461] "Men's Military Pistol, Team"                                                  
>  [462] "Women's Coxed Fours"                                                          
>  [463] "Men's Unlimited, One Hand"                                                    
>  [464] "Men's Canadian Singles, 500 metres"                                           
>  [465] "Men's Ã\u0083Â\u0089pÃ\u0083Â©e, Masters, Individual"                         
>  [466] "Men's Foil, Masters, Individual"                                              
>  [467] "Men's Individual All-Around, Apparatus Work"                                  
>  [468] "Men's Individual All-Around, Field Sports"                                    
>  [469] "Mixed Music, Compositions For Solo Or Chorus"                                 
>  [470] "Women's Ã\u0083Â\u0089pÃ\u0083Â©e, Team"                                      
>  [471] "Men's 4,000 metres Freestyle"                                                 
>  [472] "Men's Underwater Swimming"                                                    
>  [473] "Mixed Skiff"                                                                  
>  [474] "Men's Military Rifle, 200/500/600/800/900/1,000 Yards, Team"                  
>  [475] "Men's Running Target, Single And Double Shot"                                 
>  [476] "Men's Small-Bore Rifle, Any Position, 50 metres"                              
>  [477] "Men's Small-Bore Rifle, Disappearing Target, 25 metres"                       
>  [478] "Women's 10 kilometres Open Water"                                             
>  [479] "Women's Slopestyle"                                                           
>  [480] "Men's Boardercross"                                                           
>  [481] "Men's Parallel Giant Slalom"                                                  
>  [482] "Men's Parallel Slalom"                                                        
>  [483] "Men's 100 kilometres"                                                         
>  [484] "Men's Team Pursuit, 1,980 yards"                                              
>  [485] "Men's Cricket"                                                                
>  [486] "Men's Canadian Singles, 10,000 metres"                                        
>  [487] "Women's Team Sprint"                                                          
>  [488] "Men's Skiff"                                                                  
>  [489] "Men's Pentathlon"                                                             
>  [490] "Men's 1,200 metres Freestyle"                                                 
>  [491] "Women's Skeet"                                                                
>  [492] "Men's 15 kilometres Mass Start"                                               
>  [493] "Men's 30 km Skiathlon"                                                        
>  [494] "Men's 25 mile"                                                                
>  [495] "Men's 5 mile"                                                                 
>  [496] "Men's Ã\u0082Â¼ mile"                                                         
>  [497] "Men's Ã\u0082Â½ mile"                                                         
>  [498] "Men's Small-Bore Rifle, Standing, 50 metres"                                  
>  [499] "Men's Small Bore-Rifle, Standing, 50 metres, Team"                            
>  [500] "Men's Team Pursuit (8 laps)"                                                  
>  [501] "Men's Free Rifle, 1,000 Yards"                                                
>  [502] "Women's Team Pursuit"                                                         
>  [503] "Men's 3,000 metres Walk"                                                      
>  [504] "Women's Boardercross"                                                         
>  [505] "Mixed Running Target, 50 metres"                                              
>  [506] "Mixed Team Relay"                                                             
>  [507] "Women's Individual Time Trial"                                                
>  [508] "Women's Sabre, Individual"                                                    
>  [509] "Men's Sabre, Individual, Three Hits"                                          
>  [510] "Women's Double National Round"                                                
>  [511] "Men's Omnium"                                                                 
>  [512] "Mixed Hacks And Hunter Combined"                                              
>  [513] "Mixed 10 metres"                                                              
>  [514] "Men's Trap, Team"                                                             
>  [515] "Women's Individual Pursuit, 3,000 metres"                                     
>  [516] "Women's Points Race"                                                          
>  [517] "Men's Two Person Keelboat"                                                    
>  [518] "Men's Keirin"                                                                 
>  [519] "Men's Running Target, Single Shot, Team"                                      
>  [520] "Women's Two"                                                                  
>  [521] "Mixed Literature, Lyric Works"                                                
>  [522] "Mixed A-Class (Open)"                                                         
>  [523] "Men's Continental Style"                                                      
>  [524] "Men's Military Ski Patrol"                                                    
>  [525] "Mixed Painting, Graphic Arts"                                                 
>  [526] "Women's Flyweight, Freestyle"                                                 
>  [527] "Mixed Literature, Unknown Event"                                              
>  [528] "Mixed Ã\u0082Â½-1 Ton"                                                        
>  [529] "Mixed Painting, Applied Arts"                                                 
>  [530] "Mixed Singles, One Ball"                                                      
>  [531] "Men's Running Target, Double Shot, Team"                                      
>  [532] "Men's Free Pistol, 50 yards"                                                  
>  [533] "Men's Free Pistol, 50 yards, Team"                                            
>  [534] "Men's Ã\u0083Â\u0089pÃ\u0083Â©e, Masters and Amateurs, Individual"            
>  [535] "Men's 10 kilometres Open Water"                                               
>  [536] "Mixed Music, Compositions For Orchestra"                                      
>  [537] "Men's Double York Round"                                                      
>  [538] "Women's Middleweight, Freestyle"                                              
>  [539] "Men's Vaulting, Individual"                                                   
>  [540] "Men's 4 Ã\u0083Â\u0097 250 metres Freestyle Relay"                            
>  [541] "Women's Hammer Throw"                                                         
>  [542] "Men's Kayak Singles, 200 metres"                                              
>  [543] "Women's Double Trap"                                                          
>  [544] "Men's 6-Man Naval Rowing Boats"                                               
>  [545] "Mixed Music"                                                                  
>  [546] "Men's Free Rifle, Kneeling, 300 metres"                                       
>  [547] "Men's Free Rifle, Prone, 300 metres"                                          
>  [548] "Men's Free Rifle, Standing, 300 metres"                                       
>  [549] "Men's 3,200 metres Steeplechase"                                              
>  [550] "Women's Coxless Fours"                                                        
>  [551] "Women's Ski Cross"                                                            
>  [552] "Men's Ski Cross"                                                              
>  [553] "Men's Doubles, Covered Courts"                                                
>  [554] "Men's Singles, Covered Courts"                                                
>  [555] "Men's 25 kilometres"                                                          
>  [556] "Men's Large Hill / 10 km, Individual"                                         
>  [557] "Men's Normal Hill / 10 km, Individual"                                        
>  [558] "Men's Military Rifle, 200 metres"                                             
>  [559] "Men's Standing Triple Jump"                                                   
>  [560] "Men's Coxed Pairs (1 kilometres)"                                             
>  [561] "Men's Military Pistol, 30 metres"                                             
>  [562] "Women's Keirin"                                                               
>  [563] "Men's Au Cordon DorÃ\u0083Â©, 50 metres"                                      
>  [564] "Women's 300 metres Freestyle"                                                 
>  [565] "Men's Canadian Singles, 200 metres"                                           
>  [566] "Mixed 30 metresÃ\u0082Â²"                                                     
>  [567] "Men's 4,000 metres Steeplechase"                                              
>  [568] "Men's 5,000 metres, Team"                                                     
>  [569] "Men's Coxed Pairs (1 mile)"                                                   
>  [570] "Mixed Unknown Event"                                                          
>  [571] "Women's Omnium"                                                               
>  [572] "Men's 200 metres Obstacle Course"                                             
>  [573] "Men's 200 metres Team Swimming"                                               
>  [574] "Mixed 12 foot"                                                                
>  [575] "Mixed Music, Instrumental And Chamber"                                        
>  [576] "Mixed Music, Vocals"                                                          
>  [577] "Mixed Literature, Dramatic Works"                                             
>  [578] "Mixed 10-20 Ton"                                                              
>  [579] "Men's 1 mile"                                                                 
>  [580] "Men's 2 mile"                                                                 
>  [581] "Men's Ã¢Â\u0085Â\u0093 mile"                                                  
>  [582] "Mixed Sculpturing, Medals And Plaques"                                        
>  [583] "Men's 1,600 metres Medley Relay"                                              
>  [584] "Mixed Singles, Two Balls"                                                     
>  [585] "Men's Folding Kayak Doubles, 10 kilometres"                                   
>  [586] "Men's 60 metres"                                                              
>  [587] "Women's Parallel Giant Slalom"                                                
>  [588] "Mixed 2-3 Ton"                                                                
>  [589] "Men's Allround"                                                               
>  [590] "Men's Military Rifle, Prone, 600 metres"                                      
>  [591] "Men's Canadian Doubles, 10,000 metres"                                        
>  [592] "Women's Parallel Slalom"                                                      
>  [593] "Men's Dueling Pistol, 30 metres, Team"                                        
>  [594] "Men's Horizontal Bar, Teams"                                                  
>  [595] "Men's Parallel Bars, Teams"                                                   
>  [596] "Men's Small-Bore Rifle, Disappearing Target, 25 metres, Team"                 
>  [597] "Mixed Sculpturing, Medals And Reliefs"                                        
>  [598] "Men's 1,500 metres Walk"                                                      
>  [599] "Men's 3 mile, Team"                                                           
>  [600] "Mixed Sculpturing, Medals"                                                    
>  [601] "Men's Military Rifle, Kneeling Or Standing, 300 metres"                       
>  [602] "Men's Vaulting, Team"                                                         
>  [603] "Men's Free Rifle, Any Position, 300 metres"                                   
>  [604] "Men's Military Rifle, 1873-1874 Gras Model, Kneeling Or Standing, 200 metres" 
>  [605] "Men's 100 Yard Backstroke"                                                    
>  [606] "Men's 440 Yard Breaststroke"                                                  
>  [607] "Mixed Literature, Epic Works"                                                 
>  [608] "Mixed Architecture"                                                           
>  [609] "Men's 3,500 metres Walk"                                                      
>  [610] "Men's Side Horse"                                                             
>  [611] "Mixed Alpinism"                                                               
>  [612] "Men's Double American Round"                                                  
>  [613] "Men's Team Round"                                                             
>  [614] "Men's Target Archery, 33 metres, Individual"                                  
>  [615] "Men's Target Archery, 50 metres, Individual"                                  
>  [616] "Men's 1,000 metres Freestyle"                                                 
>  [617] "Men's 10 mile Walk"                                                           
>  [618] "Men's Discus Throw, Both Hands"                                               
>  [619] "Mixed 0-Ã\u0082Â½ Ton"                                                        
>  [620] "Mixed 20+ Ton"                                                                
>  [621] "Men's Unlimited, Two Hands"                                                   
>  [622] "Men's Dueling Pistol Au Commandement, 25 metres"                              
>  [623] "Men's Dueling Pistol Au VisÃ\u0083Â© 20 metres"                               
>  [624] "Men's Free Pistol, 25 metres"                                                 
>  [625] "Men's Military Revolver, 1873-1874 Gras Model, 20 metres"                     
>  [626] "Men's Military Revolver, 20 metres"                                           
>  [627] "Men's Small-Bore Rifle, Prone, 50 metres, Team"                               
>  [628] "Mixed 6.5 metres"                                                             
>  [629] "Men's 200 metres Hurdles"                                                     
>  [630] "Men's 56-pound Weight Throw"                                                  
>  [631] "Mixed Four-In-Hand Competition"                                               
>  [632] "Men's 2,500 metres Steeplechase"                                              
>  [633] "Mixed Music, Unknown Event"                                                   
>  [634] "Men's All-Around Championship"                                                
>  [635] "Men's Pole Archery, Large Birds, Individual"                                  
>  [636] "Men's Pole Archery, Large Birds, Team"                                        
>  [637] "Men's Pole Archery, Small Birds, Individual"                                  
>  [638] "Men's Pole Archery, Small Birds, Team"                                        
>  [639] "Men's 2,590 metres Steeplechase"                                              
>  [640] "Women's Double Columbia Round"                                                
>  [641] "Men's 4 mile, Team"                                                           
>  [642] "Men's Special Figures"                                                        
>  [643] "Men's Military Rifle, Standing, 300 metres"                                   
>  [644] "Men's 100 yard Freestyle"                                                     
>  [645] "Men's 440 yard Freestyle"                                                     
>  [646] "Men's 50 yard Freestyle"                                                      
>  [647] "Men's Two-Man Teams With Cesta"                                               
>  [648] "Men's Trap, Double Shot, 14 metres"                                           
>  [649] "Men's Trap, Single Shot, 16 metres"                                           
>  [650] "Mixed Long Jump"                                                              
>  [651] "Men's Folding Kayak Singles, 10 kilometres"                                   
>  [652] "Men's Free Pistol, 30 metres"                                                 
>  [653] "Men's Military Pistol, 25 metres"                                             
>  [654] "Men's 100 metres Freestyle For Sailors"                                       
>  [655] "Men's Sur La Perche Ã\u0083Â\u0080 La Herse"                                  
>  [656] "Mixed 3-10 Ton"                                                               
>  [657] "Men's Individual All-Around, 4 Events"                                        
>  [658] "Men's Unlimited Class, Greco-Roman"                                           
>  [659] "Mixed B-Class (Under 60 Feet)"                                                
>  [660] "Mixed C-Class"                                                                
>  [661] "Mixed Sculpturing, Reliefs"                                                   
>  [662] "Men's Muzzle-Loading Pistol, 25 metres"                                       
>  [663] "Mixed High Jump"                                                              
>  [664] "Men's Sur La Perche Ã\u0083Â\u0080 La Pyramide"                               
>  [665] "Men's Single Sticks, Individual"                                              
>  [666] "Men's Tumbling"                                                               
>  [667] "Men's Unknown Event"                                                          
>  [668] "Mixed 18 foot"                                                                
>  [669] "Men's Au Chapelet, 50 metres"                                                 
>  [670] "Men's Championnat Du Monde"                                                   
>  [671] "Women's Team Round"                                                           
>  [672] "Men's All-Around, Greco-Roman"                                                
>  [673] "Men's 12-Hours Race"                                                          
>  [674] "Men's 500 metres Freestyle"                                                   
>  [675] "Men's All-Around Dumbbell Contest"                                            
>  [676] "Men's Au Chapelet, 33 metres"                                                 
>  [677] "Men's Au Cordon DorÃ\u0083Â©, 33 metres"                                      
>  [678] "Men's Target Archery, 28 metres, Individual"                                  
>  [679] "Mixed Aeronautics"
```

I want to get these variables right and couldn't figure out an easy way to do it, so I finally decided to do it by hand. I'm not sure if a more elegant solution is possible, but the number of issues here is small enough that it didn't seem worth it to spend much more time searching for a way to automate this. Here is how I replaced the badly-encoded Events.   


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
