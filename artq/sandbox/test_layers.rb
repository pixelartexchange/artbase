#################################
# to run use:
#
#  $ ruby sandbox/test_layers.rb

$LOAD_PATH.unshift( "./lib" )
require 'artq'



[
  ## '0xe9b91d537c3aa5a3fa87275fbd2e4feaaed69bd0',  ## marcs
  ## '0x2204a94f96d39df3b6bc0298cf068c8c82dc8d61',  ## chichis
  '0xad8474ba5a7f6abc52708f171f57fefc5cdc8c1c',  ## madcamels
].each do |contract_address|

  c = ArtQ::Contract.new( contract_address )

  name   = c.name
  symbol = c.symbol
  totalSupply = c.totalSupply


  traitDetails  = []
  n=0

  loop do
    m=0
    loop do
      rec = c.traitDetails( n, m )
      break  if rec == ['','',false]

      traitDetails << [[n,m], rec ]
      m += 1
    end
    break  if m==0
    n += 1
  end


  puts "==>  contract @ #{contract_address}:"
  puts "  name: >#{name}<"
  puts "  symbol: >#{symbol}<"
  puts "  totalSupply: >#{totalSupply}<"

  puts "  traitDetails:"
  pp traitDetails

end




puts "bye"