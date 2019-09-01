#!/usr/bin/env perl6

my $supply = Supply.interval(2);
$supply.tap(-> $v { say "First $v" });
sleep 6;
$supply.tap(-> $v { say "Second $v"});
sleep 10;
