#!/usr/bin/env perl
#===============================================================================
#
#         FILE: C.pl
#
#        USAGE: ./C.pl
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
#      CREATED: 03/07/18 06:10:34
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use JSON;
use POE qw (Wheel::SocketFactory Wheel::ReadWrite);
use Encode;
use Model::Cjj;
use Model::JJ;
use Socket qw (AF_INET inet_ntop);

my $clients = {};

my $IDs = { id => 'hostname', };
my $pingtime = 5;

my $json = JSON->new()->utf8;
my $Null = Cjj->new();

POE::Session->create(
    inline_states => {
        _start        => \&Listen,
        listen_fail   => \&Listen_fail,
        connected     => \&Connected,
        m_listen_fail => \&m_Listen_fail,
        m_connected   => \&m_Connected,
    },

);

sub Listen {
    my $port = POE::Wheel::SocketFactory->new(
        BindPort       => '9000',
        SocketProtocol => 'tcp',
        SuccessEvent   => 'connected',
        FailureEvent   => 'listen_fail',
        Reuse          => 'on',
    );

    my $m_port = POE::Wheel::SocketFactory->new(
        BindPort       => '9100',
        BindAddress    => '127.0.0.1',
        SocketProtocol => 'tcp',
        SuccessEvent   => 'm_connected',
        FailureEvent   => 'm_listen_fail',
        Reuse          => 'on',
    );

    $_[HEAP]{port}  = $port;
    $_[HEAP]{mport} = $m_port;
}

sub Listen_fail {
    say "start port:9000 , fail !!!!";
}

sub Connected {
    my $hand = $_[ARG0];

    my $peer_host = inet_ntop( AF_INET, $_[ARG1] );

    POE::Session->create(
        inline_states => {
            _start   => \&Bind_con,
            receve   => \&Receve,
            lose_con => \&Lose_con,
            auth     => \&Auth,
            ping     => \&Ping,
            check    => \&Check,
            send_x   => \&Send_x,
            _stop    => \&stop,

        },

        args => [ $hand, $peer_host ],

    );

}

sub Bind_con {
    my $hand      = $_[ARG0];
    my $peer_host = $_[ARG1];

    $_[HEAP]{con} = POE::Wheel::ReadWrite->new(
        Handle     => $hand,
        InputEvent => "receve",
        ErrorEvent => "lose_con",
    );

    $_[HEAP]{ip} = $peer_host;
}

sub Lose_con {

}

sub Receve {
    my $info = $_[ARG0];

    my $Info = eval { $json->decode($info); };
    if ($@) {
        delete $_[HEAP]{con};
        return;
    }

    unless ($Info->{type}
        and $Info->{rsa}
        and $Info->{public}
        and $Info->{host} )
    {
        delete $_[HEAP]{con};
        return;
    }

    if ( $Info->{type} eq 'auth' ) {
        unless ( $Info->{authinfo} ) {
            delete $_[HEAP]{con};
            return;
        }
        $poe_kernel->yield( "auth", $Info );
    }
    elsif ( $Info->{type} eq 'respond_ping' ) {
        if ( exists $IDs->{ $_[SESSION]->ID }
            and $Info->{respond_ping} )
        {
            $clients->{ $Info->{host} }->{check} = $Info->{respond_ping};
        }

    }

}

sub Ping {
    my $send_check = rand();
    my $c_x        = {
        type => 'ping',
        info => $send_check,
    };

    $_[HEAP]{con}->put( $json->encode($c_x) );
    $clients->{ $IDs->{ $_[SESSION]->ID } }->{send_check} = $send_check;
    $poe_kernel->delay_add( "check" => $pingtime );

}

sub Check {
    my $host = $IDs->{ $_[SESSION]->ID };

    unless ( $clients->{$host}->{check} ) {
        say "$host  network is down !!!!!, i will shutdown this hand ";
        delete $_[HEAP]{con};
        $poe_kernel->yield("_stop");
        return;
    }

    unless ( $clients->{$host}->{send_check} eq $clients->{$host}->{check} ) {
        say "$host  network is down !!!!!, i will shutdown this hand ";
        delete $_[HEAP]{con};
        $poe_kernel->yield("_stop");
        return;
    }
    else {
        say "$host  network is ok !!!!!";
        $poe_kernel->yield("ping");
    }

}

