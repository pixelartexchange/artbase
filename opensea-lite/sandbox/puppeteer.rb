#################################
# to run use:
#
#  $ ruby sandbox/puppeteer.rb

$LOAD_PATH.unshift( "./lib" )
require 'opensea-lite'


pp Opensea::Puppeteer.chrome_path
pp Opensea::Puppeteer.chrome_path = 'hello.exe'
pp Opensea::Puppeteer.chrome_path


puts "bye"