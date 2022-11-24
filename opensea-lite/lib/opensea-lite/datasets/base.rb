

module OpenSea
  class Dataset
    ## rename to DatasetBase or such - why? why not?

  include FormatHelper


  def export( path )
    headers, recs = build

    ## todo/fix: make build dirs (if not exist)
    File.open( path, 'w:utf-8') do |f|
       f.write( headers.join( ', '))
       f.write( "\n" )
       recs.each do |values|
          f.write( values.join( ', '))
          f.write( "\n" )
        end
      end
  end


end    # class Dataset
end   # module OpenSea
