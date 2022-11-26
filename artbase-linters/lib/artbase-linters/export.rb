class CollectionsExporter

attr_reader :warns

def initialize( base_url: )
  @base_url    = base_url
  @warns       = []
end



## change cache_dir to outdir or such - why? why not?
def export( cache_dir,
             dir: '.', exclude: [] )
  @warns       = []


  slugs = []   ## collect opensea slugs for summary

  exclude_dirs = %w[
                   sandbox
                   tmp
                   i
                 ]
  exclude_dirs += exclude   ## add (optinal) user excludes



  each_dir( "#{dir}/*", exclude: exclude_dirs ) do |collection_dir|

     config_path = "#{collection_dir}/collection.yml"
     if File.exist?( config_path )
        puts "==> #{collection_dir}:"
        config = read_yaml( config_path )
        pp config

        config_slug   = config['slug']
        config_format = config['format']
        config_count  = config['count']



       ## check/add some links
       config_opensea = config['opensea']
       if config_opensea

         ## add self link
         config['self_url'] = "#{@base_url}/#{File.basename(collection_dir)}/collection.yml"

         strip_path = "#{dir}/i/#{config_slug}-strip.png"
         if File.exist?( strip_path )
            config['strip_url'] = "#{@base_url}/i/#{config_slug}-strip.png"
         else
            puts "!! preview strip missing - >#{strip_path}<"
            @warns << "teaser / preview strip missing for collection >#{collection_dir}< - >#{strip_path}<"
         end

          puts "OK  opensea @ #{config_opensea}"
          slugs << config_opensea
          ###
          ##  export / write out as json for now - why? why not?
          write_json( "#{cache_dir}/#{config_opensea}.json", config )
       else
          puts "!! opensea @ ???"
          @warns << "opensea slug missing for collection >#{collection_dir}<"
       end
     else
        puts "!! WARN - no config found for dir >#{collection_dir}<"
        @warns << "no config found for dir >#{collection_dir}<"
     end
  end


  puts
  puts "  #{slugs.size} opensea slug(s):"
  pp slugs
  puts

end  # method export


end  # class LintCollectionsReport

