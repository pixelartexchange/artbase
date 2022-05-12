module Pixelart

  class Image


def self.calc_sample_steps( width, new_width, center: true )
  ## todo/fix: assert new_width is smaller than width
  puts
  puts "==> from: #{width}px  to: #{new_width}px"

  indexes = []

  base_step = width / new_width    ## pixels per pixel

  err_step = (width % new_width) * 2   ## multiply by 2
  denominator = new_width * 2   # denominator (in de - nenner  e.g. 1/nenner 4/nenner)

  overflow = err_step*new_width/denominator  ## todo/check - assert that div is always WITHOUT remainder!!!!!

  puts
  puts "base_step (pixels per pixel):"
  puts "  #{base_step}     -  #{base_step} * #{new_width}px = #{base_step*new_width}px"
  puts "err_step  (in 1/#{width}*2):"
  puts "  #{err_step} / #{denominator}      - #{err_step*new_width} / #{denominator} = +#{err_step*new_width/denominator}px overflow"
  puts

  # initial pixel offset
  index = 0
  err   = err_step/2   ##  note: start off with +err_step/2 to add overflow pixel in the "middle"


  index +=  if center.is_a?( Integer )
              center
            elsif center
              base_step/2
            else
               0   #  use 0px offset
            end


  new_width.times do |i|
    if err >= denominator ## overflow
      puts "    -- overflow #{err}/#{denominator} - add +1 pixel offset to #{i}"
      index += 1
      err   -= denominator
    end

    puts "  #{i} => #{index}  -- #{err} / #{denominator}"


    indexes[i] = index

    index += base_step
    err   += err_step
  end

  indexes
end


    ## todo/check: rename to sample to resample or downsample - why? why not?
    def sample( steps_x, steps_y=steps_x,
                top_x: 0, top_y: 0 )
      width   = steps_x.size
      height  = steps_y.size
      puts "    downsampling from #{self.width}x#{self.height} to #{width}x#{height}..."

      dest = Image.new( width, height )

      steps_x.each_with_index do |step_x, x|
        steps_y.each_with_index do |step_y, y|
           pixel = self[top_x+step_x, top_y+step_y]

           dest[x,y] =  pixel
        end
      end

      dest
    end
    alias_method :pixelate, :sample



def sample_debug( steps_x, steps_y=steps_x,
              color:  Color.parse( '#ffff00' ),
              top_x: 0,
              top_y: 0)  ## add a yellow pixel

   ## todo/fix:  get a clone of the image (DO NOT modify in place)

    img = self

  steps_x.each_with_index do |step_x, x|
    steps_y.each_with_index do |step_y, y|
        base_x = top_x+step_x
        base_y = top_y+step_y

        img[base_x,base_y] = color

       ## add more colors
       img[base_x+1,base_y] = color
       img[base_x+2,base_y] = color

       img[base_x,base_y+1] = color
       img[base_x,base_y+2] = color
      end
  end

  self
end
alias_method :pixelate_debug, :sample_debug



###
#   add common
#     pixel(ate) steps/offsets (for re/down/sampling)
DOwNSAMPLING_STEPS = {
  '24x24' => {
    '269x269' => Image.calc_sample_steps( 269, 24 ),  # width (269px), new_width (24px)
    '512x512' => Image.calc_sample_steps( 512, 24 ),  # width (512px), new_width (24px)
  },
  '32x32' => {
    '320x320' => Image.calc_sample_steps( 320, 32 ),
    '512x512' => Image.calc_sample_steps( 512, 32 ),
  },
  '35x35' => {
    '512x512' => Image.calc_sample_steps( 512, 35 ),
  },
  '60x60' => {
    '512x512' => Image.calc_sample_steps( 512, 60 ),
  },
  '80x80' => {
    '512x512' => Image.calc_sample_steps( 512, 80 ),
  },
}

  end  # class Image
end   # module Pixelart



