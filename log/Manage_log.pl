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
use POE qw (Wheel::SocketFactory Wheel::ReadWrite);
use JSON;
use Encode;
use Data::Dumper;
use File::Basename;

my $json = JSON->new->utf8;

my $param = $ARGV[0] ? $ARGV[0] : "hostinfo";

my $send;

my $clients;

my $port = $$;

sub set_param {

    unless ( $param eq "hostinfo" ) {
        my $dir = dirname(__FILE__);
        open my $conf, "$dir/Conf/m.conf"
          or die "no m.conf , please set m.conf";

        while (<$conf>) {
            chomp;
            my ( $project, $order ) = split /:/;

            if ( $project eq $param ) {
                $send->{type}  = "first";
                $send->{info}  = eval $order;
                $send->{check} = rand();
                $send->{port}  = $port;

                POE::Session->create(
                    inline_states => {
                        _start        => \&Listen,
                        x_connected   => \&x_Connected,
                        x_listen_fail => \&x_Listen_fail,

                    },

                    args => [$port],

                );

            }
            else {
                next;
            }

        }

    }
    else {
        $send->{type} = "host_info";
    }
}

sub Listen {
    my $port = $_[ARG0];

    $_[HEAP]{S} = POE::Wheel::SocketFactory->new(
        BindPort       => $port,
        SocketProtocol => 'tcp',
        SuccessEvent   => 'x_connected',
        FailureEvent   => 'x_listen_fail',
        Reuse          => 'on',
    );

}

sub x_Connected {
    my $hand = $_[ARG0];

    POE::Session->create(
        inline_states => {
            _start     => \&Bind_x,
            x_receve   => \&x_Receve,
            x_lose_con => \&x_Lose_con,

        },

        args => [$hand],

    );

}

sub Bind_x {
    my $hand = $_[ARG0];

    $_[HEAP]{con} = POE::Wheel::ReadWrite->new(
        Handle     => $hand,
        InputEvent => "x_receve",
        ErrorEvent => "x_lose_con",
    );

}

sub x_Receve {
    say $_[ARG0];
}

sub x_Lose_con {

}

sub x_Listen_fail {
    say "start log'port listen fail .....";
    exit;
}

POE::Session->create(
    inline_states => {
        _start    => \&Conneting,
        connected => \&Connected,
        failcon   => \&Failcon,
        receve    => \&Receve,
        lose_con  => \&Lose_con,
        check_x   => \&Check_x,
    },

);

sub Conneting {
    $_[HEAP]{hand} = POE::Wheel::SocketFactory->new(
        RemoteAddress => '127.0.0.1',
        RemotePort    => 9100,
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

    &set_param;
    $_[HEAP]{con}->put( $json->encode($send) );

}

sub Receve {
    my $info = $_[ARG0];
    my $Info = $json->decode($info);

    if ( $Info->{type} eq 'host_info_respond' ) {
        say Dumper $Info->{info};
        delete $_[HEAP]{con};
    }
    elsif ( $Info->{type} eq '0' ) {
        say "@{$Info->{host}}  is  DOWn !!!!";
        exit;
    }
    elsif ( $Info->{type} eq '1' ) {
        foreach ( keys %{ $send->{info} } ) {
            $clients->{$_}->{rand} = $send->{check};
        }

#        $poe_kernel->delay_add( "check_x", "5" );

    }

}

sub Check_x {
    my @result = grep { $clients->{$_}->{rand} ne 'ok' } keys %$clients;
    if (@result) {
        say "@result isnot  connect M'port !!!!";
        exit;
    }
    else {
        $send->{type} = 'second';
        $_[HEAP]{con}->put( $json->encode($send) );
    }
}

sub Lose_con {
    exit;
}

sub Failcon {
    say "C  is not start !!!";
    exit;
}

$poe_kernel->run();

