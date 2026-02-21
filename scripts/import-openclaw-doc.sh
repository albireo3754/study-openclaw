#!/usr/bin/env bash
set -euo pipefail

# Import a doc from the local OpenClaw repo into this study repo.
# Usage:
#   scripts/import-openclaw-doc.sh \
#     /Users/pray/work/js/openclaw/docs/development/tool-schema-normalization-gemini-openai.md \
#     topics/tool-schema-normalization/README.md

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <source-file> <dest-relative-path>"
  exit 1
fi

SRC="$1"
DEST_REL="$2"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$REPO_ROOT/$DEST_REL"

if [[ ! -f "$SRC" ]]; then
  echo "[ERROR] Source file not found: $SRC"
  exit 1
fi

mkdir -p "$(dirname "$DEST")"
cp "$SRC" "$DEST"

echo "[OK] Copied"
echo "  from: $SRC"
echo "  to:   $DEST"
