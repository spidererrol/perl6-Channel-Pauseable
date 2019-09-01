#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Channel::Pauseable;

my $supply = Supply.interval(1);

my $channel = Channel::Pauseable.new(source=>$supply,:paused);
$channel.resume;

Promise.in(3).then({ say "pause"; $channel.pause });
Promise.in(5).then({ say "resume"; $channel.resume });

my $end = Promise.in(10);
$end.then({ say "Stopping!"; $supply.done });

$channel.tap: -> $i { say "A:$i" };
my $b = $channel.tap: -> $i { say "B:$i" };

Promise.in(7).then( {$b.close });

await $end;
