
## pull-in web service support
require 'sinatra/base'    ## note: using the "modular" style
require 'webrick'


## our own code
require_relative 'artserve/version'    # note: let version always go first
require_relative 'artserve/service'



class Artserve
  def self.main
     puts 'hello from main'

  #####
  # fix/todo:
  ##   use differnt port ??
  ##
  ##  use --local  for host e.g. 127.0.0.1  insteaod of 0.0.0.0 ???

 #   puts 'before Puma.run app'
 #   require 'rack/handler/puma'
 #   Rack::Handler::Puma.run ProfilepicService, :Port => 3000, :Host => '0.0.0.0'
 #   puts 'after Puma.run app'

 # use webrick for now - why? why not?
     puts 'before WEBrick.run service'
     Rack::Handler::WEBrick.run Artserve, :Port => 3000, :Host => '127.0.0.1'
     puts 'after WEBrick.run service'

    puts 'bye'
  end
end


####
# convenience aliases / shortcuts / alternate spellings
#    add ArtService / Artservice too - why? why not?
ArtServe        = Artserve
ArtServer       = Artserve
Artserver       = Artserve


puts Artbase::Module::Artserve.banner    # say hello
