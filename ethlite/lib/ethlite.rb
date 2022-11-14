require 'cocos'

require 'uri'
require 'net/http'
require 'net/https'
require 'json'


require 'openssl'
require 'digest'

## 3rd party gems
require 'rlp'               ## gem rlp    - see https://rubygems.org/gems/rlp

##  bundled require 'digest/keccak'     ## gem keccak - see https://rubygems.org/gems/keccak
require 'digest/keccak256'




## our own code
require_relative 'ethlite/version'    # note: let version always go first


require_relative 'ethlite/abi/type'
require_relative 'ethlite/abi/constant'
require_relative 'ethlite/abi/exceptions'
require_relative 'ethlite/abi/utils'
require_relative 'ethlite/abi/abi_coder'


require_relative 'ethlite/rpc'

require_relative 'ethlite/utility'
require_relative 'ethlite/contract'




module Ethlite
class Configuration
  def rpc()       @rpc || Rpc.new( ENV['INFURA_URI'] ); end
  def rpc=(value) @rpc = value; end
end # class Configuration


## lets you use
##   Ethlite.configure do |config|
##      config.rpc = Ethlite::Rpc.new( ENV['INFURA_URI'] )
##   end
def self.configure() yield( config ); end
def self.config()    @config ||= Configuration.new;  end
end  # module Ethlite




## add convenience alternate spelling
EthLite      = Ethlite


puts Ethlite.banner    # say hello

