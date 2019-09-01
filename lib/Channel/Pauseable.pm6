use v6.c;

=begin pod

=head1 NAME

Channel::Pauseable - blah blah blah

=head1 SYNOPSIS

=begin code :lang<perl6>

use Channel::Pauseable;

my $channel = Channel::Pauseable.new;

$channel.send: ...;

$channel.pause;
$channel.resume;

=end code

=head1 DESCRIPTION

Channel::Pauseable is a L<Channel> which can be paused and resumed.

It also offers the ability to automatically collect from L<Supply>s or L<Tappable>s. And can be tapped much like a L<Supply>.

=head1 METHODS

See L<Channel> for methods inherited from there. 

=head2 new(:$source,:$paused)

$source is optional and can be either a L<Supply> or a L<Tappable>. Automatically taps the $source and feeds it into the channel.

$paused is a Boolean and defaults to False. It determines the initial state of the Channel.

=head2 pause()

Pause output of the Channel. This method will throw an exception if Channel is already paused.

=head2 resume()

Resume output of the Channel. This method will throw an exception if Channel isn't paused.

=head2 is-paused

True if Channel is paused.

=head2 poll()

This is the same as per a normal L<Channel> but will always return Nil whilst the channel is paused.

=head2 tap(Tappable $source)
=head2 tap(Supply $source)

These methods tap the given $source and feeds it into the channel.

=head2 tap(&emit,:&done,:&quit,:&tap)

This taps the channel as if it was a (live) L<Supply>. See L<Supply/tap> for details.

=head2 Supply

Returns a live Supply that is supplied by this channel.

=end pod

sub debug($what) {
    #say $*THREAD.id ~ ": $what";
}

class Channel::Pauseable:ver<1.0.0>:auth<github:spidererrol> is Channel does Iterator does Iterable does Tappable {
    has Bool $.is-paused;
    has Promise $!unpaused;
    has SetHash $!source-taps;

    submethod BUILD(Bool :paused($!is-paused) = False) { $!source-taps.=new; $!unpaused = Promise.new if $!is-paused } 
    multi submethod TWEAK(Supply:D :$source) { self.tap($source) }
    multi submethod TWEAK(Tappable:D :$source) { self.tap($source) }
    multi submethod TWEAK(Bool :paused($)) { }

    method pause() {
        die "Already paused!" if $!is-paused;
        $!is-paused = True;
        $!unpaused = Promise.new();
    }
    method resume() {
        die "Not paused!" unless $!is-paused;
        $!is-paused = False;
        $!unpaused.keep;
    }

    method send(Channel::Pauseable:D: \item) {
        debug "S:" ~ item;
        nextsame;
    }

    method receive(Channel::Pauseable:D:) {
        $ = $!unpaused.result if $!is-paused;
        my $ret = callsame;
        $ = $!unpaused.result if $!is-paused;
        debug "R:$ret";
        return $ret;
    }

    method poll(Channel::Pauseable:D:) {
        return Nil if $!is-paused;
        my $ret = callsame;
        return $ret;
    }

    # The Channel iterator uses internals, this is a rewrite to use public methods which will obey pauses:
    method iterator() { self }

    method pull-one() {
        return IterationEnd if self.closed;
        return self.receive;
        CATCH {
            when X::Channel::ReceiveOnClosed { return IterationEnd }
        }
    }

    method close() {
        debug "close";
        nextsame;
    }

    method !untap(Tap:D $untap) {
        $!source-taps{$untap}--;
        debug "untap-source($untap)=" ~ $!source-taps.elems;
        self.close if $!source-taps.elems == 0;
    }

    method !source-tap($totap) {
        my $t;
        $totap.tap: -> $item { debug "==>$item"; self.send($item) }, done=>{ $t.close() }, tap=> -> $source-tap {
            $t = Tap.new({ $source-tap.close(); self!untap($t) });
            $!source-taps{$t}++;
        };
        debug "tap-source($t)";
        $t
    }
    multi method tap(Tappable:D $totap) {
        self!source-tap($totap);
    }
    multi method tap(Supply:D $totap) {
        self!source-tap($totap);
    }

    # Tappable:
    method live(-->True) {}
    method serial(Any:D:) { self.Supply.serial }
    method sane(Any:D:) { self.Supply.sane }
    multi method tap(Any:D: &emit,*%more) {
        self.Supply.tap(&emit,|%more);
    }
    # End Tappable

    has $!supply;

    method Supply {
        if ($!supply.defined) {
            return $!supply;
        }
        my $supplier = Supplier.new;
        start {
            until self.closed {
                my $thing = self.receive;
                debug "<==$thing";
                $supplier.emit($thing);
                CATCH {
                    when X::Channel::ReceiveOnClosed {}
                }
            }
        }
        return $!supply = $supplier.Supply;
    }
}

=begin pod

=head1 AUTHOR

Timothy Hinchcliffe <gitprojects.qm@spidererrol.co.uk>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 Timothy Hinchcliffe

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim:nospell
