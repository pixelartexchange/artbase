

class ImageCollection

  attr_reader :slug, :count

  def initialize( slug, count,
                  image_base: )   # check: rename count to items or such - why? why not?
    @slug = slug
    @count = count
    @image_base = image_base
  end

  def download_images( range=(0...@count) )
    start = Time.now
    delay_in_s = 0.3

    range.each do |offset|
      image_src = @image_base.sub( '{id}', offset.to_s )

      puts "==> #{offset} - #{@slug}..."

      ## note: will auto-add format file extension (e.g. .png, .jpg)
      ##        depending on http content type!!!!!
      copy_image( image_src, "./#{@slug}/image-i/#{offset}" )

      stop = Time.now
      diff = stop - start

      mins = diff / 60  ## todo - use floor or such?
      secs = diff % 60
      puts "up #{mins} mins #{secs} secs (total #{diff} secs)"

      puts "sleeping #{delay_in_s}s..."
      sleep( delay_in_s )
    end
  end
end # class ImageCollection

