require 'cocos'

require 'cgi'
require 'fileutils'


require 'optparse'


## 3rd party gems
require 'puppeteer-ruby'
require 'webclient'


## our own code
require_relative 'artbase-opensea/version'   # note: let version always go first
require_relative 'artbase-opensea/api'
require_relative 'artbase-opensea/meta_assets'
require_relative 'artbase-opensea/meta_collection'
require_relative 'artbase-opensea/convert'

require_relative 'artbase-opensea/cache'



## check - move each_dir helper upstream to cocos - why? why not?
def each_dir( glob, exclude: [], &blk )
  dirs = Dir.glob( glob ).select {|f| File.directory?(f) }

  puts "  #{dirs.size} dir(s):"
  pp dirs

  dirs.each do |dir|
     basename = File.basename( dir )
     ## check for sandbox/tmp/i/etc.  and skip
     next if exclude.include?( basename )

     blk.call( dir )
  end
end


require_relative 'artbase-opensea/reports/format_helper'
require_relative 'artbase-opensea/reports/base'
require_relative 'artbase-opensea/reports/collections'
require_relative 'artbase-opensea/reports/timeline'
require_relative 'artbase-opensea/reports/top'
require_relative 'artbase-opensea/reports/trending'


require_relative 'artbase-opensea/datasets/base'
require_relative 'artbase-opensea/datasets/collections'



require_relative 'artbase-opensea/puppeteer'


require_relative 'artbase-opensea/tool'


#####
# add convenience alias
Opensea = OpenSea


puts OpenSea.banner
puts OpenSea.root

