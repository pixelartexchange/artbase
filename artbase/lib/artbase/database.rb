

module Artbase


class Importer    ## use to import metadata into database

  def self.read( path )
    code = read_text( path )
    parse( code )
  end

  def self.parse( code )
    importer = new
    importer.instance_eval( code )
    importer
  end


  def slugify( str )
    str = str.strip.downcase
    str = str.gsub( /[ ]/, '_' )
    str
  end



  ############
  #   defaults ("built-ins") method for to_metadata, etc.

  def to_metadata( attributes )
    h = {}
    attributes.each do |key,value|
      slug = slugify( key )
      h[ slug ] = value
    end
    h
  end
end  # class Importer





module Database
  def self.create( spec )
    ActiveRecord::Schema.define do
      create_table :metadata do |t|

        spec.each do |column|
           column_name = column[0].to_sym
           column_opts = column[1] || {}
           column_type = (column[2] || 'string').to_sym

           t.__send__( column_type, column_name, **column_opts )
        end

        t.string  :image, null: false

        t.timestamps
      end
    end  # Schema.define
  end # method self.create


  def self.connect( database='./artbase.db' )

        config =   { adapter:  'sqlite3',
                     database: database,
                      }

      puts "Connecting to db using settings: "
      pp config
      ActiveRecord::Base.establish_connection( config )
      # ActiveRecord::Base.logger = Logger.new( STDOUT )

      ## if sqlite3 add (use) some pragmas for speedups
        ## note: if in memory database e.g. ':memory:' no pragma needed!!
        ## try to speed up sqlite
        ##   see http://www.sqlite.org/pragma.html
        con = ActiveRecord::Base.connection
        con.execute( 'PRAGMA synchronous=OFF;' )
        con.execute( 'PRAGMA journal_mode=OFF;' )
        con.execute( 'PRAGMA temp_store=MEMORY;' )

  end


  def self.auto_migrate!( spec )
    # first time? - auto-run db migratation, that is, create db tables
    unless Metadata.table_exists?
      create( spec )
    end
  end


  class Metadata < ActiveRecord::Base
    self.table_name = "metadata"
  end


end # module Database
end # module Artbase
