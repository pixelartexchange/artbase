
require 'artbase-cocos'


## add activerecord (database) machinery
require 'sqlite3'
require 'active_record'



##  our own code
require_relative 'artbase-importers/version'
require_relative 'artbase-importers/database'
require_relative 'artbase-importers/importer'
require_relative 'artbase-importers/collection'






puts Artbase::Module::Importers.banner    # say hello
