
module OpenSea
class TimelineCollectionsReport  < Report

  Collection =  Struct.new(:date, :buf, :buf2)



  def initialize( *cache_dirs, select: nil,
                   artbase_dir: nil )
    @dirs  = cache_dirs
    @slugs = select
    @artbase_dir = artbase_dir
  end




 def build

  cols = []


each_meta do |meta|
   date =  if meta.contracts.size > 0
                  meta.contracts[0].created_date
              else
                  meta.created_date
              end


  artbase_config = nil
  if @artbase_dir
    ## check if extra artbase config data exists?
    artbase_path = "#{@artbase_dir}/#{meta.slug}.json"
    if File.exist?( artbase_path )
       artbase_config = read_json( artbase_path )
    end
  end



  buf = String.new('')
  buf2 = String.new('')   ## use buf2 for now for summary - rename to __ - why? why not?


  ## for summary use single-string (no newline) for now
  buf2 << "[#{meta.stats.total_supply} #{meta.name}](https://opensea.io/collection/#{meta.slug})"
  if artbase_config && artbase_config['strip_url']
    buf2 << " ![](#{artbase_config['strip_url']})"
  end



  buf << "-  #{fmt_date(date)} - **[#{meta.stats.total_supply} #{meta.name}, #{fmt_fees( meta.fees.seller_fees )}](https://opensea.io/collection/#{meta.slug})**"

  buf << " - #{meta.stats.num_owners} owner(s)"
  if meta.stats.total_sales > 0
     buf << ", #{meta.stats.total_sales} sale(s) - "
     buf << " #{fmt_eth( meta.stats.total_volume ) }"
  end

  if artbase_config && artbase_config['strip_url']
    buf << " <br> ![](#{artbase_config['strip_url']})"
  end

  buf << "\n"


  if meta.contracts.size > 0
    meta.contracts.each do |contract|
       buf << "    - **#{contract.name} (#{contract.symbol})**"
       buf << " @ [#{contract.address}](https://etherscan.io/address/#{contract.address})\n"
    end
  end

  cols << Collection.new( date, buf, buf2 )
end


## sort  cols by date

cols = cols.sort { |l,r| r.date <=> l.date }

last_year = nil
last_month = nil


 buf = "# Timeline Collections\n\n"

### 1) add summary first
last_year = nil
last_month = nil
 cols.each do |col|
    year = col.date.year
    month = col.date.month

    if year != last_year
      buf += "\n\n## #{year}\n\n"
      last_month = nil   ## reset month
    end

    if month != last_month
      buf += "\n\n**#{col.date.strftime('%B')}** - "
      buf +=  col.buf2
    else
      buf += " • "
      buf +=  col.buf2
    end

    last_year = year
    last_month = month
 end
 buf += "\n\n"


### 2) add details next
last_year = nil
last_month = nil
 cols.each do |col|
    year = col.date.year
    month = col.date.month

    if year != last_year
      buf += "\n## #{year}\n\n"
      buf += "**#{col.date.strftime('%B')}**\n\n"
    elsif month != last_month
      buf += "\n**#{col.date.strftime('%B')}**\n\n"
    else
      ## do no thing
    end

    buf +=  col.buf

    last_year = year
    last_month = month
 end

 buf
end


end # class TimelineCollectionsReport
end  # module OpenSea
