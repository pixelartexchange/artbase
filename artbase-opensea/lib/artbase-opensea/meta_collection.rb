module OpenSea
class Meta     ###  change namespace to Cache - why? why not?
class Collection



def self.read( path_or_dir )  ## rename read from cache - why? why not?
   if File.directory?( path_or_dir )
      dir = path_or_dir
      data = read_json( "#{dir}/collection.json" )

      ## merge into one hash again / "unsplat" datafiles
      path = "#{dir}/contracts.json"
      data['primary_asset_contracts'] = if File.exist?( path )
                                            read_json( path )
                                        else
                                           []   # note: default is empty array
                                        end

      path = "#{dir}/traits.json"
      data['traits']                  = if File.exist?( path )
                                             read_json( path )
                                        else
                                             {}  # note: default is empty hash
                                        end

      ##  note: merge stats_changes & stats_totals into one
      data['stats'] = {}.merge(
                          read_json( "#{dir}/stats_changes.json" ),
                          read_json( "#{dir}/stats_totals.json") )

      data['payment_tokens']          = read_json( "#{dir}/payments.json" )

      new( data )
   else
      ## sorry for now only unsplat files in directory supported
      raise ArgumentError, "sorry for now only directory w/ unsplat data files supported"
   end
end

def initialize( data )
   @data = data
end


def name()            @data['name']; end
def slug()            @data['slug']; end
def url()            "https://opensea.io/collection/#{slug}"; end
alias_method :opensea_url, :url

def created_date()    @created_date ||= DateTime.iso8601( @data['created_date'] ); end
alias_method :created, :created_date


def external_url?()     !@data['external_url'].nil?; end
def external_url()      @data['external_url']; end
def twitter_username?() !@data['twitter_username'].nil?; end
def twitter_username()  @data['twitter_username']; end
def twitter_url()      "https://twitter.com/#{twitter_username}"; end


class Contract
   def initialize( data )
      @data = data
   end

   def created_date()    @created_date ||= DateTime.iso8601( @data['created_date'] ); end
   alias_method :created, :created_date

   def name() @data['name']; end
   def symbol() @data['symbol']; end
   def address() @data['address']; end
end  # (nested) class Contract

def contracts()
   @contracts ||= begin
                   @data['primary_asset_contracts'].map do |data|
                                                          Contract.new( data )
                                                        end
                  end
end


def trait_categories( count: true )
   values = []
   @data['traits'].each do |k,h|
      value = "#{k}"
      value << " (#{h.size})"  if count
      values <<  value
   end
   values
end
alias_method :attribute_categories, :trait_categories


def payment_methods
   values = []
   @data['payment_tokens'].each do |h|
      values << "#{h['name']} (#{h['symbol']})"
   end
   values
end


class Stats
   def initialize( data )
      @data = data
   end

   ## note: auto-convert to integer - why? why not?
   ##    are counts etc. ever fractions ?
   def count()        @data['count'].to_i; end
   def total_supply() @data['total_supply'].to_i; end
   def total_sales()  @data['total_sales'].to_i; end
   def num_owners()   @data['num_owners'].to_i; end

   ## floating point numbers
   def total_volume()  @data['total_volume']; end  ## in eth
   def average_price() @data['average_price']; end ## in eth
   def floor_price()   @data['floor_price']; end   ## in eth
end   # (nested) class Stats

def stats() @stats ||= Stats.new( @data['stats'] );  end


class Fees
   def initialize( data )
      @data = data
   end

   def seller_fees
      @seller_fees ||= begin
                 @data['seller_fees'].reduce(0) do |sum, (k,v)|
                      sum += v
                      sum
                 end
               end
   end
   alias_method :creator_fees, :seller_fees

   def opensea_fees
      @opensea_fees ||= begin
                 @data['opensea_fees'].reduce(0) do |sum, (k,v)|
                      sum += v
                      sum
                 end
               end
   end
end  # (nested) class Fees


def fees()  @fees ||= Fees.new( @data['fees'] ); end

end  # (nested) class Collection
end # class Meta
end  # module OpenSea

