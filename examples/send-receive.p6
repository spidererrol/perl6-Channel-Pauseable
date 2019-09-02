#!/usr/bin/env perl6

use v6;
use Channel::Pauseable;

#my $channel = Channel.new; # This works. The pause & resume will silently fail (exception gets eaten by the Promise).
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
until $channel.closed {
    say $channel.receive;
    CATCH { when X::Channel::ReceiveOnClosed { say "ReceivedOnClosed exception"; } }
}
say "Finished";

# vim:nospell
