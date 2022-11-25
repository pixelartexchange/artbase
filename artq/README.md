#  ArtQ

artq - query (ethereum) blockchain contracts / services for (meta) data about art collections via json-rpc


* home  :: [github.com/pixelartexchange/artbase](https://github.com/pixelartexchange/artbase)
* bugs  :: [github.com/pixelartexchange/artbase/issues](https://github.com/pixelartexchange/artbase/issues)
* gem   :: [rubygems.org/gems/artq](https://rubygems.org/gems/artq)
* rdoc  :: [rubydoc.info/gems/artq](http://rubydoc.info/gems/artq)




## Usage


### Step 0:  Setup JSON RPC Client

The ArtQ command line tool
gets the eth node uri via the INFURA_URI enviroment variable / key for now.
Set the environment variable / key
depending on your operating system (OS) e.g.:

```
set INFURA_URI=https://mainnet.infura.io/v3/<YOUR_KEY_HERE>
```


### Query (Token) Collection Info

To use the artq command line tool pass in the art collection contract address in the hex (string) format.


#### Case No. 1 - "Off-Blockchain" Token Metadata

Let's try Moonbirds - an "off-blockchain" pixel art collection -
with the token contract / service at [0x23581767a106ae21c074b2276d25e5c3e136a68b](https://etherscan.io/address/0x23581767a106ae21c074b2276d25e5c3e136a68b):

```
$ artq 0x23581767a106ae21c074b2276d25e5c3e136a68b           # or
$ artq 0x23581767a106ae21c074b2276d25e5c3e136a68b info
```

resulting in:

```
name: >Moonbirds<
symbol: >MOONBIRD<
totalSupply: >10000<

tokenURIs 0..2:
  tokenId 0:
    https://live---metadata-5covpqijaa-uc.a.run.app/metadata/0
  tokenId 1:
    https://live---metadata-5covpqijaa-uc.a.run.app/metadata/1
  tokenId 2:
    https://live---metadata-5covpqijaa-uc.a.run.app/metadata/2
```

Note: By default the tokenURI method gets called / queried
for the first tokens (e.g. 0, 1, 2, etc.).

If you get a link back (e.g. starting with `https://` or `ipfs://`)
than the art collection is "off-blockchain" and
you MUST follow / request the link to get the token metadata.


For example if you request  <https://live---metadata-5covpqijaa-uc.a.run.app/metadata/0>
 you get back:

``` json
{"name":"#0",
 "image":"https://live---metadata-5covpqijaa-uc.a.run.app/images/0",
 "external_url":"https://moonbirds.xyz/",
 "attributes":[
  {"trait_type":"Eyes","value":"Angry"},
  {"trait_type":"Outerwear","value":"Hoodie Down"},
  {"trait_type":"Body","value":"Tabby"},
  {"trait_type":"Feathers","value":"Gray"},
  {"trait_type":"Background","value":"Green"},
  {"trait_type":"Beak","value":"Small"}],
 "x_debug":["orig:9650"]}
```



####  Case No. 2 - "On-Blockchain" Token Metadata (With Inline Image)



Let's try The Saudis - an "on-blockchain" pixel art collection -
with the token contract / service at [0xe21ebcd28d37a67757b9bc7b290f4c4928a430b1](https://etherscan.io/address/0xe21ebcd28d37a67757b9bc7b290f4c4928a430b1):

```
$ artq 0xe21ebcd28d37a67757b9bc7b290f4c4928a430b1       # or
$ artq 0xe21ebcd28d37a67757b9bc7b290f4c4928a430b1 info
```

resulting in:

```
name: >The Saudis<
symbol: >SAUD<
totalSupply: >5555<

tokenURIs 0..2:
  tokenId 0:
```
``` json
{"name":"The Saudis #0",
 "description":"Max Bidding",
 "image_data": "...",
 "external_url":"https://token.thesaudisnft.com/0",
 "attributes":
  [{"trait_type":"Head", "value":"Light 1"},
   {"trait_type":"Hair", "value":"Bald"},
   {"trait_type":"Facial Hair", "value":"Normal Brown Beard & Mustache"},
   {"trait_type":"Headwear", "value":"Haram Police Cap"},
   {"trait_type":"Eyewear", "value":"Regular Pixel Shades"},
   {"trait_type":"Mouthpiece", "value":"None"}]}
```

```
   tokenId 1:
```
``` json
{"name":"The Saudis #1",
 "description":"Max Bidding",
 "image_data":  "...",
 "external_url":"https://token.thesaudisnft.com/1",
 "attributes":
  [{"trait_type":"Head", "value":"Light 1"},
   {"trait_type":"Hair", "value":"Long Widow's Peak"},
   {"trait_type":"Facial Hair", "value":"Messy White Beard"},
   {"trait_type":"Headwear", "value":"Brown Shemagh & Agal"},
   {"trait_type":"Eyewear", "value":"Big Purple Shades"},
   {"trait_type":"Mouthpiece", "value":"None"}]}
```

```
  tokenId 2:
```
``` json
{"name":"The Saudis #2 🛢" ,
 "description":"Max Bidding",
 "image_data":  "...",
 "external_url":"https://token.thesaudisnft.com/2",
 "attributes":
  [{"trait_type":"Head", "value":"Dark 1"},
   {"trait_type":"Hair", "value":"Short Buzz Cut"},
   {"trait_type":"Facial Hair", "value":"Gradient Beard"},
   {"trait_type":"Headwear", "value":"Brown Shemagh & Agal"},
   {"trait_type":"Eyewear", "value":"Big Pixel Shades"},
   {"trait_type":"Mouthpiece", "value":"Shadowless Vape"}]}
```

Note:  The artq command-line tool "auto-magically"
decodes "on-blockchain"  metadata in the base64 format
and inline svg images in the base64 format get "cut" from the metadata and "pasted" decoded.  Example for tokenId 0, that is, The Saudis #0:

``` xml
<svg xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink" image-rendering="pixelated"
      height="336" width="336">
  <foreignObject x="0" y="0" width="336" height="336">
    <img xmlns="http://www.w3.org/1999/xhtml" height="336" width="336" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAJklEQVR42mNMbp32n4GGgHHUglELRi0YtWDUglELRi0YtWBoWAAAuD470bkESf4AAAAASUVORK5CYII="/>
  </foreignObject>
  <foreignObject x="0" y="0" width="336" height="336">
     <img xmlns="http://www.w3.org/1999/xhtml" height="336" width="336" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAtklEQVRIiWNgGAXDHjASoeY/JfoJKfh/e2MDTklV/waCZjARYziPlCZWBVB5fD7EawHc8C/PrhNSRr4FlBhOlAWUAhZiFK3fdYqBgYGBIdDNDEOMEMDlA5TUUzZ1G4OHkRiKAmxi2ABRPsCWVPElX2SAMw6gaZxigMsCnJlH1b+BJMuJCiJkQGzQwMDgSKYwgBw0xPqEJAtIDR4GBgqDiJjSlGgf4Eg5BOsDUlMRMRUUCqB5KgIAHCwuITa/cDMAAAAASUVORK5CYII=" />
  </foreignObject>
  <foreignObject x="0" y="0" width="336" height="336">
     <img xmlns="http://www.w3.org/1999/xhtml" height="336" width="336" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAaklEQVRIiWNgGAWjYBSMglEwBAAjPklnSZb/DAwMjDzCAgwbr7whywImItT8//L2Az4H4AUsRDqEoEGUWsDgLMnC8JSJFc6X/vebKhYwMiC5nlhDkQExcYAvIeBNJMRaADMI3TCChg8PAADd6xC7QG7FfAAAAABJRU5ErkJggg==" />
  </foreignObject>
  <foreignObject x="0" y="0" width="336" height="336">
     <img xmlns="http://www.w3.org/1999/xhtml" height="336" width="336" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAcElEQVRIie2SsQ3AIAwEnwzDCpTMyiguGQEvQ5okQoljTNL6KiSes3gAnAlhIdu/nNOCoxAx5WvNlcyet40+CmccA0XXZrbcaIXQyuMm5gFBqEGEKyGmvFwRMLzBrC6tIvU3nGKu1LWcxeU4juP8YQdbhhrmTahwzwAAAABJRU5ErkJggg==" />
  </foreignObject>
  <foreignObject x="0" y="0" width="336" height="336">
     <img xmlns="http://www.w3.org/1999/xhtml" height="336" width="336" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAATElEQVRIie2PwQoAIAhDXf//z+tQgYnWoVOwdxHm2NRMCPE/qBYkDQBfs1rpDuEk10SmV5QFPmh+k3lSfTv0UDAM7hNfGvVbkRDiZzpfrCH/gTYLqwAAAABJRU5ErkJggg==" />
  </foreignObject>
  <foreignObject x="0" y="0" width="336" height="336">
     <img xmlns="http://www.w3.org/1999/xhtml" height="336" width="336" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAJklEQVRIie3NMQEAAAjDMMC/52ECvlRA00nqs3m9AwAAAAAAAJy1C7oDLddyCRYAAAAASUVORK5CYII=" />
     </foreignObject>
  </svg>
```


#### Case No. 3 - "On-Blockchain" Layers (Incl. Metadata & Images)


Note:  Some "on-blockchain" pixel art collections
include all layers, that is, metadata and images
to compose / make-up "on-blockchain" token images "on-demand / on-the-fly" from "trait" building blocks from scratch.


If the contract uses / supports:

-  `traitDetails(uint256 _layerIndex, uint256 _traitIndex) returns (string _name, string _mimetype, bool _hide)` and
-  `traitData(uint256 _layerIndex, uint256 _traitIndex) returns string`

than you can "auto-magically" download all "on-blockchain" layers, that is, all metadata triplets by repeatedly calling `traitDetails` starting
with index `0/0`, `0/1`, ..., `1/0`, `1/1`, ... and so on e.g.

- `traitDetails( 0, 0 )`  => `["Rainbow Puke", "image/png", false]`
- `traitDetails( 0, 1 )`  => `["Bubble Gum", "image/png", false]`
- ...
- `traitDetails( 1, 0 )`  =>  `["Gold Chain", "image/png", false]`
- `traitDetails( 2, 1 )`  =>  `["Bowtie", "image/png", false]`
- ...


and all images (as binary blobs) by calling `traitData` e.g.

- `traitData( 0, 0 )`  => `"\x89PNG..."`
- `traitData( 0, 1 )`  => `"\x89PNG..."`
- ...

and so on.



Let's try Mad Camels - an "on-blockchain" pixel art collection -
with the token contract / service at [0xad8474ba5a7f6abc52708f171f57fefc5cdc8c1c](https://etherscan.io/address/0xad8474ba5a7f6abc52708f171f57fefc5cdc8c1c):


```
$ artq 0xad8474ba5a7f6abc52708f171f57fefc5cdc8c1c layers
```

resulting in a temp(orary) directory holding
all images:

```
/0_0.png
 0_1.png
 ...
 1_0.png
 1_1.png
 ...
```

![](i/madcamels-32x32.png)


and a  datafile with all metadata in the comma-separated values (csv) format, that is, `layers.csv` e.g:

```
index, name, type, hide
0/0, Rainbow Puke, image/png, false
0/1, Bubble Gum, image/png, false
0/2, Vape, image/png, false
0/3, None, image/png, false
0/4, Cigarette, image/png, false
0/5, Pipe, image/png, false
1/0, Gold Chain, image/png, false
1/1, Bowtie, image/png, false
1/2, Gold Necklace, image/png, false
1/3, None, image/png, false
2/0, Eye Patch, image/png, false
2/1, Nerd Glasses, image/png, false
2/2, Blue Beams, image/png, false
2/3, Purple Eye Shadow, image/png, false
2/4, Gold Glasses, image/png, false
2/5, Holographic, image/png, false
2/6, Clown Eyes Red, image/png, false
2/7, Clown Eyes Green, image/png, false
2/8, Eye Mask, image/png, false
2/9, Laser Eye, image/png, false
2/10, VR, image/png, false
2/11, 3D Glasses, image/png, false
2/12, None, image/png, false
2/13, Yellow Glasses, image/png, false
2/14, Cool Glasses, image/png, false
2/15, Purple Glasses, image/png, false
2/16, Green Glasses, image/png, false
3/0, Diamond, image/png, false
3/1, Silver, image/png, false
3/2, Gold, image/png, false
3/3, None, image/png, false
4/0, Crown, image/png, false
4/1, Wireless Earphone, image/png, false
4/2, Flower, image/png, false
4/3, Fez, image/png, false
4/4, Fire, image/png, false
4/5, Beanie, image/png, false
4/6, Headphone, image/png, false
4/7, White Shemagh, image/png, false
4/8, Red And White Shemagh, image/png, false
4/9, Angle Ring, image/png, false
4/10, Blue Mohawk, image/png, false
4/11, Sombrero, image/png, false
4/12, Red Mohawk, image/png, false
4/13, Blue Bandana, image/png, false
4/14, Viking, image/png, false
4/15, Pilot Helmet, image/png, false
4/16, Top Hat, image/png, false
4/17, Captain Hat, image/png, false
4/18, Thief Hat, image/png, false
4/19, Orange Cap, image/png, false
4/20, Pirate Bandana, image/png, false
4/21, Knitted Cap, image/png, false
4/22, Purple Cap, image/png, false
4/23, Black Cap, image/png, false
4/24, Pirate Hat, image/png, false
4/25, None, image/png, false
4/26, Red Cap, image/png, false
4/27, Cop Hat, image/png, false
4/28, Cowboy Hat, image/png, false
4/29, Fedora, image/png, false
5/0, Mole, image/png, false
5/1, Pimple, image/png, false
5/2, None, image/png, false
6/0, Gold, image/png, false
6/1, Cyborg, image/png, false
6/2, Skeleton, image/png, false
6/3, Female, image/png, false
6/4, Robot, image/png, false
6/5, Zombie, image/png, false
6/6, Alien, image/png, false
6/7, Default, image/png, false
7/0, Desert, image/png, false
7/1, Cream, image/png, false
7/2, Pink, image/png, false
7/3, Purple, image/png, false
7/4, Green, image/png, false
7/5, Blue, image/png, false
```


Try some more art collections with "on-blockchain" layers
such as
[Long Live Kevin](https://etherscan.io/address/0x8ae5523f76a5711fb6bdca1566df3f4707aec1c4),
[Aliens vs Punks](https://etherscan.io/address/0x2612c0375c47ee510a1663169288f2e9eb912947),
[Chi Chis](https://etherscan.io/address/0x2204a94f96d39df3b6bc0298cf068c8c82dc8d61),
[Chopper](https://etherscan.io/address/0x090c8034e6706994945049e0ede1bbdf21498e6e),
[Inverse Punks](https://etherscan.io/address/0xf3a1befc9643f94551c24a766afb87383ef64dd4),
[Marcs](https://etherscan.io/address/0xe9b91d537c3aa5a3fa87275fbd2e4feaaed69bd0),
[Phunk Ape Origins](https://etherscan.io/address/0x9b66d03fc1eee61a512341058e95f1a68dc3a913),
[Punkin Spicies](https://etherscan.io/address/0x34625ecaa75c0ea33733a05c584f4cf112c10b6b),
and many more.


Tip: For more art collections with "on-blockchain" layers see the [**Art Factory Sandbox »**](https://github.com/pixelartexchange/artfactory.sandbox)





###  Using the ArtQ Machinery in Your Own Scripts


Yes, you can. Let's try the (crypto) marcs:


``` ruby
require 'artq'

marcs_eth  = "0xe9b91d537c3aa5a3fa87275fbd2e4feaaed69bd0"

marcs = ArtQ::Contract.new( marcs_eth )

n = 0
m = 0
res = marcs.traitData( n, m )    ## note: return binary blob (for n,m-index)
pp res
#=> ["\x89PNG..."]

res = marcs.traitDetails( n, m )  ## note: returns tuple (name, mimetype, hide?)
pp res
#=> ["Zombie", "image/png", false]



## or with convenience download_layers helper
ArtQ.download_layers( marcs_eth, outdir: './marcs' )
```






## License

The scripts are dedicated to the public domain.
Use it as you please with no restrictions whatsoever.


## Questions? Comments?


Post them on the [D.I.Y. Punk (Pixel) Art reddit](https://old.reddit.com/r/DIYPunkArt). Thanks.

