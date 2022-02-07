#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw<all any>;


my $OPTS = Options->parse();

my $words = grab_words($OPTS->{'dict'}, $OPTS->{'count'});

my $freq = CharFrequency->new($words);
my @sorted = sort { $freq->score($b) <=> $freq->score($a) } @$words;

my @result = filter(\@sorted, $OPTS->{'require'}, $OPTS->{'exclude'}, $OPTS->{'pattern'});

print $_->string, "\n" for @result;


sub grab_words {
    my $filename = shift;
    my $length = shift;
    open my $f, '<', $filename or die "can't open $filename";
    my @words = map { Word->new($_) } grep { chomp; /^[a-z]/ && length($_) == $length } <$f>;
    close $f;
    return \@words;
}

sub filter {
    my $words = shift;
    my $require = shift;
    my $exclude = shift;
    my $pattern = shift;

    my @required_letters = split '', $require;
    my @excluded_letters = split '', $exclude;

    return grep {
        my $word = $_;

        all { $word->contains($_) } @required_letters
            and not any { $word->contains($_) } @excluded_letters
            and $word->matches($pattern)

    } @$words;
}


package Options;

use Getopt::Long;

sub parse {
    my $class = shift;
    my %opts = ();
    GetOptions(\%opts,
        'dict=s',
        'count=i',
        'require=s',
        'exclude=s',
        'pattern=s',
    ) or die 'Bad Arguments';

    my %new;
    tie %new, $class, \%opts;
    return \%new;
}

sub TIEHASH {
    my $class = shift;
    my $new = shift;
    return bless $new, $class;
}

sub FETCH {
    my $self = shift;
    my $key = shift;
    die qq<No option "$key"> if not defined $self->{$key};
    return $self->{$key};
}


package CharFrequency;

use List::Util qw<sum>;

sub new {
    my $class = shift;
    my $words = shift;
    my $self = {};

    for my $word (@$words) {
        map { $self->{$_} += 1 } $word->uniq();
    }

    return bless $self, $class;
}

sub score {
    my $self = shift;
    my $word = shift;
    return sum map { $self->{$_} } $word->uniq();
}


package Word;

sub new {
    my $class = shift;
    my $string = shift;
    my @chars = split '', $string;
    my %uniq = map { $_ => 1 } @chars;
    return bless {
        string => $string,
        chars => \@chars,
        uniq => \%uniq,
    }, $class;
}

sub string {
    my $self = shift;
    return $self->{'string'};
}

sub chars {
    my $self = shift;
    return $self->{'chars'};
}

sub uniq {
    my $self = shift;
    return keys %{$self->{'uniq'}};
}

sub contains {
    my $self = shift;
    my $letter = shift;
    return $self->{'uniq'}->{$letter};
}

sub matches {
    my $self = shift;
    my $pattern = shift;
    return $self->string =~ qr/$pattern/;
}
