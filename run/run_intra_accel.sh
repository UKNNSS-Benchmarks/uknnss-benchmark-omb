#!/bin/bash
#SBATCH --job-name=OMB_intra_accel
#SBATCH --output=OMB_intra_accel-%j.out
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --time=1:0:0
#SBATCH --gpus-per-node=4
#

#The number of accelrators(a) per node
#should be specified here.
a=4 #accelerator devices per node
astride=72 # Stride of tasks between MPI processes

# Specify any additional Slurm options
srunopts="--hint=nomultithread --distribution=block:block"

#The paths to OMB and its point-to-point benchmarks
#should be specified here
OMB_DIR=/projects/u6cb/benchmarks/OSU/7.5.2-gcc-cuda/libexec/osu-micro-benchmarks
OMB_PT2PT=${OMB_DIR}/mpi/pt2pt

module load craype-network-ofi
module load PrgEnv-gnu 
module load gcc-native/13.2 
module load cray-mpich
module load cuda/12.6
module load craype-accel-nvidia90
module load craype-arm-grace

export MPICH_GPU_SUPPORT_ENABLED=1


srun ${srunopts} --nodes=1 --ntasks-per-node=${a} --cpus-per-task=${astride} \
     ${OMB_DIR}/get_local_rank  \
     ${OMB_PT2PT}/osu_mbw_mr -m 1073741824:1073741824 --type mpi_int

