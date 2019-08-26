#!/usr/bin/perl
use Text::ParseWords;
use File::Basename;
if ($#ARGV < 0) {
  print "Usage: $0 <marg2d.#.#.xyz list>\n";
  print " Plots 2D marginal PDFs. Example: $0 test/*xyz\n";
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

  #pass file through awk to add a blank line whenever y value changes, then to gnuplot
  $cmd="cat $marg2d | awk -v naxis=$naxis '{if (((NR-1) % naxis) == 0) printf(\"\\n\"); print;}' > /tmp/temp_marg2d.dat";
  system($cmd);

  $cmd = "echo 'set pm3d map; set palette rgbformulae 22,13,10; set xrange [$mins[$parx]:$maxes[$parx]]; set yrange [$mins[$pary]:$maxes[$pary]]; set xlabel \"$names[$parx]\"; set ylabel \"$names[$pary]\";  splot \"/tmp/temp_marg2d.dat\" ' |gnuplot -persist";
  print $cmd . "\n";
  system($cmd);
}
