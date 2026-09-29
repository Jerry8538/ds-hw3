#!/bin/bash
#SBATCH --job-name=q1-benchmark-type3
#SBATCH --nodes=3
#SBATCH --ntasks=3
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=00:30:00
#SBATCH --output=%j.log
#SBATCH --error=%j.err
#SBATCH -D /home/cs3401.49/ds-hw3/q1/benchmark/type3

echo "========================================="
echo "Job id:  $SLURM_JOB_ID"
echo "Nodes:   $SLURM_JOB_NODELIST"
echo "Tasks:   $SLURM_NTASKS"
echo "========================================="

seconds() {
    echo "scale=3; ($2 - $1) / 1000000000" | bc
}

# matrices A and B in files A and B
# split up A into Ai based on number of tasks (# of mappers = # of tasks)
split -d -n l/$SLURM_NTASKS A A

TOTAL_START=$(date +%s%N)

# mapper
MAPPER_START=$(date +%s%N)
srun --ntasks=$SLURM_NTASKS bash -c '
    TID=$(printf "%02d" $SLURM_PROCID)
    ./../mapper B "A${TID}" > "map_${TID}"
'
MAPPER_END=$(date +%s%N)
printf "MAPPER: "
$(seconds $MAPPER_END $MAPPER_START)

# reducer (run on single node)
REDUCER_START=$(date +%s%N)
./../reducer map_* > out
REDUCER_END=$(date +%s%N)
echo "REDUCER: "
$(seconds $REDUCER_END $REDUCER_START)

TOTAL_END=$(date +%s%N)
echo "TOTAL: "
($seconds $TOTAL_END $TOTAL_START)
