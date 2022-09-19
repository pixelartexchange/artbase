
# todo/check: find a better name?
class Artserve < Sinatra::Base
  get '/' do
    erb :index
  end
end    # class ProfilepicService
