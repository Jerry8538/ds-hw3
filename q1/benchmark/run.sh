#!/bin/bash
#SBATCH --job-name=q8-mapreduce
#SBATCH --nodes=3
#SBATCH --ntasks=3
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=00:30:00
#SBATCH --output=%j.log
#SBATCH --error=%j.err
#SBATCH -D /home/cs3401.49/ds-hw3/q1/benchmark

echo "========================================="
echo "Job id:  $SLURM_JOB_ID"
echo "Nodes:   $SLURM_JOB_NODELIST"
echo "Tasks:   $SLURM_NTASKS"
echo "========================================="

echo "compiling"
# this should be done in different file when benchmarking
g++ -g ../mapper.cpp -o mapper
g++ -g ../reducer.cpp -o reducer

# matrices A and B in files A and B
# split up A into Ai based on number of tasks (# of mappers = # of tasks)
split -d -n l/$SLURM_NTASKS A A

# mapper
srun --ntasks=$SLURM_NTASKS bash -c '
    TID=$(printf "%02d" $SLURM_PROCID)
    ./mapper B "A${TID}" > "map_${TID}"
'

# reducer (run on single node)
./reducer map_* > out
