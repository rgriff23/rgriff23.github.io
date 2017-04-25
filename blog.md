---
layout: page
title: Blog
---


<dl>
 {% for post in site.posts %}
  <dt><a href="{{ post.url }}">{{ post.date | date: "%Y %m %d" }} - {{ post.title }}</dt>
</dl> 
