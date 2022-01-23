

class Collection    ## todo/check - change to OpenseaCollection or such - why? why not?

attr_reader :slug, :count

# check: rename count to items or such - why? why not?
#        default format to '24x24' - why? why not?
def initialize( slug, count,
                meta_slugify: nil,
                image_pixelate: nil,
                patch: nil,
                exclude: [],
                format:,
                source:  )
  @slug = slug
  @count = count

  @meta_slugify   = meta_slugify
  @image_pixelate = image_pixelate

  @patch  = patch

  @exclude = exclude

  @width, @height = _parse_dimension( format )


  ## note: allow multiple source formats / dimensions
  ### e.g. convert   512x512 into  [ [512,512] ]
  ##
  source = [source]  unless source.is_a?( Array )
  @sources = source.map { |dimension| _parse_dimension( dimension ) }
end

## e.g. convert dimension (width x height) "24x24" or "24 x 24" to  [24,24]
def _parse_dimension( str )
   str.split( /x/i ).map { |str| str.strip.to_i }
end


def _image_pixelate( img )
  if @image_pixelate
    @image_pixelate.call( img )
  else
    @sources.each do |source_width, source_height|
      if img.width == source_width && img.height == source_height
        return img.pixelate( from: "#{source_width}x#{source_height}",
                             to: "#{@width}x#{@height}" )
      end
    end

    puts "!! ERROR - unknown image dimension #{img.width}x#{img.height}; sorry"
    puts "           supported source dimensions include: #{@sources.inspect}"
    exit 1
  end
end




def download_meta( range=(0...@count) )
  self.class.download_meta( range, @slug )
end

def download_images( range=(0...@count) )
  self.class.download_images( range, @slug )
end

def download( range=(0...@count) )
  download_meta( range )
  download_images( range )
end





def make_composite
  ### use well-known / pre-defined (default) grids (cols x rows) for now - why? why not?

  composite_count = @count - @exclude.size
  cols, rows = if      composite_count == 100    then   [10,  10]
               elsif   composite_count == 500    then   [25,  20]
               elsif   composite_count == 10000  then   [100, 100]
               else
                   raise ArgumentError, "sorry - unknown composite count #{composite_count}/#{@count} for now"
               end

  composite = ImageComposite.new( cols, rows,
                                  width:  @width,
                                  height: @height )

  ## note: for now as a convention (auto-)add all .pngs
  ##         in saved in (default) pixelate output dir
  composite.add_glob( "./#{@slug}/ii/*.png" )

  composite.save( "./#{@slug}/tmp/#{@slug}-#{@width}x#{@height}.png" )
end



def _meta_slugify_match( regex, meta, index )
  if m=regex.match( meta.name )
    captures = m.named_captures   ## get named captures in match data as hash (keys as strings)
    # e.g.
    #=> {"num"=>"3"}
    #=> {"num"=>"498", "name"=>"Doge"}
    pp captures

    num  = captures['num']  ? captures['num'].to_i( 10 ) : nil   ## note: add base 10 (e.g. 015=>15)
    name = captures['name'] ? captures['name'].strip     : nil

    slug = ''
    if num
      slug << "%06d" % num    ## todo/check: always fill/zero-pad with six 000000's - why? why not?
    end

    if name
      slug << "-"   if num   ## add separator
      slug << slugify( name )
    end
    slug
  else
     nil  ## note: return nil if no match / slug
  end
end

def _do_meta_slugify( meta_slugify, meta, index )
  if meta_slugify.is_a?( Regexp )
    _meta_slugify_match( meta_slugify, meta, index )
  elsif meta_slugify.is_a?( Proc )
    meta_slugify.call( meta, index )
  else
    raise ArgumentError, "meta_slugify - unsupported type: #{meta_slugify.class.name}"
  end
end


