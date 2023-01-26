
module ArtQ


  ## use alternate Encoding::BINARY - why? why not?
  ##   or just use .b  e.g. "GIF87".b or such !!!
  JPGSIG   = "\xFF\xD8\xFF".force_encoding( Encoding::ASCII_8BIT )
  PNGSIG   = "\x89PNG".force_encoding( Encoding::ASCII_8BIT )
  GIF87SIG = "GIF87".force_encoding( Encoding::ASCII_8BIT )
  GIF89SIG = "GIF89".force_encoding( Encoding::ASCII_8BIT )



  def self.download_layers( contract_address,
                            outdir: "./#{contract_address}" )

    puts "==> download layers for art collection contract @ >#{contract_address}<:"

    c = Contract.new( contract_address )

    ## get some metadata - why? why not?
    name         =  c.name
    symbol       =  c.symbol
    totalSupply  =  c.totalSupply

    traitDetails = []
    n=0
    loop do
      m=0
      loop do
        rec = c.traitDetails( n, m )
        break  if rec == ['','',false]   ## note: assume end-of-list if all values are zeros / defaults.

        traitDetails << [[n,m], rec ]
        m += 1
        sleep( 0.5 )
      end
      break  if m==0
      n += 1
    end


    ## todo/check: include or drop hide (of any use?) - why? why not?
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

    write_text( "#{outdir}/cache/layers.csv", buf )

    #####
    #  try to download all images
    traitDetails.each_with_index do |t,i|
      puts "  [#{i+1}/#{traitDetails.size}] downloading #{t[1][1]} >#{t[1][0]}<..."

      n,m  = t[0]
      data = c.traitData( n, m )
      ## note: return type in abi is string!!!
      ##   change to binary blob (from utf-8 encoding)!!!!
      data.force_encoding( Encoding::ASCII_8BIT )


      basename = "#{n}_#{m}"
      if data.start_with?( PNGSIG )
        puts "BINGO!! it's a png blob - #{data.size} byte(s)"
        write_blob( "#{outdir}/cache/#{basename}.png", data )
      elsif data.start_with?( GIF87SIG ) || data.start_with?( GIF89SIG )
        puts "BINGO!! it's a gif blob - #{data.size} byte(s)"
        write_blob( "#{outdir}/cache/#{basename}.gif", data )
      elsif data.start_with?( JPGSIG )
        puts "BINGO!! it's a jpg blob - #{data.size} byte(s)"
        write_blob( "#{outdir}/cache/#{basename}.jpg", data )
      elsif data.index( /<svg[^>]*?>/i )    ## add more markers to find - why? why not?
        puts "BINGO!! it's a svg (text) blob - #{data.size} byte(s)"
        ## todo/check - save text as binary blob 1:1 - why? why not?
        write_blob( "#{outdir}/cache/#{basename}.svg", data )
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
end  # module ArtQ
