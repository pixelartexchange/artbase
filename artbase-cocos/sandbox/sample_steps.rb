####
##
#   calculate (re/dowwn)sample steps / pixel offsets
#
#
#  also see
#   Resampling in ChunckyPNG - steps and steps_residues



### check/todo: rename to calc_downsample_steps / downsample_steps - why? why not?
def calc_sample_steps( width, new_width )
  ## todo/fix: assert new_width is smaller than width

  puts
  puts "==> from: #{width}px  to: #{new_width}px"

  indexes  = []

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


steps = calc_sample_steps( 512, 24 )
puts steps.inspect

steps =  calc_sample_steps( 512, 50 )
puts steps.inspect

steps =  calc_sample_steps( 512, 35 )
puts steps.inspect


steps = calc_sample_steps( 480, 24 )
puts steps.inspect

steps = calc_sample_steps( 111, 5 )
puts steps.inspect




__END__


def steps(width, new_width)
  indicies, residues = steps_residues(width, new_width)

  for i in 1..new_width
    indicies[i - 1] = (indicies[i - 1] + (residues[i - 1] + 127) / 255)
  end
  indicies
end

def steps_residues(width, new_width)
  indicies = Array.new(new_width, nil)
  residues = Array.new(new_width, nil)

  # This works by accumulating the fractional error and
  # overflowing when necessary.

  # We use mixed number arithmetic with a denominator of
  # 2 * new_width
  base_step = width / new_width
  err_step = (width % new_width) << 1
  denominator = new_width << 1

  # Initial pixel
  index = (width - new_width) / denominator
  err = (width - new_width) % denominator

  for i in 1..new_width
    indicies[i - 1] = index
    residues[i - 1] = (255.0 * err.to_f / denominator.to_f).round

    index += base_step
    err += err_step
    if err >= denominator
      index += 1
      err -= denominator
    end
  end

  [indicies, residues]
end


