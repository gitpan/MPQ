#! /usr/bin/perl

use strict;
use warnings;

use MPQ;

my $filename = shift;
my $mpq = MPQ->new(
    filename  => $filename
);

$mpq->parse;
my $archive = $mpq->archive;

print $archive->file('(attributes)')->slurp;
