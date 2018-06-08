---
title: "Olympic history: the size of Olympians"
date: '2018-06-08'
layout: post
tags: R olympics sports tidyverse
comments: true
---

The data used in this post can be downloaded from [figshare](https://figshare.com/articles/Olympic_history_longitudinal_data_scraped_from_www_sports-reference_com/6121274) and the R code is on [GitHub](https://github.com/rgriff23/Olympic_history/blob/master/R/analyses/size.R).



## Introductions

The motto for the Olympics is "Citius, Altius, Fortius", which means "Faster, Higher, Stronger" in Latin. This motto was proposed by Pierre de Coubertin, the founder of the modern Olympics, in 1894. Indeed, as illustrated by the long history of record-breaking performances at the Olympics, athletes at every Olympics seem to be faster and stronger than the one before. In this post, I explore a correlary of this phenomenon: historical trends in the heights and weights of Olympic athletes.  

## Data exploration

As in previous posts, I removed the non-athletic Art Competitions from the dataset and I combined data from the Winter and Summer Games in each Olympiad (e.g., the 2014 Sochi Winter Games and 2016 Rio Summer Games are combined, the 2010 Vancouver Winter Games and the 2012 London Summer Games are combined, etc). 

First, let's check data completeness from each Olympiad, since it is likely that data on athletes' height and weight was rarely recorded from early Games. 

<img src="/assets/Rfigs/post_2018-06_size_completeness-1.png" title="plot of chunk post_2018-06_size_completeness" alt="plot of chunk post_2018-06_size_completeness" style="display: block; margin: auto;" />

The graph shows a dramatic increase in data completeness starting in 1960, reaching 86% for women and 90% for men. For all of the Games after this point, data completeness remained above 85% except for 1992, where completeness dips down to 80% for unclear reasons. In light of this, I limited the remainder of this data exploration to Games from 1960 onward, which includes a total of 15 Olympiads spread over a 56 year period.  



The next two plots show trends in the heights and weights of Olympic athletes over time, with the data grouped by sex.

<img src="/assets/Rfigs/post_2018-06_size_boxplot_height-1.png" title="plot of chunk post_2018-06_size_boxplot_height" alt="plot of chunk post_2018-06_size_boxplot_height" style="display: block; margin: auto;" />
<img src="/assets/Rfigs/post_2018-06_size_boxplot_weight-1.png" title="plot of chunk post_2018-06_size_boxplot_weight" alt="plot of chunk post_2018-06_size_boxplot_weight" style="display: block; margin: auto;" />

These plots show that for both men and women, height and weight has increased gradually over the history of the Games. However, these plots could be hiding important variation since different body types are favored in different events. To explore this possibility, we must dive deeper into the data and consider trends in size separately for different events. However, since events have been added and removed from the Games throughout history, we must first identify a subset of events that have appeared consistently in the Olympics from 1960 to 2016.

Out of 489 events that appeared at least once in the Olympics since 1960, only 136 were included in every Olympiad. These include events for both men and women in alpine skiing, athletics, canoeing, diving, equestrian, fencing, figure skating, gymnastics, speed skating, and swimming, as well as events for men only in basketball, biathlon, boxing, crosscountry skiing, cycling, football, field hockey, ice hockey, pentathlon, rowing, ski jumping, water polo, weightlifting, and wrestling.



This is a lot of events to consider, but we can reduce the list a bit. First, we can eliminate events based on weight classes (wrestling, weightlifting, and boxing), since the size of athletes in these events are restricted and the changes over time primarily reflect [shifting definitions](https://www.sports-reference.com/olympics/summer/2000/WRE/) of the weight classes. Second, we can eliminate events that include both men and women, including all the equestrian events and pairs figure skating. This leaves 108 events to consider. 

To charaterize historical trends in size for different events, I fit separate linear regressions for Height ~ Year and Weight ~ Year for athletes in each event, and saved the estimated regression slopes. By plotting the estimated regression slopes for height against the estimated regression slopes for weight across different events, we can identify events in which the size of athletes have changed the most. Importantly, the quadrant of the plot in which the point falls indicates the type of size change for each event:

- Upper left quadrant: athletes have gotten shorter and heavier
- Upper right quadrant: athletes have gotten taller and heavier
- Lower right quadrant: athletes have gotten taller and lighter
- Lower left quadrant: athletes have gotten shorter and lighter

Here is an interactive plot for men's events. Simply hover your cursor over a point to see the exact slopes for height and weight, as well as the sport and event. The colors of points identify clusters of events from the same sport, and the axes are scaled to show the expected change in height and weight from 1960 to 2016 (e.g., a regression slope of 5 for the weight variable indicates that the estimated increase in the weight of athletes in that event from 1960 to 2016 is 5 kg). 

<center><iframe src="https://plot.ly/~rgriff23/1.embed?showlink=false" width="500" height="500" id="igraph" scrolling="no" seamless="seamless" frameBorder="0"> </iframe></center>

The vast majority of points fall in the upper right quadrant, indicating that the most common trend is for athletes to get both taller and heavier. This agrees with the boxplots from earlier in this post, which showed that the average height and weight for Olympic athletes has increased over time. The increase in size has been most extreme for points near the upper right corner of the plot, including basketball, ice hockey, water polo, downhill skiing, and rowing. Swimmers appear near the lower right portion of this quadrant, indicating that they have increased disproportionately in height relative to weight.

While most events are characterized by larger athletes over time, quite a few points fall in the lower left quadrant, indicating that for some events, the trend has been for athletes to get shorter and lighter. The light blue cluster of points in the lower left part of the chart represent gymnasts. Likewise, long distance runners and walkers, platform divers, and figure skaters have also tended to get smaller over time. 

Virtually no points fall in the upper left quadrant, indicating that there are no events for which athletes have simultaneously gotten shorter and heavier. Only a few events fall in lower right quadrant, representing events for which athletes have gotten simultaneously taller and lighter. Ski jumping is an outlier in this quadrant: since 1960, ski jumpers have gotten 5.2 cm taller but 10.8 kg lighter on average. The other events in which athletes have gotten taller but slightly lighter include several long distance running events and the high jump. 

Here is the same plot for women's events.

<center><iframe src="https://plot.ly/~rgriff23/3.embed?showlink=false" width="500" height="500" id="igraph" scrolling="no" seamless="seamless" frameBorder="0"> </iframe></center>

Overall, results for the women's events are similar to the men's events. Although women's basketball, ice hockey, and water polo are missing from the data due to their absence from at least some of the Game since 1960, the other sports appearing in the extreme upper right quadrant are the same: alpine skiing, swimming, the shot put and the discus throw. Like the men, female gymnasts and platform divers appear in the lower left quadrant, indicating that they too have decreased in both height and weight. No events appear in the upper left quadrant, and scarcely any fall in the lower right quadrant. The one point that falls clearly in the lower right quadrant corresponds to the high jump, in which women mirror the men in becoming substantially taller and slightly lighter. 

Taken together, these charts highlight that the bodies of Olympic athletes have become increasingly extreme over time. While the trend is for athletes in most events to become taller and heavier, there are also a handful of events in which athletes have become smaller (e.g., gymnastics) or simultaneously taller and lighter (e.g., ski jumping). 

## Final thoughts

This will be my last post using the Olympic history data, at least for a while. There is always a chance I will think of something else to do with the data in the future, but for now, I'm satisfied with the exploring I've done. The very last thing I'll say is that couple of books were really helpful for getting a big-picture view of Olympic history and providing some motivation for these data explorations: 

The first is [Power, Politics, and the Olympic Games](https://www.amazon.com/Power-Politics-Olympic-Games-Alfred/dp/0880119586) by Alfred Senn. It's a bit old, 1999, but it provides a moderately detailed and insightful history of the Olympics up to that point. A recurring theme in Senn's book is the clash between Olympic myth and reality, and how the nature of this clash has evolved over the 20th century. Senn's history helps to demystify the Games, which are widely presented by the media as being a timeless and idealistic affair. 

Second, [Watching the Olympics: Politics, Power, and Representation](https://www.amazon.com/Watching-Olympics-Politics-Power-Representation-ebook/dp/B007ZZFPJO/ref=dp_kinw_strp_1?dpID=41Ohh7IVE5L&preST=_SY445_QL70_&dpSrc=detail) is a collection of essays from scholars in different disiplines. In contrast to Senn's book, each chapter is dedicated to a particular aspect of the Olympics (e.g., the selection of host cities, media coverage, security, doping, women, the paralympics) rather than to a specific period in Olympic history. The focus on topics and perspectives rather than moments in time provides a nice complement to Senn's book, and I actually read Senn's book a second time after reading this one, since much of the detail Senn provides was more interesting and meaningful in the context of the different issues and arguments raised in this book.
