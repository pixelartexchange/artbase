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

require_relative 'artbase-opensea/reports/base'
require_relative 'artbase-opensea/reports/collections'
require_relative 'artbase-opensea/reports/top'
require_relative 'artbase-opensea/reports/trending'


require_relative 'artbase-opensea/puppeteer'


require_relative 'artbase-opensea/tool'


#####
# add convenience alias
Opensea = OpenSea


puts OpenSea.banner
puts OpenSea.root

