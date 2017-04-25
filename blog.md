---
layout: page
title: Blog
---

<ul id="blog-posts" class="posts">
    {% for post in site.posts %}
      <li><span>{{ post.date | date: "%Y %m %d" }} &raquo; </span><a href="{{ post.url }}">{{ post.title }}</a></li>
    {% endfor %}
</ul>


