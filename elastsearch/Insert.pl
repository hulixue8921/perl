#!/usr/bin/env perl
#===============================================================================
#
#         FILE: Insert.pl
#
#        USAGE: ./Insert.pl
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
#      CREATED: 06/22/2018 10:43:17 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use DBI;
use Data::Dumper;
use LWP;
use JSON;
use Encode;

my $json      = JSON->new->utf8;
my $ua        = LWP::UserAgent->new();
my $elasthost = '192.168.1.23';
my $mysqlhost = 'x.x.x.x';

my $mysql = {
    database => 'x',
    host     => $mysqlhost,
    port     => 'x',
    user     => 'x',
    passwd   => 'x',
};

my $d =
"DBI:mysql:database=$mysql->{database};host=$mysql->{host};port=$mysql->{port}";
my $dbh = DBI->connect( $d, $mysql->{user}, $mysql->{passwd} )
  or die " connect mysql fail !!!";

$dbh->do("SET character_set_client='utf8'");
$dbh->do("SET character_set_connection='utf8'");
$dbh->do("SET character_set_results='utf8'");

my $xk_actor =
q { select id , name , pic, updatetime from  xk_actor where id > ?  order by id asc };
my $xk_news =
q {select a.*,b.content  from xk_news a,xk_news_info b where  a.news_id=b.news_id and a.state=1 and a.news_id > ? order by a.news_id asc  };
my $xk_movies =
q { select id , title ,type, h_m_cover ,v_m_cover,duration, playcount,stream_url,pubdate, updateline from xk_movies where status=1 and  type != 3 and id > ? order by id asc };

my $xk_videos =
q { select id , title , h_m_cover ,duration, playcount,stream_url, updateline from  xk_videos where status=1  and id > ? order by id asc };

my $xk_movies_sub = sub {
    my $dbh   = shift;
    my $hand  = shift;
    my $req   = shift;
    my $local = shift;
    &action( $dbh, $hand, $xk_movies, $local, $req, {} );
};
my $xk_news_sub = sub {
    my $dbh   = shift;
    my $hand  = shift;
    my $req   = shift;
    my $local = shift;
    &action( $dbh, $hand, $xk_news, $local, $req, {} );
};
my $xk_actor_sub = sub {
    my $dbh   = shift;
    my $hand  = shift;
    my $req   = shift;
    my $local = shift;
    &action( $dbh, $hand, $xk_actor, $local, $req, { 'name' => 'title' } );
};

my $xk_videos_sub = sub {
    my $dbh   = shift;
    my $hand  = shift;
    my $req   = shift;
    my $local = shift;
    &action( $dbh, $hand, $xk_videos, $local, $req, {} );
};

my $actions = {
    'xk_movies' => $xk_movies_sub,
    'xk_news'   => $xk_news_sub,
    'xk_actor'  => $xk_actor_sub,
    'xk_videos' => $xk_videos_sub,
};

sub action {
    my ( $dbh, $hand, $sql, $L, $req, $tan ) = @_;
    my $sth = $dbh->prepare($sql);
    $sth->execute($L);

    my $Local;
    while ( my $data = $sth->fetchrow_hashref ) {
        my $req_n;
        foreach my $key ( keys %$data ) {
            my $v = $data->{$key};
            Encode::_utf8_on($v);
            if ( $key ~~ %$tan ) {
                $req_n->{ $tan->{$key} } = $v;
            }
            else {
                $req_n->{$key} = $v;
            }
        }
        $req->content( $json->encode($req_n) );
        my $es = $ua->request($req);

        #    say $es->content;
        $Local->{id}      = $data->{id}      if exists $data->{id};
        $Local->{news_id} = $data->{news_id} if exists $data->{news_id};
    }

    if ( exists $Local->{id} ) {
        say $hand $Local->{id};
    }
    elsif ( exists $Local->{news_id} ) {
        say $hand $Local->{news_id};
    }
    else {
        say $hand $L;
    }

}

sub Insert {
    my $dbh   = shift;
    my $elast = shift;

    my $Local;

    my $req =
      HTTP::Request->new( POST => "http://$elasthost:9200/$elast/$elast" );
    $req->content_type('application/json');

    if ( open my $x, "<$elast" ) {
        $Local = <$x>;
    }
    else {
        $Local = '-1';
    }

    open my $hand, ">$elast";

    $actions->{$elast}->( $dbh, $hand, $req, $Local );

}

&Insert( $dbh, 'xk_movies' );
&Insert( $dbh, 'xk_news' );
&Insert( $dbh, 'xk_actor' );
&Insert( $dbh, 'xk_videos' );