def _meta_slugify( meta, index )
  slug = nil

  if @meta_slugify.is_a?( Array )
      @meta_slugify.each do |meta_slugify|
         slug = _do_meta_slugify( meta_slugify, meta, index )
         return slug   if slug     ## note: short-circuit on first match
                                   ##   use break instead of return - why? why not?
      end
   else  ## assume object e.g. Regexp, Proc, etc.
     slug = _do_meta_slugify( @meta_slugify, meta, index )
   end

   ## do nothing
   if slug.nil?
      puts "!! ERROR - cannot find id in >#{meta.name}<:"
      pp meta
      exit 1
   end

   slug
end



def each_meta( range=(0...@count),
               exclude: true,      &blk )
  range.each do |id|    ## todo/fix: change id to index
    meta = OpenSea::Meta.read( "./#{@slug}/meta/#{id}.json" )

    ####
    # filter out/skip
    if exclude && @exclude.include?( meta.name )
      puts "  skipping / exclude #{id} >#{meta.name}<..."
      next
    end

    blk.call( meta, id )
  end
end


def _normalize_trait_type( trait_type )
  if @patch && @patch[:trait_types]
    @patch[:trait_types][ trait_type ] || trait_type
  else
     trait_type
  end
end

def _normalize_trait_value( trait_value )
  if @patch && @patch[:trait_values]
    @patch[:trait_values][ trait_value ] || trait_value
  else
    trait_value
  end
end



def export_attributes
  ## step 1: get counters
  stats = calc_attribute_counters

  total    = stats[:total]
  counter  = stats[:traits]

  puts
  puts "attribute usage / counts:"
  pp total
  puts

  puts "#{counter.size} attribute(s):"
  counter.each do |trait_name, trait_rec|
     puts "  #{trait_name}  #{trait_rec[:count]}  (#{trait_rec[:by_type].size} uniques)"
  end

  recs = []


  ## step 2: get tabular data
  each_meta do |meta, id|   ## todo/fix: change id to index

    traits = meta.traits
    # print "#{traits.size} - "
    # pp  traits

    print "#{id}.."   if id % 100 == 0  ## print progress report

    ## setup empty hash table (with all attributes)
    rec = {
       'Slug'   => _meta_slugify( meta, id ),
       'Name' => meta.name,
    }
    ## add all attributes
    counter.keys.reduce( rec ) { |h,value| h[value] = []; h }
    ## pp rec

    ## note: use an array (to allow multiple values for attributes)
    traits.each do |trait_type, trait_value|
       trait_type  = _normalize_trait_type( trait_type )
       trait_value = _normalize_trait_value( trait_value )

       values = rec[ trait_type ]
       values << trait_value
    end
    recs << rec
  end
  print "\n"

  ## pp recs

  ## flatten recs
  data = []
  recs.each do |rec|
     row = rec.values.map do |value|
                  if value.is_a?( Array )
                     value.join( ' / ' )
                  else
                     value
                  end
             end
     data << row
  end


  ## sort by slug
  data = data.sort {|l,r| l[0] <=> r[0] }
  pp data

  ### save dataset
  ##  note: change first colum Slug to ID - only used for "internal" sort etc.
  headers = ['ID', 'Name'] + counter.keys    ## add header row

  path = "./#{@slug}/tmp/#{@slug}.csv"
  dirname = File.dirname( path )
  FileUtils.mkdir_p( dirname )  unless Dir.exist?( dirname )

  File.open( path, 'w:utf-8' ) do |f|
    f.write(  headers.join( ', ' ))
    f.write( "\n" )
    ## note: replace ID with our own internal running (zero-based) counter
    data.each_with_index do |row,i|
      f.write( ([i]+row[1..-1]).join( ', '))
      f.write( "\n" )
    end
  end
end


def calc_attribute_counters  ## todo/check: use a different name _counts/_stats etc - why? why not?

  attributes_by_count = { count: 0,
                          by_count: Hash.new(0)
                        }
  counter = {}


  each_meta do |meta, id|   ## todo/fix: change id to index
    traits = meta.traits
    # print "#{traits.size} - "
    # pp  traits

    print "#{id}.."   if id % 100 == 0  ## print progress report

    attributes_by_count[ :count ] +=1
    attributes_by_count[ :by_count ][ traits.size ] += 1

    traits.each do |trait_type, trait_value|
        trait_type  = _normalize_trait_type( trait_type )
        trait_value = _normalize_trait_value( trait_value )


        rec = counter[ trait_type ] ||= { count: 0,
                                          by_type: Hash.new(0)
                                        }
        rec[ :count ] +=1
        rec[ :by_type ][ trait_value ] += 1
    end
  end

  print "\n"
  puts

  ## return all-in-one hash
  {
    total:  attributes_by_count,
    traits: counter,
  }
