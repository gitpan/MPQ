#! /usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

BEGIN { use_ok('MPQ::Archive::HashEntry'); }
my $entry = new_ok('MPQ::Archive::HashEntry');

