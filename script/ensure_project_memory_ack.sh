#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ack_file="$repo_root/.project_memory_ack"

if [[ ! -f "$ack_file" ]]; then
  echo "Project memory acknowledgment required."
  echo "Read docs/PROJECT_MEMORY.md, then run: script/ack_project_memory.sh"
  exit 1
fi
