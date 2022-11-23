#################################
# to run use:
#
#  $ ruby sandbox/test_info.rb

$LOAD_PATH.unshift( "./lib" )
require 'artq'



[
 '0x23581767a106ae21c074b2276d25e5c3e136a68b',  ## moonbirds  (off-chain)
 '0xe21ebcd28d37a67757b9bc7b290f4c4928a430b1',  ## the saudis (on-chain)
].each do |contract_address|

  c = ArtQ::Contract.new( contract_address )

  name   = c.name
  symbol = c.symbol
  totalSupply = c.totalSupply
  tokenURIs = []
  tokenIds = (0..2)
  tokenIds.each do |tokenId|
      tokenURIs << [tokenId, c.tokenURI( tokenId )]
  end


  puts "==>  contract @ #{contract_address}:"
  puts "  name: >#{name}<"
  puts "  symbol: >#{symbol}<"
  puts "  totalSupply: >#{totalSupply}<"

  tokenURIs.each do |tokenId, tokenURI|
      puts "  tokenId #{tokenId}:"
      puts tokenURI
      puts
  end
end




puts "bye"