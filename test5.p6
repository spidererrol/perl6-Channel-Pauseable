#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Channel::Pauseable;

say "WARNING: This will never end!";

my $channel = Channel::Pauseable.new;

my $supply = Supply.interval(1);

$channel.tap($supply);

for $channel.list -> $r {
    say $r;
}
