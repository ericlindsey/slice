#!/bin/bash
set -e
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
    #../bin/slice ../slice.param > out.txt
    ../bin/slice ../slice.param
    #nohup ../bin/slice ../slice.param > out.txt &
    cd $CURRDIR
  fi
done

