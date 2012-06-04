require 'rubygems'
require 'sinatra'
require 'set'
require 'json'
require './lib/ca'
require './lib/geo'

set :public_folder, Proc.new { File.join(root, "public") }

get '/' do
  haml :index, :format => :html5
end

get '/geocode/:name' do
  name = params[:name].downcase.gsub(/\b('?[a-z])/) { $1.capitalize }
  city = Ca::CALIFORNIA[name] || Ca::CALIFORNIA['San Francisco']
  city[0, 2].join(',')
end

post '/bisect' do
  cities = {}
  min_pop = (params[:pop] || 100_000).to_i
  min_pop = 20_000 if min_pop < 20_000
  max_dist = (params[:dist] || 10).to_f
  max_dist = 200 if max_dist > 200
  max_dist /= 600 # approximate
  range_start = (params[:start] || 0).to_f
  range_end = (params[:end] || 1).to_f
  paths = params[:paths].map{ |key, value| value.map(&:to_f) }
  abs_max_dist = Geo.distance(paths.first, paths.last)
  all_cities = Ca::CALIFORNIA.select do |name, value|
    value[2] > min_pop
  end
  paths.length.pred.times do |path_index|
    origin = paths[path_index]
    destin = paths[path_index.succ]

    all_cities.each do |name, value|
      next if cities.include?(name)
      next unless Geo.distance(origin, destin) > 0.2
      next unless Geo.within(origin, destin, value, max_dist)
      cities[name] = value
    end
  end

  origin = paths.first
  destin = paths.last

  list = cities.map do |name, city|
    d1 = Geo.distance(origin, city)
    d2 = Geo.distance(city, destin)
    next if [d1, d2].max > abs_max_dist
    progress = d2 / (d1 + d2).to_f
    if progress > range_start && progress < range_end
      {
        name: name,
        progress: progress,
        population: city[2],
        latlon: city[0, 2],
        distances: [d1, d2],
      }
    end
  end.compact
  list.to_json
end
