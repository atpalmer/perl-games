#!/usr/bin/env perl

use strict;
use warnings;

my $deck = Deck->new();

my $board = Board->deal($deck);

print $board->repr, "\n";

printf "%20s: %s\n", "Pair", $board->of_a_kind_rank(2);
printf "%20s: %s\n", "Two Pair", $board->two_pair_ranks();
printf "%20s: %s\n", "3 of a Kind", $board->of_a_kind_rank(3);
printf "%20s: %s\n", "Full House", $board->full_house_ranks();
printf "%20s: %s\n", "4 of a Kind", $board->of_a_kind_rank(4);


package Card;

use constant SUITS => qw<s h d c>;
use constant RANKS => qw<2 3 4 5 6 7 8 9 T J Q K A>;

sub new {
    my $class = shift;
    my $self = shift;
    return bless \$self, $class;
}

sub rankx {
    my $self = shift;
    return $$self % 13;
}

sub rank {
    my $self = shift;
    return (RANKS)[$self->rankx];
}

sub suit {
    my $self = shift;
    return (SUITS)[$$self / 13];
}

sub repr {
    my $self = shift;
    return $self->rank . $self->suit;
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


package Board;

use List::Util qw<any>;

sub deal {
    my $class = shift;
    my $deck = shift;

    my @board = $deck->deal(5);

    # rankx => rankx count
    my @ranks = (0) x 13;
    $ranks[$_->rankx]++ for (@board);

    # "of a kind" => rankx array ref
    my @kinds = ([], [], [], [], []);
    push(@{$kinds[$ranks[$_]]}, $_) for (0..$#ranks);

    return bless {
        cards => \@board,
        ranks => \@ranks,
        kinds => \@kinds,
    }, $class;
}

sub repr {
    my $self = shift;
    return join(', ', map { $_->repr } @{$self->{cards}});
}

sub of_a_kind_rank {
    my $self = shift;
    my $kind = shift;
    my $ranks = $self->{kinds}->[$kind];
    if (int(@{$ranks}) != 1) {
        return '';
    }
    return (Card::RANKS)[$ranks->[0]];
}

sub two_pair_ranks {
    my $self = shift;
    my $ranks = $self->{kinds}->[2];
    if (int(@{$ranks}) != 2) {
        return '';
    }
    return join(', ', map { (Card::RANKS)[$_] } @{$ranks});
}

sub full_house_ranks {
    my $self = shift;
    my $three = $self->of_a_kind_rank(3);
    my $two = $self->of_a_kind_rank(2);
    if (!$three or !$two) {
        return '';
    }
    return join(', ', map { (Card::RANKS)[$_] } ($three, $two));
}
