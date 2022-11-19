#################################
# to run use:
#
#  $ ruby sandbox/download_tokens.rb


$LOAD_PATH.unshift( "./lib" )
require 'artbase-eth'



Ethlite.config.rpc =  ENV['INFURA_URI']


## try on-chain tokens

contracts = {
  edgepunks:  "0x83921cb2bdfe8f70aa2988a20dd8b91c197b04b9",
  punkinspicies: "0x34625ecaa75c0ea33733a05c584f4cf112c10b6b",
  nfl: "0xa3bfe256f70f98644b86338df9fcbccd65560e58",
  chopper: "0x090c8034e6706994945049e0ede1bbdf21498e6e",
  dankpunks: "0x5e8edf0ab7b3e13394846fe0fbb306aea47588e9",
  chichis: "0x2204a94f96d39df3b6bc0298cf068c8c82dc8d61",
  phunkapeorigins: "0x9b66d03fc1eee61a512341058e95f1a68dc3a913",
  fuks: "0x16f8cd1fedb3203e8fd6a5fa041b34cee087398b",
  inversepunks: "0xf3a1befc9643f94551c24a766afb87383ef64dd4",
  punkapesyachtclub: "0xe5a5520b798c5f67ca1b0657b932656df02595ad",
  madcamels: "0xad8474ba5a7f6abc52708f171f57fefc5cdc8c1c",
  proofofpepe: "0x2f46e37477ca4033d74986b15f0572e9913b4858",
  aliensvspunks: "0x2612c0375c47ee510a1663169288f2e9eb912947",
  nomads: "0x95123d2f71d88e2afb5351befb4762d2574fba7a",
  marcs: "0xe9b91d537c3aa5a3fa87275fbd2e4feaaed69bd0",
}



contracts.each do |contract_name, contract_address|
  sleep( 0.5 )

  t = TokenContract.new( contract_address )
  id = 0     ## try tokenId no.0
  res = t.tokenURI( id )

  write_text( "./tmp/tokens/#{contract_name}-no.#{id}.txt", res )
end

puts "bye"