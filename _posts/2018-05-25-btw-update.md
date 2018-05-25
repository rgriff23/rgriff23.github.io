---
title: 'Major update to R package btw: prettier code, BayesTraitsV3 and Windows support'
date: "2018-05-25"
layout: post
tags: R BayesTraits btw
comments: TRUE
---

I've finished a long-overdue update to `btw`, my R package for running [BayesTraits](https://www.evolution.rdg.ac.uk/BayesTraits.html) from R. There are three significant changes in version 2 of `btw`:

1. `btw` is now compatible with both Mac OS and Windows systems. Shout out to <a target="_blank" href="http://dk-giscience.zgis.net/index.php/37-website/256-ranacher-peter">Peter Ranacher</a> for contributing code to run `btw` functions on Windows, which I modified and incorporated into the update.

2. User input is now much more flexible. I have replaced the many functions containing a dizzying array of arguments with a single function that accepts a character vector containing the desired BayesTraits commands, with each command having its own character string. These commands are copied as-is into the `input.txt` file. Thus, any commands you can pass to BayesTraitsV3, you can pass to  `btw`. In addition to adding flexibility for users, this format makes it easier for anyone who is familiar with BayesTraits to learn to use `btw`.

3. `btw` now supports all the new functionality of BayesTraitsV3. I endeavored to be thorough in importing and handling all of the different types of output from BayesTraitsV3. The only type of output `btw` doesn't support is the variable rates model output, but I don't recommend using this model anyway (read [this paper](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12285) to know why).

The updated [project page](/projects/btw) provides more detail and a tutorial. 
