# Example build instructions: IsambardAI

[IsambardAI](https://docs.isambard.ac.uk/specs/#system-specifications-isambard-ai-phase-2)
is an HPE Cray EX system with NVIDIA GH200 and the HPE Cray Slingshot 11 interconnect.

**Download and unpack source code**

```bash
wget https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.5.2.tar.gz
tar -xzf osu-micro-benchmarks-7.5.2.tar.gz
```

**Build the micro-benchmarks with GPU support via CUDA**

```bash
module load craype-network-ofi
module load PrgEnv-gnu 
module load gcc-native/13.2 
module load cray-mpich
module load cuda/12.6
module load craype-accel-nvidia90
module load craype-arm-grace

export CUDA_PATH=/opt/nvidia/hpc_sdk/Linux_aarch64/24.11/cuda/12.6

export MPICH_GPU_SUPPORT_ENABLED=1

../configure CC=cc CXX=CC FC=ftn \
   --prefix=/projects/u6cb/benchmarks/OSU/7.5.2-gcc \
   --enable-cuda \
   --with-cuda-include=$CUDA_PATH/include \
   --with-cuda-libpath=$CUDA_PATH/lib

make -j16
make -j16 install 
```

The `--prefix` option will cause the micro-benchmark executables to
be installed in a directory named `libexec/osu-micro-benchmarks` in
the directory specified in the prefix option.
