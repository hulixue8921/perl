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

package JJ;

use Crypt::RSA;

sub new {
    my $class = shift;
    my @param = @_;

    my $x = {};

    my $y = {
        private => sub {
            my $private = shift;
            $x->{private} = $private;
        },
        public => sub {
            my $public = shift;
            $x->{public} = eval $public;
        },
        rsa => sub {
            my $rsa = shift;
            $x->{rsa} = eval $rsa;
        },

    };

    while ( @param && ( $#param + 1 ) % 2 == 0 ) {
        my @x = splice @param, 0, 2;
        $y->{ $x[0] }->( $x[1] ) if exists $y->{ $x[0] };
    }

    bless $x, $class;
}

sub jiami {
    my $self   = shift;
    my $string = shift;

    die "object is error !!!!" unless $self->{rsa} or $self->{public};

    my $x = $self->{rsa}->encrypt(
        Message => $string,
        Key     => $self->{public},
        Armour  => 1,
    ) || die $self->{rsa}->errstr() ;

        return $x;

}

sub jiemi {
    my $self   = shift;
    my $string = shift;

    die "object is error !!!!" unless $self->{rsa} or $self->{private};

    my $x = $self->{rsa}->decrypt(
        Cyphertext => $string,
        Key        => $self->{private},
        Armour     => 1,
    )   || die $self->{rsa}->errstr() ;

        return $x;

}

 sub sig {
     my $self=shift;
     my $mess=shift;
    
     die "object is error !!!!" unless $self->{rsa} or $self->{private};

     my $sig= $self->{rsa}->sign (
                Message => $mess,
                Key =>  $self->{private},
             ) || die $self->{rsa}->errstr();

     return $sig;
 
 }

sub Verify {
     my $self=shift;
     my $mess=shift;
     my $sig=shift;

     my $ver=$self->{rsa}->verify (
              Message => $mess,
                Key   => $self->{public},
                Signature => $sig,
             ) || die $self->{rsa}->errstr();

     return $ver;
 
 }

1
