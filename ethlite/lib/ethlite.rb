require 'cocos'

require 'uri'
require 'net/http'
require 'net/https'
require 'json'


require 'openssl'
require 'digest'

## 3rd party gems
require 'digest/keccak'     ## gem keccak - see https://rubygems.org/gems/keccak
require 'rlp'               ## gem rlp    - see https://rubygems.org/gems/rlp



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



## add convenience alternate spelling
EthLite      = Ethlite


puts Ethlite.banner    # say hello

