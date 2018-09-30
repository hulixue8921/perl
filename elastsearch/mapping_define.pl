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

my $req = HTTP::Request->new( PUT => 'http://192.168.1.23:9200/ewang' );

$req->content_type('application/json');

my $n;

 $n->{mappings}->{product}->{properties}->{id}->{type} = "long";
 $n->{mappings}->{product}->{properties}->{product_id}->{type} = "long";
 $n->{mappings}->{product}->{properties}->{sku_code}->{type} = "string";
 $n->{mappings}->{product}->{properties}->{price}->{type} = "double";
 $n->{mappings}->{product}->{properties}->{user_price}->{type} = "double";
 $n->{mappings}->{product}->{properties}->{cost_price}->{type} = "double";
 $n->{mappings}->{product}->{properties}->{stock}->{type} = "long";
 $n->{mappings}->{product}->{properties}->{images}->{type} = "string";
 $n->{mappings}->{product}->{properties}->{sku_attribut_value_ids}->{type} = "long";
 $n->{mappings}->{product}->{properties}->{web_url}->{type} = "string";
 $n->{mappings}->{product}->{properties}->{is_show}->{type} = "long";
 $n->{mappings}->{product}->{properties}->{brand_id}->{type} = "long";
 $n->{mappings}->{product}->{properties}->{product_category_id}->{type} = "long";
 $n->{mappings}->{product}->{properties}->{topic_id}->{type} = "long";
 $n->{mappings}->{product}->{properties}->{app_cover_image}->{type} = "string";

 $n->{mappings}->{product}->{properties}->{create_time}->{type} = "date";
 $n->{mappings}->{product}->{properties}->{create_time}->{format} = "epoch_second";
 $n->{mappings}->{product}->{properties}->{show_time}->{type} = "date";
 $n->{mappings}->{product}->{properties}->{show_time}->{format} = "epoch_second";

 $n->{mappings}->{product}->{properties}->{search_key}->{type} = "string";
 $n->{mappings}->{product}->{properties}->{search_key}->{analyzer} = "ik_max_word";
 $n->{mappings}->{product}->{properties}->{search_key}->{search_analyzer} = "ik_smart";

 $n->{mappings}->{product}->{properties}->{brand_name}->{type} = "string";
 $n->{mappings}->{product}->{properties}->{brand_name}->{analyzer} = "ik_max_word";
 $n->{mappings}->{product}->{properties}->{brand_name}->{search_analyzer} = "ik_smart";

 $n->{mappings}->{product}->{properties}->{topic_name}->{type} = "string";
 $n->{mappings}->{product}->{properties}->{topic_name}->{analyzer} = "ik_max_word";
 $n->{mappings}->{product}->{properties}->{topic_name}->{search_analyzer} = "ik_smart";

 $n->{mappings}->{product}->{properties}->{show_name}->{type} = "string";
 $n->{mappings}->{product}->{properties}->{show_name}->{analyzer} = "ik_max_word";
 $n->{mappings}->{product}->{properties}->{show_name}->{search_analyzer} = "ik_smart";





=cut3不改变数据结构， 用于排序和聚合
$n->{mappings}->{My_type}->{properties}->{City}->{fields}->{RAW}->{type}="string";
$n->{mappings}->{My_type}->{properties}->{City}->{fields}->{RAW}->{analyzer}="english";
=cut


$req->content( $json->encode($n) );

my $es = $ua->request($req);

say $es->content;

