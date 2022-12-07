#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'

class Article
  attr_accessor :url, :depth

  def initialize(url, depth=0)
    @url = url
    @depth = depth
    @links = nil
  end

  def links
    # We retrieve a list of adjacent articles by simply requesting the page and
    # examining the links. It is possible to grab the links through Wikipedia's
    # REST API, but those records seem to be out-of-sync with the content
    # on the website, which I judge to be authoritative. In addition,
    # screen-scraping seems to be noticably faster than a series of paginated
    # API calls, as I can get all the links in a single request.

    return @links unless @links.nil?

    doc = Nokogiri::HTML(URI.open(url))
    @links = doc.css('#content a')
    @links = @links.map {|element| element['href']}.compact

    # Filter out external links
    @links = @links.select { |l| l.match? /^\/wiki\// }

    # Internal Wikipedia pages. Including them seems inappropriate.
    @links = @links.reject { |l| l.match? /^\/wiki\/Category:\S+/ }
    @links = @links.reject { |l| l.match? /^\/wiki\/File:\S+/ }
    @links = @links.reject { |l| l.match? /^\/wiki\/Help:\S+/ }
    @links = @links.reject { |l| l.match? /^\/wiki\/Special:\S+/ }
    @links = @links.reject { |l| l.match? /^\/wiki\/Template:\S+/ }
    @links = @links.reject { |l| l.match? /^\/wiki\/Template_talk:\S+/ }
    @links = @links.reject { |l| l.match? /^\/wiki\/User:\S+/ }
    @links = @links.reject { |l| l.match? /^\/wiki\/Wikipedia:\S+/ }

    # Strip deep links, as they are unnecessary and sometimes make Ruby choke
    @links = @links.map { |l| l.sub(/\#.+$/, '') }

    # Make them real URLs that we can fetch later
    @links = @links.map{|l| 'https://en.wikipedia.org' + l }

    # Remove duplicates
    @links = @links.uniq
    @links
  end
end

usage = <<END

Count the steps between any Wikipedia article and Kevin Bacon's own Wikipedia
article.

Usage: bacon.rb 'https://en.wikipedia.org/wiki/Minnesota'
END

if ARGV.length < 1
  STDERR.puts usage
  exit(1)
end

source = ARGV[0]
target = 'https://en.wikipedia.org/wiki/Kevin_Bacon'

# By definition, Kevin Bacon has a Bacon Number of 0.
# See: https://en.wikipedia.org/wiki/Six_Degrees_of_Kevin_Bacon
if source == target
  puts 0
  exit(0)
end

# This is a simple breadth-first search of the graph. It would likely be
# faster to use a bi-drectional BFS search, but I don't think there is a
# straightforward way to do that with the way we are building the graph
# on the fly.

queue = []
visited = Set.new

current_node = Article.new(source)
queue << current_node
visited << current_node.url

while queue.any?
  current_node = queue.shift
  current_node.links.each do |link|
    if link == target
      puts current_node.depth + 1
      exit 0
    end

    next if visited.include? link

    queue << Article.new(link, current_node.depth+1)
    visited << link
  end
end

# In the unthinkable scenario where no path of any length is found, we return
# -1.
puts '-1'
