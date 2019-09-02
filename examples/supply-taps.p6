#!/usr/bin/env perl6

use v6;
use Channel::Pauseable;

my $channel = Channel::Pauseable.new;

my $supply = Supply.interval(1);

my $tap = $channel.tap($supply);

Promise.in(3).then({ say "pause"; $channel.pause });
Promise.in(7).then({ say "resume"; $channel.resume });

my $end = Promise.in(10);
$end.then({ say "Stopping!"; $tap.close });

$channel.tap: -> $i { say "A:$i" };
my $b = $channel.tap: -> $i { say "B:$i" };

Promise.in(5).then( {$b.close });

await $end;

# vim:nospell
