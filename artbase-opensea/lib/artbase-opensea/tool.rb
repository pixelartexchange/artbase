


module OpenSea
class Tool

  def self.main( args=ARGV )
    puts "==> welcome to opensea tool with args:"
    pp args

    options = { }
    parser = OptionParser.new do |opts|

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

    if args.size < 2
      puts "!! ERROR - no command found - use <collection> <command>..."
      puts ""
      exit
    end

    name       = args[0]   ## todo/check - use collection_name/slug or such?
    command    = args[1]

=begin
    path = if File.exist?( "./#{name}/config.rb" )
               "./#{name}/config.rb"
           else
               "./#{name}/collection.rb"
           end
    puts "==> reading collection config >#{path}<..."

    ## note: assume for now global const COLLECTION gets set/defined!!!
    ##   use/change to a script/dsl loader/eval later!!!
    load( path )

    ## pp COLLECTION

    ## configure collection  (note: requires self)
    self.collection = COLLECTION
=end

    if ['p', 'page'].include?( command )
      download_pages( name )
    elsif ['pp', 'print', 'pretty'].include?( command )
      pp_pages( name ) ## pretty print (meta data) pages
    elsif ['i', 'img', 'image', 'images'].include?( command )
      download_images( name )
    elsif ['conv', 'convert'].include?( command )
      do_convert_images( name )
=begin
    elsif ['m', 'meta'].include?( command )
      download_meta( offset: options[ :offset] )
    elsif ['i', 'img', 'image', 'images'].include?( command )
      download_images( offset: options[ :offset] )
    elsif ['a', 'attr', 'attributes'].include?( command )
      dump_attributes
    elsif ['x', 'exp', 'export'].include?( command )
      export_attributes
    elsif ['c', 'composite'].include?( command )
      make_composite
    elsif ['strip'].include?( command )
      make_strip
=end
    elsif ['t', 'test'].include?( command )
       puts "  testing, testing, testing"
    else
      puts "!! ERROR - unknown command >#{command}<, sorry"
    end

    puts "bye"
  end

  def self.download_pages( collection )
    puts "==> download meta data pages >#{collection}<"

    Puppeteer.download_assets( collection )
  end


  def self.do_convert_images( collection )
    puts "==> convert images to .png (from .gif/.jpg) >#{collection}<"

    convert_images( collection, from: 'jpg', to: 'png', dir: 'cache/i' )
    convert_images( collection, from: 'gif', to: 'png', dir: 'cache/i' )
  end


  def self.pp_pages( collection )
    puts "==> pretty print (pp) meta data pages >#{collection}<"

    ## todo/check: sort by number (if two digits (e.g. 1/../9/10/11)) - why? why not?
    files = Dir.glob( "./#{collection}/opensea/*.json" )
    pp files

    puts "  #{files.size } file(s)"

    count = 0
    files.each_with_index do |path,i|
      puts "===> reading batch #{i}/#{files.size} - #{path}..."

      meta = Meta.read( path )
      puts "   #{meta.size} record(s):"
      count += meta.size

      meta.each do |asset|
        token_id = asset.token_id

        puts
        puts "  name >#{asset.name}<, description: >#{asset.description}<"
        puts "     token id >#{asset.token_id}<"

       ## note: if not meta(data) slugify regex present, use a counter (starting at 0)
       slug = if defined?( META_SLUGIFY )
                do_meta_slugify( META_SLUGIFY, asset.name )
              elsif token_id && !token_id.empty?
                token_id
              else
                puts "!! ERROR: no token_id found and no meta_slugify defined; cannot get id; sorry"
                exit 1
              end

        puts "   slug: >#{slug}<"

        if asset.image_url.nil?
          puts "!! ERROR - no image_url found; sorry"
          pp data
          exit 1
         end
        puts "   image_url: >#{asset.image_url}<"
      end
    end
    puts "  #{count} record(s)"
  end


  def self.download_images( collection )
    puts "==> download images >#{collection}<"
    ## todo/check: sort by number (if two digits (e.g. 1/../9/10/11)) - why? why not?
    files = Dir.glob( "./#{collection}/opensea/*.json" )
    pp files

    puts "  #{files.size } file(s)"

    files.each_with_index do |path,i|
      puts "===> reading batch #{i}/#{files.size} - #{path}..."

      meta = Meta.read( path )
      puts "   #{meta.size} record(s):"


      meta.each do |asset|
        token_id = asset.token_id

        puts
        puts "  name >#{asset.name}<, description: >#{asset.description}<"
        puts "     token id >#{asset.token_id}<"

       ## note: if not meta(data) slugify regex present, use a counter (starting at 0)
       slug = if defined?( META_SLUGIFY )
                do_meta_slugify( META_SLUGIFY, asset.name )
              elsif token_id && !token_id.empty?
                token_id
              else
                puts "!! ERROR: no token_id found and no meta_slugify defined; cannot get id; sorry"
                exit 1
              end

        puts "   slug: >#{slug}<"

        if asset.image_url.nil?
          puts "!! ERROR - no image_url found; sorry"
          pp data
          exit 1
         end
        puts "   image_url: >#{asset.image_url}<"

        download_image( asset.image_url, slug,
                          outdir: "./#{collection}/cache/i" )
      end
    end
  end



  def self.slugify( str )
    #  e.g #0 Mark Shaw   =>  0_mark_shaw

    str = str.strip.downcase
    str = str.gsub( /[#]/, '' )
    str = str.gsub( /[ ]+/, ' ' ) ## unify spaces
    str = str.gsub( ' ', '_' )
    str
  end

  def self.do_meta_slugify( regex, str )
    if m=regex.match( str )
      captures = m.named_captures   ## get named captures in match data as hash (keys as strings)
      # e.g.
      #=> {"num"=>"3"}
      #=> {"num"=>"498", "name"=>"Doge"}
      # pp captures

      num  = captures['num']  ? captures['num'].to_i( 10 ) : nil   ## note: add base 10 (e.g. 015=>15)
      name = captures['name'] ? captures['name'].strip     : nil

      slug = ''
      if num
        slug << "%d" % num    ## todo/check: always fill/zero-pad with six 000000's - why? why not?
      end

      if name
        slug << "-"   if num   ## add separator
        slug << slugify( name )
      end
      slug
    else
       puts "!! ERROR:  no match for meta slugify in >#{str}<:"
       pp regex
       exit 1
    end
  end


  def self.download_image( image_url, name, outdir: )
    res = Webclient.get( image_url )

    if res.status.ok?
       content_type   = res.content_type
       content_length = res.content_length

       puts "  content_type: #{content_type}, content_length: #{content_length}"

       format = if content_type =~ %r{image/jpeg}i
                  'jpg'
                elsif content_type =~ %r{image/png}i
                  'png'
                elsif content_type =~ %r{image/gif}i
                  'gif'
                else
                  puts "!! ERROR:"
                  puts " unknown image format content type: >#{content_type}<"
                  exit 1
                end

       ## make sure path exists
       FileUtils.mkdir_p( outdir )  unless Dir.exist?( outdir )

       ## save image - using b(inary) mode
       File.open( "#{outdir}/#{name}.#{format}", 'wb' ) do |f|
         f.write( res.body )
       end
    else
       puts "!! ERROR - failed to download image; sorry - #{res.status.code} #{res.status.message}"
       exit 1
    end
  end



end # class Tool


end # module OpenSea




#  ReggaetonPunk #79 => 79
#  META_SLUGIFY = /^.+ #(?<num>[0-9]+)$/

META_SLUGIFY = /^CovidPunk (?<name>.+)$/
