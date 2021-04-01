#! /usr/bin/perl

use warnings;
use strict;
use POSIX;

binmode(STDOUT, ":utf8");

# Modul SIP2::SC muss im Ordner lib vorhanden sein
use lib 'lib';
use SIP2::SC;

# Adresse Aleph Test-Server
#my $sc = SIP2::SC->new('alephtest.unibas.ch:5331');

# Adresse produktiver Aleph-Server
my $sc = SIP2::SC->new('ub-bibproxy1.ub.unibas.ch:5003');

# Logfiles mit Timestamp

# Status der SIP2-Schnittstelle abfragen
$sc->message("9900302.00");

my $item = 'BM0575087';

$sc->message("09N2020113    08142820091214    081428AP|AO|AB$item|AC|BIN|");


