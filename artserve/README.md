#  Artserve


artserve - serve up single-file SQLite artbase dbs to query metadata and images with SQL and more


* home  :: [github.com/pixelartexchange/artbase](https://github.com/pixelartexchange/artbase)
* bugs  :: [github.com/pixelartexchange/artbase/issues](https://github.com/pixelartexchange/artbase/issues)
* gem   :: [rubygems.org/gems/artserve](https://rubygems.org/gems/artserve)
* rdoc  :: [rubydoc.info/gems/artserve](http://rubydoc.info/gems/artserve)



## Command-Line Tool

Use the command line tool named - surprise, surpirse - `artserve`
to run a zero-config / out-of-the-box artbase server that lets
you query entire collections in single sqlite database (metadata & images) with a "serverless" web page.
Type:

    $ artserve        # defaults to ./artbase.db

That will start-up a (local loopback) web server  running on port 3000.
Open-up up the index page in your browser to get started e.g. <http://localhost:3000/>.

That's it.



**`artbase.db` Options**

If you pass in a directory to artserve
the machinery will look for an `artbase.db` in the directory e.g.

    $ artserve moonbirds    # defaults to ./moonbirds/artbase.db
    $ artserve goblintown   # defaults to ./goblintown/artbase.db
    # ...

If you pass in a file to artserve
the machinery will use the bespoke name & path to look for the sqlite database e.g.

    $ artserve punkbase.db
    $ artserve moonbirdbase.db
    # ...




## Install

Just install the gem:

    $ gem install artserve



## License

The scripts are dedicated to the public domain.
Use it as you please with no restrictions whatsoever.


## Questions? Comments?


Post them on the [D.I.Y. Punk (Pixel) Art reddit](https://old.reddit.com/r/DIYPunkArt). Thanks.

