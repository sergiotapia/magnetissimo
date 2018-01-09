# Contrbution guide

This document is a Work in Progress, please [open an issue](https://github.com/sergiotapia/magnetissimo/issues/new) and tell us what you would expect to
see here.

## HOWTO

Basically, a sane rule to avoid bureaucracy **and** losing touch about what happens is:

* Is it a feature? If yes, then make a pull request
* IS it a quickfix? If yes, then post a patch / diff on an issue 
* Neither a feature or an issue? Open an issue and we'll see what's best

You can also contact us on Slack! See the README for more information.

## Crawlers

The crawlers live in `lib/magnetissimo/crawler/`. They all belong to a special supervisor that is located in the `crawler` directory as well. If you want
to track an unusual behaviour, it is recommended to comment out all of the lines that are not interesting and track the unusual behaviour in one crawler.
They all must comply to the `WebParser` behaviour.
