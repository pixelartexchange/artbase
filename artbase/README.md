# artbase - zero-config server; (auto-)downloads & serves pre-configured pixel art collections "out-of-the-box"; incl. 2x/4x/8x zoom for bigger image sizes and more; xcopy binaries for easy installation



## Build & Run From Source


Use

```
$ go build artbase.go
```

to get a x-copy zero-config binary for your operation system / architecture.
To run use:

```
$ artbase
```

This will start-up a (web) server (listening on port 8080)
that will (auto-)download on demand pre-configured
collections to your working directory and use the "cached"
version the next time.

Pre-configured pixel art collections include:

- [punks (24x24)](https://github.com/cryptopunksnotdead/awesome-24px/blob/master/collection/punks.png)
- [morepunks (24x24)](https://github.com/cryptopunksnotdead/awesome-24px/blob/master/collection/morepunks.png)
- [coolcats (24x24)](https://github.com/cryptopunksnotdead/awesome-24px/blob/master/collection/coolcats.png)
- And more


(Web) Services


To get images, use `/:name/:id`

Example:
`/punks/0`, `/punks/1`, `/punks/2`, ...

Note: The default image size is the default
(minimum) size of the collection e.g. 24x24 for punks, morepunks,
coolcats and so on.
Use the z (zoom) parameter to upsize.

Try 2x:
`/punks/0?z=2`, `/punks/1?z=2`, `/punks/2?z=2`, ...

Try 8x:
`/punks/0?z=8`, `/punks/1?z=8`, `/punks/2?z=8`, ... And so on.





## License

The `artbase` sources & binaries are dedicated to the public domain.
Use it as you please with no restrictions whatsoever.


## Questions? Comments?

Post them on the [CryptoPunksDev reddit](https://old.reddit.com/r/CryptoPunksDev). Thanks.

