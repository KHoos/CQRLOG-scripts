#!/usr/bin/perl -wT

# Haal uit cqrlog callsigns die geselecteerd zijn voor een kaartje (SB, SMB)
# en ga vervolgens zoeken of er meer qso's zijn die op dat kaartje kunnen en
# markeer die hetzelfde
# Search in the cqrlog database callsigns that have been selected for a card
# (SB or SMB) and search for more contacts which could be added to that card
#
# at this moment does not update the other contacts, maybe a future option
# Also keeps a count of the number of cards

use strict;
#
# this needs to be the same setting as in cqrlog itself
my $contactspercard = 4;

use DBI;

use POSIX;

my $debug = 0;
my $totalcards = 0;

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

$totalcards += runcallsigns("SB");
$totalcards += runcallsigns("SMB");

printf "Total cards: %d\n",$totalcards;

sub runcallsigns {
	my $qsltype = shift;

	my $thistypecnt = 0;

#	my $sth = $dbh->prepare("SELECT DISTINCT callsign FROM cqrlog_main WHERE qsl_s = ?");
	my $sth = $dbh->prepare("SELECT callsign,count(id_cqrlog_main) FROM cqrlog_main WHERE qsl_s = ? GROUP BY callsign ORDER BY callsign");
	if (!$sth->execute($qsltype)){
		warn "Error:" . $sth->errstr."\n";
		return;
	}

	while (my $row = $sth->fetchrow_arrayref){
		printf "Callsign %s has qsltype %s\n",$$row[0],$qsltype;

		$thistypecnt += ceil($$row[1]/$contactspercard);
		my $sthother = $dbh->prepare("SELECT qsodate,time_on,band,mode FROM cqrlog_main WHERE callsign=? and qsl_s = ''");
		if (!$sthother->execute($$row[0])){
			warn "Error:" . $sthother->errstr."\n";
		} else {
			while (my $rowother = $sthother->fetchrow_arrayref){
				printf "Qsl without card option: Date %s time %s band %s mode %s\n",$$rowother[0],$$rowother[1],$$rowother[2],$$rowother[3];
			}
		}
	}
	printf "Total cards for type %s is %d\n",$qsltype,$thistypecnt;
	return $thistypecnt;
}

