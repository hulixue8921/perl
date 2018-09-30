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
#      CREATED: 12/18/2017 11:17:26 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use LWP;
use JSON;
use Data::Dumper;

my $json = JSON->new->utf8;

my $ua = LWP::UserAgent->new();

my $req = HTTP::Request->new( POST => 'http://192.168.1.34:9200/my_index/xxx' );

$req->content_type('application/json');


$N->{}=10000;


$req->content( $json->encode($N) );

my $es = $ua->request($req);

say $es->content;

