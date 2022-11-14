require 'ethlite'




class TokenContract

  ABI_tokenURI =  <<TXT
  { "name":"tokenURI",
    "type":"function",
    "stateMutability":"view",
    "inputs":
      [{"name":"tokenId", "type":"uint256"}],
    "outputs":
      [{ "name":"", "type":"string"}]
   }
TXT

 ABI_traitData =  <<TXT
   {"name":"traitData",
   "type":"function",
   "stateMutability":"view",
     "inputs":
      [{ "name":"layerIndex","type":"uint256"},
       {"name":"traitIndex", "type":"uint256"}],
     "outputs":
     [{"name":"","type":"string"}]
   }
TXT

  ABI_traitDetails = <<TXT
 {  "name":"traitDetails",
    "type":"function",
    "stateMutability":"view",
    "inputs":[{"name":"layerIndex","type":"uint256"},
                {"name":"traitIndex","type":"uint256"}],
     "outputs":[{"components":
           [{"name":"name","type":"string"},
           {"name":"mimetype","type":"string"},
           {"name":"hide","type":"bool"}],
           "name":"","type":"tuple"}]
 }
TXT


  ETH_tokenURI     = Ethlite::ContractMethod.new( ABI_tokenURI )
  ETH_traitData    = Ethlite::ContractMethod.new( ABI_traitData  )
  ETH_traitDetails = Ethlite::ContractMethod.new( ABI_traitDetails )


  def initialize( contract_address )
     @contract_address = contract_address
  end

  def tokenURI( id )
    args = [id]
    ETH_tokenURI.do_call( rpc, @contract_address, args )
  end

  def traitData( n, m )
    args = [n,m]
    ETH_traitData.do_call( rpc, @contract_address, args )
  end

  def traitDetails( n, m )
    args = [n,m]
    ETH_traitDetails.do_call( rpc, @contract_address, args )
  end



  JPGSIG   = "\xFF\xD8\xFF".force_encoding( Encoding::ASCII_8BIT )
  PNGSIG   = "\x89PNG".force_encoding( Encoding::ASCII_8BIT )
  GIF87SIG = "GIF87".force_encoding( Encoding::ASCII_8BIT )
  GIF89SIG = "GIF89".force_encoding( Encoding::ASCII_8BIT )


  def download_layers( tiers, outdir:'./layers' )

    tiers.each_with_index do |tier,n|
      tier.each_with_index do |dist,m|

        sleep( 0.5 )
        res = traitData( n, m )
        pp res

        basename = "#{n}_#{m}"
        if res.start_with?( PNGSIG )
          puts "BINGO!! it's a png blob"
          write_blob( "#{outdir}/#{basename}.png", res )
       elsif res.start_with?( GIF87SIG ) || res.start_with?( GIF89SIG )
         puts "BINGO!! it's a gif blob"
         write_blob( "#{outdir}/#{basename}.gif", res )
       elsif res.start_with?( JPGSIG )
         puts "BINGO!! it's a jpg blob"
         write_blob( "#{outdir}/#{basename}.jpg", res )
       else
         puts "!! ERROR - unknown image format; sorry"
         exit 1
       end
      end
    end


    headers= ['index', 'dist', 'name', 'type', 'hide' ]
    recs = []

    tiers.each_with_index do |tier,n|
      tier.each_with_index do |dist,m|

        sleep( 0.5 )
        res = traitDetails( n, m )
        pp res
        rec = ["#{n}/#{m}",
               dist.to_s,
               res[0].to_s,
               res[1].to_s,
               res[2].to_s ]
        recs << rec
      end
    end

    buf = String.new('')
    buf << headers.join( ', ')
    buf << "\n"
    recs.each do |rec|
      buf << rec.join( ', ')
      buf << "\n"
    end

    write_text( "#{outdir}//layers.csv", buf )
  end



private
  def rpc   ## get rpc client
    Ethlite.config.rpc    ## use "global" default
  end
end   ## TokenContract



