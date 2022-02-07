
class TokenCollection

  attr_reader :slug, :count

  def initialize( slug, count,
                  token_base: )   # check: rename count to items or such - why? why not?
    @slug = slug
    @count = count
    @token_base = token_base
  end


  def download_meta( range=(0...@count) )
    start = Time.now
    delay_in_s = 0.3

    range.each do |offset|
      token_src = @token_base.sub( '{id}', offset.to_s )

      puts "==> #{offset} - #{@slug}..."

      copy_json( token_src, "./#{@slug}/token-meta/#{offset}.json" )

      stop = Time.now
      diff = stop - start

      mins = diff / 60  ## todo - use floor or such?
      secs = diff % 60
      puts "up #{mins} mins #{secs} secs (total #{diff} secs)"

      puts "sleeping #{delay_in_s}s..."
      sleep( delay_in_s )
    end
  end


  def download_images( range=(0...@count) )
    start = Time.now
    delay_in_s = 0.3

    range.each do |offset|
      txt = File.open( "./#{@slug}/token-meta/#{offset}.json", 'r:utf-8') { |f| f.read }
      data = JSON.parse( txt )

      meta_name  = data['name']
      meta_image = data['image']

      puts "==> #{offset} - #{@slug}..."
      puts "   name: #{meta_name}"
      puts "   image: #{meta_image}"

      ## note: will auto-add format file extension (e.g. .png, .jpg)
      ##        depending on http content type!!!!!
      start_copy = Time.now
      copy_image( meta_image, "./#{@slug}/token-i/#{offset}" )

      stop = Time.now

      diff = stop -start_copy
      puts "    download image in #{diff} sec(s)"

      diff = stop - start
      mins = diff / 60  ## todo - use floor or such?
      secs = diff % 60
      puts "up #{mins} mins #{secs} secs (total #{diff} secs)"

      puts "sleeping #{delay_in_s}s..."
      sleep( delay_in_s )
    end
  end
end # class TokenCollection
