

## check - move each_dir helper upstream to cocos - why? why not?
def each_dir( glob, exclude: [], &blk )
  dirs = Dir.glob( glob ).select {|f| File.directory?(f) }

  puts "  #{dirs.size} dir(s):"
  pp dirs

  dirs.each do |dir|
     basename = File.basename( dir )
     ## check for sandbox/tmp/i/etc.  and skip
     next if exclude.include?( basename )

     blk.call( dir )
  end
end




module OpenSea
  class Report
    ## rename to ReportBase or such - why? why not?
    ##   our use a ReportHelper module to include - why? why not?



def fmt_date( date )
   date.strftime( '%b %d, %Y' )
end

def fmt_fees( basis )
   ## in basis point e.g. 100  => 1%
   ##                     250  => 2.5%
   ##                    1000  => 10%

   if basis == 0
      "-"
   else
      "#{'%.1f%%' % (basis/100.0)}"
   end
end


ETH_IN_USD = 1300.0

def fmt_eth( amount )
   if amount.nil?
      "???"
   elsif amount == 0.0
      "0"
   else
      usd = amount*ETH_IN_USD

      usd_str = if usd / 1_000_000 >= 1
                   "#{'%.1f' % (usd / 1_000_000)} million(s)"
                elsif usd >= 1000
                   "#{'%.0f' % usd}"
                else
                   "#{'%.2f' % usd}"
                end

      if amount >= 0.015
        "#{'Ξ%.2f' % amount} (~ US$ #{usd_str})"
      elsif amount >= 0.0015
        "#{'Ξ%.3f' % amount} (~ US$ #{usd_str})"
      else
        "Ξ#{amount} (~ US$ #{usd_str})"
      end
   end
end



def save( path )
   buf = build
   write_text( path, buf )
end

end    # class Report
end   # module OpenSea
