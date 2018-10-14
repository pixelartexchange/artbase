# encoding: utf-8


class CsvJson

###################################
## add simple logger with debug flag/switch
#
#  use Parser.debug = true   # to turn on
#
#  todo/fix: use logutils instead of std logger - why? why not?

def self.build_logger()
  l = Logger.new( STDOUT )
  l.level = :info    ## set to :info on start; note: is 0 (debug) by default
  l
end
def self.logger() @@logger ||= build_logger; end
def logger()  self.class.logger; end




def self.parse( data, &block )
  csv = new( data )

  if block_given?
    csv.each( &block )  ## note: caller (responsible) must close file!!! - add autoclose - why? why not?
  else  # slurp contents, if no block is given
    csv.read            ## note: caller (responsible) must close file!!! - add autoclose - why? why not?
  end
end # method self.parse



def initialize( data )
  if data.is_a?( String )
    @input = data   # note: just needs each for each_line
  else  ## assume io
    @input = data
  end
end



include Enumerable

def each( &block )
  if block_given?
    @input.each_line do |line|

      logger.debug  "line:"             if logger.debug?
      logger.debug line.pretty_inspect  if logger.debug?


      ##  note: chomp('') if is an empty string,
      ##    it will remove all trailing newlines from the string.
      ##    use line.sub(/[\n\r]*$/, '') or similar instead - why? why not?
      line = line.chomp( '' )
      line = line.strip         ## strip leading and trailing whitespaces (space/tab) too
      logger.debug line.pretty_inspect    if logger.debug?

      if line.empty?             ## skip blank lines
        logger.debug "skip blank line"    if logger.debug?
        next
      end

      if line.start_with?( "#" )  ## skip comment lines
        logger.debug "skip comment line"   if logger.debug?
        next
      end

      ## note: auto-wrap in array e.g. with []
      json = JSON.parse( "[#{line}]" )
      logger.debug json.pretty_inspect   if logger.debug?
      block.call( json )
    end
  else
     to_enum
  end
end # method each

def read() to_a; end # method read

end # class CsvJson
