

def counter_to_text( counter )

  counter = counter.to_a

  attribute_counter = counter[0]
  more_counter      = counter[1..-1]


  puts "Attribute Counts\n"
  trait_type, h = attribute_counter

  total = h[:by_type].values.reduce(0) { |sum,count| sum+count }


  types = h[:by_type]
  types = types.sort { |l,r| l[0]<=>r[0] }  ## sort by name

  puts "\n"
  puts "|Name|Total (%)|"
  puts "|--------|----------:|"

  types.each do |rec|
      name     = rec[0]
      count    = rec[1]
      percent =  Float(count*100)/Float(total)

      puts "| **#{name} Attributes** | #{count} (#{'%.2f' % percent}) |"
  end
  puts "\n"

  more_counter.each_with_index do |(trait_type, h),i|
    print " · "  if i > 0   ## add separator
    print "#{trait_type } (#{h[:by_type].size})"
  end
  puts "\n\n"



  more_counter.each do |trait_type, h|
    print "### #{trait_type } (#{h[:by_type].size}) - "
    print "∑Total #{h[:count]}/#{total}\n"

    puts "\n"
    puts "|Name|Total (%)|"
    puts "|--------|----------:|"

      types = h[:by_type]
      types = types.sort do |l,r|
                            # sort by 1) by count
                            #         2) by name a-z
                                  res = r[1] <=> l[1]
                                  res = l[0] <=> r[0]  if res == 0
                                  res
                         end  ## sort by count
      types.each do |rec|
         name     = rec[0]
         count    = rec[1]
         percent =  Float(count*100)/Float(total)

         puts "| **#{name}** | #{count} (#{'%.2f' % percent}) |"
      end
      puts "\n\n"
    end
end




def counter_to_csv( counter )

  puts "type, name, count"
  counter.each do |trait_type, h|
    puts "#{trait_type}, ∑ Total, #{h[:count]}"
    h[:by_type].each do |trait_value, count|
       puts "#{trait_type}, #{trait_value}, #{count}"
    end
  end
end



