$LOAD_PATH.unshift( "../ordinals/lib" )
$LOAD_PATH.unshift( "./lib" )
require 'ordbase'



## calculate some statis

base_dir = "../../ordinals.cache"


datasets = Dir.glob( "#{base_dir}/btc/*.json" )

puts "  #{datasets.size} inscription(s)"


stats = InscriptionStats.new

datasets.each do |path|
  data = read_json( path )

  stats.update( data )
end

pp stats.data

puts "  bye"
