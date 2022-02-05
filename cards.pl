#!/usr/bin/env perl

use strict;
use warnings;

my $deck = Deck->new();

my $board = Board->deal($deck);

print join(', ', map { $_->repr } @$board), "\n";

package Board;

sub deal {
    my $class = shift;
    my $deck = shift;
    my @board = $deck->deal(5);
    return bless \@board, $class;
}

package Deck;

use List::Util qw<shuffle>;

sub new {
    my $class = shift;
    my @cards = shuffle map { Card->new($_) } (0..51);
    return bless \@cards, $class;
};

sub deal {
    my $self = shift;
    my $count = shift;
    return splice(@$self, 0, $count);
}

package Card;

use constant RANKS => qw<2 3 4 5 6 7 8 9 T J Q K A>;
use constant SUITS => qw<s h d c>;

sub new {
    my $class = shift;
    my $self = shift;
    return bless \$self, $class;
}

sub rank {
    my $self = shift;
    return (RANKS)[$$self % 13];
}

sub suit {
    my $self = shift;
    return (SUITS)[$$self / 13];
}

sub repr {
    my $self = shift;
    return $self->rank . $self->suit;
}
