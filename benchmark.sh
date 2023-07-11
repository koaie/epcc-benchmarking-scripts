#!/bin/bash

# Set the maximum number of cores to use to the number of cores on the machine
max_cores=$(nproc)
runs=1
iterations=20
# Parse command line arguments
while getopts ":hc:o:p:r:i:" opt; do
  case $opt in
    h)
      echo "Usage: $0 [-h] [-c max_cores] [-p benchmark_dir]"
      echo "  -h              Display this help message"
      echo "  -c max_cores    The maximum number of CPU cores to use for benchmarking"
      echo "                  (default: nproc)"
      echo "  -r runs    The number of application runs"
      echo "                  (default: 1)"
      echo "  -i iterations    The number of iterations"
      echo "                  (default: 20)"
      echo "  -p benchmark_dir The directory containing the benchmark executables"
      echo "  -o results_dir The directory containing the benchmark results"
      exit 0
      ;;
    c)
      max_cores=$OPTARG
      ;;
    r)
      runs=$OPTARG
      ;;
    p)
      benchmark_dir=$OPTARG
      ;;
    o)
      results_dir=$OPTARG
      ;;
    i)
      iterations=$OPTARG
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

declare -A test_time=(
  ["synchbench"]="20000"
  ["schedbench"]="15000"
  ["arraybench"]="30000"
  ["taskbench"]="30000"
)

# Loop over each benchmark executable in the directory
for benchmark in $benchmark_dir/*; do

  # Check that the benchmark is executable
  if ! [[ -x "$benchmark" ]] || [[ -d "$benchmark" ]]; then
    echo "Skipping $benchmark: not executable"
    continue
  fi

#  if [[ -z ${problem_size[${benchmark##*/}]} ]]; then
#    echo "Skipping $benchmark: problem size not provided"
#    continue
#  fi

  # Loop over the number of cores to use
  for (( cores=1; cores <= max_cores; cores++ )); do
    for (( j = 1 ; j <= $runs ; j++ )); do
      # Run the benchmark and save the output to a file
      hostname=$(hostname)
      output_file="${results_dir}/$hostname-${benchmark##*/}-$cores-$j.txt"
      OMP_NUM_THREADS=$cores $benchmark --raw-data --outer-repetitions $iterations > $output_file
      echo "Benchmark $benchmark with $cores cores: output written to $output_file"
    done
  done

done
