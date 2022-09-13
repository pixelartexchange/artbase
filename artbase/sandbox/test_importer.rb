####
#   check if redefine/override works
#      for class instance with eval_instance for to_metadata ??


class Importer

  def slugify
      puts "  calling slugify"
  end

  def to_metadata( attributes )
    puts "hello from Importer#to_metadata:"
    slugify
    pp attributes
    h = {}
    h
  end

end  # class Importer



importer = Importer.new
importer.to_metadata( [0,0,0] )

importer.instance_eval( <<TXT )
  def to_metadata( attributes )
    h = super
    puts "hello from Importer#to_metadata (instance #{object_id}):"
    slugify
    pp attributes
    h
  end
TXT

importer.to_metadata( [1,1,1] )

importer = Importer.new
importer.to_metadata( [2,2,2] )


puts "bye"