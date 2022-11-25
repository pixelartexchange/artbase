require 'ethlite'
require 'optparse'


## our own code
require_relative 'artq/version'   # let version go first
require_relative 'artq/contract'
require_relative 'artq/layers'
require_relative 'artq/tokens'



module ArtQ

class Tool


  def self.is_addr?( str )
    ## e.g.
    ##  must for now start with 0x (or 0X)
    ##  and than 40 hexdigits (20 bytes)
    ##  e.g. 0xe21ebcd28d37a67757b9bc7b290f4c4928a430b1
    str.match( /\A0x[0-9a-f]{40}\z/i )
  end



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


    ## todo/check - use collection_name/slug or such?
    contract_address = nil
    outdir           = nil

    if is_addr?( args[0] ) ## do nothing; it's an address
       contract_address = args[0]
       outdir           = "./tmp/#{contract_address}"
    else  ## try reading  collection.yml config
      config_path = "./#{args[0]}/collection.yml"
      if File.exist?( config_path )
         config = read_yaml( config_path )
         contract_address = config['token']['contract']
         outdir           = "./#{args[0]}"
      else
        puts "!! ERROR - no config found for collection >#{contract_address}<; sorry"
        exit 1
      end
    end


    command          = args[1] || 'info'


    if ['i','inf','info'].include?( command )
        do_info( contract_address )
    elsif ['l', 'layer', 'layers'].include?( command )
        ## note: outdir - save into cache for now
        do_layers( contract_address, outdir: outdir )
    elsif ['t', 'token', 'tokens'].include?( command )
        ## note: outdir - saves into token (metadata) & token-i (images)
        do_tokens( contract_address, outdir: outdir )
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

    recs = []
    tokenIds = (0..2)
    tokenIds.each do |tokenId|
      tokenURI =        c.tokenURI( tokenId )
      recs << [tokenId, tokenURI]
    end

    puts "   name: >#{name}<"
    puts "   symbol: >#{symbol}<"
    puts "   totalSupply: >#{totalSupply}<"
    puts
    puts "   tokenURIs #{tokenIds}:"
    recs.each do |tokenId, tokenURI|
       puts "     tokenId #{tokenId}:"
       meta = Meta.parse( tokenURI )
       if meta.data.empty?   ## assume "off-blockchain" if no "on-blockchain" data found
         puts "        #{tokenURI}"
       else   ## assume "on-blockchain" data
          pp meta.data
          puts
          puts "    image_data:"
          puts meta.image_data
       end
    end
  end



  def self.do_layers( contract_address, outdir: )
    puts "==> query layers for art collection contract @ >#{contract_address}<:"

    ArtQ.download_layers( contract_address,
                          outdir: outdir )
  end

  def self.do_tokens( contract_address, outdir: )
    puts "==> query inline 'on-blockchain' token metadata & images for art collection contract @ >#{contract_address}<:"
    ArtQ.download_tokens( contract_address,
                          outdir: outdir )
  end

end  # class Tool
end   # module ArtQ




######
#  add convience alternate spelling / names
Artq  = ArtQ


