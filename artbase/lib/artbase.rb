require 'pp'
require 'time'
require 'date'

require 'uri'
require 'net/http'
require 'net/https'
require 'cgi'
require 'fileutils'

require 'json'

require 'optparse'



## our own gems
require 'pixelart'





## our own code
require 'artbase/version'    # note: let version always go first

require 'artbase/image'


require 'artbase/helper'
require 'artbase/opensea'

require 'artbase/collection'
require 'artbase/attributes'


require 'artbase/tool'



puts Artbase.banner
puts Artbase.root
