# Bi-temporal inventory

This stores the messages in a tamperproof bi-temporal database, which enables historical analysis of inventory data. I used to work with inventory management software, and something like this
would have been a godsend. Even with this basic functionality.

# How to play

Install [immudb](https://github.com/codenotary/immudb), [foreman](https://github.com/theforeman/foreman), [websocketd](https://github.com/joewalnes/websocketd), and `ruby` version 3.2.0

`rake spec` to run all the tests

`bundle install` for gem dependencies and `foreman start` starts the app.

## TODO

There's a lot of issues with this. In rough order of importance to effort ratio

### Immudb k/v is the wrong DB choice

I had to hack in timestamps for the k/v mode of immudb.

In a surprising move for a bi-temporal database, it doesn't include them by default in k/v histories. I started off sure they did and decided to go ahead anyway because I thought it'd be funny.

Would I use this in production? Absolutely not.  
Did working around this limitation teach me a lot? Not really.

But, it was fun to figure out.

If I'd had time (or wanted this to be something people actually used) I'd try porting [verter](https://github.com/tolitius/verter) to ruby, and make an adapter for activerecord.
You could run it along side any standard SQL db.

The other items on this list wouldn't be worth addressing until after this is done.

### General refactoring

Mainly thinking about the history functionality being in essentially a helper module.  
I could fix this if I had time, but I think it's a trickle down effect of the wrong DB choice.

After converting to verter-activerecord, I'd start with extracting models for store and model, and a mixin module for history concerns.

### App structure

It's awful and easy to fix, but this is working and I have stuff to do

### Failure recovery

Top of the list being the consumer/frontend crashing if it can't obtain a DB connection, and not
knowing how to re-obtain a connection.

### Test coverage

There's some test coverage, but the doing the rest wouldn't be worth it before changing databases

### Indexing

Somewhat addressed by storing permutations of key combinations to enable scanning using prefixes.  
But ugly as sin, and even more brittle.

### Caching

Every time you load a detail page, it re-queries for all history of that item.
I don't think this would be too hard to implement.

First off, segment cache entries by time resolution. We don't need to know the inventory model updates
for every second, but having one for every 10 minutes, or multiple for different resolutions of time
would drastically reduce DB load.

I could possibly implement it at the DB level instead with some clever indexing.
