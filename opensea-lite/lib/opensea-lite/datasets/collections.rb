
module OpenSea
class CollectionsDataset  < Dataset


  def initialize( cache_dir )
    @cache_dir = cache_dir
  end



def build

  headers = [
     'slug',
     'created',
     'items',
     'seller fee',
     'no. of owners',
     'no. of sales',
     'total sales',
     'contract(s)',
     'name',
  ]

  recs = []


each_dir( "#{@cache_dir}/*" ) do |dir|
  puts "==> #{dir}"

  meta = Meta::Collection.read( dir )

   date =  if meta.contracts.size > 0
                  meta.contracts[0].created_date
              else
                  meta.created_date
              end

  values = [
    meta.slug,
    date.strftime( '%b %d %Y' ),
    meta.stats.total_supply,
    fmt_fees( meta.fees.seller_fees ),
    meta.stats.num_owners,
    meta.stats.total_sales,
    "#{meta.stats.total_volume.round} ETH",
  ]


  buf = String.new('')
  if meta.contracts.size > 0
    buf << "(#{meta.contracts.size}) "
    meta.contracts.each_with_index do |contract,i|
      buf << " | "  if i > 0
      buf << "#{contract.name} (#{contract.symbol})"
      buf << " @ #{contract.address}"
    end
  else
    buf = "OPENSTORE"
  end
  values << buf

   values <<  meta.name
   recs << values
end

  ## sort  cols by date

  recs = recs.sort { |l,r| Date.strptime(r[1], '%b %d %Y' ) <=>
                           Date.strptime(l[1], '%b %d %Y' ) }

  [headers, recs]
end

end # class CollectionsDataset
end  # module OpenSea
