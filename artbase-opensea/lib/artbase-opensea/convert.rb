
module OpenSea


def self.slugify( str )
  str  # to be done
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



##
#  todo/fix:
#
#  - add token_id if present
#  - add id as opensea_id  !!!!!!!


def self.convert( collection,
                  meta_slugify: nil,
                  excludes: [] )

  files = Dir.glob( "./#{collection}/opensea/*.json" )
  pp files

  puts "  #{files.size }file(s)"

  num = 0
  files.each_with_index do |path,i|

    puts "===> reading batch #{i}/#{files.size} - #{path}..."
meta = Meta.read( path )
meta.each do |asset|
   data = {}
   data['name']        = asset.name
   data['description'] = asset.description


   token_id = asset.token_id
   ## note: if not meta(data) slugify regex present, use a counter (starting at 0)
   slug = if meta_slugify
             do_meta_slugify( meta_slugify, asset.name )
          elsif token_id && !token_id.empty?
             ## quick hack
             ##   skip if excludes
             next  if excludes.include?( token_id.to_i(10) )
             token_id
          else
            ##
            puts "!! ERROR: no token_id found and no meta_slugify defined; cannot get id; sorry"
            exit 1
             num.to_s
          end



   if asset.image_url.nil?
    puts "!! ERROR - no image_url found in >#{path}<; sorry"
    pp data
    exit 1
   end

   data['image']       = asset.image_url

   traits = []
   asset.traits.each do |trait|
      traits << { 'trait_type' => trait[0],
                  'value'      => trait[1] }
   end
   data['attributes'] = traits



   puts "#{slug} - #{asset.name}"
   pp asset.traits
   puts

   outpath = "./#{collection}/token/#{slug}.json"
   File.open( outpath, "w:utf-8" ) do |f|
      f.write( JSON.pretty_generate( data ) )
   end

   num += 1
  end
end
end

end # module OpenSea
