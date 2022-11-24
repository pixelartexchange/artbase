###
#  to run use:
#
#    $ ruby -I ./lib sandbox/stripes.rb

$LOAD_PATH.unshift( "../../pixelart/pixelart/lib" )
require 'artbase'


def calc_stripes( length, n: )
  puts
  puts "==> calc_stripes( #{length}, n: #{n})"
  stripes = Image.calc_stripes( length, n: n, debug: true )

  puts
  pp stripes
end


calc_stripes( 24, n: 2 )
calc_stripes( 25, n: 2 )

calc_stripes( 24, n: 6 )

calc_stripes( 24, n: 3 )
calc_stripes( 25, n: 3 )

calc_stripes( 24, n: 15 )



puts "bye"
