

module OpenSea
  BASE = 'https://api.opensea.io/api/v1'


  ## todo/check: rename to query or search or such - why? why not?
  def self.assets_url( collection:,
                       limit: 20,
                       cursor: nil )
     src = "#{BASE}/assets?collection=#{collection}" +
           "&order_direction=desc" +
           "&include_orders=false" +
           "&limit=#{limit}" +
           "&format=json"

     src += "&cursor=#{cursor}"   if cursor

     src
  end


  def self.assets( collection:,
                   limit: 20,
                   cursor: nil )
     src = assets_url( collection: collection,
                       limit: limit,
                       cursor: cursor )
     call( src )
  end


  def self.collection_url( collection )
    src = "#{BASE}/collection/#{collection}" +
           "?format=json"
    src
  end

  def self.collection( collection )
    call( collection_url(collection) )
  end



  def self.call( src )   ## get response as (parsed) json (hash table)
    uri = URI.parse( src )

    http = Net::HTTP.new( uri.host, uri.port )

    puts "[debug] GET #{uri.request_uri} uri=#{uri}"

    headers = {
      'User-Agent' => "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36",
      # 'User-Agent' => "ruby v#{RUBY_VERSION}",
     }


    request = Net::HTTP::Get.new( uri.request_uri, headers )
    if uri.instance_of? URI::HTTPS
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    response   = http.request( request )

    if response.code == '200'
      puts "#{response.code} #{response.message} -  content_type: #{response.content_type}, content_length: #{response.content_length}"

      text = response.body.to_s
      text = text.force_encoding( Encoding::UTF_8 )

      data = JSON.parse( text )
      data
    else
      puts "!! ERROR:"
      puts "#{response.code} #{response.message}"
      exit 1
    end
  end


end # module OpenSea