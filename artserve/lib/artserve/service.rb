
# todo/check: find a better name?
class Artserve < Sinatra::Base

  get '/artbase.db' do
    path = settings.artbase
    puts "  serving sqlite database as (binary) blob >#{path}<..."
    headers( 'Content-Type' => "application/octet-stream" )

    blob = File.open( path, 'rb' ) { |f| f.read }
    puts "     #{blob.size} byte(s)"
    blob
  end

  get '/' do
    erb :index
  end

end    # class ProfilepicService
