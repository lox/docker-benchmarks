#!/bin/bash
set -euo pipefail

# Portable date between macos and linux
# (needs brew install coreutils)
date() {
  if [[ "$OSTYPE" =~ ^(darwin) ]] ; then
    gdate "$@"
  else
    command date "$@"
  fi
}

# Run a command with millisecond timing, store
# the resulting timing in stopwatch_time
stopwatch() {
  t1=$(date +%s.%N)
  "$@" &>/dev/null
  t2=$(date +%s.%N)
  dt=$(echo "($t2 - $t1) * 1000" | bc)
  stopwatch_time="$(printf "%0.1f" "$dt")"
}

benchmark() {
  iterations="$1"; shift
  counter=1
  times=()

  # Run through iterations and stopwatch each one
  while [ "$counter" -le "$iterations" ] ; do
    printf ">> Iteration %d of %d (%s)\\n" "$counter" "$iterations" "$*"
    stopwatch "$@"
    printf "Δ %0.1fms\\n" "$stopwatch_time" >&2
    ((counter++))
    times+=("$stopwatch_time")
  done

  total=0

  # Calculate a total and a counter for averaging
  for t in "${times[@]}" ; do
    total="$(echo "$total+$t" | bc)"
  done

  printf "\\n✅ Average of %0.1fms over %d runs\\n\\n" \
    "$(echo "$total / ${#times[@]}" | bc)" "${#times[@]}"

  printf "Command (%s) took an average of %0.1fms over %d runs" \
    "$*" \
    "$(echo "$total / ${#times[@]}" | bc)" \
    "${#times[@]}" |
    buildkite-agent annotate --style "success"
}

instance_info() {
  instance_id=$(curl -q http://169.254.169.254/latest/meta-data/instance-type || true)

  if [[ -n "$instance_id" ]] ; then
    printf "Instance Type: %s\\n" "$instance_id"
  fi

  echo "Block info:"
  lsblk

  echo "CPU info:"
  grep 'vendor' /proc/cpuinfo | uniq
  grep 'model name' /proc/cpuinfo | uniq
  printf "count %s\\n" "$(grep -c 'processor' /proc/cpuinfo)"
}
