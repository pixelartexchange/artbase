#  Recursive Length Prefix (RLP) Lite


rlp-lite - light-weight machinery to serialize / deserialze via rlp (recursive length prefix)



* home  :: [github.com/pixelartexchange/artbase](https://github.com/pixelartexchange/artbase)
* bugs  :: [github.com/pixelartexchange/artbase/issues](https://github.com/pixelartexchange/artbase/issues)
* gem   :: [rubygems.org/gems/rlp-lite](https://rubygems.org/gems/rlp-lite)
* rdoc  :: [rubydoc.info/gems/rlp-lite](http://rubydoc.info/gems/rlp-lite)




## Usage


``` ruby
require 'rlp-lite'

######
## encode

list =  ['ruby', 'rlp', 255]

encoded = Rlp.encode( list )
#=> "\xCB\x84ruby\x83rlp\x81\xFF".b

#######
## decode

decoded = Rlp.decode( "\xCB\x84ruby\x83rlp\x81\xFF".b )
#=> ["ruby", "rlp", "\xFF".b]
```



Note:  All integers get returned (decoded) as big integers in binary buffers (that is, string with binary "ASCII-8BIT" encoding)
e.g. `"\xFF".b` and not `255`.



More examples from the official ethereum rlp tests,
see [test/data/rlptest.json](test/data/rlptest.json).


``` ruby
######
# lists of lists
obj = [ [ [], [] ], [] ]
encoded = Rlp.encode( obj )
#=> "\xC4\xC2\xC0\xC0\xC0".b

decoded =  Rlp.decode( "\xC4\xC2\xC0\xC0\xC0".b )
#=> [[[], []], []]

# or using a hex string (not a binary buffer)
decoded =  Rlp.decode( "0xc4c2c0c0c0" )
#=> [[[], []], []]


#####
# dict(onary)
obj = [["key1", "val1"],
       ["key2", "val2"],
       ["key3", "val3"],
       ["key4", "val4"]]
encoded = Rlp.encode( obj )
#=> "\xEC\xCA\x84key1\x84val1\xCA\x84key2\x84val2\xCA\x84key3\x84val3\xCA\x84key4\x84val4".b

decoded = Rlp.decode( "\xEC\xCA\x84key1\x84val1\xCA\x84key2\x84val2\xCA\x84key3\x84val3\xCA\x84key4\x84val4".b )
#=> [["key1", "val1"], ["key2", "val2"], ["key3", "val3"], ["key4", "val4"]]

# or using a hex string (not a binary buffer)
decoded = Rlp.decode( "0xecca846b6579318476616c31ca846b6579328476616c32ca846b6579338476616c33ca846b6579348476616c34" )
#=> [["key1", "val1"], ["key2", "val2"], ["key3", "val3"], ["key4", "val4"]]
```


## License

The scripts are dedicated to the public domain.
Use it as you please with no restrictions whatsoever.


## Questions? Comments?


Post them on the [D.I.Y. Punk (Pixel) Art reddit](https://old.reddit.com/r/DIYPunkArt). Thanks.

