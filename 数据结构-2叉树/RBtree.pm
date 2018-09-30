#!/usr/bin/env perl
#===============================================================================
#
#         FILE: red_black_tree.pl
#
#        USAGE: ./red_black_tree.pl
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
#      CREATED: 09/11/2018 02:44:41 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use Data::Dumper;

package RBtree;
use Data::Dumper;

###定义根 b:black  r: red
my $Tree = {};

####get node's key
sub tree_key {
    my $node = shift;
    return 0 unless ref $node eq 'HASH' or ref $node eq 'RBtree';
    foreach my $key ( keys %$node ) {
        unless ( $key eq 'left' or $key eq 'right' or $key eq 'c' ) {
            return '00' if $key eq 0;
            return $key;
        }
    }
}

### input ($Tree , $x (查找的key) , []:to store parents , []:to store location  ) ##
###output ($node ,$parents() , $location() ) ####
sub Search {
    my ( $tree, $x, $parents, $location ) = @_;

    my $key = &tree_key($tree);
    if ($key) {
        if ( $x gt $key ) {
            push @$parents,  $tree;
            push @$location, 'right';
            &Search( $tree->{right}, $x, $parents, $location );
        }
        elsif ( $x lt $key ) {
            push @$parents,  $tree;
            push @$location, 'left';
            &Search( $tree->{left}, $x, $parents, $location );
        }
        elsif ( $x eq $key ) {
            return ( $tree, $parents, $location );
        }
    }

}

###input ($Tree , $node , []:store parents , []: store location)
sub Insert {
    my ( $tree, $node, $parents, $location ) = @_;
    $node->{c} = 'r';

    my $key = &tree_key($tree);

    if ($key) {
        if ( &tree_key($node) gt $key ) {
            push @$parents,  $tree;
            push @$location, 'right';
            &Insert( $tree->{right}, $node, $parents, $location );
        }
        elsif ( &tree_key($node) lt $key ) {
            push @$parents,  $tree;
            push @$location, 'left';
            &Insert( $tree->{left}, $node, $parents, $location );
        }
        else {
            return;
        }
    }
    else {
        my $p = $parents->[-1];
        my $l = $location->[-1];

        unless ($l) {
            $node->{c} = 'b';
            $Tree = $node;
            return;
        }
        else {
            $p->{$l} = $node;
        }

        &P_red( $parents, $location );

    }
}

sub P_red {
    my ( $parents, $location ) = @_;
    my ( $p, $l, $p2, $l2, $pb, $pbl );
    $p         = $parents->[-1];
    $l         = $location->[-1];
    $p2        = $parents->[-2];
    $l2        = $location->[-2];
    $Tree->{c} = 'b';
    if ( $#$parents eq '-1' or $#$parents eq '0' ) {
        return;
    }
    else {
        return 1 if $p->{c} eq 'b';
        $pbl = $l2 eq 'right' ? 'left' : 'right';
        $pb = $p2->{$pbl};
        my $r_b = 'b';
        if ( &tree_key($pb) ) {
            $r_b = $pb->{c} eq 'r' ? 'r' : 'b';
        }

        if ( $r_b eq 'r' ) {
            $p->{c}  = 'b';
            $pb->{c} = 'b';
            $p2->{c} = 'r';
            pop @$parents;
            pop @$parents;
            pop @$location;
            pop @$location;
            &P_red( $parents, $location );
        }
        elsif ( $r_b eq 'b' ) {
            if ( $l2 eq $l ) {
                my $node = $p->{$l};
                $node->{c} = 'b';
                my $p3 = $parents->[-3];
                my $l3 = $location->[-3];
                &if_rolation( $l2, $p, $p2, $p3, $l3 );
                pop @$parents;
                pop @$parents;
                pop @$location;
                pop @$location;

            }
            else {
                $p->{c} = 'b';
                my $node = $p->{$l};
                my $p3   = $parents->[-3];
                my $l3   = $location->[-3];
                &if_rolation( $l,  $node, $p,  $p2, $l2 );
                &if_rolation( $l2, $node, $p2, $p3, $l3 );
                pop @$parents;
                pop @$parents;
                pop @$location;
                pop @$location;
            }
            &P_red( $parents, $location );
        }

    }

}

