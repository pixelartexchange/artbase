


## Usage

Let's try the Etherbears collection ( max.):

``` ruby
CHROME_PATH = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'

OpenSea::Puppeteer.chrome_path = CHROME_PATH


# step 1: download assets metadata (in batches of 20)
#           (auto-)saved to /etherbears/opensea/*.json
OpenSea::Puppeteer.download_assets( 'etherbears' )

# step 2: "unbundle" the batches to "standard" one-by-one metadata token files
#            (auto-)saved to /etherbears/token/*.json
OpenSea.convert( 'etherbears' )
```


