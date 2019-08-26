#!/bin/bash
set -e

# remove all files created during run of slice or grid

if [ $# -lt 1 ]; then
  echo "usage: $0 dirlist (eg. $0 test*)"
  exit
fi
CURRDIR=`pwd`
for arg in "$@"
do
  if [ -d $arg ]; then
    cd $arg
    pwd
    \rm -f axis_scales.dat correlations.dat marg2d*cpt marg2d*grd marg2d*ps marg2d*xyz marg2d*dat margs1D.dat meanmodel.dat models.dat means_stds.dat scales_margs.dat out.txt
    cd $CURRDIR
  fi
done
