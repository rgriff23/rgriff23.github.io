---
layout: page
title: Blog
---

{% comment %}

<ul>
{% for post in site.posts %}
    <li><a href="{{ post.url }}">{{ post.date | date: "%Y %M %D" }} - {{ post.title }}</a>
    <a>Tag{% if post.tags.size > 1 %}s{% endif %}: \`{{ post.tags | sort | join: " " }}\`</a></li>
{% endfor %}
</ul>

{% endcomment %}

 <dl>
 {% for post in site.posts %}
  <dt><a href="{{ post.url }}">{{ post.date | date: "%Y %m %d" }} - {{ post.title }}</dt>
   <dd>- <a>Tag{% if post.tags.size > 1 %}s{% endif %}: 
          {{ post.tags | sort | join: " " }}</a></dd>
</dl> 
