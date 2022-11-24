#################################
# to run use:
#
#  $ ruby sandbox/download.rb

$LOAD_PATH.unshift( "./lib" )
require 'opensea-lite'



url = OpenSea.assets_url( collection: 'etherbears' )
pp url


puts "bye"