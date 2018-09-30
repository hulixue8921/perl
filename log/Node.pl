#!/usr/bin/env perl
#===============================================================================
#
#         FILE: X.pl
#
#        USAGE: ./X.pl
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
#      CREATED: 03/08/18 07:41:56
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use Model::Cjj;
use Model::JJ;
use Data::Dumper;
use POE qw (Wheel::SocketFactory Wheel::ReadWrite Wheel::FollowTail);
use JSON;
use Encode;
use File::Basename;

my $dir = dirname(__FILE__);
open my $conf, "$dir/Conf/x.conf" or die "no x.conf , please set x.conf";
my $Conf;

while (<$conf>) {
    chomp;
    my ( $x, $y ) = split /:/;

    $Conf->{$x} = $y;

}

die "set x.conf error , please reset x.conf"
  unless $Conf->{ID}
  and $Conf->{host}
  and $Conf->{port}
  and $Conf->{reconnect_time};

my $host = $Conf->{ID};

my $M         = Cjj->new();
my $jiemi_sig = JJ->new( rsa => $M->rsa, private => $M->private );
my $public    = $M->public;
my $rsa       = $M->rsa;
my $json      = JSON->new->utf8;

POE::Session->create(
    inline_states => {
        _start       => \&Conneting,
        connected    => \&Connected,
        failcon      => \&Failcon,
        receve       => \&Receve,
        lose_con     => \&Lose_con,
        respond_ping => \&Respond_ping,
    },

);

sub Conneting {
    say "start to connect:C !!!!";
    $_[HEAP]{hand} = POE::Wheel::SocketFactory->new(
        RemoteAddress => $Conf->{host},
        RemotePort    => $Conf->{port},
        SuccessEvent  => 'connected',
        FailureEvent  => 'failcon',
    );

}

sub Connected {
    my $hand = $_[ARG0];
    $_[HEAP]{con} = POE::Wheel::ReadWrite->new(
        Handle     => $hand,
        InputEvent => 'receve',
        ErrorEvent => 'lose_con',
    );

    my $send = {
        host     => $host,
        rsa      => $rsa,
        public   => $public,
        type     => 'auth',
        authinfo => $jiemi_sig->sig($host),
    };

    $_[HEAP]{con}->put( $json->encode($send) );

}

sub Receve {
    my $info = $_[ARG0];
    my $Info = $json->decode($info);
    if ( $Info->{type} eq 'ping' ) {
        $poe_kernel->yield( "respond_ping", $Info );
    }
    elsif ( $Info->{type} eq 'auth_respond_fail' ) {
        die "$Info->{info}";
    }
    elsif ( $Info->{type} eq 'first' ) {
        POE::Session->create(
            inline_states => {
                _start      => \&Con_m,
                m_connected => \&m_Connected,
                m_failcon   => \&m_Failcon,
                m_lose_con  => \&m_Failcon,
                send_m      => \&Send_m,
                _stop       => \&stop,
            },
            args => [ $Info->{port}, $Info->{info} ],
        );

    }
}

sub Con_m {
    my $port = $_[ARG0];
    $_[HEAP]{info} = $_[ARG1];

    $_[HEAP]{hand} = POE::Wheel::SocketFactory->new(
        RemoteAddress => $Conf->{host},
        RemotePort    => $port,
        SuccessEvent  => 'm_connected',
        FailureEvent  => 'm_failcon',
    );

}

sub m_Connected {
    my $hand = $_[ARG0];
    my $info = $_[HEAP]{info};

    $_[HEAP]{con} = POE::Wheel::ReadWrite->new(
        Handle     => $hand,
        ErrorEvent => "m_lose_con",
    );

    foreach my $file (@$info) {
        $_[HEAP]{file}{$file} = POE::Wheel::FollowTail->new(
            Filename   => $file,
            InputEvent => 'send_m',

        );

    }

}

sub m_Failcon {

    $poe_kernel->yield("_stop");

}

sub stop {
    delete $_[HEAP]{file};
    delete $_[HEAP]{con};
    say "M'port is down !!!!";

}

sub Send_m {
    my $info = $_[ARG0];
    $_[HEAP]{con}->put( $Conf->{ID} . ":" . $info );
}

sub Respond_ping {
    my $Info = $_[ARG0];

    my $send = {
        host         => $host,
        rsa          => $rsa,
        public       => $public,
        type         => 'respond_ping',
        respond_ping => $Info->{info},
    };

    $_[HEAP]{con}->put( $json->encode($send) );

}

sub Lose_con {
    $poe_kernel->delay_add( "_start" => $Conf->{reconnect_time} );
}

sub Failcon {
    $poe_kernel->delay_add( "_start" => $Conf->{reconnect_time} );
}

$poe_kernel->run();

