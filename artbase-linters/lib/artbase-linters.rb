require 'artbase-cocos'


## our own code
require_relative 'artbase-linters/version'
require_relative 'artbase-linters/base'
require_relative 'artbase-linters/collections_linter'  # e.g. LintCollectionsReport etc.
require_relative 'artbase-linters/contracts_linter'

require_relative 'artbase-linters/export'
require_relative 'artbase-linters/opensea_linter'






puts Artbase::Module::Linters.banner    # say hello

