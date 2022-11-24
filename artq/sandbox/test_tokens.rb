#################################
# to run use:
#
#  $ ruby sandbox/test_tokens.rb

$LOAD_PATH.unshift( "./lib" )
require 'artq'


[
 ## '0xe9b91d537c3aa5a3fa87275fbd2e4feaaed69bd0',  ## marcs
 '0x2204a94f96d39df3b6bc0298cf068c8c82dc8d61',  ## chichis
 ## '0xad8474ba5a7f6abc52708f171f57fefc5cdc8c1c',  ## madcamels
  ## '0xcd46fce2daf0f2f5129f74b502667e61b15c89f3',   ## people
  ## '0xe21ebcd28d37a67757b9bc7b290f4c4928a430b1',  ## the saudis
].each do |contract_address|

  ArtQ.download_tokens( contract_address,
                        outdir: "./tmp/#{contract_address}" )

end




puts "bye"