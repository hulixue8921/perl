#!/usr/bin/env perl
#===============================================================================
#
#         FILE: n.pl
#
#        USAGE: ./n.pl
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
#      CREATED: 12/01/2017 10:40:27 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;

package Cjj;
use Crypt::RSA;
use Data::Dumper;

sub new {
    my $rsa = new Crypt::RSA;
    my ( $public, $private ) = $rsa->keygen(
        Identity  => 'hulixue@xiankan.com',
        Size      => 1024,
        Password  => 'Gxcm123',
        Verbosity => 1,
    ) or die $rsa->errstr();

    bless {
        public  => $public,
        private => $private,
        rsa     => $rsa,
      },
      'Cjj';

}

sub public {
    my $self = shift;
    my ( $hhhhhhh, $Pub ) = split /=/, Dumper( $self->{public} ), 2;
    return $Pub;
}

sub private {
    my $self = shift;
   # my ( $hhhhhhh, $Pri ) = split /=/, Dumper( $self->{private} ), 2;
    return $self->{private};
}

sub rsa {
    my $self = shift;
    my ( $hhhhhhh, $R ) = split /=/, Dumper( $self->{rsa} ), 2;
    return $R;
}

1
