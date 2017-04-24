---
layout: project
title: "caRds"
author: Randi H. Griffin
output: html_document
---

This is an R package for producing pretty caRds for special occasions. If you have the devtools package installed, you can install `caRds` from GitHub:


```r
library(devtools)
install_github("rgriff23/caRds")
library(caRds)
```
___

### Thanksgiving

`TurkeyDay` creates a Thanksgiving turkey:


```r
TurkeyDay(from = "Randi", to = "America")
```

![plot of chunk unnamed-chunk-2](/projects/caRds/figure/unnamed-chunk-2-1.png)

Wish Canada a happy Canadian Thanksgiving with `canadian = TRUE`:


```r
TurkeyDay(from = "Randi", to = "Canada", canadian = TRUE)
```

![plot of chunk unnamed-chunk-3](/projects/caRds/figure/unnamed-chunk-3-1.png)


___

### Christmas

`ChristmasTree` generates a jolly tree with presents underneath:


```r
ChristmasTree(from = "Randi", to = "Chase", numPresents = 10)
```

![plot of chunk unnamed-chunk-4](/projects/caRds/figure/unnamed-chunk-4-1.png)


Add tinsel with `tinsel = TRUE`. 


```r
ChristmasTree(from = "Randi", to = "Chase", numPresents = 10, tinsel = TRUE)
```

![plot of chunk unnamed-chunk-5](/projects/caRds/figure/unnamed-chunk-5-1.png)


___

### Valentine's Day

`OneThousandHearts` sprinkles 1000 tiny hearts about a larger heart, creating negative heart space where a romantic message can be included. If you use the `to` argument to specify the recipient of your Valentine's Day caRd, a simple message will be generated automatically:


```r
OneThousandHearts(to = "Samara")
```

![plot of chunk unnamed-chunk-6](/projects/caRds/figure/unnamed-chunk-6-1.png)


Alternatively, use `lines` to include a personalized message up to 4 lines long:


```r
OneThousandHearts(line1 = "Roses are red", 
  line2 = "Violets are blue", 
  line3 = "If you were a Pokemon", 
  line4 = "I would choose you!")
```

![plot of chunk unnamed-chunk-7](/projects/caRds/figure/unnamed-chunk-7-1.png)

___

### Easter

`EasterEgg` lays an egg of any color with a baby chicken inside:


```r
EasterEgg(shell = "skyblue")
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8-1.png)

___
