



module OpenSea
  class Report
    ## rename to ReportBase or such - why? why not?
    ##   our use a ReportHelper module to include - why? why not?

  include FormatHelper



  def each_meta( &blk )
    @dirs.each do |cache_dir|
      each_dir( "#{cache_dir}/*" ) do |dir|
         puts "==> #{dir}"
         meta = Meta::Collection.read( dir )

         if @slugs && !@slugs.include?( meta.slug )
           ## skipping collection (slug NOT included in selected slug set/filter)
           next
         end

         blk.call( meta )
      end
    end
  end



  def save( path )
    buf = build
    write_text( path, buf )
  end


end    # class Report
end   # module OpenSea
