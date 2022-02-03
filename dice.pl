use strict;
use warnings;
use v5.10;

package Die;

sub new {
    my $new = int(rand(6));
    return bless \$new, 'Die';
}

sub face {
    my $self = shift;
    return $$self + 1;
}

package Dice;

sub new {
    my $num = shift;
    my @new;
    push(@new, Die::new()) for (1..$num);
    return bless \@new, 'Dice';
}

sub faces {
    my $self = shift;
    return map { $_->face() } @$self;
}

sub total {
    my $self = shift;
    my $total = 0;
    $total += $self->[$_]->face() for (0..$#$self);
    return $total;
}

package main;

my $dice = Dice::new(5);

say "Values: ", map { "[$_]" } $dice->faces();
say "Total: ", $dice->total();
