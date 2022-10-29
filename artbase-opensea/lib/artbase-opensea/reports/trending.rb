
module OpenSea
class TrendingCollectionsReport  < Report


  Collection =  Struct.new(:thirty_day_volume,
                           :date,
                           :buf)


  def initialize( *cache_dirs, select: nil )
    @dirs  = cache_dirs
    @slugs = select
  end


def build

  cols = []

each_meta do |meta|

     date =  if meta.contracts.size > 0
                  meta.contracts[0].created_date
              else
                  meta.created_date
              end

  buf = String.new('')

  buf << "- "
  if meta.stats.thirty_day_sales > 0
     buf << " #{meta.stats.thirty_day_sales} in 30d - #{fmt_eth( meta.stats.thirty_day_volume )},"
     if meta.stats.seven_day_sales > 0
        buf << " #{meta.stats.seven_day_sales} in 7d - #{fmt_eth( meta.stats.seven_day_volume )},"
        if meta.stats.one_day_sales > 0
           buf << " #{meta.stats.one_day_sales} in 1d - #{fmt_eth( meta.stats.one_day_volume )},"
        else
           buf << " 0 in 1d "
        end
     else
        buf << " 0 in 7d/1d "
     end
  else
     buf << " 0 in 30d/7d/1d "
  end

  buf << " **[#{meta.stats.total_supply} #{meta.name} (#{fmt_date(date)}), #{fmt_fees( meta.fees.seller_fees )}](https://opensea.io/collection/#{meta.slug})**\n"
  buf << "   - owners: #{meta.stats.num_owners},"
  if meta.stats.total_sales > 0
    buf << "   sales:  #{meta.stats.total_sales}"
    buf << "   -  #{fmt_eth( meta.stats.total_volume )} @ "
    buf << "   price avg #{fmt_eth( meta.stats.average_price ) },"
    buf << "   floor #{fmt_eth( meta.stats.floor_price ) }"
  else
     buf << "   sales: 0"
  end
  buf << "\n"

  cols << Collection.new( meta.stats.thirty_day_volume, date, buf )

end
 cols = cols.sort do |l,r|
                    res = r.thirty_day_volume <=> l.thirty_day_volume
                    res = r.date <=> l.date   if res == 0
                    res
                  end

 buf = "# Trending Collections\n\n"
 buf +=  cols.map { |col| col.buf }.join( '' )
 buf
end
end   # class TrendingCollectionReport
end    # module OpenSea
