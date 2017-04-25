---
layout: page
title: Blog
---

{% for post in site.posts %}
    <li><a href="{{ post.url }}">{{ post.date }} - {{ post.title }}</a></li>
    <a>Tag{% if post.tags.size > 1 %}s{% endif %}: \`{{ post.tags | sort | join: " " }}\`</a>
{% endfor %}

