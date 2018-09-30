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
#      CREATED: 05/09/2018 05:30:51 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use YAML qw(Dump Bless);

my $host_port = "30000";
my $meta      = "rcperl";

my $rongqi;
$rongqi->{name}        = "rcperl";                     #必须小写
$rongqi->{port}        = "1234";
$rongqi->{image}       = "192.168.1.34:5000/hlx/fuzai";
$rongqi->{workdir}     = "/usr/local/perl";
$rongqi->{command}     = ["perl"];
$rongqi->{args}        = ["mq.pl"];
$rongqi->{hostNetwork} = "false";

my $hash->{apiVersion} = "v1";
$hash->{kind} = "ReplicationController";

$hash->{metadata}->{name} = $meta;

$hash->{spec}->{replicas} = "2";
$hash->{spec}->{template}->{metadata}->{labels}->{app} = $meta;

$hash->{spec}->{template}->{spec}->{containers}->[0]->{name} = $rongqi->{name};
$hash->{spec}->{template}->{spec}->{containers}->[0]->{image} =
  $rongqi->{image};
$hash->{spec}->{template}->{spec}->{containers}->[0]->{imagePullPolicy} = "Never";
$hash->{spec}->{template}->{spec}->{containers}->[0]->{workingDir} =$rongqi->{workdir};

#$hash->{spec}->{template}->{spec}->{containers}->[0]->{restartPolicy} = "Never";

=cut
$hash->{spec}->{template}->{spec}->{containers}->[0]->{ports}->[0]->{name} =
  $rongqi->{name};
$hash->{spec}->{template}->{spec}->{containers}->[0]->{ports}->[0]
  ->{containerPort} = $rongqi->{port};
$hash->{spec}->{template}->{spec}->{containers}->[0]->{ports}->[0]->{hostPort} =
  $host_port;
=cut

$hash->{spec}->{template}->{spec}->{containers}->[0]->{command} =
  $rongqi->{command};
$hash->{spec}->{template}->{spec}->{containers}->[0]->{args} = $rongqi->{args};
$hash->{spec}->{template}->{spec}->{containers}->[0]->{workingDir} =
  $rongqi->{workdir};


$hash->{spec}->{template}->{spec}->{containers}->[0]->{resources}->{limits}
  ->{cpu} = "100";
$hash->{spec}->{template}->{spec}->{containers}->[0]->{resources}->{limits}
  ->{memory} = "16G";
$hash->{spec}->{template}->{spec}->{containers}->[0]->{resources}->{requests}
  ->{memory} = "5G";
$hash->{spec}->{template}->{spec}->{containers}->[0]->{resources}->{requests}
  ->{cpu} = "2";

$hash->{spec}->{template}->{spec}->{containers}->[0]->{volumeMounts}->[0]
  ->{name} = "hulixuev";
$hash->{spec}->{template}->{spec}->{containers}->[0]->{volumeMounts}->[0]
  ->{mountPath} = "/mnt";
$hash->{spec}->{template}->{spec}->{volumes}->[0]->{name} = "hulixuev";
$hash->{spec}->{template}->{spec}->{volumes}->[0]->{hostPath}->{path} = "/data";

my $h->{kind}='Service';
   $h->{apiVersion}='v1';
   $h->{metadata}->{name}=$meta;
   $h->{metadata}->{labels}->{app}="$meta";

   $h->{spec}->{type}='NodePort';
   $h->{spec}->{ports}->[0]->{port}=$rongqi->{port};
   $h->{spec}->{ports}->[0]->{nodePort}=$host_port;
   $h->{spec}->{selector}->{app}=$meta;

print Dump $hash, $h;

