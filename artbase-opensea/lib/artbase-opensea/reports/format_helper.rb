
module OpenSea
module FormatHelper


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




end # module FormatHelper
end # module OpenSea