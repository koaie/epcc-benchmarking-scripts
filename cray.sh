#!/bin/bash

benchmark_dir=$(pwd)
version="cce/15.0.0"

while getopts ":hp:v:" opt; do
  case $opt in
    h)
      echo "Usage: $0 [-h] [-p benchmark_dir]"
      echo "  Compiles benchmarks with cray compiler"
      echo "  -h              Display this help message"
      echo "  -p              The directory containing the benchmark source files"
      echo "                  (Defaults to working dir)"
      echo "  -v              Package version to use"
      echo "                  (Defaults to cce/15.0.0)"
      exit 0
      ;;
    p)
      benchmark_dir=$OPTARG
      ;;
    v)
      version=$OPTARG
      ;;
     \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

module load $version
cd $benchmark_dir
make clean
cp Makefile.defs.cray Makefile.defs
make
mkdir cray
find . -maxdepth 1 -type f -executable -exec mv {} cray/ \;
module unload $version
