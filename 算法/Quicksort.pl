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
#      CREATED: 11/30/2017 10:01:30 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use Data::Dumper;
  
my @x=(7, 1 ,4,6,2,9,10,8);


 sub f {
    my $x=shift;

    my @X;
    my @Y;

    if ( $#$x == -1 or $#$x == 0 ) {
        return $x;
    } else {
        foreach my $i (1..$#$x) {
             if ( $x->[$i] > $x->[0] ) {
                  push @Y , $x->[$i];
              } else {
                  push @X, $x->[$i];
              }
        }
        
           my $rx= &f(\@X);
           my $ry= &f(\@Y);

           return [@$rx, $x->[0] , @$ry];

    }

 
 }


say Dumper &f(\@x);


