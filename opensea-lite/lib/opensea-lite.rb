require 'cocos'

require 'cgi'
require 'fileutils'


require 'optparse'


## 3rd party gems
require 'puppeteer-ruby'
require 'webclient'


## our own code
require_relative 'opensea-lite/version'   # note: let version always go first
require_relative 'opensea-lite/api'
require_relative 'opensea-lite/meta_assets'
require_relative 'opensea-lite/meta_collection'
require_relative 'opensea-lite/convert'

require_relative 'opensea-lite/cache'



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


require_relative 'opensea-lite/reports/format_helper'
require_relative 'opensea-lite/reports/base'
require_relative 'opensea-lite/reports/collections'
require_relative 'opensea-lite/reports/timeline'
require_relative 'opensea-lite/reports/top'
require_relative 'opensea-lite/reports/trending'


require_relative 'opensea-lite/datasets/base'
require_relative 'opensea-lite/datasets/collections'



require_relative 'opensea-lite/puppeteer'


require_relative 'opensea-lite/tool'


#####
# add convenience alias
Opensea = OpenSea


puts OpenSea.banner
puts OpenSea.root

