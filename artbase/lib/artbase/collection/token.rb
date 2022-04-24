
class TokenCollection

  attr_reader :slug, :count

  def initialize( slug, count,
                  token_base:,
                  format:,
                  source:  )   # check: rename count to items or such - why? why not?
    @slug = slug
    @count = count
    @token_base = token_base


    @width, @height = _parse_dimension( format )
    @source_width, @source_height = _parse_dimension( source )
  end


  ## e.g. convert dimension (width x height) "24x24" or "24 x 24" to  [24,24]
  def _parse_dimension( str )
    str.split( /x/i ).map { |str| str.strip.to_i }
  end



  def pixelate( range=(0...@count), force: false )

    steps_x = Image.calc_sample_steps( @source_width, @width )
    steps_y = Image.calc_sample_steps( @source_height, @height )

    range.each do |id|
      outpath = "./#{@slug}/#{@width}x#{@height}/#{id}.png"
      if !force && File.exist?( outpath )
        next   ## note: skip if file already exists
      end


      puts "==> #{id}  - reading / decoding #{id} ..."
      start = Time.now

      img = Image.read( "./#{@slug}/token-i/#{id}.png" )

      stop = Time.now
      diff = stop - start

      puts "  in #{diff} sec(s)\n"

      if img.width == @source_width && img.height == @source_height
        pix = img.pixelate( steps_x, steps_y )

        ## todo/check: keep usingu slug e.g. 0001.png or "plain" 1.png - why? why not?
        ## slug = "%04d" % id
        pix.save( outpath )
      else
        puts "!! ERROR - unknown/unsupported dimension - #{img.width}x#{img.height}; sorry"
        exit 1
      end
    end
  end



  def download_meta( range=(0...@count), force: false )
    start = Time.now
    delay_in_s = 0.3

    range.each do |offset|
      outpath = "./#{@slug}/token/#{offset}.json"
      if !force && File.exist?( outpath )
        next   ## note: skip if file already exists
      end


      token_src = @token_base.sub( '{id}', offset.to_s )

      ## quick ipfs (interplanetary file system) hack - make more reusabele!!!
      if token_src.start_with?( 'ipfs://' )
       # use/replace with public gateway
       token_src = token_src.sub( 'ipfs://', 'https://ipfs.io/ipfs/' )
      end

      puts "==> #{offset} - #{@slug}..."

      copy_json( token_src, outpath )

      stop = Time.now
      diff = stop - start

      mins = diff / 60  ## todo - use floor or such?
      secs = diff % 60
      puts "up #{mins} mins #{secs} secs (total #{diff} secs)"

      puts "sleeping #{delay_in_s}s..."
      sleep( delay_in_s )
    end
  end


  def download_images( range=(0...@count), force: false )
    start = Time.now
    delay_in_s = 0.3

    range.each do |offset|
      ## note: for now assumes only .png format!!!
      ##    todo - check for more format - why? why not?
      outpath = "./#{@slug}/token-i/#{offset}.png"
      if !force && File.exist?( outpath )
        next   ## note: skip if file already exists
      end



      txt = File.open( "./#{@slug}/token/#{offset}.json", 'r:utf-8') { |f| f.read }
      data = JSON.parse( txt )

      meta_name  = data['name']
      meta_image = data['image']

      puts "==> #{offset} - #{@slug}..."
      puts "   name: #{meta_name}"
      puts "   image: #{meta_image}"

      ## quick ipfs (interplanetary file system) hack - make more reusabele!!!
      if meta_image.start_with?( 'https://ipfs.io/ipfs/' )
        meta_image = meta_image.sub( 'https://ipfs.io/ipfs/', 'ipfs://' )
      end

      if meta_image.start_with?( 'ipfs://' )
        # use/replace with public gateway
        meta_image = meta_image.sub( 'ipfs://', 'https://ipfs.io/ipfs/' )
        # meta_image = meta_image.sub( 'ipfs://', 'https://cloudflare-ipfs.com/ipfs/' )
      end

      ## note: will auto-add format file extension (e.g. .png, .jpg)
      ##        depending on http content type!!!!!
      start_copy = Time.now
      copy_image( meta_image, "./#{@slug}/token-i/#{offset}" )

      stop = Time.now

      diff = stop - start_copy
      puts "    download image in #{diff} sec(s)"

      diff = stop - start
      mins = diff / 60  ## todo - use floor or such?
      secs = diff % 60
      puts "up #{mins} mins #{secs} secs (total #{diff} secs)"

      puts "sleeping #{delay_in_s}s..."
      sleep( delay_in_s )
    end
  end




end # class TokenCollection
