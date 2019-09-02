#!/usr/bin/env perl6

use v6;
use Channel::Pauseable;

my $channel = Channel::Pauseable.new;

my $supply = Supply.interval(1);

my $tap = $channel.tap($supply);

Promise.in(10).then({ say "Stopping!"; $tap.close });

for $channel.list -> $r {
    say $r;
}

# vim:nospell
