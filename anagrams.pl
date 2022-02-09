#!/usr/bin/env perl

use strict;
use warnings;

use Algorithm::Permute;

my $input = shift @ARGV or die 'need arg: input';
my $filename = shift @ARGV;

my %words;

if (-f $filename) {
    open my $f, '<', $filename or die;
    %words = map { chomp; $_ => 1 } <$f>;
    close $f;
} else {
    warn 'warning: no dictionary file';
    tie %words, 'DummyDict';
}

chomp $input;
my @chars = split '', $input;

for (my $r = scalar @chars; $r > 2; --$r) {
    my $iter = Algorithm::Permute->new([@chars], $r);

    my %seen;
    while (my @curr = $iter->next) {
        my $s = join '', @curr;
        if (exists $words{$s} and not exists $seen{$s}) {
            $seen{$s}++;
        }
    }

    for (sort keys %seen) {
        print "$_\n";
    }
}


package DummyDict;

sub TIEHASH {
    my $class = shift;
    my $self = undef;
    bless \$self, $class;
}

sub EXISTS {
    1;
}

