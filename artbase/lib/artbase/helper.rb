


def slugify( name )
  name.downcase.gsub( /[^a-z0-9 ()$_-]/ ) do |_|
     puts " !! WARN: asciify - found (and removing) non-ascii char >#{Regexp.last_match}<"
     ''  ## remove - use empty string
  end.gsub( ' ', '_')
end



=begin
  moved/ use Image.convert !!!  remove here
def convert_images( collection, from: 'jpg',
                                to: 'png',
                                dir: 'i',
                                overwrite: true )
    files = Dir.glob( "./#{collection}/#{dir}/*.#{from}" )
    puts "==> converting #{files.size} image(s) from #{from} to #{to}"

    files.each_with_index do |file,i|
      dirname   = File.dirname( file )
      extname   = File.extname( file )
      basename  = File.basename( file, extname )

      ## skip convert if target / dest file already exists
      next  if overwrite == false && File.exist?( "#{dirname}/#{basename}.#{to}" )


      cmd = "magick convert #{dirname}/#{basename}.#{from} #{dirname}/#{basename}.#{to}"

      puts "   [#{i+1}/#{files.size}] - #{cmd}"
      system( cmd )

      if from == 'gif'
        ## assume multi-images for gif
        ##   save  image-0.png  to  image.png
        path0 = "#{dirname}/#{basename}-0.#{to}"
        path  = "#{dirname}/#{basename}.#{to}"

        puts "   saving #{path0} to #{path}..."

        blob = File.open( path0, 'rb' ) { |f| f.read }
        File.open( path, 'wb' ) { |f| f.write( blob ) }
      end
    end
end
=end







def copy_json( src, dest )
  uri = URI.parse( src )



  headers = { 'User-Agent' => "ruby v#{RUBY_VERSION}" }

  redirect_limit = 6
  response       = nil

  until false
    raise ArgumentError, 'HTTP redirect too deep' if redirect_limit == 0
    redirect_limit -= 1

    puts "[debug] GET #{uri.request_uri} uri=#{uri}"

    http = Net::HTTP.new( uri.host, uri.port )

    if uri.instance_of? URI::HTTPS
      # puts "[debug] use SSL (HTTPS); set verify mode to none"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    request = Net::HTTP::Get.new( uri.request_uri, headers )
    response   = http.request( request )


    if response.code == '301' ||
       response.code == '302' ||
       response.code == '303' ||
       response.code == '307'
      # 301 = moved permanently
      # 302 = found
      # 303 = see other
      # 307 = temporary redirect

      puts "[debug] #{response.code} #{response.message}"
      puts "[debug]   location: #{response.header['location']}"

      newuri = URI.parse( response.header['location'] )
      if newuri.relative?
         puts "[debug]  url relative; try to make it absolute"
        newuri = uri + response.header['location']
      end

      uri = newuri
      puts "[debug]  #{uri.class.name} new uri.class.name"
    else
      break
    end
  end


  if response.code == '200'
    puts "#{response.code} #{response.message}"
    puts "  content_type: #{response.content_type}, content_length: #{response.content_length}"

    text = response.body.to_s
    text = text.force_encoding( Encoding::UTF_8 )

    data = JSON.parse( text )

    File.open( dest, "w:utf-8" ) do |f|
      f.write( JSON.pretty_generate( data ) )
    end
  else
    puts "!! error:"
    puts "#{response.code} #{response.message}"
    exit 1
  end
end


def copy_image( src, dest,
                 dump_headers: false )
  uri = URI.parse( src )

  http = Net::HTTP.new( uri.host, uri.port )

  puts "[debug] GET #{uri.request_uri} uri=#{uri}"

  headers = { 'User-Agent' => "ruby v#{RUBY_VERSION}" }

  request = Net::HTTP::Get.new( uri.request_uri, headers )
  if uri.instance_of? URI::HTTPS
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  response   = http.request( request )

  if response.code == '200'
    puts "#{response.code} #{response.message}"

    content_type   = response.content_type
    content_length = response.content_length
    puts "  content_type: #{content_type}, content_length: #{content_length}"

    if dump_headers   ## for debugging dump headers
      headers = response.each_header.to_h
      puts "htttp respone headers:"
      pp headers
    end


    format = if content_type =~ %r{image/jpeg}i
                'jpg'
             elsif content_type =~ %r{image/png}i
                'png'
              elsif content_type =~ %r{image/gif}i
                'gif'
              elsif content_type =~ %r{image/svg}i
                'svg'
             else
              puts "!! error:"
              puts " unknown image format content type: >#{content_type}<"
              exit 1
            end

    ##   make sure path exits - autocreate dirs
    ## make sure path exists
    dirname = File.dirname( "#{dest}.#{format}" )
    FileUtils.mkdir_p( dirname )  unless Dir.exist?( dirname )

    if format == 'svg'
      ## save as text  (note: assume utf-8 encoding for now)
      text = response.body.to_s
      text = text.force_encoding( Encoding::UTF_8 )

      File.open( "#{dest}.svg", 'w:utf-8' ) do |f|
        f.write( text )
      end
    else
      ## save as binary
      File.open( "#{dest}.#{format}", 'wb' ) do |f|
        f.write( response.body )
      end
    end
  else
    puts "!! error:"
    puts "#{response.code} #{response.message}"
    exit 1
  end
end




