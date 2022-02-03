use strict;
use warnings;
use v5.10;

package Die;

sub from_face {
    my $face = shift;
    my $new = $face - 1;
    return bless \$new, 'Die';
}

sub random {
    my $new = int(rand(6));
    return bless \$new, 'Die';
}

sub index {
    my $self = shift;
    return $$self;
}

sub face {
    my $self = shift;
    return $$self + 1;
}

package Dice;

sub roll {
    my @dice;
    push(@dice, Die::random()) for (1..5);
    my @counts = (0) x 6;
    map { $counts[$_->index()]++ } @dice;
    return bless {
        dice => \@dice,
        counts => \@counts,
    }, 'Dice';
}

sub faces {
    my $self = shift;
    return map { $_->face() } @{$self->{dice}};
}

sub total {
    my $self = shift;
    my $total = 0;
    map { $total += $_->face() } @{$self->{dice}};
    return $total;
}

sub total_of {
    my $self = shift;
    my $face = shift;
    my $diex = Die::from_face($face)->index();
    return $face * $self->{counts}->[$diex];
}

sub has_of_a_kind {
    my $self = shift;
    my $kind = shift;
    return int(grep { $_ >= $kind } @{$self->{counts}});
}

sub has_full_house {
    my $self = shift;
    return
        (grep { $_ == 2 } @{$self->{counts}}) &&
        (grep { $_ == 3 } @{$self->{counts}});
}

sub straight_len {
    my $self = shift;
    my $len = 0;
    map { $len = ($_) ? $len + 1 : 0 } @{$self->{counts}};
    return $len;
}

sub has_straight_len {
    my $self = shift;
    my $len = shift;
    return $len == $self->straight_len();
}

sub scorecard {
    my $self = shift;
    return [
        [        "Aces", $self->total_of(1)],
        [        "Twos", $self->total_of(2)],
        [      "Threes", $self->total_of(3)],
        [       "Fours", $self->total_of(4)],
        [       "Fives", $self->total_of(5)],
        [       "Sixes", $self->total_of(6)],
        [ "3 of a Kind", ($self->has_of_a_kind(3) * $self->total())],
        [ "4 of a Kind", ($self->has_of_a_kind(4) * $self->total())],
        [  "Full House", ($self->has_full_house() * 25)],
        ["Sm. Straight", ($self->has_straight_len(4) * 30)],
        ["Lg. Straight", ($self->has_straight_len(5) * 40)],
        [ "5 of a Kind", ($self->has_of_a_kind(5) * 50)],
        [      "Chance", $self->total()],
    ];
}

package main;

my $dice = Dice::roll();

say "Faces: ", map { "[$_]" } $dice->faces();
say "Score Options:";

for (@{$dice->scorecard()}) {
    my ($k, $v) = @$_;
    printf("%20s: %d\n", $k, $v);
}

