---
layout: page
title: Blog
---


<dl>
 {% for post in site.posts %}
  <dt><a href="{{ post.url }}">{{ post.date | date: "%Y %m %d" }} - {{ post.title }}</dt>
   <dd>- Tag{% if post.tags.size > 1 %}s{% endif %}: 
          {{ post.tags | sort | join: " " }}</dd>
</dl> 