sub Auth {
    my $Info = $_[ARG0];
    my $jiami_ver = JJ->new( rsa => $Info->{rsa}, public => $Info->{public} );
    my $ver_ok =
      eval { $jiami_ver->Verify( $Info->{host}, $Info->{authinfo} ) };
    if ($ver_ok) {
        if ( exists $clients->{ $Info->{host} } ) {
            my $auth_respond = {
                type => 'auth_respond_fail',
                info =>
"$Info->{host}:  hostname is authed by IP: $clients->{$Info->{host}}->{ip} , please set other hostname !!!"
            };
            $_[HEAP]{con}->put( $json->encode($auth_respond) );
            say "$auth_respond->{info}";
        }
        else {
            $clients->{ $Info->{host} }->{conid} = $_[SESSION]->ID;
            $clients->{ $Info->{host} }->{ip}    = $_[HEAP]{ip};
            $IDs->{ $_[SESSION]->ID }            = $Info->{host};
            say " $Info->{host} auth ok !!!! ";

            $poe_kernel->yield("ping");
        }

    }
    else {
        say "$Info->{host} auth fail !!!!";
        delete $_[HEAP]{con};
        return;
    }

}

sub stop {

    my $session_id = $_[SESSION]->ID;

    if ( exists $IDs->{$session_id} ) {
        delete $clients->{ $IDs->{$session_id} };
        delete $IDs->{$session_id};
    }

    say "stop $session_id";

}

sub m_Connected {
    my $hand = $_[ARG0];

    POE::Session->create(
        inline_states => {
            _start     => \&m_Bind,
            m_receve   => \&m_Receve,
            m_lose_con => \&m_Lose_con,
            host_info  => \&Host_info,
            _stop      => \&m_stop,

        },

        args => [$hand],
    );

}

sub m_Bind {
    my $hand = $_[ARG0];

    $_[HEAP]{con} = POE::Wheel::ReadWrite->new(
        Handle     => $hand,
        InputEvent => "m_receve",
        ErrorEvent => "m_lose_con",
    );

}

sub m_Receve {
    my $info = $_[ARG0];
    my $Info = $json->decode($info);

    if ( $Info->{type} eq 'host_info' ) {
        $poe_kernel->yield("host_info");
    }
    elsif ( $Info->{type} eq 'first' ) {
        my $result = &check_x( $Info->{info} );
        $_[HEAP]{con}->put( $json->encode($result) );
        if ( $result->{type} eq '1' ) {
            foreach my $host ( keys $Info->{info} ) {
                my $xinfo;
                $xinfo->{type} = 'first';
                $xinfo->{rand} = $Info->{check};
                $xinfo->{info} = $Info->{info}->{$host};
                $xinfo->{port} = $Info->{port};

                $poe_kernel->post( $clients->{$host}->{conid},
                    'send_x', $xinfo );
            }
        }
    }
    elsif ( $Info->{type} eq 'second' ) {
       # $_[HEAP]{con}->put( $json->encode($c_x) );
    }

}

sub Send_x {
    my $info = $_[ARG0];
    $_[HEAP]{con}->put ( $json->encode ( $info ) );
}

sub check_x {
    my $info = shift;
    my $result;

    my @all = keys %$clients;
    my @if  = keys %$info;

    my %all = map { $_ => 1 } @all;
    my %if  = map { $_ => 1 } @if;

    my @result = grep { !$all{$_} } @if;

    if (@result) {
        $result->{type} = 0;
        $result->{host} = \@result;
    }
    else {
        $result->{type} = 1;
    }
    return $result;

}

sub Host_info {
    my $info = {
        info => $clients,
        type => 'host_info_respond',
    };
    my $Info = $json->encode($info);
    $_[HEAP]{con}->put($Info);

}

sub m_Lose_con {
    delete $_[HEAP]{con};
}

sub m_stop {
    say "mange is over !!!";
}

$poe_kernel->run;

