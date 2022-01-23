######################
#  pixelart image extensions
#    move upstream!!!!!


module Pixelart

class Image
  def sample( *args, **kwargs )
    ## note: for now always assume square image (e.g. 24x24, 32x32 and such)

    offsets = if kwargs[:from] && kwargs[:to]
                PIXEL_OFFSETS[ kwargs[:to] ][ kwargs[ :from ]]
              else
                args[0]   ## assume "custom" hash of offsets
              end

    width = height = offsets.size

    puts "     #{self.width}x#{self.height} => #{width}x#{height}"


    dest = Image.new( width, height )

    offsets.each do |offset_x, x|
      offsets.each do |offset_y, y|
         pixel = self[offset_x,offset_y]

         dest[x,y] =  pixel
      end
    end

    dest
  end
  alias_method :pixelate, :sample
end  # class Image



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


###
#   add common
#     pixel(ate) offsets (for sampling)
PIXEL_OFFSETS = {}

module Pixelart
  class Image
    PIXEL_OFFSETS = ::PIXEL_OFFSETS
  end
end   # module Pixelart


require_relative 'image/24x24'
require_relative 'image/32x32'
require_relative 'image/60x60'
require_relative 'image/80x80'
