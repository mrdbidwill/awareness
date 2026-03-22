#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ack_file="$repo_root/.project_memory_ack"

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
user="${USER:-unknown}"

cat > "$ack_file" <<EOF
acknowledged_at=${timestamp}
user=${user}
EOF

echo "Project memory acknowledged at ${timestamp}."
