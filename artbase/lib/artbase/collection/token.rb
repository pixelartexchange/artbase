
class TokenCollection

  attr_reader :slug, :count

  def initialize( slug, count,
                  token_base:,
                  image_base: nil,
                  image_base_id_format: nil,
                  format:,
                  source:,
                  top_x: 0,
                  top_y: 0,
                  center_x: true,
                  center_y: true,
                  excludes: []  )   # check: rename count to items or such - why? why not?
    @slug = slug
    @count = count
    @token_base = token_base
    @image_base = image_base
    @image_base_id_format = image_base_id_format

    @width, @height = _parse_dimension( format )
    @source_width, @source_height = _parse_dimension( source )

    @top_x = top_x    ## more (down)sampling / pixelate options
    @top_y = top_y
    @center_x = center_x
    @center_y = center_y

    @excludes = excludes
  end


  ## e.g. convert dimension (width x height) "24x24" or "24 x 24" to  [24,24]
  def _parse_dimension( str )
    str.split( /x/i ).map { |str| str.strip.to_i }
  end



  def pixelate( range=(0...@count), force: false,
                                     debug: false,
                                     zoom: nil )


    range.each do |id|

      if @excludes.include?( id )
        puts "  skipping #{id}; listed in excludes #{@excludes.inspect}"
        next
      end

      outpath = "./#{@slug}/#{@width}x#{@height}/#{id}.png"
      if !force && File.exist?( outpath )
        next   ## note: skip if file already exists
      end

      center_x =  if @center_x.is_a?( Proc ) then @center_x.call( id ); else @center_x; end
      center_y =  if @center_y.is_a?( Proc ) then @center_y.call( id ); else @center_y; end

      steps_x = Image.calc_sample_steps( @source_width-@top_x, @width,   center: center_x )
      steps_y = Image.calc_sample_steps( @source_height-@top_y, @height, center: center_y )


      puts "==> #{id}  - reading / decoding #{id} ..."
      start = Time.now

      img = Image.read( "./#{@slug}/token-i/#{id}.png" )

      stop = Time.now
      diff = stop - start

      puts "  in #{diff} sec(s)\n"

      if img.width == @source_width && img.height == @source_height
        pix = if debug
                img.pixelate_debug( steps_x, steps_y,
                                    top_x: @top_x,
                                    top_y: @top_y )
              else
                img.pixelate( steps_x, steps_y,
                              top_x: @top_x,
                              top_y: @top_y )
              end
        ## todo/check: keep usingu slug e.g. 0001.png or "plain" 1.png - why? why not?
        ## slug = "%04d" % id
        pix.save( outpath )

        if zoom
          outpath = "./#{@slug}/#{@width}x#{@height}/#{id}@#{zoom}x.png"
          pix.zoom( zoom ).save( outpath )
        end
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


      image_url =  if @image_base
                      if @image_base_id_format
                        @image_base.sub( '{id}', @image_base_id_format % offset )
                      else
                        @image_base.sub( '{id}', offset.to_s )
                      end
                   else
                     txt = File.open( "./#{@slug}/token/#{offset}.json", 'r:utf-8') { |f| f.read }
                      data = JSON.parse( txt )

                      meta_name  = data['name']
                      meta_image = data['image']

                      puts "==> #{offset} - #{@slug}..."
                      puts "   name: #{meta_name}"
                      puts "   image: #{meta_image}"
                      meta_image
                   end

      ## quick ipfs (interplanetary file system) hack - make more reusabele!!!
      if image_url.start_with?( 'https://ipfs.io/ipfs/' )
        image_url = image_url.sub( 'https://ipfs.io/ipfs/', 'ipfs://' )
      end

      if image_url.start_with?( 'ipfs://' )
        # use/replace with public gateway
        image_url = image_url.sub( 'ipfs://', 'https://ipfs.io/ipfs/' )
        # image_url = image_url.sub( 'ipfs://', 'https://cloudflare-ipfs.com/ipfs/' )
      end

      ## note: will auto-add format file extension (e.g. .png, .jpg)
      ##        depending on http content type!!!!!
      start_copy = Time.now
      copy_image( image_url, "./#{@slug}/token-i/#{offset}" )

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
