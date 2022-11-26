
$LOAD_PATH.unshift( "../artbase-cocos/lib" )
$LOAD_PATH.unshift( "./lib" )
require 'artbase-importers'

puts "===> build database"

slug = 'goblintown'

importer = Artbase::Importer.read( "./sandbox/#{slug}/build.rb" )

columns = importer.metadata_columns
pp columns

Artbase::Database.connect( "./tmp/#{slug}/artbase.db" )
Artbase::Database.auto_migrate!( columns )


collection = TokenCollection.read( "./sandbox/#{slug}/collection.yml" )
pp collection


#  collection.import( importer )

puts "bye"