sub Travel {

    my $tree = shift;
    my $from = shift;    # $from = 1 前序 | 2 中序 | 3 后序
    my $Print = sub {
        my $tree  = shift;
        my $key   = &tree_key($tree);
        my $color = $tree->{c};
        my $lkey  = &tree_key( $tree->{left} );
        my $rkey  = &tree_key( $tree->{right} );

        if ( $lkey and $rkey ) {
            say "$key color:$color"
              . " left: "
              . &tree_key( $tree->{left} )
              . " right: "
              . &tree_key( $tree->{right} );
        }
        elsif ($rkey) {
            say "$key color: $color" . " right:" . &tree_key( $tree->{right} );

        }
        elsif ($lkey) {
            say "$key color: $color" . " left:" . &tree_key( $tree->{left} );

        }
        else {
            say "$key color: $color";
        }

    };
    if ( &tree_key($tree) ) {
        if ( $from eq 1 ) {
            $Print->($tree);
            &Travel( $tree->{left},  $from );
            &Travel( $tree->{right}, $from );

        }
        elsif ( $from eq 2 ) {
            &Travel( $tree->{left}, $from );
            $Print->($tree);
            &Travel( $tree->{right}, $from );

        }
        elsif ( $from eq 3 ) {
            &Travel( $tree->{left},  $from );
            &Travel( $tree->{right}, $from );
            $Print->($tree);
        }
    }

}

sub L_rolation {
    my ( $s, $p, $g, $gl ) = @_;
    my $gs = $s->{left};
    $p->{right} = $gs;
    $s->{left}  = $p;

    unless ( &tree_key($g) ) {
        $Tree = $s;
    }
    else {
        $g->{$gl} = $s;
    }
}

sub R_rolation {
    my ( $s, $p, $g, $gl ) = @_;
    my $gs = $s->{right};
    $p->{left}  = $gs;
    $s->{right} = $p;

    unless ( &tree_key($g) ) {
        $Tree = $s;
    }
    else {
        $g->{$gl} = $s;
    }
}

sub if_rolation {
    my ( $if, $s, $p, $g, $gl ) = @_;

    if ( $if eq 'right' ) {
        &L_rolation( $s, $p, $g, $gl );
    }
    elsif ( $if eq 'left' ) {
        &R_rolation( $s, $p, $g, $gl );
    }
}

sub Db {
    my $x = shift;
    my $t = &gettimeofday();
    open my $y, '>>debug';
    say $y "$x $t";
}

