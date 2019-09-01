NAME
====

Channel::Pauseable - blah blah blah

SYNOPSIS
========

```perl6
use Channel::Pauseable;

my $channel = Channel::Pauseable.new;

$channel.send: ...;

$channel.pause;
$channel.resume;
```

DESCRIPTION
===========

Channel::Pauseable is a [Channel](Channel) which can be paused and resumed.

It also offers the ability to automatically collect from [Supply](Supply)s or [Tappable](Tappable)s. And can be tapped much like a [Supply](Supply).

METHODS
=======

See [Channel](Channel) for methods inherited from there. 

new(:$source,:$paused)
----------------------

$source is optional and can be either a [Supply](Supply) or a [Tappable](Tappable). Automatically taps the $source and feeds it into the channel.

$paused is a Boolean and defaults to False. It determines the initial state of the Channel.

pause()
-------

Pause output of the Channel. This method will throw an exception if Channel is already paused.

resume()
--------

Resume output of the Channel. This method will throw an exception if Channel isn't paused.

is-paused
---------

True if Channel is paused.

poll()
------

This is the same as per a normal [Channel](Channel) but will always return Nil whilst the channel is paused.

tap(Tappable $source)
---------------------

tap(Supply $source)
-------------------

These methods tap the given $source and feeds it into the channel.

tap(&emit,:&done,:&quit,:&tap)
------------------------------

This taps the channel as if it was a (live) [Supply](Supply). See [Supply/tap](Supply/tap) for details.

Supply
------

Returns a live Supply that is supplied by this channel.

AUTHOR
======

Timothy Hinchcliffe <gitprojects.qm@spidererrol.co.uk>

COPYRIGHT AND LICENSE
=====================

Copyright 2019 Timothy Hinchcliffe

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