end


def dump_attributes
  stats = calc_attribute_counters

  total    = stats[:total]
  counter  = stats[:traits]

  puts
  puts "attribute usage / counts:"
  pp total
  puts

  puts "#{counter.size} attribute(s):"
  counter.each do |trait_name, trait_rec|
     puts "  #{trait_name}  #{trait_rec[:count]}  (#{trait_rec[:by_type].size} uniques)"
  end

  puts
  pp counter
end



def pixelate( range=(0...@count) )

  meta_slugs = Hash.new( 0 )   ## deduplicate (auto-add counter if duplicate)

  ### todo/fix: must read slugs starting at 0
  ###               to work for deduplicate!!!!!!


  range.each do |id|
    meta = OpenSea::Meta.read( "./#{@slug}/meta/#{id}.json" )

    ####
    # filter out/skip
    if @exclude.include?( meta.name )
       puts "  skipping / exclude #{id} >#{meta.name}<..."
       next
    end

    puts meta.name


    meta_slug = _meta_slugify( meta, id )
    count = meta_slugs[ meta_slug ] += 1

    meta_slug = "#{meta_slug}_(#{count})"  if count > 1


    img = Image.read( "./#{@slug}/i/#{id}.png" )

    pix = _image_pixelate( img )

    path = "./#{@slug}/ii/#{meta_slug}.png"
    puts "   saving to >#{path}<..."
    pix.save( path )
  end
end



################################
# private (static) helpers
#

def self.download_images( range, collection,
                            original: false )
  start = Time.now
  delay_in_s = 0.3

  range.each do |offset|
    meta = OpenSea::Meta.read( "./#{collection}/meta/#{offset}.json" )

    puts "==> #{offset}.json  -  #{meta.name}"

    image_src =  if original
                   meta.image_original_url
                 else
                   meta.image_url
                 end

    puts "    >#{image_src}<"
    if image_src.nil?
       puts "!! ERROR - no image url found (use original: #{original}):"
       pp meta
       exit 1
    end

    ## note: use a different directory to avoid size confusion!!!
    img_slug =  if original
                   'i_org'
                else
                   'i'
                end

    ## note: will auto-add format file extension (e.g. .png, .jpg)
    ##        depending on http content type!!!!!
    copy_image( image_src, "./#{collection}/#{img_slug}/#{offset}" )

    stop = Time.now
    diff = stop - start

    mins = diff / 60  ## todo - use floor or such?
    secs = diff % 60
    puts "up #{mins} mins #{secs} secs (total #{diff} secs)"

    puts "sleeping #{delay_in_s}s..."
    sleep( delay_in_s )
  end
end


def self.download_meta( range, collection )
  start = Time.now
  delay_in_s = 0.3

  range.each do |offset|

    dest = "./#{collection}/meta/#{offset}.json"
    meta = nil

    puts "==> #{offset} / #{collection} (#{dest})..."

    data = OpenSea.assets( collection: collection,
                           offset:     offset )
    meta = OpenSea::Meta.new( data )
    puts "  name:      >#{meta.name}<"
    puts "  image_url: >#{meta.image_url}<"


    File.open( dest, "w:utf-8" ) do |f|
      f.write( JSON.pretty_generate( data ) )
    end


    stop = Time.now
    diff = stop - start

    mins = diff / 60  ## todo - use floor or such?
    secs = diff % 60
    puts "up #{mins} mins #{secs} secs (total #{diff} secs)"

    puts "  sleeping #{delay_in_s}s..."
    sleep( delay_in_s )
  end
end


end # class Collection
