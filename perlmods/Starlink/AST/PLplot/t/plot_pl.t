#!perl

use strict;
use Test::More;
use Data::Dumper;

require_ok( "Starlink::AST" );
require_ok( "Starlink::AST::PLplot" );

use File::Spec;

BEGIN {
 
 eval { use Graphics::PLplot };
 if ( $@ ) {
   plan skip_all => "Graphics::PLplot module not installed.";
   exit;
 } 
 
 eval "use Astro::FITS::CFITSIO;";
 if ( $@ ) {
   plan skip_all => "Astro::FITS::CFITSIO not installed.";
   exit;
 }
 
 eval "use Astro::FITS::Header::CFITSIO;";
 if ( $@ ) {
   plan skip_all => "Astro::FITS::Header::CFITSIO not installed.";
   exit;
 }
 
 plan tests => 5;  
 
};

Starlink::AST::Begin();

# FITS File
# ---------
my $file = File::Spec->catfile( File::Spec->updir(), "data", "m31.fit" );

# Get FITS Header
# ---------------

my $header = new Astro::FITS::Header::CFITSIO( File => $file );
my @cards = $header->cards();

# Make FitsChan
# -------------
my $wcsinfo = $header->get_wcs();
isa_ok( $wcsinfo, "Starlink::AST::FrameSet" );

# Set up window
# -------------
my $nx = $header->value("NAXIS1");
my $ny = $header->value("NAXIS2");

plsdev( "xwin" );

plinit();
pladv(0);
plvpor(0,1,0,1);
plwind(0,1,0,1);
plschr(2,1);

plscmap1n(0);
plscmap1l(1,[0,1],[1,0],[1,0],[1,0],[0,0]);



my ( $x1, $x2, $y1, $y2 ) = (0.2,0.8,0.2,0.8);

my $xscale = ( $x2 - $x1 ) / $nx;
my $yscale = ( $y2 - $y1 ) / $ny;
my $scale = ( $xscale < $yscale ) ? $xscale : $yscale;
my $xleft   = 0.5 * ( $x1 + $x2 - $nx * $scale );
my $xright  = 0.5 * ( $x1 + $x2 + $nx * $scale );
my $ybottom = 0.5 * ( $y1 + $y2 - $ny * $scale );
my $ytop    = 0.5 * ( $y1 + $y2 + $ny * $scale );

# Read data 
# ---------
my $array = read_file( $file );

Graphics::PLplot::plimage($array, $nx, $ny,
			  $xleft, $xright, 
			  $ybottom, $ytop,
			  0,12000,
			  $xleft, $xright,
			  $ybottom, $ytop
			 );

# Change FrameSet
# ---------------
#$wcsinfo->Set( System => "GALACTIC" );

# AST axes
# --------
my $plot = Starlink::AST::Plot->new( $wcsinfo, 
   [$xleft,$ybottom,$xright,$ytop],[0.5,0.5, $nx+0.5, $ny+0.5], "Grid=1");
isa_ok( $plot, "Starlink::AST::Plot" );

my $status = $plot->plplot();
is( $status, 1, "Result from registering PLplot with AST" );

#$plot->Set( Colour => 2, Width => 5 );
$plot->Grid();

# Switch to GRAPHICS frame for easy plotting
$plot->Set( "Current=1" );
$plot->Text("Test Text 1", [0.4,0.4],[0.0,1.0],"CC");
#$plot->Set( Colour => 3  );
$plot->Text("Test Text 2", [0.5,0.5],[0.0,1.0],"CC");
#$plot->Set( Colour => 4 );
$plot->Text("Test Text 3", [0.6,0.6],[0.0,1.0],"CC");

#$plot->Set( Colour => 6, Width => 5 );
$plot->Mark( 6, [0.6,0.5,0.4], [0.3, 0.2,0.2]  );

#$plot->Set( Colour => 2, Width => 5 );
$plot->PolyCurve( [0.2,0.3,0.25], [0.8,0.5,0.5]);


# Done!
sleep(2);

plend();
exit;

sub read_file {
   my $file = shift;

   my $status = 0;
   my $fptr = Astro::FITS::CFITSIO::open_file(
             $file, Astro::FITS::CFITSIO::READONLY(), $status);

   my ($array, $nullarray, $anynull);
   $fptr->read_pixnull( 
     Astro::FITS::CFITSIO::TLONG(), [1,1], $nx*$ny, $array, $nullarray, 
     $anynull ,$status);
   $fptr->close_file($status);

   return $array;
}

1;  
