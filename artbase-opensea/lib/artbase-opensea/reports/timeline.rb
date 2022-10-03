
module OpenSea
class TimelineCollectionsReport  < Report

  Collection =  Struct.new(:date, :buf)


  def initialize( cache_dir )
    @cache_dir = cache_dir
  end


 def build

  cols = []

each_dir( "#{@cache_dir}/*" ) do |dir|
  puts "==> #{dir}"

  meta = Meta::Collection.read( dir )

   date =  if meta.contracts.size > 0
                  meta.contracts[0].created_date
              else
                  meta.created_date
              end


  buf = String.new('')

  buf << "-  #{fmt_date(date)} - **[#{meta.stats.total_supply} #{meta.name}, #{fmt_fees( meta.fees.seller_fees )}](https://opensea.io/collection/#{meta.slug})**"
  buf << " - #{meta.stats.num_owners} owner(s)"
  if meta.stats.total_sales > 0
     buf << ", #{meta.stats.total_sales} sale(s) - "
     buf << " #{fmt_eth( meta.stats.total_volume ) }"
  end
  buf << "\n"

  if meta.contracts.size > 0
    meta.contracts.each do |contract|
       buf << "    - **#{contract.name} (#{contract.symbol})**"
       buf << " @ [#{contract.address}](https://etherscan.io/address/#{contract.address})\n"
    end
  end

  cols << Collection.new( date, buf )
end

## sort  cols by date

cols = cols.sort { |l,r| r.date <=> l.date }


 buf = "# Timeline Collections\n\n"
 buf +=  cols.map { |col| col.buf }.join
 buf
end
end # class TimelineCollectionsReport
end  # module OpenSea
