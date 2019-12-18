# Redeliste [![Build Status](https://travis-ci.com/memowe/redeliste.svg?branch=master)](https://travis-ci.com/memowe/redeliste)

Eine Echtzeit-Multiuser-Redeliste.

![][screenshot]

[screenshot]: public/redeliste.png

## Dependencies

- [Perl][Perl] 5.20
- [Mojolicious][Mojo] 8.24

[Perl]: https://www.perl.org/get.html
[Mojo]: https://mojolicious.org/

## Install

    $ cpanm -n --installdeps .

Make sure to add a `redeliste.conf` file (use `redeliste.conf.sample` as an example).

## Run

    $ hypnotoad script/redeliste

## Author and License

Copyright (c) 2019 [Mirko Westermeier][mirko] ([\@memowe][mgh], [mirko@westermeier.de][mmail])

Released under the MIT (X11) license. See [LICENSE][mit] for details.

[mirko]: http://mirko.westermeier.de
[mgh]: https://github.com/memowe
[mmail]: mailto:mirko@westermeier.de
[mit]: LICENSE
