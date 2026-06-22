#!/usr/bin/env bash
set -euo pipefail

# Build the `api` image fetching fresh remote code by passing a timestamp cache-bust
CACHEBUST=$(date +%s)
echo "Building api image with CACHEBUST=${CACHEBUST} (will clone remote repo at build time)"
docker compose build --build-arg CACHEBUST=${CACHEBUST} --no-cache api
docker compose up -d --force-recreate api

echo "Done. Use 'docker compose logs -f api' to follow logs."
