#!/bin/bash

# Default values
RUNTIME=60
TEST_TYPE="random-read"
RESULTS_FILE="benchmark_results.md"

# Help message
function show_help {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Run storage benchmarks against Mayastor storage class"
  echo
  echo "Options:"
  echo "  -r, --runtime SECONDS    Set benchmark runtime in seconds (default: 60)"
  echo "  -t, --test TEST_TYPE     Set benchmark test type (default: random-read)"
  echo "                           Available tests: random-read, random-write, sequential-read, sequential-write, mixed, latency"
  echo "  -a, --all                Run all benchmark tests"
  echo "  -c, --cleanup            Clean up benchmark resources after completion"
  echo "  -h, --help               Show this help message"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -r|--runtime)
      RUNTIME="$2"
      shift 2
      ;;
    -t|--test)
      TEST_TYPE="$2"
      shift 2
      ;;
    -a|--all)
      RUN_ALL=true
      shift
      ;;
    -c|--cleanup)
      CLEANUP=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

# Set up benchmark resources
echo "Setting up benchmark resources..."
kubectl apply -k .

# Initialize results file
echo "# Benchmark Results" > $RESULTS_FILE
echo "" >> $RESULTS_FILE
echo "| Test Type | IOPS | Bandwidth | Avg Latency (usec) |" >> $RESULTS_FILE
echo "|-----------|------|-----------|--------------------|" >> $RESULTS_FILE

# Function to run a single benchmark
function run_benchmark {
  local test_type=$1
  local runtime=$2

  echo "--------------------------------------------------------"
  echo "Running $test_type benchmark (${runtime}s)..."
  echo "--------------------------------------------------------"

  cat job.yaml | TEST_TYPE="$test_type" RUNTIME="$runtime" envsubst | kubectl apply -f -

  kubectl wait --for=condition=complete job/storage-benchmark-$test_type --timeout=5m || true

  POD=$(kubectl get pods --selector=job-name=storage-benchmark-$test_type -o jsonpath='{.items[0].metadata.name}')
  OUTPUT=$(kubectl logs $POD)

  echo "$OUTPUT"

  kubectl delete job storage-benchmark-$test_type

  # Parse results
  IOPS=$(echo "$OUTPUT" | grep -oP 'IOPS=\K[0-9\.kMG]+')
  BW=$(echo "$OUTPUT" | grep -oP 'BW=\K[0-9\.kMG/]+\s\([0-9\.kMG/]+\)')
  LATENCY=$(echo "$OUTPUT" | grep -oP 'avg=\K[0-9\.]+')

  # Handle missing metrics
  IOPS=${IOPS:-N/A}
  BW=${BW:-N/A}
  LATENCY=${LATENCY:-N/A}

  # Append to results file
  echo "| $test_type | $IOPS | $BW | $LATENCY |" >> $RESULTS_FILE

  echo "--------------------------------------------------------"
  echo "$test_type benchmark completed."
  echo "--------------------------------------------------------"
  echo
}

# Run benchmarks
if [[ "$RUN_ALL" == true ]]; then
  TESTS=("random-read" "random-write" "sequential-read" "sequential-write" "mixed" "latency")
  for test in "${TESTS[@]}"; do
    run_benchmark "$test" "$RUNTIME"
  done
else
  run_benchmark "$TEST_TYPE" "$RUNTIME"
fi

# Clean up if requested
if [[ "$CLEANUP" == true ]]; then
  echo "Cleaning up benchmark resources..."
  kubectl delete -k .
fi

echo ""
echo "============ Benchmark Summary ============"
cat $RESULTS_FILE
echo "============================================"
echo "Benchmark results saved to $RESULTS_FILE!"