#!/bin/sh
# /usr/local/bin/k3s. The k3s server binary is /usr/local/lib/k3s/k3s (./cmd/server of k3s v1.37.2+k3s1, built from
# source by Dockerfile.offline.pinned). That binary runs kubectl only when invoked under the name `kubectl` (argv[0]),
# so `k3s kubectl ...` went through the release's self-extracting wrapper, which made that dispatch. This keeps it.
if [ "${1:-}" = kubectl ]; then shift; exec /usr/local/bin/kubectl "$@"; fi
exec /usr/local/lib/k3s/k3s "$@"
