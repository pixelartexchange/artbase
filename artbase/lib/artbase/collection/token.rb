
class TokenCollection   < Artbase::Base


#############
# (nested) Meta classes
#    read meta data into struct
class Meta
  def self.read( path )
    new( read_json( path ))
  end


  def initialize( data )
    @data = data
  end


  def name
    @name ||= _normalize( @data['name'] )
  end

  def description
    @description ||= _normalize( @data['description'] )
  end

  ## note: auto-convert "" (empty string) to nil
  def image()          _blank( @asset['image'] ); end
  alias_method :image_url, :image     ## add image_url alias - why? why not?


  def attributes
    @attributes ||= begin
                   traits = []
                   ## keep traits as (simple)
                   ##   ordered array of pairs for now
                   ##
                   ##  in a step two make lookup via hash table
                   ##   or such easier / "automagic"

                   @data[ 'attributes' ].each do |t|
                      trait_type  = t['trait_type'].strip
                      trait_value = t['value'].strip
                      traits << [trait_type, trait_value]
                   end

                   traits
                  end
  end
  alias_method :traits, :attributes    ## keep traits alias - why? why not?

### "private"  convenience / helper methods
    def _normalize( str )
       return if str.nil?    ## check: check for nil - why? why not?

       ## normalize string
       ##   remove leading and trailing spaces
       ##   collapse two and more spaces into one
       ##    change unicode space to ascii
       str = str.gsub( "\u{00a0}", ' ' )
       str = str.strip.gsub( /[ ]{2,}/, ' ' )
       str
    end

    def _blank( o )   ## auto-convert  "" (empty string) into nil
       if o && o.strip.empty?
         nil
       else
         o
       end
    end
end  # (nested) class Meta




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
                  excludes: [],
                  offset: 0  )   # check: rename count to items or such - why? why not?
    @slug = slug
    @count = count
    @offset = offset   ## starting by default at 0 (NOT 1 or such)

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


  def _range    ## return "default" range  - make "private" helper public - why? why not?
     ## note: range uses three dots (...) exclusive (NOT inclusive) range
     ##  e.g. 0...100 => [0,..,99]
     ##       1...101 => [1,..,100]
     (0+@offset...@count+@offset)
  end




def each_meta( range=_range,
               exclude: true,      &blk )
  range.each do |id|    ## todo/fix: change id to index
    meta = Meta.read( "./#{@slug}/token/#{id}.json" )

    ####
    # filter out/skip
    # if exclude && @exclude.include?( meta.name )
    #  puts "  skipping / exclude #{id} >#{meta.name}<..."
    #  next
    # end

    blk.call( meta, id )
  end
end





  def pixelate( range=_range, force: false,
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



  def download_meta( range=_range, force: false )
    start = Time.now
    delay_in_s = 0.3

    range.each do |offset|
      outpath = "./#{@slug}/token/#{offset}.json"
      if !force && File.exist?( outpath )
        next   ## note: skip if file already exists
      end


      token_src = @token_base.sub( '{id}', offset.to_s )

      ## quick ipfs (interplanetary file system) hack - make more reusabele!!!
      token_src = handle_ipfs( token_src )

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


  ## note: default to direct true if image_base present/availabe
  ##                    otherwise to false
  def download_images( range=_range, force: false,
                                           direct: @image_base ? true : false )
    start = Time.now
    delay_in_s = 0.3

    range.each do |offset|
      ## note: for now assumes only .png format!!!
      ##    todo - check for more format - why? why not?
      outpath = "./#{@slug}/token-i/#{offset}.png"
      if !force && File.exist?( outpath )
        next   ## note: skip if file already exists
      end


      image_url =  if direct && @image_base
                      if @image_base_id_format
                        @image_base.sub( '{id}', @image_base_id_format % offset )
                      else
                        @image_base.sub( '{id}', offset.to_s )
                      end
                   else
                      ## todo/check - change/rename data to meta - why? why not?
                      data = Meta.read( "./#{@slug}/token/#{offset}.json" )

                      meta_name  = data.name
                      meta_image = data.image

                      puts "==> #{offset} - #{@slug}..."
                      puts "   name: #{meta_name}"
                      puts "   image: #{meta_image}"
                      meta_image
                   end

      ## quick ipfs (interplanetary file system) hack - make more reusabele!!!
      image_url = handle_ipfs( image_url )


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
