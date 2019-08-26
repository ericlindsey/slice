#!/bin/bash
set -e
if [ $# -lt 1 ]; then
  echo "usage: $0 dirlist (eg. ./run.sh test*)"
  exit
fi
CURRDIR=`pwd`
for arg in "$@"
do
  if [ -d $arg ]; then
    cd $arg
    pwd
    ../bin/grid ../slice.param > out.txt 
    # nohup ../bin/slice ../slice.param > out.txt &
    cd $CURRDIR
  fi
done

