class CollectionsOpenSeaLinter

  attr_reader :warns

  def lint( dir: '.', exclude: [] )
    @warns       = []

    exclude_dirs = %w[
                     sandbox
                     tmp
                     i
                   ]
    exclude_dirs += exclude   ## add (optinal) user excludes


    each_dir( "#{dir}/*", exclude: exclude_dirs ) do |dir|

       config_path = "#{dir}/collection.yml"
       if File.exist?( config_path )
          puts "==> #{dir}:"
          config = read_yaml( config_path )
          pp config

          config_slug   = config['slug']
          config_format = config['format']
          config_count  = config['count']

         config_opensea = config['opensea']
         if config_opensea
            puts "OK  opensea @ #{config_opensea}"

            ## auto-sync check via online opensea api call/request?
              ####
              #  check for matching contracts
              #   via opensea api

            raw = Opensea.collection(  config_opensea )

            ## note: simplify result
            ##  remove nested 'collection' level
            data = raw['collection']
            data_contracts = data['primary_asset_contracts']
            ## pp data_contracts

            puts "  #{data_contracts.size} contract(s)"
            if data_contracts.size > 0
              address = data_contracts[0]['address']
              pp address
              ## e.g. {"address"=>"0xe4cfae3aa41115cb94cff39bb5dbae8bd0ea9d41"

              config_address    = (config['token']||{})['contract'] || ''
              if config_address.is_a?( Integer )
                 puts "!! ERROR - artbase config - token.contract is a number, string expected:"
                 pp config_address
                 exit 1
              end

              if address != config_address.downcase
                puts "!! ERROR - contracts do NOT match:"
                puts ">#{address}<   @ opensea"
                puts ">#{config_address}<   @ token.contract artbase config"
                exit 1
              else
                puts "OK - BINGO!  (token) contracts match"
              end
            else
              ## assume openstore
              config_token_base = config['token_base'] || ''
              if ['opensea', 'openstore@opensea'].include?( config_token_base.downcase )
                puts "OK - BINGO!  (token) contracts match"
              else
                  puts "!! ERROR - contracts do NOT match:"
                  puts ">OPENSTORE<   @ opensea"
                  puts ">#{config_token_base}<   @ token_base artbase config"
                  exit 1
              end
            end

         else
            puts "!! opensea @ ???"
            @warns << "opensea slug missing for collection >#{dir}<"
         end
       else
          puts "!! WARN - no config found for dir >#{dir}<"
          @warns << "no config found for dir >#{dir}<"
       end
    end
  end  # method lint


end  # class CollectionsOpenSeaLinter
