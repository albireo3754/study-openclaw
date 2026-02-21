#!/usr/bin/env bash
set -euo pipefail

# Move a STUDY document inside this repository.
# (Not for importing from the upstream openclaw repo.)
#
# Usage:
#   scripts/import-openclaw-doc.sh <source-relative-path> <dest-relative-path>
#
# Example:
#   scripts/import-openclaw-doc.sh \
#     topics/tmp/gemini-openai-notes.md \
#     topics/tool-schema-normalization/README.md

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <source-relative-path> <dest-relative-path>"
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC_REL="$1"
DEST_REL="$2"
SRC="$REPO_ROOT/$SRC_REL"
DEST="$REPO_ROOT/$DEST_REL"

if [[ ! -f "$SRC" ]]; then
  echo "[ERROR] Study doc not found in repo: $SRC_REL"
  echo "        resolved path: $SRC"
  exit 1
fi

mkdir -p "$(dirname "$DEST")"
mv "$SRC" "$DEST"

echo "[OK] Moved study doc"
echo "  from: $SRC_REL"
echo "  to:   $DEST_REL"
