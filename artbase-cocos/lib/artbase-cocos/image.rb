######################
#  pixelart image extensions
#    move upstream!!!!!


module Pixelart
class ImageComposite
  def add_glob( glob )
    files = Dir.glob( glob )
    puts "#{files.size} file(s) found matching >#{glob}<"


    files = files.sort
    ## puts files.inspect

    files.each_with_index do |file,i|
      puts "==> [#{i+1}/#{files.size}] - #{file}"
      img = Image.read( file )

      self << img    ## todo/check: use add alias - why? why not?
    end
  end
end   # class ImageComposite
end   # module Pixelart






