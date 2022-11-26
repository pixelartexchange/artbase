
module Artbase
class Base     ## "abstract" Base collection - check -use a different name - why? why not?

  def import( importer )

    each_meta do |meta, id|
      puts "==> #{id}"
      pp meta.attributes
      puts
      h = importer.to_metadata( meta.attributes )
      ## auto-add id  (as intenger) - why? why not?
      h[ 'id' ] = id


      img = Image.read( "./#{@slug}/#{@width}x#{@height}/#{id}.png" )

      image = "data:image/png;base64, "
      image += Base64.strict_encode64( img.to_blob )

      puts "image:"
      puts image

      rec = Database::Metadata.new( h )
      rec.image = image

      ## check for custom callback hooks
      if importer.respond_to?( :before_save )
        importer.before_save( rec )
      end

      rec.save!
    end
  end  # method import

end  # class Base
end  # module Artbase