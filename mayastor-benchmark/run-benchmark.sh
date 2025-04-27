#!/bin/bash

# Default values
RUNTIME=60
TEST_TYPE="random-read"

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

# Set up benchmark resources
echo "Setting up benchmark resources..."
kubectl apply -k .

# Function to run a single benchmark
function run_benchmark {
  local test_type=$1
  local runtime=$2
  
  echo "--------------------------------------------------------"
  echo "Running $test_type benchmark (${runtime}s)..."
  echo "--------------------------------------------------------"
  
  # Create job from template with environment variables
  cat job.yaml | \
    TEST_TYPE="$test_type" \
    RUNTIME="$runtime" \
    envsubst | \
    kubectl apply -f -
  
  # Wait for job to complete
  kubectl wait --for=condition=complete job/storage-benchmark-$test_type --timeout=5m
  
  # Get logs from the job's pod
  POD=$(kubectl get pods --selector=job-name=storage-benchmark-$test_type -o jsonpath='{.items[0].metadata.name}')
  kubectl logs $POD
  
  # Delete the job
  kubectl delete job storage-benchmark-$test_type
  
  echo "--------------------------------------------------------"
  echo "$test_type benchmark completed"
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

# Clean up
if [[ "$CLEANUP" == true ]]; then
  echo "Cleaning up benchmark resources..."
  kubectl delete -k .
fi

echo "Benchmark completed!"