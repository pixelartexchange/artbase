require 'ethlite'
require 'optparse'


## our own code
require_relative 'artq/version'   # let version go first



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
    else
      puts "!! ERROR - unknown command >#{command}<, sorry"
    end

    puts "bye"
  end


  ETH_name = Ethlite::ContractMethod.new( 'name',
                         inputs: [],
                         outputs: ['string'] )

  ETH_symbol = Ethlite::ContractMethod.new( 'symbol',
                         inputs: [],
                         outputs: ['string'] )

  ETH_totalSupply = Ethlite::ContractMethod.new( 'totalSupply',
                         inputs: [],
                         outputs: ['uint256'] )

  ETH_tokenURI     = Ethlite::ContractMethod.new( 'tokenURI',
                        inputs: ['uint256'],
                        outputs: ['string'] )



  def self.do_info( contract_address )
    puts "==> query art collection contract info @ >#{contract_address}<:"

    rpc = JsonRpc.new( ENV['INFURA_URI'] )

    name         =  ETH_name.do_call( rpc, contract_address, [] )
    symbol       =  ETH_symbol.do_call( rpc, contract_address,  [] )
    totalSupply  =  ETH_totalSupply.do_call( rpc, contract_address,  [] )

    meta = []
    tokenIds = (0..2)
    tokenIds.each do |tokenId|
      tokenURI =        ETH_tokenURI.do_call( rpc, contract_address, [tokenId] )
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
end  # class Tool


end   # module ArtQ




######
#  add convience alternate spelling / names
Artq  = ArtQ


