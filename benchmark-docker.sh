#!/bin/bash
set -euo pipefail
source "./benchmark.bash"

aws_region="${AWS_DEFAULT_REGION:-us-east1}"
aws_account_id="${1:-005820773040}"

image_name_base="cache-bench"
image_sizes=(64 512 1024)

iterations=3

echo "~~~ Instance info"
instance_info

echo "+++ Benchmarking :docker: build performance"

for size in "${image_sizes[@]}" ; do
  echo "Size=${size}"
  benchmark "$iterations" docker build \
    --build-arg SIZE="$size" \
    --no-cache \
    --tag "${image_name_base}-${size}" .
done

echo "+++ Benchmarking :ecr: push/pull performance"

echo "Logging in to ECR"
aws ecr get-login --region "$aws_region" --no-include-email | bash

for size in "${image_sizes[@]}" ; do
  image_name="${image_name_base}-${size}"
  ecr_repository="${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${image_name_base}:latest"

  docker tag "$image_name" "$ecr_repository"

  echo "Pushing $ecr_repository"
  benchmark 1 docker push "$ecr_repository"

  echo "Removing local images and tags..."
  docker rmi -f "$image_name"
  docker rmi -f "${ecr_repository}"

  echo "Pulling $ecr_repository"
  benchmark 1 docker pull "$ecr_repository"

  echo "Removing local images and tags..."
  docker rmi -f "$image_name"
  docker rmi -f "${ecr_repository}"
done

echo "~~~ Cleaning up"
aws ecr batch-delete-image --region "${aws_region}" \
  --repository-name "${image_name_base}" --image-ids imageTag=latest
