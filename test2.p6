#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Channel::Pauseable;

my $channel = Channel::Pauseable.new;
my @senders = (^10).map: -> $r {
    start {
        sleep $r;
        say "Send: $r";
        $channel.send($r);
    }
}
Promise.in(3).then({ $channel.pause });
Promise.in(8).then({ $channel.resume });
start {
    await @senders;
    $channel.close;
}
for $channel.list -> $r {
    say $r;
}

