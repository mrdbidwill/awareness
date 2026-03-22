#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

"$repo_root/script/ensure_project_memory_ack.sh"

if ! command -v rbenv >/dev/null 2>&1; then
  echo "rbenv is required. Install rbenv and ensure it is on PATH."
  exit 1
fi

export RBENV_ROOT="${RBENV_ROOT:-$HOME/.rbenv}"
export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"
eval "$(rbenv init -)"

expected_ruby="$(cat .ruby-version)"
actual_ruby="$(ruby -e 'print RUBY_VERSION')"

if [[ "$expected_ruby" != "$actual_ruby" ]]; then
  echo "Ruby version mismatch. Expected $expected_ruby, got $actual_ruby."
  exit 1
fi

expected_bundler="$(awk '/BUNDLED WITH/{getline; gsub(/^[[:space:]]+/, "", $0); print $0; exit}' Gemfile.lock)"
actual_bundler="$(bundle -v | awk '{print $3}')"

if [[ "$expected_bundler" != "$actual_bundler" ]]; then
  echo "Bundler version mismatch. Expected $expected_bundler, got $actual_bundler."
  exit 1
fi

echo "Preflight OK: Ruby $actual_ruby, Bundler $actual_bundler"
