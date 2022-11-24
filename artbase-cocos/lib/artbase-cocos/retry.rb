
## for more ideas on retry
##    see https://github.com/ooyala/retries


## todo/check:  use a different name than retry - why? why not?
def retry_on_error( max_tries: 3, &block )
  errors = []
  delay = 3  ## 3 secs

    begin
      block.call

    ## note: add more exception here (separated by comma) like
    ##         rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED => e
    rescue Net::ReadTimeout => e
        ##  (re)raise (use raise with arguments or such - why? why not?)
        raise    if errors.size >= max_tries

        ## ReadTimeout, a subclass of Timeout::Error, is raised if a chunk of the response cannot be read within the read_timeout.
        ##                subclass of RuntimeError
        ##                subclass of StandardError
        ##                subclass of Exception
        puts "!! ERROR - #{e}:"
        pp e

        errors << e

        puts
        puts "==> retrying (count=#{errors.size}, max_tries=#{max_tries}) in #{delay} sec(s)..."
        sleep( delay )
        retry
    end

  if errors.size > 0
    puts "  #{errors.size} retry attempt(s) on error(s):"
    pp errors
  end

  errors
end
