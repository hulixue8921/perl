#!/usr/bin/env perl
#===============================================================================
#
#         FILE: mq.pl
#
#        USAGE: ./mq.pl
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
#      CREATED: 05/11/18 02:48:50
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use POE qw (Wheel::SocketFactory Wheel::ReadWrite);
use Socket qw (AF_INET inet_ntop);

my $name = `hostname`;

my $fabu = {
    'qa' => sub {
        my $param = shift;
        open my $hand, "-|", "/sysadmin/bin/qa/qa_v.sh $param";
        return $hand;
    },
    'm' => sub {
        my $param = shift;
        open my $hand, "-|", "/sysadmin/bin/m/m_v.sh $param";
        return $hand;
    },
    'app' => sub {
        my $param = shift;
        open my $hand, "-|", "/sysadmin/bin/app/app_v.sh $param";
        return $hand;
    },
    'www' => sub {
        my $param = shift;
        open my $hand, "-|", "/sysadmin/bin/www/www_v.sh $param";
        return $hand;
    },
    'cms' => sub {
        my $param = shift;
        open my $hand, "-|", "/sysadmin/bin/cms/cms_v.sh $param";
        return $hand;
    },
    'qacms' => sub {
        my $param = shift;
        open my $hand, "-|", "/sysadmin/bin/qacms/qacms_v.sh $param";
        return $hand;
    },
    'pay' => sub {
        my $param = shift;
        open my $hand, "-|", "/sysadmin/bin/pay/pay_v.sh $param";
        return $hand;
    },
};

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
        BindPort       => '1234',
        SocketProtocol => 'tcp',
        SuccessEvent   => 'connected',
        FailureEvent   => 'listen_fail',
        Reuse          => 'on',
    );
    $_[HEAP]{port} = $port;
}

sub Connected {
    my $hand = $_[ARG0];
    my $peer_host = inet_ntop( AF_INET, $_[ARG1] );
    POE::Session->create(
        inline_states => {
            _start       => \&Bind_con,
            receve       => \&Receve,
            order_receve => \&Order_Receve,
            lose_con     => \&Lose_con,
            _stop        => \&stop,
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

    $_[HEAP]{con}->put('domain@version:');
}

sub Receve {
    my $string = $_[ARG0];
    my ( $domain, $ver ) = split /@/, $string;

    if ( $domain && $ver && exists $fabu->{$domain} ) {
        my $hand = $fabu->{$domain}->($ver);
        $_[HEAP]{order} = POE::Wheel::ReadWrite->new(
            Handle     => $hand,
            InputEvent => "order_receve",
        );
    }
    else {
         $_[HEAP]{con}->put ( " param  is error !!!"  );
          $poe_kernel->post ("lose_con");
    }

}

sub Order_Receve {
    my $string = $_[ARG0];
    say $string;
    $_[HEAP]{con}->put("$string");
}

sub Lose_con {
    say "start lost";
    delete $_[HEAP]{con};
    delete $_[HEAP]{order};
    $poe_kernel->post("_stop");
}

sub stop {
    say "lost connt !!!";
    return;
}

$poe_kernel->run;
