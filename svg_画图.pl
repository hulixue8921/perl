#!/usr/bin/env perl
#===============================================================================
#
#         FILE: 4.pl
#
#        USAGE: ./4.pl
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
#      CREATED: 07/18/2018 10:16:03 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;

use SVG;

my $svg = SVG->new( width => 2000, height => 2000 );

my @qidian = ( 150, 100 );
my $x      = 500;
my $y      = 400;
my $xk     = 10;
my $yk     = 5;

my $xkl = ($x-20) / $xk;
my $ykl = ($y-20) / $yk;

my $Y = $svg->line(
    id    => 'l1',
    x1    => $qidian[0],
    y1    => $qidian[1],
    x2    => $qidian[0],
    y2    => $qidian[1] + $y,
    style => {
        'stroke'         => 'blue',
        'stroke-width'   => '1',
        'stroke-opacity' => '1',
    }
);

my $X = $svg->line(
    id    => 'l2',
    x1    => $qidian[0],
    y1    => $qidian[1] + $y,
    x2    => $qidian[0] + $x,
    y2    => $qidian[1] + $y,
    style => {
        'stroke'         => 'blue',
        'stroke-opacity' => '1',
        'stroke-width'   => '1',
    }
);

# x 轴的刻度
for my $k ( 1 .. $xk ) {
    my @x = ( $qidian[0] + $xkl * $k, $qidian[1] + $y );
    my @y = ( $qidian[0] + $xkl * $k, $qidian[1] + $y + 10 );

    my @a = ( $qidian[0] + $xkl * $k, $qidian[1] );
    my @b = ( $qidian[0] + $xkl * $k, $qidian[1] + $y );

    $svg->line(
        x1    => $x[0],
        y1    => $x[1],
        x2    => $y[0],
        y2    => $y[1],
        style => {
            'stroke'         => 'blue',
            'stroke-opacity' => '1',
            'stroke-width'   => '1',
          }

    );

    $svg->line(
        x1    => $a[0],
        y1    => $a[1],
        x2    => $b[0],
        y2    => $b[1],
        style => {
            'stroke'         => 'black',
            'stroke-opacity' => '0.6',
            'stroke-width'   => '0.1',
          }

    );
}

# y 轴的刻度
for my $k ( 1 .. $yk  ) {
    my @x = ( $qidian[0], $qidian[1] + $y - $ykl * $k );
    my @y = ( $qidian[0] - 10, $qidian[1] + $y - $ykl * $k );

    my @a = ( $qidian[0], $qidian[1] + $y - $ykl * $k );
    my @b = ( $qidian[0] + $x, $qidian[1] + $y - $ykl * $k );

    $svg->line(
        x1    => $x[0],
        y1    => $x[1],
        x2    => $y[0],
        y2    => $y[1],
        style => {
            'stroke'         => 'blue',
            'stroke-opacity' => '1',
            'stroke-width'   => '1',
          }

    );
    $svg->line(
        x1    => $a[0],
        y1    => $a[1],
        x2    => $b[0],
        y2    => $b[1],
        style => {
            'stroke'         => 'black',
            'stroke-opacity' => '0.6',
            'stroke-width'   => '0.1',
          }

    );
}

my $XV = $svg->text(
    id    => 't1',
    x     => $qidian[0] + $x,
    y     => $qidian[1] + $y + 20,
    style => {
        'font'      => 'Arial',
        'font-size' => 20
    }
)->cdata('x');

my $YV = $svg->text(
    id => 't2',
    x  => $qidian[0] - 20,
    y  => $qidian[1],
)->cdata('y');

print $svg->xmlify;

