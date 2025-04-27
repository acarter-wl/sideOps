# Mayastor Storage Benchmark

This benchmark suite evaluates multiple aspects of Mayastor storage performance including:
- Random read/write operations
- Sequential read/write operations
- Mixed workloads
- Latency testing

## Usage

```bash
# Run a single benchmark test (default: random-read for 60 seconds)
./run-benchmark.sh

# Run a specific benchmark test for 120 seconds
./run-benchmark.sh --test random-write --runtime 120

# Run all benchmark tests for 30 seconds each
./run-benchmark.sh --all --runtime 30

# Run benchmarks and clean up resources after completion
./run-benchmark.sh --all --cleanup
```

## Available Tests

- `random-read`: 4K block size random read operations
- `random-write`: 4K block size random write operations
- `sequential-read`: 128K block size sequential read operations
- `sequential-write`: 128K block size sequential write operations
- `mixed`: 70% read/30% write mixed random workload
- `latency`: Low queue depth test to measure latency

## Customization

To modify the benchmark parameters:
1. Edit the FIO test profiles in `configmap.yaml`
2. Change PVC size in `pvc.yaml` if needed
3. Apply changes with `kubectl apply -k .`

## Interpreting Results

The benchmark outputs include:
- IOPS (operations per second)
- Bandwidth (MB/s)
- Latency metrics (average, percentiles)
- CPU utilization

Key metrics to focus on:
- 99th percentile latency for consistent performance
- IOPS for random workloads
- Bandwidth for sequential workloads
- Service time vs. wait time to identify bottlenecks
