
echo "==================== CephFS Benchmark ===================="
echo "Running at $(date)"
echo "System information:"
uname -a
echo

echo "==================== Sequential Write Test ===================="
dd if=/dev/zero of=/data/tempfile bs=1M count=1024 conv=fdatasync 2>&1 | grep -v records
echo

echo "==================== Sequential Read Test ===================="
# Clear cache to ensure accurate read testing
echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || echo "Failed to drop caches (normal if not root)"
dd if=/data/tempfile of=/dev/null bs=1M count=1024 2>&1 | grep -v records
echo

echo "==================== FIO Random I/O Tests ===================="
fio --name=random-rw --directory=/data --size=512M --rw=randrw --bs=4k \
  --direct=1 --ioengine=libaio --iodepth=16 --rwmixread=70 --rwmixwrite=30 \
  --runtime=60 --numjobs=4 --time_based --group_reporting
echo

echo "==================== Cleanup ===================="
rm -f /data/tempfile
echo "Benchmark completed at $(date)"
EOF

chmod +x /data/benchmark.sh
./data/benchmark.sh | tee /data/benchmark_results_$(date +%Y%m%d_%H%M%S).txt
