---
layout: page
title: Blog
---

{% comment %}
*
*  This loop loops through a collection called `collection_name`
*  and sorts it by the front matter variable `date` and than filters
*  the collection with `reverse` in reverse order
*
*  To make it work you first have to assign the data to a new string
*  called `sorted`.
*
{% endcomment %}
<ul>
    {% assign sorted = (site.posts | sort: 'date') | reverse %}
    {% for item in sorted %}
    <li>{{ item.title }}</li>
    {% endfor %}
</ul>