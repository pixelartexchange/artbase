#################################
# to run use:
#
#  $ ruby sandbox/download_layers.rb


$LOAD_PATH.unshift( "./lib" )
require 'artbase-eth'


##
## todo/fix upstream
##   if config value is a string  - auto-add Rpc.new !!!!

Ethlite.config.rpc = Ethlite::Rpc.new( ENV['INFURA_URI'] )


madcamels_eth   = "0xad8474ba5a7f6abc52708f171f57fefc5cdc8c1c"

=begin
madcamels = TokenContract.new( madcamels_eth )

madcamels_tiers = [
   [99,369,475,1146,1159,1252],
   [578,902,942,2078],
 #  [26,40,72,78,79,92,117,138,239,248,305,316,338,513,541,635,723],
 #  [745,855,1324,1576],
 #  [18,28,32,33,39,44,45,60,66,68,111,114,119,121,130,134,161,168,181,182,187,201,228,239,276,287,295,301,311,321],
 #  [170,210,4120],
 #  [1,61,119,152,210,612,1224,2121],
 #  [66,431,530,1063,1198,1212],
]

madcamels.download_layers( madcamels_tiers, outdir: './tmp/madcamels' )
=end

marcs_eth  = "0xe9b91d537c3aa5a3fa87275fbd2e4feaaed69bd0"

marcs = TokenContract.new( marcs_eth )

n = 0
m = 0
res = marcs.traitData( n, m )    ## note: return binary blob (for n,m-index)
pp res

res = marcs.traitDetails( n, m )  ## note: returns tuple (name, mimetype, hide?)
pp res



marcs_tiers = [
 [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4979],
 [75,115,120,141,193,272,439,3645],
# [20,48,64,74,84,88,88,89,90,102,104,108,111,136,138,142,150,168,176,188,190,214,2428],
# [94,188,196,330,4192],
# [32,106,113,114,114,116,120,128,130,131,136,149,176,180,196,322,505,2232],
# [16,16,16,45,47,49,55,61,63,63,66,68,68,69,71,73,74,80,86,88,94,95,99,99,111,112,118,120,142,164,169,190,194,198,222,382,420,897],
# [31,46,66,86,99,100,111,115,123,133,138,163,169,180,189,190,214,244,256,266,2081],
# [190,322,4488],
# [146,199,421,1066,3168],
# [334,432,4234],
# [44,87,113,125,127,148,162,168,190,225,230,253,1063,2065],
# [16,24,64,99,99,99,128,1044,1126,1146,1155],
]

marcs.download_layers( marcs_tiers, outdir: './tmp/marcs' )



puts "bye"
