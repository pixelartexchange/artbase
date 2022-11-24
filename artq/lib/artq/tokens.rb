
module ArtQ



class Meta    ## check:  change/rename to MetaToken or such - why? why not?
  def self.parse( tokenURI )
    if tokenURI.start_with?( 'data:application/json;base64' )

      str = tokenURI.sub( 'data:application/json;base64', '' )
      str = Base64.decode64( str )
      data = JSON.parse( str )

      ## check for image_data - and replace if base64 encoded
      image_data     = data['image_data']
      svg_image_data = data['svg_image_data']

      if svg_image_data && svg_image_data.start_with?( 'data:image/svg+xml;base64' )
        data['svg_image_data'] = '...'
        data['image_data'] = '...'   if image_data
        ## note:  prefer svg_image_data if present over image_data - why? why not?
        str = svg_image_data.sub( 'data:image/svg+xml;base64', '' )
        image_data = Base64.decode64( str )
      elsif image_data && image_data.start_with?( 'data:image/svg+xml;base64' )
        data['image_data'] = '...'
        str = image_data.sub( 'data:image/svg+xml;base64', '' )
        image_data = Base64.decode64( str )
      else
        ## assume no inline image_data ??
      end

      new( data, image_data )
    else
      new   ## use new({},nil) - why? why not?
    end
   end

   def initialize( data={},
                   image_data=nil )
      @data       = data
      @image_data = image_data
   end

  def data()       @data; end
  def image_data() @image_data; end
end  # class Meta



## download on-blockchain token metadata and (inline) images
def self.download_tokens( contract_address,
                          outdir: "./#{contract_address}",
                          ids: (0..99) )

  puts "==> download token (on-blockchain) metadata and (inline) images for art collection contract @ >#{contract_address}<:"

  c = Contract.new( contract_address )

  ## get some metadata - why? why not?
  name         = c.name
  symbol       = c.symbol
  totalSupply  = c.totalSupply


  warns = []   ## collect all warnings

  tokenIds = ids
  tokenIds.each do |tokenId|
    tokenURI = c.tokenURI( tokenId )
    sleep( 0.5 )


    puts "     tokenId #{tokenId}:"
    meta = Meta.parse( tokenURI )
    if meta.data.empty?
      ## todo/check: raise TypeError or such or return nil - why? why not?
       warns << "token no. #{tokenId} metadata not 'on-blockchain'? expected json base64-encoded; got:"
       puts "!! WARN - " + warns[-1]
       pp tokenURI
    else
       path = "#{outdir}/token/#{tokenId}.json"
       write_json( path, meta.data )

       if meta.image_data
          ## assume svg for now - always - why? why not?
          path = "#{outdir}/token-i/#{tokenId}.svg"
          write_text( path, meta.image_data )
       else
         warns << "token no. #{tokenId} (inline) image data not found in 'on-blockchain' metadata; got:"
         puts "!! WARN - " + warns[-1]
         pp meta.data
       end
    end
  end

  if warns.size > 0
      puts "!!! #{warns.size} WARNING(S):"
      pp warns
  end

  puts
  puts "   name: >#{name}<"
  puts "   symbol: >#{symbol}<"
  puts "   totalSupply: >#{totalSupply}<"
end

end  # module ArtQ
