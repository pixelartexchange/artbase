require 'ethlite'
require 'optparse'


## our own code
require_relative 'artq/version'   # let version go first
require_relative 'artq/contract'



module ArtQ





class Tool

  def self.main( args=ARGV )
    puts "==> welcome to artq tool with args:"
    pp args

    options = {
              }

    parser = OptionParser.new do |opts|

      opts.on("--rpc STRING",
              "JSON RPC Host (default: nil)") do |str|
          options[ :rpc]  = str
      end

      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
    end

    parser.parse!( args )
    puts "options:"
    pp options

    puts "args:"
    pp args

    if args.size < 1
      puts "!! ERROR - no collection found - use <collection> <command>..."
      puts ""
      exit
    end

    contract_address = args[0]   ## todo/check - use collection_name/slug or such?
    command          = args[1] || 'info'


    if ['i','inf','info'].include?( command )
        do_info( contract_address )
    elsif ['l', 'layer', 'layers'].include?( command )
        do_layers( contract_address )
    else
      puts "!! ERROR - unknown command >#{command}<, sorry"
    end

    puts "bye"
  end





  def self.do_info( contract_address )
    puts "==> query info for art collection contract @ >#{contract_address}<:"

    c = Contract.new( contract_address )

    name         =  c.name
    symbol       =  c.symbol
    totalSupply  =  c.totalSupply

    meta = []
    tokenIds = (0..2)
    tokenIds.each do |tokenId|
      tokenURI =        c.tokenURI( tokenId )
      meta << [tokenId, tokenURI]
    end

    puts "   name: >#{name}<"
    puts "   symbol: >#{symbol}<"
    puts "   totalSupply: >#{totalSupply}<"
    puts
    puts "   tokenURIs #{tokenIds}:"
    meta.each do |tokenId, tokenURI|
       puts "     tokenId #{tokenId}:"
       if tokenURI.start_with?( 'data:application/json;base64')
          ## on-blockchain!!!
          ## decode base64

          str = tokenURI.sub( 'data:application/json;base64', '' )
          str = Base64.decode64( str )
          data = JSON.parse( str )


          ## check for image_data - and replace if base64 encoded
          image_data = data['image_data']

          if image_data.start_with?( 'data:image/svg+xml;base64' )
            data['image_data'] = '...'
            str = image_data.sub( 'data:image/svg+xml;base64', '' )
             image_data = Base64.decode64( str )
          end

          pp data
          puts
          puts "    image_data:"
          puts image_data
       else
         puts "        #{tokenURI}"
       end
    end
  end



  JPGSIG   = "\xFF\xD8\xFF".force_encoding( Encoding::ASCII_8BIT )
  PNGSIG   = "\x89PNG".force_encoding( Encoding::ASCII_8BIT )
  GIF87SIG = "GIF87".force_encoding( Encoding::ASCII_8BIT )
  GIF89SIG = "GIF89".force_encoding( Encoding::ASCII_8BIT )


  def self.do_layers( contract_address )
    puts "==> query layers for art collection contract @ >#{contract_address}<:"

    c = Contract.new( contract_address )

    name         =  c.name
    symbol       =  c.symbol
    totalSupply  =  c.totalSupply


    traitDetails = []
    n=0
    loop do
      m=0
      loop do
        rec = c.traitDetails( n, m )
        break  if rec == ['','',false]

        traitDetails << [[n,m], rec ]
        m += 1
        sleep( 0.5 )
      end
      break  if m==0
      n += 1
    end

    headers = ['index', 'name', 'type', 'hide']
    recs = []
    traitDetails.each do |t|
      recs << [ t[0].join('/'),
                t[1][0],
                t[1][1],
                t[1][2].to_s]
    end

    buf = String.new('')
    buf << headers.join( ', ' )
    buf << "\n"
    recs.each do |rec|
       buf << rec.join( ', ' )
       buf << "\n"
    end

    outdir = "./tmp/#{contract_address}"
    write_text( "#{outdir}/layers.csv", buf )

    #####
    #  try to download all images
    traitDetails.each do |t|
      n,m  = t[0]
      data = c.traitData( n, m )

      basename = "#{n}_#{m}"
      if data.start_with?( PNGSIG )
        puts "BINGO!! it's a png blob"
        write_blob( "#{outdir}/#{basename}.png", data )
      elsif data.start_with?( GIF87SIG ) || data.start_with?( GIF89SIG )
        puts "BINGO!! it's a gif blob"
        write_blob( "#{outdir}/#{basename}.gif", data )
      elsif data.start_with?( JPGSIG )
        puts "BINGO!! it's a jpg blob"
        write_blob( "#{outdir}/#{basename}.jpg", data )
      else
        puts "!! ERROR - unknown image format; sorry"
        exit 1
      end
      sleep( 0.5 )
    end


    puts "   name: >#{name}<"
    puts "   symbol: >#{symbol}<"
    puts "   totalSupply: >#{totalSupply}<"
    puts
    puts "   traitDetails:"
    pp  traitDetails
  end


end  # class Tool
end   # module ArtQ




######
#  add convience alternate spelling / names
Artq  = ArtQ


