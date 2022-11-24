
module OpenSea

module Puppeteer

###
##  todo: use a config block in the future - why? why not?
def self.chrome_path=( path )
  if File.exist?( path )
    puts "** bingo! found chrome executable @ path >#{path}<"
  else
    puts "*** ERROR - sorry; cannot find chrome executable @ path >#{path}<"
    exit 1
  end

  @chrome_path = path
end

def self.chrome_path
  @chrome_path
end



def self.download_assets( collection,
                          offset: nil )

   opts = {}
   opts[:headless]        = false
   opts[:executable_path] = chrome_path  if chrome_path   ## add only if set (default is nil)


  ::Puppeteer.launch( **opts ) do |browser|

    ## make sure path exists
    dirname= "./#{collection}/opensea"
    FileUtils.mkdir_p( dirname )  unless Dir.exist?( dirname )


    cursor = nil
    if offset
      txt = File.open( "#{dirname}/#{offset}.json", "r:utf-8" ) {|f| f.read }
      meta = JSON.parse( txt )
      cursor = meta['next']
    end

    page = browser.new_page
    page_url  = OpenSea.assets_url( collection: collection,
                                    cursor: cursor )
    puts page_url

    count =  offset ? offset+1 : 0   ## default - start with count 0

     loop do
        response = page.goto( page_url )
        pp response.headers

        puts
        puts page.content[0..200]

        puts
        puts response.text[0..200]

        data = JSON.parse( response.text )

        outpath = "#{dirname}/#{count}.json"
        File.open( outpath, "w:utf-8" ) do |f|
            f.write( JSON.pretty_generate( data ) )
        end

        cursor = data[ 'next' ] ## e.g. "LXBrPTQyNzY5MDcw",
        count += 1

        break  if count > 1000   ##  "circuit breaker"
        break  if cursor.nil?

        page_url = OpenSea.assets_url( collection: collection,
                                       cursor: cursor )
        puts page_url


        delay_in_secs =  2
        puts "sleeping #{delay_in_secs} sec(s)..."
        sleep( delay_in_secs )
     end
  end
end


end # module Puppeteer
end # module OpenSea
