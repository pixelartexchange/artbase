
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
    ## note: name might be an integer number e.g. 0/1/2 etc.
    ##      e.g. see crypto pudgy punks and others?
    ##    always auto-convert to string
    @name ||= _normalize( @data['name'].to_s )
  end


  def description
    @description ||= _normalize( @data['description'] )
  end

  ## note: auto-convert "" (empty string) to nil
  def image()          _blank( @data['image'] ); end
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






  def self.read( path )
    puts "==> reading collection config >#{path}<..."
    config = read_yaml( path )

    new(
        config['slug'],
        config['count'],
        token_base: config['token_base'],
        image_base: config['image_base'],
        format: config['format'],
        source: config['source'],
        offset: config['offset'] || 0
      )
  end  # method self.read




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


    ## note: allow multiple source formats / dimensions
    ### e.g. convert   512x512 into  [ [512,512] ]
    ##
    source = [source]  unless source.is_a?( Array )
    @sources = source.map { |dimension| _parse_dimension( dimension ) }

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


  def _range( offset: 0 )    ## return "default" range  - make "private" helper public - why? why not?
     ## note: range uses three dots (...) exclusive (NOT inclusive) range
     ##  e.g. 0...100 => [0,..,99]
     ##       1...101 => [1,..,100]
     ##
     ##  note: allow offset argument
     ##           (to start with different offset - note: in addition to builtin 0/1 offset)

     (0+@offset+offset...@count+@offset)
  end



def each_image( range=_range,
                exclude: true,      &blk )
  range.each do |id|
    ####
    # filter out/skip
    # if exclude && @excludes.include?( id )
    #  puts "  skipping / exclude #{id}..."
    #  next
    # end

    puts "==> #{id}"
    img = Image.read( "./#{@slug}/#{@width}x#{@height}/#{id}.png" )
    blk.call( img, id )
  end
end


def each_meta( range=_range,
               exclude: true,      &blk )
  range.each do |id|  ## check: change/rename id to index - why? why not?
    meta = Meta.read( "./#{@slug}/token/#{id}.json" )

    ####
    # filter out/skip
    # if exclude && @excludes.include?( meta.name )
    #  puts "  skipping / exclude #{id} >#{meta.name}<..."
    #  next
    # end

    blk.call( meta, id )
  end
end





  def pixelate( range=_range, exclude: true,
                              force: false,
                              debug: false,
                              zoom: nil,
                              faster: false )

    range.each do |id|

      if exclude && @excludes.include?( id )
        puts "  skipping #{id}; listed in excludes #{@excludes.inspect}"
        next
      end

      outpath = "./#{@slug}/#{@width}x#{@height}/#{id}.png"
      if !force && File.exist?( outpath )
        next   ## note: skip if file already exists
      end

      center_x =  if @center_x.is_a?( Proc ) then @center_x.call( id ); else @center_x; end
      center_y =  if @center_y.is_a?( Proc ) then @center_y.call( id ); else @center_y; end



      puts "==> #{id}  - reading / decoding #{id} ..."


    if faster
      ## note: faster for now only supports
      ##        single /one source format
      ##         always will use first source format from array for now
      cmd = "./pixelator "
      cmd << "./#{@slug}/token-i/#{id}.png"
      cmd << " " + @sources[0][0].to_s
      cmd << " " + @sources[0][1].to_s
      cmd << " " + outpath
      cmd << " " + @width.to_s
      cmd << " " + @height.to_s
      puts "==> #{cmd}..."
      ret = system( cmd )
      if ret
        puts "OK"
      else
        puts "!! FAIL"
        if ret.nil?
          puts "  command not found"
        else
          puts "  exit code: #{$?}"
        end
      end
    else
      start = Time.now

      img = Image.read( "./#{@slug}/token-i/#{id}.png" )

      stop = Time.now
      diff = stop - start

      puts "  in #{diff} sec(s)\n"


      source = nil
      @sources.each do |source_width, source_height|
        if img.width == source_width && img.height == source_height
            source = [source_width, source_height]
            break
        end
      end


      if source
          source_width  = source[0]
          source_height = source[1]

          steps_x = Image.calc_sample_steps( source_width-@top_x, @width,   center: center_x )
          steps_y = Image.calc_sample_steps( source_height-@top_y, @height, center: center_y )

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
        puts "!! ERROR - unknown/unsupported dimension - #{img.width}x#{img.height}; sorry - tried:"
        pp @sources
        exit 1
      end
    end
    end
  end



  def meta_url( id: )
    src = @token_base.gsub( '{id}', id.to_s )

    ## quick ipfs (interplanetary file system) hack - make more reusabele!!!
    src = handle_ipfs( src )
    src
  end
  alias_method :token_url, :meta_url


  def image_url( id:,
                 direct: @image_base ? true : false  )
    src =  if direct && @image_base
              ###
              ## todo/fix:
              ##   change image_base_id_format
              ##    to image_base proc with para id and call proc!!!!
              if @image_base_id_format
                @image_base.gsub( '{id}', @image_base_id_format % id )
              else
                @image_base.gsub( '{id}', id.to_s )
              end
           else
              ## todo/check - change/rename data to meta - why? why not?
              data = Meta.read( "./#{@slug}/token/#{id}.json" )

              meta_name  = data.name
              meta_image = data.image

              puts "==> #{id} - #{@slug}..."
              puts "   name: #{meta_name}"
              puts "   image: #{meta_image}"
              meta_image
          end
    src

    ## quick ipfs (interplanetary file system) hack - make more reusabele!!!
    src = handle_ipfs( src )
    src
 end



  def download_meta( range=_range, force: false )
    start = Time.now
    delay_in_s = 0.3

    range.each do |id|
      outpath = "./#{@slug}/token/#{id}.json"
      if !force && File.exist?( outpath )
        next   ## note: skip if file already exists
      end

      dirname = File.dirname( outpath )
      FileUtils.mkdir_p( dirname )  unless Dir.exist?( dirname )

      puts "==> #{id} - #{@slug}..."

      token_src = meta_url( id: id )
      copy_json( token_src, outpath )

      stop = Time.now
      diff = stop - start
      puts "    download token metadata in #{diff} sec(s)"

      mins = diff / 60  ## todo - use floor or such?
      secs = diff % 60
      puts "up #{mins} mins #{secs} secs (total #{diff} secs)"

      puts "sleeping #{delay_in_s}s..."
      sleep( delay_in_s )
    end
  end


  ## note: default to direct true if image_base present/availabe
  ##                    otherwise to false
  ##   todo/check: change/rename force para to overwrite - why? why not?
  def download_images( range=_range, force: false,
                                           direct: @image_base ? true : false )
    start = Time.now
    delay_in_s = 0.3

    range.each do |id|

      ## note: skip if (downloaded) file already exists
      skip = false
      if !force
        ['png', 'gif', 'jgp', 'svg'].each do |format|
          if File.exist?( "./#{@slug}/token-i/#{id}.#{format}" )
            skip = true
            break
          end
        end
      end
      next if skip

      image_src = image_url( id: id, direct: direct )

      ## note: will auto-add format file extension (e.g. .png, .jpg)
      ##        depending on http content type!!!!!
      start_copy = Time.now
      copy_image( image_src, "./#{@slug}/token-i/#{id}" )

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
