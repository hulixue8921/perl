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
my $hash->{apiVersion}="v1";
   $hash->{kind}="Pod";
   
   $hash->{metadata}->{name}="perl";
   $hash->{metadata}->{labels}->{name}="perl";
  

   $hash->{spec}->{containers}->[0]->{name}="perl";
   $hash->{spec}->{containers}->[0]->{image}="192.168.1.34:5000/hlx/mq";
   $hash->{spec}->{containers}->[0]->{workingDir}="/usr/local/perl";
   
   
   $hash->{spec}->{containers}->[0]->{ports}->[0]->{name}="perl";
   $hash->{spec}->{containers}->[0]->{ports}->[0]->{containerPort}=1234;
   $hash->{spec}->{containers}->[0]->{ports}->[0]->{hostPort}=1234;
   
   $hash->{spec}->{containers}->[0]->{command}=["perl"];
   $hash->{spec}->{containers}->[0]->{args}=["mq.pl"];
   $hash->{spec}->{containers}->[0]->{workingDir}="/usr/local/perl";
   
   $hash->{spec}->{containers}->[0]->{resources}->{limits}->{cpu}="100";
   $hash->{spec}->{containers}->[0]->{resources}->{limits}->{memory}="2G";
   $hash->{spec}->{containers}->[0]->{resources}->{requests}->{memory}="1G";
   $hash->{spec}->{containers}->[0]->{resources}->{requests}->{cpu}="2";
   $hash->{spec}->{containers}->[0]->{restartPolicy}="Never";
  
   $hash->{spec}->{containers}->[0]->{volumeMounts}->[0]->{name}="hulixuev";
   $hash->{spec}->{containers}->[0]->{volumeMounts}->[0]->{mountPath}="/mnt";
   $hash->{spec}->{volumes}->[0]->{name}="hulixuev";
   $hash->{spec}->{volumes}->[0]->{hostPath}->{path}="/data";
  # $hash->{spec}->{containers}->[0]->{volumeMounts}->[0]->{readOnly}="boolean";



print Dump $hash;

