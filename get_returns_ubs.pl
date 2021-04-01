#!/usr/bin/perl -w
# Holt von Alma Analytics die Barcodes zurueckgebrachter Medien und schreibt sie nach STDOUT

use HTTP::Request::Common;
use LWP;
use Encode;
use strict;

# vgl. https://developers.exlibrisgroup.com/blog/Working-with-Analytics-REST-APIs/
# Name des Reports und API-Key anpassen
my $anl_api = '';
my $report = decode("utf-8", '/shared/Region Basel 41SLSP_UBS/Reports/3RD/ALEPH-RETURN/Alma-to-Aleph-Loan-Return-Sync');
my $codes_per_page = 1000;     # allowed range: 25 - 1000

my $ua = LWP::UserAgent->new();
my $url = "https://api-eu.hosted.exlibrisgroup.com/almaws/v1/analytics/reports";
my $first_url = $url . "?path=$report&limit=$codes_per_page&apikey=$anl_api";
my $xml = getNextPage($first_url);

#print $xml . "\n";

# <ResumptionToken> nur beim Aufruf der ersten Seite. Fuer Folgeseiten diesen ersten Wert wiederverwenden.
my $resume_url;
my ($resumption_token) = $xml =~ /<ResumptionToken>(.+?)<\/ResumptionToken>/;
if ($resumption_token) { $resume_url = $url . "?token=$resumption_token&apikey=$anl_api"; }

my $cnt_returns = 0;
my $is_finished = 0; 
my $is_finished_xml; 

while (!$is_finished) {
   my @barcodes     = $xml =~ /<Column1>(.+?)<\/Column1>/g;
   #my @return_dates = $xml =~ /<Column2>(.+?)<\/Column2>/g;
   #my @return_times = $xml =~ /<Column3>(.+?)<\/Column3>/g;

   ($is_finished_xml)   = $xml =~ /<IsFinished>(.+?)<\/IsFinished>/;
   if ($is_finished_xml eq 'true')
      { $is_finished = 1; }

   while (@barcodes) {
      my $line = sprintf "%-30s", shift @barcodes;
   #   my $return_date = shift @return_dates;
   #   my $return_time = shift @return_times;
   #   $return_date =~ s/\-//g;
   #   $return_time =~ s/\://g;
   #   print $line . $return_date . $return_time ."0\n";
      print $line . "\n";
      $cnt_returns++;
   }

   unless ($is_finished)
      { $xml = getNextPage($resume_url); }
}

print STDERR "Alma meldet $cnt_returns zurückgebuchte Medien\n";
exit; 

sub getNextPage {
    my $url = shift;
    my $get = HTTP::Request->new(GET=>$url);
    my $xml_ref = $ua->request($get);
    return $$xml_ref{'_content'};
} 
