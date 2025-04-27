#!/bin/bash

# Default values
RUNTIME=60
TEST_TYPE="random-read"
RUN_ALL=false
CLEANUP=false

# Help message
function show_help {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Run storage benchmarks against mayastor-ha storage class"
  echo
  echo "Options:"
  echo "  -r, --runtime SECONDS    Set benchmark runtime in seconds (default: 60)"
  echo "  -t, --test TEST_TYPE     Set benchmark test type (default: random-read)"
  echo "                           Available tests: random-read, random-write, sequential-read,"
  echo "                           sequential-write, mixed, latency"
  echo "  -a, --all                Run all benchmark tests"
  echo "  -c, --cleanup            Clean up benchmark resources after completion"
  echo "  -h, --help               Show this help message"
  echo
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

# Setup benchmark resources
echo "Setting up benchmark resources..."
kubectl apply -k .

# Initialize results markdown table
RESULTS="| Test Type | IOPS | Bandwidth | Avg Latency (usec) |\n|-----------|------|----------|--------------------|"

# Function to run a single benchmark
target_pod_name() {
  kubectl get pods --selector=job-name=storage-benchmark-$1 -o jsonpath='{.items[0].metadata.name}'
}

function run_benchmark {
  local test_type=$1
  local runtime=$2

  echo "--------------------------------------------------------"
  echo "Running $test_type benchmark (${runtime}s)..."
  echo "--------------------------------------------------------"

  cat job.yaml | \
    TEST_TYPE="$test_type" \
    RUNTIME="$runtime" \
    envsubst | \
    kubectl apply -f -

  kubectl wait --for=condition=complete job/storage-benchmark-$test_type --timeout=10m

  POD=$(target_pod_name $test_type)
  LOG=$(kubectl logs "$POD")
  echo "$LOG"

  # Parse metrics
  IOPS=$(echo "$LOG" | grep -i "IOPS=" | head -1 | sed -E 's/.*IOPS=([^,]+).*/\1/')
  BANDWIDTH=$(echo "$LOG" | grep -i "READ:" | grep -o 'bw=[^,]*' | head -1 | cut -d= -f2)
  if [ -z "$BANDWIDTH" ]; then
    BANDWIDTH=$(echo "$LOG" | grep -i "WRITE:" | grep -o 'bw=[^,]*' | head -1 | cut -d= -f2)
  fi
  AVG_LATENCY=$(echo "$LOG" | grep -A1 "clat (usec)" | grep "avg=" | sed -E 's/.*avg=([^,]+).*/\1/')

  IOPS=${IOPS:-N/A}
  BANDWIDTH=${BANDWIDTH:-N/A}
  AVG_LATENCY=${AVG_LATENCY:-N/A}

  # Add to results table
  RESULTS="${RESULTS}\n| ${test_type} | ${IOPS} | ${BANDWIDTH} | ${AVG_LATENCY} |"

  # Cleanup job
  kubectl delete job storage-benchmark-$test_type

  echo "Benchmark $test_type completed."
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

# Clean up
if [[ "$CLEANUP" == true ]]; then
  echo "Cleaning up benchmark resources..."
  kubectl delete -k .
fi

# Print the final results summary
echo -e "\n============ Benchmark Summary ============\n"
echo -e "$RESULTS" | column -t -s '|'
echo -e "\n============================================\n"

# Optionally, save to file
echo -e "$RESULTS" > benchmark_summary.md
