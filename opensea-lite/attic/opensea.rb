module OpenSea


#############
# read meta data into struct

class Meta
  def self.read( path )
    txt  = File.open( path, 'r:utf-8' ) { |f| f.read }
    data = JSON.parse( txt )
    new( data )
  end


  def initialize( data )
    @data = data

    assets = @data['assets']
    if assets.size != 1
      puts "!! error - expected one asset per file only - got #{assets.size} - sorry"
      exit 1
    end

    @asset = assets[0]
  end

  def name
    @name ||= _normalize( @asset['name'] )
  end

  def description
    @description ||= _normalize( @asset['description'] )
  end

  ## note: auto-convert "" (empty string) to nil
  def image_original_url() _blank( @asset['image_original_url'] );  end
  def image_url()          _blank( @asset['image_url'] ); end


  def token_id() @asset['token_id']; end    ## note: keep id as string as is - why? why not?


  def traits
    @traits ||= begin
                   traits = []
                   ## keep traits as (simple)
                   ##   ordered array of pairs for now
                   ##
                   ##  in a step two make lookup via hash table
                   ##   or such easier / "automagic"

                   @asset[ 'traits' ].each do |t|
                      trait_type  = t['trait_type'].strip
                      trait_value = t['value'].strip
                      traits << [trait_type, trait_value]
                   end

                   traits
                  end
  end



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
end  # class Meta
end # module OpenSea

