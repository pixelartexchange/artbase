#################################
# to run use:
#
#  $ ruby sandbox/download.rb

$LOAD_PATH.unshift( "./lib" )
require 'artbase-opensea'



url = OpenSea.assets_url( collection: 'etherbears' )
pp url


puts "bye"