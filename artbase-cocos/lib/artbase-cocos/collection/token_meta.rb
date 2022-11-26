
class TokenCollection

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

end # class TokenCollection