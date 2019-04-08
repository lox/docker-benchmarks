#!/bin/bash
set -euo pipefail
source "./benchmark.bash"

cpu_load() {
  echo "scale=5000; a(1)*4" | bc -l
}

iterations=3

echo "+++ Instance info"
instance_info

benchmark "$iterations" cpu_load
