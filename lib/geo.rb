class Geo
  def self.line_distance(origin, destin, target)
    x0, y0 = target[0, 2]
    x1, y1 = origin[0, 2]
    x2, y2 = destin[0, 2]
    x0 *= 1.4
    x1 *= 1.4
    x2 *= 1.4
    ((x2-x1) * (y1-y0) - (x1-x0) * (y2-y1)).abs / Math.sqrt((x2-x1) ** 2 + (y2-y1) ** 2)
  end

  def self.distance(origin, destin)
    x1, y1 = origin[0, 2]
    x2, y2 = destin[0, 2]
    self.coor_dist(x1, y1, x2, y2)
  end

  # mostly lifted from:
  # https://github.com/almartin/Ruby-Haversine/blob/master/haversine.rb
  def self.to_radian(value)
    value * Math::PI / 180.0
  end

  def self.coor_dist(lat1, lon1, lat2, lon2)
    earth_radius = 6371 # Earth's radius in KM

    lat1_radian = to_radian(lat1)
    lat2_radian = to_radian(lat2)
    delta_lat_radian = to_radian(lat2 - lat1)
    delta_lon_radian = to_radian(lon2 - lon1)

    # Calculate square of half the chord length between latitude and longitude
    a = Math.sin(delta_lat_radian / 2) * Math.sin(delta_lat_radian / 2) +
        Math.cos(lat1_radian) * Math.cos(lat2_radian) *
        Math.sin(delta_lon_radian / 2) * Math.sin(delta_lon_radian / 2)

    # Calculate the angular distance in radians
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    earth_radius * c
  end

  def self.populous(city, min_pop)
    city[:pop] >= min_pop
  end

  def self.within(origin, destin, city, max_dist)
    distance = line_distance(origin, destin, city)
    distance <= max_dist
  end
end

=begin
require './lib/ca'
require './lib/geo'
sf = CALIFORNIA[:name].index('San Francisco'); sf = [CALIFORNIA[:lat][sf], CALIFORNIA[:lon][sf], CALIFORNIA[:pop][sf]]
sd = CALIFORNIA[:name].index('San Diego');     sd = [CALIFORNIA[:lat][sd], CALIFORNIA[:lon][sd], CALIFORNIA[:pop][sd]]
fr = CALIFORNIA[:name].index('Fresno');        fr = [CALIFORNIA[:lat][fr], CALIFORNIA[:lon][fr], CALIFORNIA[:pop][fr]]
sj = CALIFORNIA[:name].index('San Jose');      sj = [CALIFORNIA[:lat][sj], CALIFORNIA[:lon][sj], CALIFORNIA[:pop][sj]]
bk = CALIFORNIA[:name].index('Bakersfield');   bk = [CALIFORNIA[:lat][bk], CALIFORNIA[:lon][bk], CALIFORNIA[:pop][bk]]
la = CALIFORNIA[:name].index('Los Angeles');   la = [CALIFORNIA[:lat][la], CALIFORNIA[:lon][la], CALIFORNIA[:pop][la]]
Geo.distance(sf, sd, fr)
Geo.distance(sf, sd, sj)
Geo.distance(sf, sd, bk)
Geo.distance(sf, sd, la)

CALIFORNIA[:pop].length.times do |index|
  tgt = [CALIFORNIA[:lat][index], CALIFORNIA[:lon][index]]
  pop = CALIFORNIA[:pop][index]
  puts CALIFORNIA[:name] if Geo.distance(sd, sf, tgt) < 0.01 && pop > 10000000
end and nil

=end
