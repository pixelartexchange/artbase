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

        ## add self link
        config['self_url'] = "#{@base_url}/#{File.basename(dir)}/collection.yml"

        strip_path = "#{dir}/i/#{config_slug}-strip.png"
        if File.exist?( strip_path )
           config['strip_url'] = "#{@base_url}/i/#{config_slug}-strip.png"
        else
           puts "!! preview strip missing"
           @warns << "teaser / preview strip missing for collection >#{dir}<"
        end


       ## check/add some links
       config_opensea = config['opensea']
       if config_opensea
          puts "OK  opensea @ #{config_opensea}"
          ###
          ##  export / write out as json for now - why? why not?
          write_json( "#{cache_dir}/#{config_opensea}.json", config )
       else
          puts "!! opensea @ ???"
          @warns << "opensea slug missing for collection >#{dir}<"
       end
     else
        puts "!! WARN - no config found for dir >#{dir}<"
        @warns << "no config found for dir >#{dir}<"
     end
  end
end  # method export


end  # class LintCollectionsReport

