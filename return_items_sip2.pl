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
my $sc = SIP2::SC->new('aleph.unibas.ch:5331');

# Logfiles mit Timestamp
my $logfile_ubs = strftime("log/return_items_ubs_%Y%m%d.log", localtime); 
my $logfile_ube = strftime("log/return_items_ube_%Y%m%d.log", localtime); 
my $logfile_zbs = strftime("log/return_items_zbs_%Y%m%d.log", localtime); 

# Inputfiles mit Timestamp
my $inputfile_ubs = strftime("input/barcodes_ubs_%Y%m%d.sys", localtime);
my $inputfile_ube = strftime("input/barcodes_ube_%Y%m%d.sys", localtime);
my $inputfile_zbs = strftime("input/barcodes_zbs_%Y%m%d.sys", localtime);

#my $inputfile_ubs = strftime("input/barcodes_ubs_20210318.sys", localtime);
#my $inputfile_ube = strftime("input/barcodes_ube_20210318.sys", localtime);
#my $inputfile_zbs = strftime("input/barcodes_zbs_20210318.sys", localtime);

# Status der SIP2-Schnittstelle abfragen
$sc->message("9900302.00");

# Rueckbuchungen Basel (UBS)
open my $out_ubs, ">:utf8", $logfile_ubs or die "$0: open $logfile_ubs $!";
open my $in_ubs, "<", $inputfile_ubs or die "$0: open $inputfile_ubs: $!";

# Meldung falls keine Barcodes im Inputfile existieren
if (-z $inputfile_ubs ) {
    print "No barcodes for UBS\n";
    print $out_ubs "Keine Barcodes vom letzten Tag vorhanden (IZ UBS)\n";
}

# Für jeden Barcode im Inputfile einen SIP2-Befehl absetzen
while (my $z = <$in_ubs>) {
    chomp $z;
    #my $item = 'BM0575087';
    my $item = $z;
    my $logoutput = $sc->message("09N2020113    08142820091214    081428AP|AO|AB$item|AC|BIN|");
    my @logoutput = split( /\|/, $logoutput);
    
    my $barcode;
    my $title;
    my $sublibrary;
    my $message;

    for (@logoutput) {
    
        if ($_ =~ /^AB/ ) {
            $barcode = substr($_,2);
        } elsif ( $_ =~ /^AJ/ ) {
            $title = substr($_,2);
        } elsif ( $_ =~ /^AQ/ ) {
            $sublibrary = substr($_,2);
        } elsif ( $_ =~ /^AF/ ) {
            $message = substr($_,2);
        }
    }

    print $out_ubs $barcode . ":" . $sublibrary . ":" . $title . ":" . $message . "\n";
}

close $in_ubs;


# Rueckbuchungen Solothurn (ZBS)
open my $out_zbs, ">:utf8", $logfile_zbs or die "$0: open $logfile_zbs $!";
open my $in_zbs, "<", $inputfile_zbs or die "$0: open $inputfile_zbs $!";

# Meldung falls keine Barcodes im Inputfile existieren
if (-z $inputfile_zbs ) {
    print "No barcodes for ZBS\n";
    print $out_zbs "Keine Barcodes vom letzten Tag vorhanden (IZ ZBS)\n";
}

# Für jeden Barcode im Inputfile einen SIP2-Befehl absetzen
while (my $z = <$in_zbs>) {
    chomp $z;
    my $item = $z;
    my $logoutput = $sc->message("09N2020113    08142820091214    081428AP|AO|AB$item|AC|BIN|");
    my @logoutput = split( /\|/, $logoutput);

    my $barcode;
    my $title;
    my $sublibrary;
    my $message;

    for (@logoutput) {
    
        if ($_ =~ /^AB/ ) {
            $barcode = substr($_,2);
        } elsif ( $_ =~ /^AJ/ ) {
            $title = substr($_,2);
        } elsif ( $_ =~ /^AQ/ ) {
            $sublibrary = substr($_,2);
        } elsif ( $_ =~ /^AF/ ) {
            $message = substr($_,2);
        }
    }

    print $out_zbs $barcode . ":" . $sublibrary . ":" . $title . ":" . $message . "\n";
}

close $in_zbs;


# Rueckbuchungen Bern (UBE)
open my $out_ube, ">:utf8", $logfile_ube or die "$0: open $logfile_ube $!";
open my $in_ube, "<", $inputfile_ube or die "$0: open $inputfile_ube: $!";

# Meldung falls keine Barcodes im Inputfile existieren
if (-z $inputfile_ube ) {
    print "No barcodes for UBE\n";
    print $out_ube "Keine Barcodes vom letzten Tag vorhanden (IZ UBE)\n";
}

# Für jeden Barcode im Inputfile einen SIP2-Befehl absetzen
while (my $z = <$in_ube>) {
    chomp $z;
    my $item = $z;
    my $logoutput = $sc->message("09N2020113    08142820091214    081428AP|AO|AB$item|AC|BIN|");
    my @logoutput = split( /\|/, $logoutput);
    
    my $barcode;
    my $title;
    my $sublibrary;
    my $message;

    for (@logoutput) {
    
        if ($_ =~ /^AB/ ) {
            $barcode = substr($_,2);
        } elsif ( $_ =~ /^AJ/ ) {
            $title = substr($_,2);
        } elsif ( $_ =~ /^AQ/ ) {
            $sublibrary = substr($_,2);
        } elsif ( $_ =~ /^AF/ ) {
            $message = substr($_,2);
        }
    }

    print $out_ube $barcode . ":" . $sublibrary . ":" . $title . ":" . $message . "\n";
}

close $in_ube


