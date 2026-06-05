#!/usr/bin/env bash
set -euo pipefail
INPUT_DIR="${1:-.}"
OUTPUT_FILE="${2:-output.jsonl}"

find "$INPUT_DIR" -type f -iname '*.json' -print0 \
| xargs -0 -P "$(nproc)" -n 100 sh -c '
  for f; do
    id="${f##*/}"; id="${id%.json}"
    jq -c --arg id "$id" \
      "{callid:\$id,status,sentiment,classification,summary,purpose,
        evaluations:([.evaluations//{}|keys]|add//[]|join(\",\"))}" \
      "$f" 2>/dev/null
  done
' _ >> "$OUTPUT_FILE"

echo "Done → $OUTPUT_FILE ($(wc -l < "$OUTPUT_FILE") lines)"
