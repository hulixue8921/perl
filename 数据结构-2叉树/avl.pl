#!/usr/bin/env perl
#===============================================================================
#
#         FILE: avl.pl
#
#        USAGE: ./avl.pl
#
#  DESCRIPTION: i
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 08/31/2018 10:11:39 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use Data::Dumper;

my $Tree;
$Tree->{right} = undef;
$Tree->{left}  = undef;
$Tree->{10}    = 'data';
$Tree->{s}     = 0;

####input ( $tree , key, [](store parents), [](store node location) ) , return (node , parents , location)######
sub Search {
    my ( $tree, $key, $parents, $location ) = @_;

    if ($tree) {
        if ( $key > &tree_key($tree) ) {
            push @$parents,  $tree;
            push @$location, 'right';
            &Search( $tree->{right}, $key, $parents, $location );
        }
        elsif ( $key < &tree_key($tree) ) {
            push @$parents,  $tree;
            push @$location, 'left';
            &Search( $tree->{left}, $key, $parents, $location );
        }
        elsif ( $key eq &tree_key($tree) ) {
            return ( $tree, pop @$parents, pop @$location );
        }
    }
    else {
        return ();
    }

}

###input ($tree , $node,,[] ,[](store location)), return 0|1 ####
sub Insert {
    my ( $tree, $node, $parents, $location ) = @_;

    if ($tree) {
        if ( &tree_key($node) > &tree_key($tree) ) {
            push @$location, 'right';
            push @$parents,  $tree;
            &Insert( $tree->{right}, $node, $parents, $location );
        }
        elsif ( &tree_key($node) < &tree_key($tree) ) {
            push @$location, 'left';
            push @$parents,  $tree;
            &Insert( $tree->{left}, $node, $parents, $location );
        }
        else {
            return 0;
        }
    }
    else {
        my $t = pop @$parents;
        my $l = pop @$location;
        ###insert avl
        $t->{$l} = $node;
        &status( $t, $l );

        ###修改平衡因子, 并返回 status 为 2 | -2 的node, 对node 进行balance
        if ( $t->{s} eq 0 ) {
            return;
        }
        else {
            while (@$parents) {
                my $node = pop @$parents;
                my $l    = pop @$location;
                &status( $node, $l );
                if ( $node->{s} eq '2' or $node->{s} eq '-2' ) {
                    my $p  = $parents->[-1];
                    my $pl = $location->[-1];
                    &Balance( $node, $p, $l, $pl );
                    last;
                }

            }

        }

    }
}

sub Left {
    my ( $node, $parents, $l, $pl ) = @_;
    if ($parents) {
        $node->{s} = 0;
        $node->{$l}->{s} = 0;
        my $son = $node->{$l};
        $node->{right}  = $son->{left};
        $son->{left}    = $node;
        $parents->{$pl} = $son;
    }
    else {
        $node->{s} = 0;
        $node->{$l}->{s} = 0;
        my $son = $node->{$l};
        $node->{right} = $son->{left};
        $son->{left}   = $node;
        $Tree          = $son;
    }
}

