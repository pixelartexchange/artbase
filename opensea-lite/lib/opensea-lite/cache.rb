
module OpenSea
class Cache     ## todo: change cache to downloader / batch or such - why? why not?


def initialize( cache_dir = './cache' )
  @cache_dir = cache_dir    ## note: might be a proc (!) NOT just a string
end



def download( slugs, *includes, delay_in_s: 2 )

  includes = [:all]   if includes.empty?


slugs.each do |slug|

  puts
  puts "==> fetching #{slug}..."

  raw = Opensea.collection( slug )

  ## note: simplify result
  ##  remove nested 'collection' level

  data = raw['collection']

  cache_dir =   if @cache_dir.is_a?( Proc )
                   @cache_dir.call( data )
                else  ## assume "static/classic" string
                   @cache_dir
                end


  ## remove editors  - do not care for now
  data.delete( 'editors' )


  data_contracts = data['primary_asset_contracts']
  data.delete( 'primary_asset_contracts' )

  data_traits = data['traits']
  data.delete( 'traits')

  ## note: split stats hash into two part
  ##   - changes  (always changing)
  ##   - totals   (more stable)
  data_stats_changes  = data['stats']
  data.delete( 'stats')

  ## move totals to its own hash
  data_stats_totals  = { }

  %w[
    total_volume
    total_sales
    total_supply
    count
    num_owners
    average_price
    num_reports
    market_cap
    floor_price
  ].each do |key|
      data_stats_totals[ key ] = data_stats_changes.delete( key )
  end





  data_payments = data['payment_tokens']
  data.delete( 'payment_tokens' )

  ## clean payment - remove keys:
  ##   - eth_price
  ##   - usd_price
  ##  - will change daily
  data_payments = data_payments.map do |payment|
                                        payment.delete( 'eth_price' )
                                        payment.delete( 'usd_price' )
                                        payment
                                    end

  ## clean collection  - remove deprecated (duplicate keys):
  ##  - dev_buyer_fee_basis_points
  ##  - dev_seller_fee_basis_points
  ##  - opensea_buyer_fee_basis_points
  ##  - opensea_seller_fee_basis_points
  ##  - payout_address
  data.delete( 'dev_buyer_fee_basis_points' )
  data.delete( 'dev_seller_fee_basis_points' )
  data.delete( 'opensea_buyer_fee_basis_points' )
  data.delete( 'opensea_seller_fee_basis_points' )
  data.delete( 'payout_address' )


  ## clean collection - remove deprecated (duplicate keys):
  ##   - dev_buyer_fee_basis_points
  ##   - dev_seller_fee_basis_points
  ##   - opensea_buyer_fee_basis_points
  ##   - opensea_seller_fee_basis_points
  ##   - buyer_fee_basis_points
  ##   - seller_fee_basis_points
  ##   - payout_address
  data_contracts = data_contracts.map do |contract|
                                    contract.delete( 'dev_buyer_fee_basis_points' )
                                    contract.delete( 'dev_seller_fee_basis_points' )
                                    contract.delete( 'opensea_buyer_fee_basis_points' )
                                    contract.delete( 'opensea_seller_fee_basis_points' )
                                    contract.delete( 'buyer_fee_basis_points' )
                                    contract.delete( 'seller_fee_basis_points' )
                                    contract.delete( 'payout_address' )
                                    contract
                                      end


  path = "#{cache_dir}/#{slug}/collection.json"

  write_json( path, data )   if includes.include?( :all ) ||
                                includes.include?( :collection )

  ## note: only save if contracts present  - why? why not?
  if data_contracts.size > 0
    path = "#{cache_dir}/#{slug}/contracts.json"
    write_json( path, data_contracts )   if includes.include?( :all ) ||
                                            includes.include?( :contracts )
  end

  if data_traits.size > 0
    path = "#{cache_dir}/#{slug}/traits.json"
    write_json( path, data_traits )     if includes.include?( :all ) ||
                                           includes.include?( :traits )
  end

  if includes.include?( :all ) ||
     includes.include?( :stats )

    ## FileUtils.remove_file( "#{cache_dir}/#{slug}/stats.json" )

    path = "#{cache_dir}/#{slug}/stats_changes.json"
    write_json( path, data_stats_changes )

    path = "#{cache_dir}/#{slug}/stats_totals.json"
    write_json( path, data_stats_totals )
  end


  path = "#{cache_dir}/#{slug}/payments.json"
  write_json( path, data_payments )  if includes.include?( :all ) ||
                                        includes.include?( :payments )


  puts "  sleeping #{delay_in_s}s..."
  sleep( delay_in_s )
end
end





end    # class Cache
end   # module OpenSea


