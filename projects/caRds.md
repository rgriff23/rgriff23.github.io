---
layout: project
title: "caRds"
author: Randi H. Griffin
comments: true
---

___

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

![plot of chunk project_caRds_usturkey](/assets/Rfigs/project_caRds_usturkey-1.png)

Wish Canada a happy Canadian Thanksgiving with `canadian = TRUE`:


```r
TurkeyDay(from = "Randi", to = "Canada", canadian = TRUE)
```

![plot of chunk project_caRds_canturkey](/assets/Rfigs/project_caRds_canturkey-1.png)

___

### Christmas

`ChristmasTree` generates a jolly tree with presents underneath:


```r
ChristmasTree(from = "Randi", to = "Chase", numPresents = 10)
```

![plot of chunk project_caRds_xmastree](/assets/Rfigs/project_caRds_xmastree-1.png)

Add tinsel with `tinsel = TRUE`. 


```r
ChristmasTree(from = "Randi", to = "Chase", numPresents = 10, tinsel = TRUE)
```

![plot of chunk project_caRds_xmastreetins](/assets/Rfigs/project_caRds_xmastreetins-1.png)
___

### Valentine's Day

`OneThousandHearts` sprinkles 1000 tiny hearts about a larger heart, creating negative heart space where a romantic message can be included. If you use the `to` argument to specify the recipient of your Valentine's Day caRd, a simple message will be generated automatically:


```r
OneThousandHearts(to = "Samara")
```

![plot of chunk project_caRds_hearts](/assets/Rfigs/project_caRds_hearts-1.png)

Alternatively, use `lines` to include a personalized message up to 4 lines long:


```r
OneThousandHearts(line1 = "Roses are red", 
  line2 = "Violets are blue", 
  line3 = "If you were a Pokemon", 
  line4 = "I would choose you!")
```

![plot of chunk project_caRds_heartspoem](/assets/Rfigs/project_caRds_heartspoem-1.png)

___

### Easter

`EasterEgg` lays an egg of any color with a baby chicken inside:


```r
EasterEgg(shell = "skyblue")
```

![plot of chunk project_caRds_egg](/assets/Rfigs/project_caRds_egg-1.png)
___
