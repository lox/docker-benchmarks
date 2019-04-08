#!/bin/bash
set -euo pipefail
source "./benchmark.bash"

iterations=3

echo "+++ Benchmark Disk"
benchmark "$iterations" dd if=/dev/zero of="$HOME/testfile" bs=1G count=1 oflag=direct
rm "$HOME/testfile"