sub Right {
    my ( $node, $parents, $l, $pl ) = @_;
    if ($parents) {
        $node->{s} = 0;
        $node->{$l}->{s} = 0;
        my $son = $node->{$l};
        $node->{left}   = $son->{right};
        $son->{right}   = $node;
        $parents->{$pl} = $son;
    }
    else {
        $node->{s} = 0;
        $node->{$l}->{s} = 0;
        my $son = $node->{$l};
        $node->{left} = $son->{right};
        $son->{right} = $node;
        $Tree         = $son;
    }
}
####-2 1####
sub RL {
    my ( $node, $parents, $l, $pl ) = @_;
    my $son  = $node->{$l};
    my $gson = $son->{left};

    if ( $gson->{right} and $gson->{left} ) {
        $node->{s} = 0;
        $son->{s}  = 0;
        $gson->{s} = 0;
    }
    elsif ( $gson->{left} ) {
        $node->{s} = 0;
        $son->{s}  = -1;
        $gson->{s} = 0;

    }
    elsif ( $gson->{right} ) {
        $node->{s} = 1;
        $son->{s}  = 0;
        $gson->{s} = 0;
    }
    else {
        $node->{s} = 0;
        $son->{s}  = 0;
        $gson->{s} = 0;
    }

    ####right rolation####
    $son->{left}   = $gson->{right};
    $gson->{right} = $son;
    $node->{right} = $gson;

    #####left rolation####
    if ($parents) {
        $node->{right}  = $gson->{left};
        $gson->{left}   = $node;
        $parents->{$pl} = $gson;
    }
    else {
        $node->{right} = $gson->{left};
        $gson->{left}  = $node;
        $Tree          = $gson;
    }

}
####2 -1####
sub LR {
    my ( $node, $parents, $l, $pl ) = @_;
    my $son  = $node->{$l};
    my $gson = $son->{right};

    if ( $gson->{right} and $gson->{left} ) {
        $node->{s} = 0;
        $son->{s}  = 0;
        $gson->{s} = 0;
    }
    elsif ( $gson->{left} ) {
        $node->{s} = -1;
        $son->{s}  = 0;
        $gson->{s} = 0;

    }
    elsif ( $gson->{right} ) {
        $node->{s} = 0;
        $son->{s}  = 1;
        $gson->{s} = 0;
    }
    else {
        $node->{s} = 0;
        $son->{s}  = 0;
        $gson->{s} = 0;
    }

    ####left rolation#####
    $son->{right} = $gson->{left};
    $gson->{left} = $son;
    $node->{left} = $gson;
    ####right rolation#####
    if ($parents) {
        $node->{left}   = $gson->{right};
        $gson->{right}  = $node;
        $parents->{$pl} = $gson;
    }
    else {
        $node->{left}  = $gson->{right};
        $gson->{right} = $node;
        $Tree          = $gson;
    }

}

sub Balance {
    my ( $node, $parents, $l, $pl ) = @_;

    if ( $node->{s} eq '-2' and $node->{$l}->{s} eq '-1' ) {
        &Left( $node, $parents, $l, $pl );
    }
    elsif ( $node->{s} eq '2' and $node->{$l}->{s} eq '1' ) {
        &Right( $node, $parents, $l, $pl );
    }
    elsif ( $node->{s} eq '-2' and $node->{$l}->{s} eq '1' ) {
        &RL( $node, $parents, $l, $pl );
    }
    elsif ( $node->{s} eq '2' and $node->{$l}->{s} eq '-1' ) {
        &LR( $node, $parents, $l, $pl );
    }

}

sub status {
    my ( $node, $location ) = @_;

    if ( $location eq 'right' ) {
        $node->{s}--;
    }
    elsif ( $location eq 'left' ) {
        $node->{s}++;
    }

}

sub Travel {
    my $tree = shift;

    if ($tree) {
        &Travel( $tree->{left} );
        if ( $tree->{left} && $tree->{right} ) {
            say &tree_key($tree) 
              . '------' . "left:"
              . &tree_key( $tree->{left} )
              . " right:"
              . &tree_key( $tree->{right} )
              . " s: $tree->{s}";
        }
        elsif ( $tree->{left} ) {
            say &tree_key($tree) 
              . '------' . "left:"
              . &tree_key( $tree->{left} )
              . " s: $tree->{s}";
        }
        elsif ( $tree->{right} ) {
            say &tree_key($tree) 
              . '------' 
              . "right:"
              . &tree_key( $tree->{right} )
              . " s: $tree->{s}";
        }
        else {
            say &tree_key($tree) . "------" . " s: $tree->{s}";
        }
        &Travel( $tree->{right} );
    }

}

sub tree_key {
    my $tree = shift;
    foreach my $key ( keys %$tree ) {
        return $key unless $key eq 'right' or $key eq 'left' or $key eq 's';
    }
}

#my ($node , $parents , $left)=&Search($Tree , 20, [] ,[]);
#&Insert($Tree , $x ,[],[]);
#say Dumper $node;
#&Travel($Tree);

my @x = ( 1 .. 16 );
foreach my $key (@x) {
    my $x = { $key => '', right => undef, left => undef, s => 0 };
    &Insert( $Tree, $x, [], [] );
}

&Travel($Tree);
