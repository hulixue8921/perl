#!/usr/bin/env perl
#===============================================================================
#
#         FILE: 1.pl
#
#        USAGE: ./1.pl
#
#  DESCRIPTION:
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 11/19/18 02:16:24
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use AVLTree;
use 5.010;
use Data::Dumper;
use Encode;
use POE qw (Wheel::SocketFactory Wheel::ReadWrite);
use JSON;

my $json = JSON->new()->utf8;

sub compare {
    my ( $i1, $i2 ) = @_;
    my ( $id1, $id2 ) = ( $i1->{id}, $i2->{id} );
    return $id1 gt $id2 ? -1 : ( $id1 lt $id2 ) ? 1 : 0;
}

my $tree = AVLTree->new( \&compare );
my $Ignore = [ ';', '；', "\f", ',', '，', ' ' ];

sub add_to_avl {
    my $string = shift;
    my @string = @$string;
    my @other  = @string[ 1 .. $#string ];
    my $data   = {};

    my $do_data = sub {
        my $other = shift;
        my @other = @$other;
        my $stack = [];
        push @$stack, $data;

        foreach my $i ( 0 .. $#other ) {
            my $d = pop @$stack;

            $d->{ $other[$i] } = {};
            $d->{ $other[$i] } = { 'over' => undef } if $i == $#other;
            push @$stack, $d->{ $other[$i] };
        }

    };

    my $update_avl = sub {
        my $other = shift;
        my $find  = shift;
        my @other = @$other;
        my $stack = [];
        push @$stack, $find;

        foreach my $i ( 0 .. $#other ) {
            my $F = pop @$stack;
            if ( exists $F->{ $other[$i] } ) {
                $F->{ $other[$i] }->{'over'} = undef if $i == $#other;
                push @$stack, $F->{ $other[$i] };
            }
            else {
                $F->{ $other[$i] } = {};
                $F->{ $other[$i] } = { 'over' => undef } if $i == $#other;
                push @$stack, $F->{ $other[$i] };
            }
        }

    };

    my $find = $tree->find( { id => $string[0] } );
    if ($find) {
        $update_avl->( \@other, $find->{ $string[0] } );
    }
    else {
        $do_data->( \@other );
        $tree->insert( { id => $string[0], $string[0] => $data } );
    }

}

sub reg {
    my $string   = shift;
    my @string   = split( //, $string );
    my $Index    = 0;
    my $ifupdate = 0;
    while ( $Index <= $#string ) {
        my $index = [];
        my @other = @string[ $Index + 1 .. $#string ];
        my $find  = $tree->find( { id => $string[$Index] } );
        if ($find) {
            push @$index, $Index;
            &find_other( \@other, $find->{ $string[$Index] }, $index, '0', [] );
            if ( $#$index == -1 ) {
                $Index++;
            }
            else {
                foreach my $i (@$index) {
                    $string[$i] = '*';
                    $ifupdate = 1;
                }
                $Index = $index->[-1] + 1;
            }
        }
        else {
            $Index++;
        }
    }

    if ($ifupdate) {
        return join( '', @string );
    }
    else {
        return $string;
    }

}

sub find_other {
    my ( $Other, $find, $index, $count, $flag ) = @_;
    my @other = @$Other;
    my $num   = keys %$find;

    if ( $#other == -1 ) {
        unless ( exists $find->{'over'} ) {
            if ( $#$flag == -1 ) {
                @$index = ();
            }
            else {
                while (@$index) {
                    my $i = pop @$index;
                    if ( $i == $flag->[-1] ) {
                        last;
                    }
                }
            }
        }
        else {
            return;
        }
    }
    else {
        my $k;
        while (@other) {
            $k = shift @other;
            if ( $count == 0 ) {
                $count = $index->[-1] + 1;
            }
            else {
                $count++;
            }

            unless ( $k ~~ @$Ignore ) {
                last;
            }
        }

        if ( exists $find->{$k} ) {
            if ( exists $find->{'over'} ) {
                push @$flag,  $count;
                push @$index, $count;
                &find_other( \@other, $find->{$k}, $index, $count, $flag );
            }
            else {
                push @$index, $count;
                &find_other( \@other, $find->{$k}, $index, $count, $flag );
            }
        }
        else {
            if ( exists $find->{'over'} ) {
                return;
            }
            else {
                if ( $#$flag == -1 ) {
                    @$index = ();
                }
                else {
                    while (@$index) {
                        my $i = pop @$index;
                        if ( $i == $flag->[-1] ) {
                            last;
                        }
                    }
                }
            }
        }

    }

}

### 增加敏感词库
open my $F, "< /root/perl/m";
while (<$F>) {
    chomp;
    Encode::_utf8_on($_);
    unless ($_) {
        next;
    }
    my @x = split( //, $_ );
    &add_to_avl( \@x );
}

#say Dumper $tree->find( { id => '1' } );
#say &reg($ARGV[0]);
#
POE::Session->create(
    inline_states => {
        _start      => \&Listen,
        listen_fail => \&Listen_fail,
        connected   => \&Connected,
    },

);

sub Listen {
    my $port = POE::Wheel::SocketFactory->new(
        BindPort       => '5000',
        SocketProtocol => 'tcp',
        SuccessEvent   => 'connected',
        FailureEvent   => 'listen_fail',
        Reuse          => 'on',
    );
    $_[HEAP]{port} = $port;
}

sub Listen_fail {
    say "start port:80 , fail !!!!";
}

sub Connected {
    my $hand = $_[ARG0];
    POE::Session->create(
        inline_states => {
            _start   => \&Bind_con,
            receve   => \&Receve,
            lose_con => \&Lose_con,
            _stop    => \&stop,

        },

        args => [$hand],

    );
}

sub Bind_con {
    my $hand      = $_[ARG0];
    $_[HEAP]{con} = POE::Wheel::ReadWrite->new(
        Handle     => $hand,
        InputEvent => "receve",
        ErrorEvent => "lose_con",
    );
}

sub Lose_con {
    $poe_kernel->yield('_stop');
}

sub Receve {
        my ($heap, $info, $wheel_id) = @_[HEAP, ARG0, ARG1];
        Encode::_utf8_on($info);
        my $Data=&reg($info);
        $_[HEAP]{con}->put($Data);
}
sub stop {
    my $session_id = $_[SESSION]->ID;
    say "stop $session_id";
}

$poe_kernel->run;


