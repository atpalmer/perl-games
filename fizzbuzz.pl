#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

sub try(&@) {
    my $code = \&{shift @_};
    my $text = shift;
    return $code->() ? $text : '';
}

sub or_default {
    my $textref = shift;
    my $default = shift;
    return length($$textref) ? $$textref : $default;
}

for (1..100) {
    my $fizz = try { $_ % 3 == 0 } "fizz";
    my $buzz = try { $_ % 5 == 0 } "buzz";
    my $fizzbuzz = bless \"$fizz$buzz";
    say $fizzbuzz->or_default($_);
}
