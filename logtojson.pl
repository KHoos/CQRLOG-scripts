#!/usr/bin/perl -w

# export recent qso list to Geo JSON format for inclusion in a webpage
# with google maps
#
# webpage at https://pe4kh.idefix.net/qsomap.html

# based on
# https://github.com/mikegrb/p5-Misc-MacLoggerDX/blob/master/export-json.pl

use strict;

use DBI;
use JSON;
use Locale::Country;

use Geo::Distance;

my $debug = 0;

# cqrlog002 is the second database in cqrlog (as PE4KH is my second callsign)
# adjust the path for your own cqrlog

my $dsn = "DBI:mysql:database=cqrlog002;mysql_socket=/home/koos/.config/cqrlog/database/sock";

# adjust this for your home location
#
my ($homelat,$homelong)=maidenhead2latlong("JO22NC");

my $dbh = DBI->connect($dsn, { RaiseError => 1, PrintError => 0,} );

if (!$dbh){
	if ($debug){
		warn "No db connection\n";
	}
	exit 1;
}

my @mappoints;

my $geo = new Geo::Distance;

my $sth = $dbh->prepare("
	SELECT callsign,band,mode,loc,rst_s,rst_r,qsodate,time_on,time_off,freq
	FROM cqrlog_main
	WHERE loc != \"\"
	ORDER BY qsodate DESC,time_on DESC LIMIT 150");

if (!$sth->execute){
	if ($debug) {
		warn "Error:" . $sth->errstr."\n";
	}
	exit 1;
}

while ( my $row = $sth->fetchrow_hashref ) {
	my $description;
	
	if ($row->{loc} ne ""){
		my ($latitude,$longitude)=maidenhead2latlong($row->{loc});
		my $distance = $geo->distance('kilometer', $homelong,$homelat => $longitude,$latitude);
		if ($debug){
			printf "Converted %s to %f,%f, distance %f\n",$row->{loc},$longitude,$latitude,$distance;
		}
		$description=sprintf "<h3>%s</h3><div style=\"line-height: 1.2em\">%s %s<br>%s on %s MHz<br>Distance %.0f km (%d digit locator)</div>",$row->{callsign},$row->{qsodate},$row->{time_on},$row->{mode},$row->{freq},$distance,length($row->{loc});
		push @mappoints, {
			type => 'Feature',
			geometry => {
				type => 'Point',
				coordinates => [ $longitude, $latitude ],
			},
			properties => {
				name => $row->{callsign},
				description => $description,
			},
		},
	}
}

open( my $fh, '>', 'qsogeo.json' );
say $fh to_json { type => 'FeatureCollection', features => \@mappoints };
close $fh;

# http://www.perlmonks.org/?node_id=912476
sub maidenhead2latlong {
 
  # convert a Maidenhead Grid location (eg FN03ir)
  #  to decimal degrees
  # this code could be cleaner/shorter/clearer
    my @locator =
        split( //, uc(shift) );    # convert arg to upper case array
    my $lat = my $long = 0;
    my ( $latdiv, $longdiv );
    my @divisors = ( 72000, 36000, 7200, 3600, 300, 150 );
                              # long,lat field size in seconds
    my $max = ( @locator > @divisors ) ? $#divisors : $#locator;
  
    for my $i ( 0 .. $max ) {
        my $val = ( int( $i/2 ) % 2 ) ? $locator[$i] : ord($locator[$i]) - ord('A');
        if ( $i % 2 ) {              # lat
            $latdiv = $divisors[$i]; # save latdiv for later
            $lat += $val * $latdiv;
        }
        else {                        # long
            $longdiv = $divisors[$i]; # save longdiv for later
            $long += $val * $longdiv;
        }
    }
    $lat  += ( $latdiv / 2 );         # location of centre of square
    $long += ( $longdiv / 2 );
    return ( ( $lat / 3600 ) - 90, ( $long / 3600 ) - 180 );
}

