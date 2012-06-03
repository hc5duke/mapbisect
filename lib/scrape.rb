#!/usr/bin/env ruby
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'json';

cal = Hpricot(open('http://www.city-data.com/city/California.html'))
city = (cal/'table.cityTAB td:nth-child(2)').map(&:inner_text).map{|name| name.sub(/, ca$/i, '')}
pops = (cal/'table.cityTAB td:nth-child(3)').map{|t|t.inner_text.gsub(',', '').to_i}
lats = JSON.load(cal.inner_html[/latTab = .*\n/].split(';').first.split('=').last)
lons = JSON.load(cal.inner_html[/lonTab = .*\n/].split(';').first.split('=').last)

# reject stuff
rejects = [
  'East San Gabriel Valley',
  'Upper San Gabriel Valley',
  'Central Contra Costa',
  'North Coast',
  'Southwest San Gabriel Valley',
  'Central Coast',
  'South Coast',
  'West Contra Costa',
  'Coachella Valley',
  'North Antelope Valley',
]
min_pop = 20_000

cc = city.zip(lats, lons, pops).reject{|arr| rejects.include? arr[0] || arr[3] < min_pop}
File.open('./data/ca.txt', 'w') do |f|
  cc.each do |arr|
    f.write(arr.join("\t"))
    f.write("\n")
  end
end
