# Wikipedia Graph Search

Play [The Six Degrees of Kevin Bacon][1] with any Wikipedia article.

## Introduction

This simple program counts the links between a given Wikipedia article
and [Kevin Bacon's Wikipedia page][2].

## Installation and Usage

This was written to use Ruby 3.1.2, but there's nothing about it that requires
that specific version.

Installing dependancies:

    bundle install

Running the script:

    bundle exec ./bacon.rb 'https://en.wikipedia.org/wiki/Miles_Teller'

## Implementation Notes

This script builds its graph by screen-scraping Wikipedia, which is *extremely*
inefficient. The proper way to do this work is to grab a bulk download
of Wikipedia's data from [`dumps.wikimedia.org`][3] and extract the link data
into your own database, eliminating the need to contact Wikipedia at all.
Unfortunately, these dumps are very large, and even a dump of just the pagelinks
table would consume more disk space than I have available to work with, and I
would have no easy way to distribute this script with the extracted article
data necessary to run it. Beyond that practical constraint, data extracted
from Wikipedia dumps can be as much as a week out of date.

But such an approach would offer considerable advantages. In addition to the
performance advantages of reading from disk instead of querying the network,
having complete knowledge of the entire Wikipedia graph enables a bi-directional
breadth-first search, which I suspect would be faster than the simple BFS I use
in my code.

[1]: https://en.wikipedia.org/wiki/Six_Degrees_of_Kevin_Bacon
[2]: https://en.wikipedia.org/wiki/Kevin_Bacon
[3]: https://dumps.wikimedia.org/
