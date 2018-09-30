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
#      CREATED: 08/23/2018 04:53:07 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use Data::Dumper;

my $Tree->{10} = 'data';
$Tree->{left}  = undef;
$Tree->{right} = undef;

sub tree_key {
    my $tree = shift;
    my $v;
    foreach my $key ( keys %{$tree} ) {
        unless ( $key eq 'left' or $key eq 'right' ) {
            $v = $key;
        }
    }
    return $v;
}

sub Insert {
    my $tree = shift;
    my $x    = shift;

    my $node->{$x} = 'data';
    $node->{left}  = undef;
    $node->{right} = undef;

    my $treekey = &tree_key($tree);

    if ( $x > $treekey ) {
        if ( $tree->{right} ) {
            &Insert( $tree->{right}, $x );
        }
        else {
            $tree->{right} = $node;
        }
    }
    else {
        if ( $tree->{left} ) {
            &Insert( $tree->{left}, $x );
        }
        else {
            $tree->{left} = $node;
        }
    }

}

sub travel {
    my $tree = shift;
    if ($tree) {
        say &tree_key($tree);
        &travel( $tree->{left} );
        &travel( $tree->{right} );
    }
}

####return list (node  parents  location)####
sub Search {
    my $tree = shift;
    my $x    = shift;
    my $p    = shift;
    my $L    = shift;

    my $t_key = &tree_key($tree);

    if ($tree) {
        if ( $x > $t_key ) {
            push @$p, $tree;
            push @$L, 'right';
            &Search( $tree->{right}, $x, $p, $L );
        }
        elsif ( $x < $t_key ) {
            push @$p, $tree;
            push @$L, 'left';
            &Search( $tree->{left}, $x, $p, $L );
        }
        elsif ( $x eq $t_key ) {
            return ( $tree, pop @{$p}, pop @{$L} );
        }

    }

}
###return ($node , $parents ) ###
sub Left_max {
    my $tree    = shift;
    my $num     = shift;
    my $parents = shift;

    if ($tree) {
        if ( $num eq 0 ) {
            push @$parents, $tree;
            &Left_max( $tree->{left}, 1, $parents );
        }
        else {
            push @$parents, $tree;
            &Left_max( $tree->{right}, 1, $parents );
        }
    }
    else {
        return ( pop @$parents, pop @$parents );
    }

}

###return ($node , $parents ) ###
sub Right_min {
    my $tree    = shift;
    my $num     = shift;
    my $parents = shift;

    if ($tree) {
        if ( $num eq 0 ) {
            push @$parents, $tree;
            &Right_min( $tree->{right}, 1, $parents );
        }
        else {
            push @$parents, $tree;
            &Right_min( $tree->{left}, 1, $parents );
        }
    }
    else {
        return ( pop @$parents, pop @$parents );
    }

}

sub Del {
    my $tree = shift;
    my $x    = shift;

    my ( $dnode, $dparents, $dlocation ) = &Search( $tree, $x, [], [] );

    my ( $lnode, $lparents ) = &Left_max( $dnode, 0, [] );
    my ( $rnode, $rparents ) = &Right_min( $dnode, 0, [] );

    my ( $left_first, $left_more, $right_first, $right_more );

    if ($dparents) {
        $left_first = sub {
            $dparents->{$dlocation} = $lnode;
            $lnode->{right} = $dnode->{right};
        };
        $left_more = sub {
            $dparents->{$dlocation} = $lnode;
            $lparents->{right}      = $lnode->{left};
            $lnode->{left}          = $dnode->{left};
            $lnode->{right}         = $dnode->{right};
        };
        $right_first = sub {
            $dparents->{$dlocation} = $rnode;
            $rnode->{left} = $dnode->{left};
        };
        $right_more = sub {
            $dparents->{$dlocation} = $rnode;
            $rparents->{left}       = $rnode->{right};
            $rnode->{right}         = $dnode->{right};
            $rnode->{left}          = $dnode->{left};
        };
    }
    else {
        $left_first = sub {
            $lnode->{right} = $dnode->{right};
            $Tree = $lnode;
        };
        $left_more = sub {
            $lnode->{right}    = $dnode->{right};
            $lparents->{right} = $lnode->{left};
            $lnode->{left}    = $dnode->{left};
            $Tree              = $lnode;
        };
        $right_first = sub {
            $rnode->{left} = $dnode->{left};
            $Tree = $rnode;
        };
        $right_more = sub {
            $rnode->{left}    = $dnode->{left};
            $rparents->{left} = $rnode->{right};
            $rnode->{right}    = $dnode->{right};
            $Tree             = $rnode;
        };
    }

    if ( $dnode->{left} ) {
        if (&tree_key($lparents) eq &tree_key($dnode)) {
            $left_first->();
        }
        else {
            $left_more->();
        }
    }
    elsif ( $dnode->{right} ) {
        if (&tree_key($rparents) eq &tree_key($dnode)) {
            $right_first->();
        }
        else {
            $right_more->();
        }
    } else {
        $dparents->{$dlocation}=undef;
    }

}

&Insert( $Tree, 11 );
&Insert( $Tree, 8 );
#&Insert( $Tree, 5 );
&Insert( $Tree, 9 );
&Insert( $Tree, 10.5 );
&Insert( $Tree, 15 );
&Insert( $Tree, 8.5 );
&Insert( $Tree, 8.4 );
&Insert( $Tree, 8.46 );
&Insert( $Tree, 8.6 );
&Del( $Tree, 8 );
&travel($Tree);

=cut
my ($t)=&Search($tree , 29 ,[]);
my ($y)=&Left_max($t ,0);
say Dumper $y;
=cut
