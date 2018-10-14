# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_parser.rb


require 'helper'

class TestParser < MiniTest::Test


def parser
  CsvJson
end


def test_parse
  records = [[1, "John", "12 Totem Rd. Aspen",             true],
             [2, "Bob",  nil,                              false],
             [3, "Sue",  "Bigsby, 345 Carnival, WA 23009", false]]


  assert_equal records, parser.parse( <<TXT )
  # hello world

  1,"John","12 Totem Rd. Aspen",true
  2,"Bob",null,false
  3,"Sue","Bigsby, 345 Carnival, WA 23009",false
TXT
end


end # class TestParser
