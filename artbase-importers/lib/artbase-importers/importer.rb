
module Artbase

  class Importer    ## use to import metadata into database

    def self.read( path )
      code = read_text( path )
      parse( code )
    end

    def self.parse( code )
      importer = new
      importer.instance_eval( code )
      importer
    end


    def slugify( str )
      str = str.strip.downcase
      str = str.gsub( /[ ]/, '_' )
      str
    end



    ############
    #   defaults ("built-ins") method for to_metadata, etc.

    def to_metadata( attributes )
      h = {}
      attributes.each do |key,value|
        slug = slugify( key )
        h[ slug ] = value
      end
      h
    end
  end  # class Importer

end   # module Artbase