sub Balance {
    my ( $parents, $location, $color ) = @_;

    my $p1 = $parents->[-1];
    my $l1 = $location->[-1];
    my $p2 = $parents->[-2];
    my $l2 = $location->[-2];

    if ( $#$parents eq '-1' or $color eq 'r' ) {
        return;
    }
    else {

        # 0 , 继承者is red
        my $t = $p1->{$l1} if $p1;
        if ( &tree_key($t) ) {
            if ( $t->{c} eq 'r' ) {
                $t->{c} = 'b';
                return 1;
            }
        }
        my $bl = $l1 eq 'right' ? 'left' : 'right';
        my $b = &tree_key( $p1->{$bl} ) ? $p1->{$bl} : undef;
        unless ($b) {

            # 1 no brother
            if ( $p1->{c} eq 'r' ) {

                # 1.1  parents is red
                $p1->{c} = 'b';
            }
            else {

                # 1.2  parents is black
                pop @$parents;
                pop @$location;
                &Balance( $parents, $location, 'b' );
            }
        }
        else {

            # 2 have brother
            my $b_son_y_color = &tree_key( $b->{$bl} ) ? $b->{$bl}->{c} : 'b';
            my $b_son_j_color = &tree_key( $b->{$l1} ) ? $b->{$l1}->{c} : 'b';

            if ( $b_son_y_color eq 'b' and $b_son_j_color eq 'b' ) {

                # 2.1 brother'son is black or no son (two black)
                if ( $p1->{c} eq 'r' ) {

                    # 2.1.1  parents is red;
                    &if_rolation( $bl, $b, $p1, $p2, $l2 );
                }
                else {

                    # 2.1.2  parents is black;
                    if ( $b->{c} eq 'r' ) {

                        # 2.1.2.1  brother is red;
                        my $s1 = &tree_key( $b->{$bl} ) ? $b->{$bl} : undef;
                        my $s2 = &tree_key( $b->{$l1} ) ? $b->{$l1} : undef;
                        if ( $s1 and $s2 ) {
                            my $gs1 =
                              &tree_key( $s2->{$bl} ) ? $s2->{$bl} : undef;
                            my $gs2 =
                              &tree_key( $s2->{$l1} ) ? $s2->{$l1} : undef;
                            $b->{c} = 'b';
                            &if_rolation( $bl, $b, $p1, $p2, $l2 );
                            my $gs1_color = $gs1 ? $gs1->{c} : 'b';
                            my $gs2_color = $gs2 ? $gs2->{c} : 'b';

                            if ( $gs2_color eq 'r' ) {
                                &if_rolation( $l1, $gs2, $s2, $p1, $bl );
                                &if_rolation( $bl, $gs2, $p1, $b,  $l1 );
                            }
                            elsif ( $gs1_color eq 'r' ) {
                                $p1->{c} = 'r';
                                &if_rolation( $bl, $s2, $p1, $b, $l1 );
                            }
                            else {
                                $s2->{c} = 'r';
                            }

                        }
                        elsif ($s1) {
                            $b->{c} = 'b';
                            &if_rolation( $bl, $b, $p1, $p2, $l2 );
                        }
                        elsif ($s2) {
                            $b->{c} = 'b';
                            &if_rolation( $l1, $s2,        $b,  $p1, $bl );
                            &if_rolation( $bl, $p1->{$bl}, $p1, $p2, $l2 );
                        }

                    }
                    else {

                        # 2.1.2.2  brother is black;
                        $b->{c} = 'r';
                        pop @$parents;
                        pop @$location;
                        &Balance( $parents, $location, 'b' );
                    }
                }
            }
            else {

                # 2.2 brother'son have red
                if ( $b_son_y_color eq 'r' ) {

                    # 2.2.1 brother 远处的son is red
                    my $bc = $b->{c};
                    my $pc = $p1->{c};
                    $b->{c}        = $pc;
                    $p1->{c}       = $bc;
                    $b->{$bl}->{c} = 'b';
                    &if_rolation( $bl, $b, $p1, $p2, $l2 );
                }
                else {

                    # 2.2.2 brother 近处的son is red
                    $b->{$l1}->{c} = $p1->{c};
                    $p1->{c} = 'b';
                    &if_rolation( $l1, $b->{$l1},  $b,  $p1, $bl );
                    &if_rolation( $bl, $p1->{$bl}, $p1, $p2, $l2 );
                }
            }

        }
    }

}


sub Del {
    my ( $tree, $x ) = @_;
    my ( $node, $parents, $location ) = &Search( $tree, $x, [], [] );
    return unless $node;
    if ( $node->{left} ) {
        my ( $Parents, $Location, $color ) =
          &Left_max( $node, $parents, $location, [], [] );
        push @$parents,  @$Parents  if $Parents->[0];
        push @$location, @$Location if $Location->[0];
        &Balance( $parents, $location, $color );
    }
    elsif ( $node->{right} ) {
        my ( $Parents, $Location, $color ) =
          &Right_min( $node, $parents, $location, [], [] );
        push @$parents,  @$Parents  if $Parents->[0];
        push @$location, @$Location if $Location->[0];
        &Balance( $parents, $location, $color );
    }
    elsif ( $node->{c} eq 'r' ) {
        my $p = $parents->[-1];
        my $l = $location->[-1];
        $p->{$l} = undef;
    }
    elsif ( $node->{c} eq 'b' ) {
        my $p = $parents->[-1];
        my $l = $location->[-1];
        $p->{$l} = undef if $l;
        $Tree = {} unless $l;
        &Balance( $parents, $location, 'b' );
    }

}

