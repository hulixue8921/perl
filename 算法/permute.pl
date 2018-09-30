#!/usr/bin/env perl
#===============================================================================
#
#         FILE: permute.pl
#
#        USAGE: ./permute.pl  
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
#      CREATED: 07/12/2017 04:02:24 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use Data::Dumper;

sub per {
    my @array=@{$_[0]};
    my @perms=@{$_[1]};
 
    unless (@array) {
         say "@perms";
    } else {
         my (@newarray , @newperms , $i);
         foreach $i (0..$#array) {
              @newarray=@array;
              @newperms=@perms;
              unshift (@newperms ,splice (@newarray , $i , 1));
              &per([@newarray] , [@newperms]);
         };
    
    }



};


 &per([1..10], []);


