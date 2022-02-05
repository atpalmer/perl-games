#!/usr/bin/env perl

use strict;
use warnings;

my $deck = Deck->new();

my $board = Board->deal($deck);

print $board->repr, "\n";

printf "%20s: %s\n", "Pair", Rank::repr($board->of_a_kind_rank(2));
printf "%20s: %s\n", "Two Pair", Rank::repr($board->two_pair_ranks());
printf "%20s: %s\n", "3 of a Kind", Rank::repr($board->of_a_kind_rank(3));
printf "%20s: %s\n", "Straight", Rank::repr($board->straight_ranks());
printf "%20s: %s\n", "Flush", Rank::repr($board->flush_ranks());
printf "%20s: %s\n", "Full House",  Rank::repr($board->full_house_ranks());
printf "%20s: %s\n", "4 of a Kind", Rank::repr($board->of_a_kind_rank(4));
printf "%20s: %s\n", "Straight Flush", Rank::repr($board->straight_flush_ranks());


package Rank;

use constant RANKS => qw<2 3 4 5 6 7 8 9 T J Q K A>;

sub repr {
    return join ', ', map { defined($_) ? (RANKS)[$_] : '<none>' } @_;
}


package Suit;

use constant SUITS => qw<s h d c>;

sub repr {
    my $x = shift;
    return (SUITS)[$x];
}


package Card;

sub new {
    my $class = shift;
    my $self = shift;
    return bless \$self, $class;
}

sub rankx {
    my $self = shift;
    return $$self % 13;
}

sub suitx {
    use integer;
    my $self = shift;
    return $$self / 13;
}

sub repr {
    my $self = shift;
    return Rank::repr($self->rankx) . Suit::repr($self->suitx);
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

use List::Util qw<any all>;

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

    my $flush_suit = $board[0]->suitx;
    if (not all { $_->suitx == $flush_suit } @board[1..$#board]) {
        $flush_suit = undef;
    }

    return bless {
        cards => \@board,
        ranks => \@ranks,
        kinds => \@kinds,
        flush_suit => $flush_suit,
    }, $class;
}

sub repr {
    my $self = shift;
    return join(', ', map { $_->repr } @{$self->{cards}});
}

sub of_a_kind_rank {
    my $self = shift;
    my $kind = shift;
    my $ranks = $self->{kinds}[$kind];
    if (int(@{$ranks}) != 1) {
        return ();
    }
    return @{$ranks};
}

sub two_pair_ranks {
    my $self = shift;
    my $ranks = $self->{kinds}[2];
    if (int(@{$ranks}) != 2) {
        return ();
    }
    return @{$ranks};
}

sub full_house_ranks {
    my $self = shift;
    my $three = $self->of_a_kind_rank(3);
    my $two = $self->of_a_kind_rank(2);
    if (!$three or !$two) {
        return ();
    }
    return ($three, $two);
}

sub straight_ranks {
    my $self = shift;
    my $ranks = $self->{ranks};
    my @results = ();
    if ($ranks->[$#{$ranks}]) {
        push(@results, $#{$ranks});
    }
    for (0..$#{$ranks}) {
        if ($ranks->[$_] > 0) {
            push(@results, $_);
        } else {
            @results = ();
        }
        return @results if int(@results) == 5;
    }
    return ();
}

sub flush_ranks {
    my $self = shift;
    if (!defined($self->{flush_suit})) {
        return ();
    }
    return map { $_->rankx } @{$self->{cards}};
}

sub straight_flush_ranks {
    my $self = shift;
    if (!defined($self->{flush_suit})) {
        return ();
    }
    return $self->straight_ranks();
}