sub Left_max {
    my ( $node, $parents, $location, $Parents, $Location, $n ) = @_;
    if ($node) {
        unless ($n) {
            push @$Parents,  $node;
            push @$Location, 'left';
            &Left_max( $node->{left}, $parents, $location, $Parents, $Location,
                1 );
        }
        else {
            push @$Parents,  $node   if $node->{right};
            push @$Location, 'right' if $node->{right};
            &Left_max( $node->{right}, $parents, $location, $Parents, $Location,
                1 );
        }
    }
    else {
        my $dnode = $Parents->[0];
        my $dl    = $Location->[0];
        my $Node  = $Parents->[-1];
        my $Nl    = $Location->[-1];
        my $fnode = $Node->{$Nl};
        my $Color = $fnode->{c};
        $fnode->{c} = $dnode->{c};

        if (@$parents) {
            if ( $#$Parents eq 0 ) {
                my $l = $location->[-1];
                $parents->[-1]->{$l} = $fnode;
                $fnode->{right}      = $dnode->{right};
                $Parents->[0]        = $fnode;
            }
            else {
                my $l = $location->[-1];
                $parents->[-1]->{$l} = $fnode;
                $Node->{$Nl}         = $fnode->{left};
                $fnode->{right}      = $dnode->{right};
                $fnode->{left}       = $dnode->{left};
                $Parents->[0]        = $fnode;

            }
        }
        else {
            ####del node is root####
            if ( $#$Parents eq 0 ) {
                $fnode->{right} = $dnode->{right};
                $Tree           = $fnode;
                $Parents->[0]   = $fnode;
            }
            else {
                $Node->{$Nl}    = $fnode->{left};
                $fnode->{right} = $dnode->{right};
                $fnode->{left}  = $dnode->{left};
                $Tree           = $fnode;
                $Parents->[0]   = $fnode;
            }

        }

        return ( $Parents, $Location, $Color );
    }

}

sub Right_min {
    my ( $node, $parents, $location, $Parents, $Location, $n ) = @_;
    if ($node) {
        unless ($n) {
            push @$Parents,  $node;
            push @$Location, 'right';
            &Right_min( $node->{right}, $parents, $location, $Parents,
                $Location, 1 );
        }
        else {
            push @$Parents,  $node  if $node->{left};
            push @$Location, 'left' if $node->{left};
            &Right_min( $node->{left}, $parents, $location, $Parents, $Location,
                1 );
        }
    }
    else {
        my $dnode = $Parents->[0];
        my $dl    = $Location->[0];
        my $Node  = $Parents->[-1];
        my $Nl    = $Location->[-1];
        my $fnode = $Node->{$Nl};
        my $Color = $fnode->{c};
        $fnode->{c} = $dnode->{c};
        if (@$parents) {

            if ( $#$Parents eq 0 ) {
                my $l = $location->[-1];
                $parents->[-1]->{$l} = $fnode;
                $fnode->{left}       = $dnode->{left};
                $Parents->[0]        = $fnode;
            }
            else {
                my $l = $location->[-1];
                $parents->[-1]->{$l} = $fnode;
                $Node->{$Nl}         = $fnode->{right};
                $fnode->{right}      = $dnode->{right};
                $fnode->{left}       = $dnode->{left};
                $Parents->[0]        = $fnode;

            }
        }
        else {
            if ( $#$Parents eq 0 ) {
                $fnode->{left} = $dnode->{left};
                $Tree          = $fnode;
                $Parents->[0]  = $fnode;
            }
            else {
                $Node->{$Nl}    = $fnode->{right};
                $fnode->{right} = $dnode->{right};
                $fnode->{left}  = $dnode->{left};
                $Tree           = $fnode;
                $Parents->[0]   = $fnode;
            }
        }

        return ( $Parents, $Location, $Color );
    }

}

sub new {
    my $x= $Tree;
    bless { tree => $x}, 'RBtree';
}

sub add {
    my $self=shift;
    my @x=@_;
    my $n=$#x + 1;
    return 0 unless $n % 2 eq '0';
    while (@x) {
        my $k=shift @x;
        my $v=shift @x;
        my $node={$k => $v , right => undef , left=>undef};
        &Insert($self->{tree} , $node , [], []);
    }

    $self->{tree}=$Tree;
    
}

sub travel {
    my $self=shift;
    my $n=shift;
    &Travel($self->{tree} , $n);
}

sub find {
    my $self=shift;
    my $x=shift;
    return 0 unless $x;
    &Search($self->{tree}, $x , [], []);
}

sub del {
    my $self=shift;
    my $x=shift;
    return 0 unless $x;
    &Del ($self->{tree} , $x);
    $self->{tree}=$Tree;
}

1
