##
#  to run use
#     ruby -I ./lib -I ./test test/test_contract.rb


require 'helper'



class TestDigest < MiniTest::Test

  KECCAK256_TESTS = [
   ['',                'c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470'],
   ['testing',         '5f16f4c7f149ac4f9510d9cf8cf384038ad348b3bcdc01915f95de12df9d1b02'],
   ['Hello, Cryptos!', '2cf14baa817e931f5cc2dcb63c889619d6b7ae0794fc2223ebadf8e672c776f5'],
 ]

 SHA3_256_TESTS = [
   ['',                'a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a'],
   ['Hello, Cryptos!', '7dddf4bc9b86352b67e8823e5010ddbd2a90a854469e2517992ca7ca89e5bd58'],
 ]


  def test_keccak256
    KECCAK256_TESTS.each do |item|
      assert_equal item[1], _keccak256( item[0] )
    end
  end

  def test_sha3_256
    SHA3_256_TESTS.each do |item|
      assert_equal item[1], _sha3_256( item[0] )
    end
  end

######
# (private) helpers

def _keccak256( str )
  ## note: force string encoding to binary (via #b) !!!
  Digest::KeccakLite.new( 256 ).hexdigest( str.b )
end

def _sha3_256( str )
  ## note: force string encoding to binary (via #b) !!!
  Digest::SHA3Lite.new( 256 ).hexdigest( str.b )
end

end   # TestDigest

