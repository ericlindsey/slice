#!/usr/bin/perl
use Text::ParseWords;
use File::Basename;
if ($#ARGV < 0) {
  print "Usage: $0 <marg2d.#.#.xyz list>\n";
  exit;
}
my $dir=dirname($ARGV[0]);
my $fname = "$dir/slice.param";
if ( ! -f $fname ) {
  print "couldn't find $fname... looking in current directory instead.\n";
  $fname = "slice.param";
}
#read slice.param file
open(INFILE, $fname) || die("Could not open slice.param file!");
my $i=0;
while( <INFILE> ) {
  s/#.*//;            # ignore comments by erasing them
  s/\s+$//;           # remove trailing whitespace
  s/^\s+//;           # remove leading whitespace
  next if /^(\s)*$/;  # skip blank lines
  chomp;              # remove trailing newline characters
  if ( $i <= 7) {
    push @params, $_;    # push the data line onto the array
  } else {
    @vals = quotewords('\s+', 0, $_);
    push @mins, $vals[0];
    push @maxes, $vals[1];
    push @names, $vals[2];
  }
  $i++;
}
close(INFILE);
$ndim= $params[7];
$naxis= $params[3];

foreach $marg2d (@ARGV) {
  if (! -f $marg2d) {
    print "couldn't find $marg2d.\n";
    next;
  }
  #get axis numbers, convert to perl index (starts with 0)
  @vals=split(/\./,basename($marg2d));
  $pary = $vals[1] - 1;
  $parx = $vals[2] - 1;
  
  #get GMT parameters for xyz2grd
  $str=`gmt gmtinfo -C $marg2d`;
  @minmax= split(/\s+/,$str);
  # the below works because the x, y coordinates in the xyz file are centered on each bin,
  # while the min/max values in slice.param specify the edges of the domain.
  $dx=($minmax[0]-$mins[$parx])*2;
  $dy=($minmax[2]-$mins[$pary])*2;

  $namex=$names[$parx];
  $namey=$names[$pary];
  $incx=($maxes[$parx]-$mins[$parx])/4;
  $ticx=$incx/5;
  $incy=($maxes[$pary]-$mins[$pary])/4;
  $ticy=$incy/5;
  
  $grdname=dirname($marg2d)."/".basename($marg2d,".xyz",).".grd";
  $range="-R$minmax[0]/$minmax[1]/$minmax[2]/$minmax[3]";
  $cmd = "gmt xyz2grd $marg2d -G$grdname $range -I$dx/$dy";
  print "Executing commands:\n";
  print "$cmd\n";
  system($cmd);
  $cptname=dirname($marg2d)."/".basename($marg2d,".xyz",).".cpt";
  $psname=dirname($marg2d)."/".basename($marg2d,".xyz",).".ps";
  $cmd = "gmt grd2cpt $grdname -Cjet -D -Z > $cptname";
  print "$cmd\n";
  system($cmd);
  $cmd = "gmt grdimage $grdname -JX6i/6i $range -Ba${incx}f${ticx}:\"$namex\":/a${incy}f${ticy}:\"$namey\":WSen:.\"$grdname\": -X3 -Y3 -C$cptname -Q -P --PAPER_MEDIA=Custom_8ix9i --HEADER_FONT_SIZE=14p --LABEL_FONT_SIZE=14p > $psname";
  print "$cmd\n";
  system($cmd);
  $cmd = "open $psname";
  print "$cmd\n";
  system($cmd);
}
