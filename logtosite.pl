#!/usr/bin/perl -wT

# Fetch from cqrlog the 50 most recent contacts and extract the fields to a
# .csv file as used on the top right of https://pe4kh.idefix.net/
# Some fields are extracted but not used

use strict;

use DBI;
use Text::CSV;

my $debug = 0;

# cqrlog002 is the second database in cqrlog (as PE4KH is my second callsign)
# adjust the path for your own cqrlog

my $dsn = "DBI:mysql:database=cqrlog002;mysql_socket=/home/koos/.config/cqrlog/database/sock";

my $dbh = DBI->connect($dsn, { RaiseError => 1, PrintError => 0,} );

if (!$dbh){
	if ($debug){
		warn "No db connection\n";
	}
	exit 1;
}

my $sth = $dbh->prepare("
	SELECT callsign,band,mode,loc,rst_s,rst_r,qsodate,time_on,time_off,prop_mode,satellite
	FROM cqrlog_main
	ORDER BY qsodate DESC, time_on DESC LIMIT 50");

if (!$sth->execute){
	if ($debug) {
		warn "Error:" . $sth->errstr."\n";
	}
	exit 1;
}
my @row;

my $csv = Text::CSV->new ( { binary => 1 } );

my $fh;

open $fh, ">:encoding(utf8)", "new.csv" or die "new.csv: $!";


while (@row = $sth->fetchrow_array()) {
	$csv->combine(@row);
	print $fh $csv->string()."\n";
	if ($debug) {
		printf "QSO with %s on %s in %s from %s snt %s rcv %s at %s %s %s\n",@row;
	}
}

close $fh;
