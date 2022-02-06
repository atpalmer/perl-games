#!/usr/bin/env perl

use strict;
use warnings;

use Algorithm::Permute;

my $filename = shift @ARGV or die 'need arg: filename';
my $input = shift @ARGV or die 'need arg: input';

open my $f, '<', $filename or die;
my %words = map { chomp; $_ => 1 } <$f>;
close $f;

chomp $input;
my @chars = split '', $input;

my %seen;

Algorithm::Permute::permute {
    my $s = join('', @chars);
    if ($words{$s}) {
        print "$s\n" if not exists $seen{$s};
        $seen{$s}++;
    }
} @chars;

