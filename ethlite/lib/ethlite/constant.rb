
module Ethlite
  module Constant

    BYTE_EMPTY = "".freeze
    BYTE_ZERO  = "\x00".freeze
    BYTE_ONE   = "\x01".freeze

    TT32   = 2**32
    TT40   = 2**40
    TT160  = 2**160
    TT256  = 2**256
    TT64M1 = 2**64 - 1

    UINT_MAX = 2**256 - 1
    UINT_MIN = 0
    INT_MAX  = 2**255 - 1
    INT_MIN  = -2**255

    HASH_ZERO = ("\x00"*32).freeze


    PUBKEY_ZERO = ("\x00"*32).freeze
    PRIVKEY_ZERO = ("\x00"*32).freeze
    PRIVKEY_ZERO_HEX = ('0'*64).freeze

    CONTRACT_CODE_SIZE_LIMIT = 0x6000


=begin
   # The RLP short length limit.
    SHORT_LENGTH_LIMIT = 56.freeze

    # The RLP long length limit.
    LONG_LENGTH_LIMIT = (256 ** 8).freeze

    # The RLP primitive type offset.
    PRIMITIVE_PREFIX_OFFSET = 0x80.freeze

    # The RLP array type offset.
    LIST_PREFIX_OFFSET = 0xc0.freeze

    # The binary encoding is ASCII (8-bit).
    BINARY_ENCODING = "ASCII-8BIT".freeze

    # Infinity as constant for convenience.
    INFINITY = (1.0 / 0.0).freeze

=end
  end  # module Constant
end  # module Ethlite
