require 'rubygems'
require 'sinatra'

set :public_folder, Proc.new { File.join(root, "public") }

get '/' do
  haml :index, :format => :html5
end
