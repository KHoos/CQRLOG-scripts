#!/usr/bin/perl -w

# Fetch from cqrlog the 4 character maidenhead locators of contacts to create
# locator files to use in gcmwin
# 
# everything:  gcmwin-locators-all.log
# HF:          gcmwin-locators-hf.log
# 10m:         gcmwin-locators-10m.log
# 15m:         gcmwin-locators-15m.log
# 17m:         gcmwin-locators-17m.log
# 20m:         gcmwin-locators-20m.log
# 30m:         gcmwin-locators-30m.log
# 40m:         gcmwin-locators-40m.log
# 60m:         gcmwin-locators-60m.log
# 80m:         gcmwin-locators-80m.log
#
# 2m:          gcmwin-locators-2m.log
# 70cm:        gcmwin-locators-70cm.log
# via satellite:
#              gcmwin-PE4KH-locators-sat.log
#
# and the confirmed version listing squares in which at least one contact
# is confirmed via paper card or eqsl or lotw
#
# Yes, this creates an overlap of worked-and-confirmed squares, it could be
# neater to have unconfirmed and confirmed squares but I'd have to get the SQL
# query right

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

# all

querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main","gcmwin-locators-all.log");
querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE BAND IN (\"10M\",\"15M\",\"17M\",\"20M\",\"30M\",\"40M\",\"60M\",\"80M\",\"160M\")","gcmwin-locators-hf.log");
querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE ( QSL_R=\"Q\" OR EQSL_QSL_RCVD=\"E\" OR LOTW_QSLR=\"L\" ) AND BAND IN (\"10M\",\"15M\",\"17M\",\"20M\",\"30M\",\"40M\",\"60M\",\"80M\",\"160M\")","gcmwin-locatorsconfirmed-hf.log");

querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE BAND = \"10M\"","gcmwin-locators-10m.log");
querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE ( QSL_R=\"Q\" OR EQSL_QSL_RCVD=\"E\" OR LOTW_QSLR=\"L\" ) AND BAND = \"10M\"","gcmwin-locatorsconfirmed-10m.log");

querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE BAND = \"15M\"","gcmwin-locators-15m.log");
querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE ( QSL_R=\"Q\" OR EQSL_QSL_RCVD=\"E\" OR LOTW_QSLR=\"L\" ) AND BAND = \"15M\"","gcmwin-locatorsconfirmed-15m.log");
querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE BAND = \"17M\"","gcmwin-locators-17m.log");
querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE ( QSL_R=\"Q\" OR EQSL_QSL_RCVD=\"E\" OR LOTW_QSLR=\"L\" ) AND BAND = \"17M\"","gcmwin-locatorsconfirmed-17m.log");

querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE BAND = \"20M\"","gcmwin-locators-20m.log");
querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE ( QSL_R=\"Q\" OR EQSL_QSL_RCVD=\"E\" OR LOTW_QSLR=\"L\" ) AND BAND = \"20M\"","gcmwin-locatorsconfirmed-20m.log");

querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE BAND = \"30M\"","gcmwin-locators-30m.log");
querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE ( QSL_R=\"Q\" OR EQSL_QSL_RCVD=\"E\" OR LOTW_QSLR=\"L\" ) AND BAND = \"30M\"","gcmwin-locatorsconfirmed-30m.log");
querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE BAND = \"40M\"","gcmwin-locators-40m.log");
querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE ( QSL_R=\"Q\" OR EQSL_QSL_RCVD=\"E\" OR LOTW_QSLR=\"L\" ) AND BAND = \"40M\"","gcmwin-locatorsconfirmed-40m.log");
querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE BAND = \"60M\"","gcmwin-locators-60m.log");
querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE ( QSL_R=\"Q\" OR EQSL_QSL_RCVD=\"E\" OR LOTW_QSLR=\"L\" ) AND BAND = \"60M\"","gcmwin-locatorsconfirmed-60m.log");
querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE BAND = \"80M\"","gcmwin-locators-80m.log");
querytolog("SELECT DISTINCT LEFT(loc,4) FROM cqrlog_main WHERE ( QSL_R=\"Q\" OR EQSL_QSL_RCVD=\"E\" OR LOTW_QSLR=\"L\" ) AND BAND = \"80M\"","gcmwin-locatorsconfirmed-80m.log");
querytolog("SELECT DISTINCT LEFT(loc,6) FROM cqrlog_main WHERE BAND = \"2M\" AND PROP_MODE NOT IN (\"ECH\", \"RPT\", \"SAT\")","gcmwin-locators-2m.log");
querytolog("SELECT DISTINCT LEFT(loc,6) FROM cqrlog_main WHERE ( QSL_R=\"Q\" OR EQSL_QSL_RCVD=\"E\" OR LOTW_QSLR=\"L\" ) AND BAND = \"2M\" AND PROP_MODE NOT IN ( \"ECH\", \"RPT\", \"SAT\")","gcmwin-locatorsconfirmed-2m.log");
querytolog("SELECT DISTINCT LEFT(loc,6) FROM cqrlog_main WHERE BAND = \"70CM\" AND PROP_MODE NOT IN (\"ECH\", \"RPT\", \"SAT\")","gcmwin-locators-70cm.log");
querytolog("SELECT DISTINCT LEFT(loc,6) FROM cqrlog_main WHERE ( QSL_R=\"Q\" OR EQSL_QSL_RCVD=\"E\" OR LOTW_QSLR=\"L\" ) AND BAND = \"70CM\" AND PROP_MODE NOT IN (\"ECH\", \"RPT\", \"SAT\")","gcmwin-locatorsconfirmed-70cm.log");
querytolog("SELECT DISTINCT LEFT(loc,6) FROM cqrlog_main WHERE PROP_MODE = \"SAT\"","gcmwin-PE4KH-locators-sat.log");
querytolog("SELECT DISTINCT LEFT(loc,6) FROM cqrlog_main WHERE  ( QSL_R=\"Q\" OR EQSL_QSL_RCVD=\"E\" OR LOTW_QSLR=\"L\" ) AND PROP_MODE = \"SAT\"","gcmwin-PE4KH-locatorsconfirmed-sat.log");

sub querytolog {
	my $query = shift;
	my $logfile = shift;

	my $sth = $dbh->prepare($query);
	if (!$sth->execute){
		warn "Error:" . $sth->errstr."\n";
		return;
	}

	open my $fh, ">", $logfile or die "Opening ".$logfile." : ".$!;
	while (my $row = $sth->fetchrow_arrayref){
		if ($$row[0] ne ""){
			say $fh $$row[0];
		}
	}
	close $fh;
}

