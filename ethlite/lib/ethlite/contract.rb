  module Ethlite
      class ContractMethod

       def self.parse_abi( abi )
         ## convenience helper -  auto-convert to json if string passed in
         abi = JSON.parse( abi ) if abi.is_a?( String )

         name           = abi['name']
         constant       = !!abi['constant'] || abi['stateMutability']=='view'
         input_types    = abi['inputs']  ? abi['inputs'].map{|a| _parse_component_type( a ) } : []
         output_types   = abi['outputs'] ? abi['outputs'].map{|a| _parse_component_type( a ) } : []
         type           = abi['type'] || 'function'

         new( name, inputs: input_types,
                    outputs: output_types,
                    constant: constant,
                    type: type )
       end

       def self._parse_component_type( argument )
        if argument['type'] =~ /^tuple((\[[0-9]*\])*)/
          argument['components'] ? "(#{argument['components'].collect{ |c| _parse_component_type( c ) }.join(',')})#{$1}"
                                 : "()#{$1}"
        else
          argument['type']
        end
      end




        attr_reader :signature,
                    :name,
                    :signature_hash,
                    :input_types,
                    :output_types,
                    :constant

        def initialize( name, inputs:,
                              outputs:  [],
                              constant: true,
                              type:     'function' )
          @name         = name
          @constant     = constant
          @input_types  = inputs
          @output_types = outputs

          @signature      = Abi::Utils.function_signature( @name, @input_types )
          @signature_hash = Abi::Utils.signature_hash( @signature, type=='event' ? 64 : 8)
        end

        def do_call( rpc, contract_address, args )
          data = '0x' + @signature_hash + Abi::Utils.encode_hex(
                                           Abi::AbiCoder.encode_abi(@input_types, args) )

          method = 'eth_call'
          params = [{ to:   contract_address,
                      data: data},
                    'latest']
          response = rpc.request( method, params )


          puts "response:"
          pp response

          string_data = [Abi::Utils.remove_0x_head(response)].pack('H*')
          return nil if string_data.empty?

          result = Abi::AbiCoder.decode_abi( @output_types, string_data )
          puts
          puts "result decode_abi:"
          pp result


          result.length==1 ? result.first : result
        end

      end  # class ContractMethod
end  # module Ethlite

