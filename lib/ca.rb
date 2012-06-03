require 'set'

class Ca
  def self.init
    values = {}
    File.open('./data/ca.txt').each do |line|
      name, lat, lon, pop = line.split("\t")
      values[name] = [lat.to_f, lon.to_f, pop.to_f]
    end
    values
  end

  CALIFORNIA = init
end
