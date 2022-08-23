require 'cocos'


(0..9999).each do |id|
   res = wget( "https://live---metadata-5covpqijaa-uc.a.run.app/metadata/#{id}" )

   if res.status.ok?
      ## save metadata - pretty print/reformat json
      write_json( "./tmp/#{id}.json", res.json )
   else
      puts "!! ERROR: failed to download metadata; sorry - #{res.status.code} #{res.status.message}"
      exit 1
   end
end
