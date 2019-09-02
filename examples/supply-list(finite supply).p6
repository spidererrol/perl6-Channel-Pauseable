#!/usr/bin/env perl6

use v6;
use Channel::Pauseable;

my $channel = Channel::Pauseable.new;

my $supply = Supply.interval(1).head(10);

$channel.tap($supply);

for $channel.list -> $r {
    say $r;
}
