use v6;

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

# vim:nospell
