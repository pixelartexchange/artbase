
module OpenSea
class CollectionsReport  < Report

  Collection =  Struct.new(:date, :buf)

def build( root_dir )

  cols = []

each_dir( "#{root_dir}/*" ) do |dir|
  puts "==> #{dir}"

  meta = Meta::Collection.read( dir )


  buf = String.new('')
  buf << "##  #{meta.name}\n\n"

  buf << "opensea: [#{meta.slug}](https://opensea.io/collection/#{meta.slug}) - created on #{fmt_date(meta.created_date)}<br>\n"
  buf << "web:  <#{meta.external_url}><br>\n"   if meta.external_url?
  buf << "twitter: [#{meta.twitter_username}](https://twitter.com/#{meta.twitter_username})<br>\n"  if meta.twitter_username?

  buf << "\n"

  if meta.contracts.size > 0
    buf << "contracts (#{meta.contracts.size}):\n"
    meta.contracts.each do |contract|
       buf << "- **#{contract.name} (#{contract.symbol})**"
       buf << " created on #{fmt_date(contract.created_date)}"
       buf << " @ [#{contract.address}](https://etherscan.io/address/#{contract.address})\n"
    end
    buf << "\n"
  end

  buf << "stats:\n"
  buf << "- count / total supply: #{meta.stats.count} / #{meta.stats.total_supply},"
  buf << " num owners:  #{meta.stats.num_owners}\n"
  if meta.stats.total_sales > 0
     buf << "- total sales:  #{meta.stats.total_sales},"
     buf << " total volume: #{fmt_eth( meta.stats.total_volume ) }\n"
     buf << "- average price: #{fmt_eth( meta.stats.average_price ) }\n"
     buf << "- floor price: #{fmt_eth( meta.stats.floor_price ) }\n"
  else
     buf << "- total sales:  0\n"
  end
  buf << "\n"


  buf << "fees:"
  buf << " seller #{fmt_fees( meta.fees.seller_fees )},"
  buf << " opensea #{fmt_fees( meta.fees.opensea_fees )}\n"
  buf << "\n"

  buf << "payments (#{meta.payment_methods.size}): #{meta.payment_methods.join(', ')}\n"
  buf << "\n"

  attribute_categories = meta.attribute_categories( count: true )
  if attribute_categories.size > 0
    buf << "<details><summary>attribute categories (#{attribute_categories.size}):</summary>\n"
    buf << "\n"
    attribute_categories.each do |cat|
       buf << "- #{cat}\n"
    end
    buf << "\n"
    buf << "</details>\n"
  end

  date =  if meta.contracts.size > 0
                  meta.contracts[0].created_date
              else
                  meta.created_date
              end

  cols << Collection.new( date, buf )
end

## sort  cols by date

cols = cols.sort { |l,r| r.date <=> l.date }


 buf = "# Collections\n\n"
 buf +=  cols.map { |col| col.buf }.join( "\n\n" )
 buf
end
end # class CollectionsReport
end  # module OpenSea
