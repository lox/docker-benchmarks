#!/bin/bash
set -euo pipefail

instance_type=$(curl -q http://169.254.169.254/latest/meta-data/instance-type)

printf "Instance Type: %s\\n" "$instance_type"

echo "Block info:"
lsblk

echo "CPU info:"
cpu_vendor=$(grep 'vendor' /proc/cpuinfo | uniq | cut -d':' -f2)
model_name=$(grep 'model name' /proc/cpuinfo | uniq | cut -d':' -f2)
cpu_count=$(grep -c 'processor' /proc/cpuinfo)

echo "$cpu_vendor $model_name x $cpu_count"

buildkite-agent annotate --style 'info' --context 'ctx-info' \
  "Instance Type: $instance_type"
