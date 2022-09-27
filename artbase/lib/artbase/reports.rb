



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




class LintCollectionsReport

attr_reader :warns, :collections


def initialize( base_url: )
  @base_url    = base_url
  @warns       = []
  @collections = []
end


def build( base_dir='.', exclude: [] )
  @warns       = []
  @collections = []

  buf = String.new('')

  exclude_dirs = %w[
                   sandbox
                   tmp
                   i
                 ]
  exclude_dirs += exclude   ## add (optinal) user excludes



  each_dir( "#{base_dir}/*", exclude: exclude_dirs ) do |dir|

     config_path = "#{dir}/collection.yml"
     if File.exist?( config_path )
        puts "==> #{dir}:"
        config = read_yaml( config_path )
        pp config

        config_slug   = config['slug']
        config_format = config['format']
        config_count  = config['count']

        @collections << [
           config_slug,
           config_format,
           config_count.to_s,
           "#{@base_url}/#{File.basename(dir)}/collection.yml"
        ]

        buf << "## #{config_format}  #{config_slug} (in #{dir}) - #{config_count} max.\n\n"


        strip_path = "#{base_dir}/i/#{config_slug}-strip.png"
        if File.exist?( strip_path )
           buf << "![](i/#{config_slug}-strip.png)\n\n"
        else
           buf << "!! preview strip missing\n\n"
           @warns << "teaser / preview strip missing for collection >#{dir}<"
        end

        token_dir = "#{dir}/token"
        if Dir.exist?( token_dir )
           count = Dir.glob( "#{token_dir}/*.json" ).length
           puts "   #{count} in /token"

           if count != config_count
             buf << "!! "
           else
             buf << "OK "
           end
           buf <<   "  #{count} of #{config_count} in /token<br>\n"
        end

        format_dir = "#{dir}/#{config_format}"
        if Dir.exist?( format_dir )
          count = Dir.glob( "#{format_dir}/*.png" ).length
          puts "   #{count} in /#{config_format}"

          if count != config_count
             buf << "!! "
           else
             buf << "OK "
           end
           buf <<   "  #{count} of #{config_count} in /#{config_format}<br>\n"
        end

       ## check/add some links
       config_opensea = config['opensea']
       if config_opensea
          buf << "OK  opensea @ [#{config_opensea}](https://opensea.io/collection/#{config_opensea})<br>\n"
       else
          buf << "!! opensea @ ???<br>\n"
          @warns << "opensea slug missing for collection >#{dir}<"
       end
       buf << "\n\n"

       buf << "```\n"
       buf << config.pretty_inspect
       buf << "```\n\n"

     else
        puts "!! WARN - no config found for dir >#{dir}<"
        @warns << "no config found for dir >#{dir}<"
     end
  end
  buf
end  # method build


def export_collections
  ##
  #   note sort by format
  #      smaller first e.g. 24x24 to 100x100 etc.

  recs = @collections.sort do |l,r|
                                  l_px = _parse_px( l[1] )
                                  r_px = _parse_px( r[1] )
                                  res  = l_px <=> r_px
                                  res  = l[0] <=> r[0]  if res == 0
                                  res
                              end

  headers = ['slug', 'format', 'count', 'config']

  buf = String.new('')
  buf << headers.join( ', ' )
  buf << "\n"
  recs.each do |values|
    buf << values.join( ', ' )
    buf << "\n"
  end
  buf
end  # method export_collections


def _parse_px( str )
  str.scan( /\d+/ )[0].to_i
end

end  # class LintCollectionsReport



class LintContractsReport

attr_reader :warns, :contracts


def initialize
  @warns     = []
  @contracts = []
end


def build( base_dir='.', exclude: [] )
  @warns     = []
  @contracts = []

  buf = String.new('')

  exclude_dirs = %w[
                   sandbox
                   tmp
                   i
                 ]
  exclude_dirs += exclude   ## add (optinal) user excludes



  each_dir( "#{base_dir}/*", exclude: exclude_dirs ) do |dir|

     config_path = "#{dir}/collection.yml"
     if File.exist?( config_path )
        puts "==> #{dir}:"
        config = read_yaml( config_path )
        pp config

        config_slug   = config['slug']
        config_format = config['format']
        config_count  = config['count']

        config_opensea = config['opensea']

        config_token  = config['token']

        if config_token
          config_token_contract = config_token['contract']

          if config_token_contract.is_a?( Integer )
            ## convert decimal number back to hexstring
            ##   note: assumes 40 hexstring (ethereum address) for now
            config_token_contract =  '0x%040x' % config_token_contract
          end

          config_token_name     = config_token['name']
          config_token_symbol   = config_token['symbol']
          config_token_created  = config_token['created']

          @contracts << [
             config_format,
             config_token_name,
             config_token_symbol,
             config_count.to_s,        ## note: make sure all values are always strings
             config_token_created,
             config_token_contract,
             config_slug,
             config_opensea,
          ]

          buf << "## #{config_format}  #{config_token_name} (#{config_token_symbol}) - #{config_count} max.\n\n"
          strip_path = "#{base_dir}/i/#{config_slug}-strip.png"
          if File.exist?( strip_path )
             buf << "![](i/#{config_slug}-strip.png)\n\n"
          else
             buf << "!! preview strip missing\n\n"
             @warns << "teaser / preview strip missing for collection >#{dir}<"
          end

          buf << "created: #{config_token_created} <br>\n"

          ## note: for now assumes all ethereum contracts by default
          etherscan_url = "https://etherscan.io/address/#{config_token_contract}"
          buf << "etherscan @ [#{config_token_contract}](#{etherscan_url})\n\n"

          ## check/add some links
          ## check: always holds/assume 1:1 mapping of contract to
          ##           opensea collection - why? why not?
          if config_opensea
            buf << "OK  opensea @ [#{config_opensea}](https://opensea.io/collection/#{config_opensea})<br>\n"
          else
            buf << "!! opensea @ ???<br>\n"
            @warns << "opensea slug missing for collection >#{dir}<"
          end
          buf << "\n\n"
        else
          puts "!! WARN - no token / contract found for dir >#{dir}<"
          @warns << "no token / contract found for dir >#{dir}<"
        end
     else
        puts "!! WARN - no config found for dir >#{dir}<"
        @warns << "no config found for dir >#{dir}<"
     end
  end
  buf
end  # method build


def export_contracts
  ##
  #   note sort by created date

=begin
  recs = @collections.sort do |l,r|
                                  l_px = _parse_px( l[1] )
                                  r_px = _parse_px( r[1] )
                                  res  = l_px <=> r_px
                                  res  = l[0] <=> r[0]  if res == 0
                                  res
                              end
=end
  recs = @contracts

  headers = [
     'format',
     'token_name',
     'token_symbol',
      'count',
      'token_created',
      'token_contract',
      'artbase_slug',
      'opensea_slug',
  ]

  buf = String.new('')
  buf << headers.join( ', ' )
  buf << "\n"
  recs.each do |values|
    buf << values.join( ', ' )
    buf << "\n"
  end
  buf
end  # method export_contracts

end  # class LintContractsReport

