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
$ artq 0x23581767a106ae21c074b2276d25e5c3e136a68b
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
$ artq 0xe21ebcd28d37a67757b9bc7b290f4c4928a430b1
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




## License

The scripts are dedicated to the public domain.
Use it as you please with no restrictions whatsoever.


## Questions? Comments?


Post them on the [D.I.Y. Punk (Pixel) Art reddit](https://old.reddit.com/r/DIYPunkArt). Thanks.

