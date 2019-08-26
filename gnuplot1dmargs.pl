#!/usr/bin/perl
use Text::ParseWords;
if ($#ARGV < 0) {
  print "Usage: $0 directory [parameter # list]\n";
  exit;
}
my $wd=`pwd`;
chomp($wd);
my $dir="$wd/$ARGV[0]";
my $fname = "$dir/slice.param";
if ( ! -f $fname ) {
  print "couldn't find $fname... looking in current directory instead.\n";
  $fname = "slice.param";
}
#read slice.param file for number of parameters and their names
open(INFILE, $fname) || die("Could not open slice.param file!");
my $i=0;
while( <INFILE> ) {
  s/#.*//;            # ignore comments by erasing them
  s/\s+$//;           # remove trailing whitespace
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
#list of marginals to plot
if ($#ARGV > 0) {
  shift;
  @list= @ARGV;
} else {
  @list=(1 .. $ndim);
}
$cmd="paste $dir/axis_scales.dat $dir/margs1D.dat  > $dir/scales_margs.dat";
system($cmd);
$cmd="echo 'plot ";
foreach $i ( @list ) {
  $marg=$i+$ndim;
  $cmd = $cmd . "\"$dir/scales_margs.dat\" using $i:$marg title \"$names[$i-1]\" w l,";
}
$cmd =~ s/,$//; #remove last comma
$cmd = "$cmd' | gnuplot -persist\n";
system($cmd);
