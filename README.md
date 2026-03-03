# UK-NNSS OSU Micro-Benchmark

**Note:** This benchmark/repository is closely based on the one used for the [NERSC-10 benchmarks](https://www.nersc.gov/systems/nersc-10/benchmarks/)

The OSU micro-benchmark suite (OMB) tests the performance of network
communication functions for MPI and other communication interfaces.

## Status

Stable

## Maintainers

[@aturner-epcc](https://github.com/aturner-epcc)

**Important:** Please do not contact the benchmark maintainers directly with any questions.
All questions on the benchmark must be submitted via the procurement response mechanism.

## Software

- [OSU MPI Micro-Benchmarks](https://mvapich.cse.ohio-state.edu/benchmarks/)

## Building the benchmark

**Important:** All results submitted should be based on the following version:

- [OSU MPI Micro-Benchmarks 7.5.2](https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.5.2.tar.gz)


### Permitted modifications

The only permitted modifications allowed are those that
modify the source code or build/installation files to resolve unavoidable compilation or
runtime errors. Any modifications must be fully documented
(e.g., as a pull request, diff or patch file) and reported with the benchmark results.

### Manual build

The OMB source code is distributed by the [MVAPICH
website](https://mvapich.cse.ohio-state.edu/benchmarks/).

We provide an example build process based on the process used to install on the
[IsambardAI](https://docs.isambard.ac.uk/specs/#system-specifications-isambard-ai-phase-2) system.

- [Example build instructions on IsambardAI](build_isambardai.md)

## Running the benchmark

OMB provides a script named `get_local_rank` that may (optionally) used
as a wrapper function when launching the OMB tests. Its purpose is to
define an the `LOCAL_RANK` environment variable before starting the
target executable (e.g. `osu_latency`). `LOCAL_RANK` enumerates the
ranks on each node so that the MPI library can control affinity between
ranks and processors. Different MPI launchers expose the local rank
information in different ways, and
`libexec/osu-micro-benchmarks/get_local_rank` should be modified
accordingly. Notes describing the appropriate modifications are included
within the `get_local_rank` script.

As an example, on IsambardAI, MPI jobs are started using the SLURM PMI, and
the `LOCAL_RANK` may be set using `export LOCAL_RANK=$SLURM_LOCALID`.

### Required tests

The full OMB suite tests numerous communication patterns. Only the
benchmarks listed in the following table are required:


| Test                |Description| Message <br/> Size | Nodes <br> Used | Ranks <br> Used |
|---                  |---        |---                |--- |--- |
| osu_latency         | Point-to-Point <br/> Latency |  8 B | 2 | 1 per node |
| osu_bibw            | Point-to-Point <br/> Bi-directional <br> bandwidth |  1 MB | 2 | 1 per node |
| osu_mbw_mr          | Point-to-Point <br/> Multi-Bandwidth <br>& Message Rate | 16 KB | 2 | Host-to-Host (two tests) :<br>     - 1 per NIC<br/>    - 1 per core <br/> Device-to-Device (two tests):<br/>    - 1 per NIC<br/>    - 1 per accelerator |
| osu_get_acc_latency | Point-to-Point <br/> One-sided Accumulate Latency |  8 B | 2 | 1 per node |
| osu_allreduce       | All-reduce Latency | 8B, 25 MB | full-system | 1 per NIC |
| osu_alltoall        | All-to-all Latency | 1 MB | full-system | 1 per NIC <br/> odd process count |

For the point-to-point tests (those that that use two (2) nodes), the
nodes should be the maximum distance (number of hops) apart in the
network topology.

For the all-to-all test, the total number of ranks must be odd in order
to circumvent software optimisations that would avoid stressing the
network bisection bandwidth. If the product Nodes_Used x NICs_per_node
is even, then the number of ranks used should be one less than this
product.

On systems that include accelerator devices, the tests should be
executed twice: once to test performance to and from host memory, and
again to to measure latency to and from device memory. Toggling between
these tests requires configuring and compiling with the appropriate
option (see `./configure --help`).

### Benchmark execution

Examples of job scripts that run the required tests
are located in the `run` directory.
The job scripts should be edited to reflect
the architecture of the target system as follows:

- For all tests (`run_*.sh`),
  specify the number of NICs per node
  by setting the `j` variable`.

- For point-to-point tests (`run_p2p_[host,accel].sh`),
  specify a pair of maximally distant nodes
  by setting the `SBATCH -w` option (or equivalent for other schedulers).
  Note that selection of an appropriate pair of nodes
  requires knowing the nodes' placement on the network topology.
  Other mechanisms for controlling node placement (besides `-w`)
  may be used if available.

- For tests of collective operations (`run_coll_[host,accel].sh`),
  specify the number of nodes in the full system
  by setting the `SBATCH --nodes` option.

- For point-to-point tests between host processors (`run_p2p_host.sh`),
  specify the number of CPU cores per node
  by setting the `k` variable.

- For tests using accelerator devices (`run_[p2p,coll]_accel.sh`),
  specify the number of devices per node
  by setting the `a` variable.

- For tests using accelerator devices (`run_[p2p,coll]_accel.sh`),
  specify the device interface interface to be used
  by providing the appropriate option to the `osu_<test>` command
  (i.e. `-d[ROCm,CUDA,OpenACC]` ).

Runtime options to control the execution of each test can be viewed by
supplying the `--help` option. The number of iterations (`-i`) should not 
be changed from its default value. The `-x` option should not be used to
exclude warmup iterations; results should include the warmup iterations.
If the test is using device memory, then it is enabled by the `-d`
device option with the appropriate interface (e.g. `-d [ROCm, CUDA,
OpenACC] D D`).

## Reporting Results

The bidder should provide:

- Details of any changes made to the OSU micro-benchmark source code
  and modifications to any build files (e.g. configure scripts, makefiles)
- Details of the build process for the OSU micro-benchmark software 
  for both the host-to-host and device-to-device versions
- Details on how the tests were run, including any batch job submission
  scripts
- The benchmark results

## Example performance data

The following example performance data is from the IsambardAI system

- Point-to-point, accelerator: [example_output/OMB_p2p_accel-2252830.out](example_output/OMB_p2p_accel-2252830.out)
- Point-to-point, host: [example_output/OMB_p2p_host-2252822.out](example_output/OMB_p2p_host-2252822.out)
- Collectives, accelerator (512 nodes): [example_output/OMB_coll_accel-2253239.out](example_output/OMB_coll_accel-2253239.out)
- Collectives, host (512 nodes): [example_output/OMB_coll_host-2345626.out](example_output/OMB_coll_host-2345626.out) 

## License

This benchmark description and associated files are released under the
MIT license.
