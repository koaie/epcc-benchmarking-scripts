#!/bin/bash

#SBATCH --partition=standard
#SBATCH --qos=standard
#SBATCH --exclusive
#SBATCH --time=08:00:00
#SBATCH --distribution=block:block
#SBATCH --hint=nomultithread
#SBATCH --cpus-per-task=128
#SBATCH --tasks-per-node=1
#SBATCH -o output.txt

# Set the maximum number of cores to use to the number of cores on the machine
# Parse command line arguments
command=""
scommand="srun --distribution=block:block --hint=nomultithread"
scripts_dir="/work/ta114/ta114/koa/scripts"

while getopts ":hc:o:p:r:i:n:" opt; do
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
      echo "  -n         Number of nodes"
      echo "  -p benchmark_dir The directory containing the benchmark executables"
      echo "  -o results_dir The directory containing the benchmark results"
      exit 0
      ;;
    c)
      command="${command} -c $OPTARG"
      scommand="${scommand} --cpus-per-task=$OPTARG"
      ;;
    r)
      command="${command} -r $OPTARG"
      ;;
    p)
      path=$OPTARG
      ;;
    o)
      results_dir=$OPTARG
      ;;
    s)
      source=$OPTARG
      ;;
    n)
      scommand="${scommand} --nodes=$OPTARG"
      ;;
    i)
      command="${command} -i $OPTARG"
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


declare -a compilers=("gcc" "cray" "aocc" "icc")

# Loop over each benchmark executable in the directory
for compiler in "${compilers[@]}"; do

  mkdir "${results_dir}/${compiler}"
  eval "${scommand} ${scripts_dir}/benchmark.sh $command -p ${path}/${compiler} -o ${results_dir}/${compiler}"
done
