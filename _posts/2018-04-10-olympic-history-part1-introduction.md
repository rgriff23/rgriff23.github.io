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



The final dataset contains 10 columns and 257,430 rows. Below, I use `tidyverse` methods to read the cleaned version of the dataset into R and compute some simple summary statistics for each column.



Now for some summary statistics: 


```
>  [1] 125913
```


```
>  
>       M      F 
>  189142  68288
```


```
>  [1] 98336
```


```
>  [1] 10 96
```


```
>  [1] 41
```


```
>  [1] 65
```


```
>  [1] 227
```


```
>  .
>  Bronze Silver   Gold 
>   12592  12467  12715
```


```
>  [1] 34
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

