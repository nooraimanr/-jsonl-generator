# json-to-jsonl-extractor

A fast, parallel Bash script that extracts selected fields from a directory of JSON call records and writes them into a single newline-delimited JSON (JSONL) file.

---

## Overview

Each input file is a single JSON object representing one call record. The script traverses an input directory, processes every `.json` file in parallel, and appends a flattened JSONL row per file to the output — making it suitable for bulk ingestion into analytics pipelines, search engines (e.g. Typesense, Elasticsearch), or data warehouses.

---

## Output Schema

Each output line is a JSON object with the following fields:

| Field | Source | Description |
|---|---|---|
| `callid` | filename (without `.json`) | Unique call identifier |
| `status` | `.status` | Call status |
| `sentiment` | `.sentiment` | Sentiment label |
| `classification` | `.classification` | Call classification |
| `summary` | `.summary` | Call summary text |
| `purpose` | `.purpose` | Call purpose |
| `evaluations` | `.evaluations` keys, comma-joined | Evaluation categories present |

---

## Usage

```bash
./extract.sh <input_dir> <output_file>
```

### Arguments

| Argument | Default | Description |
|---|---|---|
| `input_dir` | `.` (current directory) | Path to the folder containing `.json` files. Typically `/path/to/<date>/json_folder` |
| `output_file` | `output.jsonl` | Path to the output JSONL file |

### Examples

```bash
# Basic usage
./extract.sh /data/2025-06-01/calls output.jsonl

# Using defaults (processes current directory, writes to output.jsonl)
./extract.sh

# Explicit paths
./extract.sh /mnt/calldata/2025-06-01 /mnt/results/2025-06-01.jsonl
```

> **Note:** The script **appends** to the output file. If the output file already exists, new rows will be added to the end. Clear or remove the file beforehand if a clean run is needed.

---

## Requirements

- `bash` 4+
- `jq` — for JSON parsing and field extraction
- `xargs` with `-P` support (standard on Linux; GNU coreutils)
- `nproc` — used to auto-detect CPU core count for parallelism

---

## Performance

The script uses `xargs -P "$(nproc)"` to process files across all available CPU cores, with batches of 100 files per worker. This makes it practical for directories containing tens of thousands of JSON files.

---

## Error Handling

- Files that fail `jq` parsing are silently skipped (`2>/dev/null`); the script continues processing remaining files.
- `set -euo pipefail` is set at the top level for strict error propagation in the outer shell.

---

## Notes

- Input discovery is recursive — all `.json` files under `input_dir` at any depth are processed.
- The `callid` is derived from the filename only (not any internal field), so filenames are expected to be meaningful identifiers.
- Field extraction is non-strict: missing fields resolve to `null` in the output rather than causing failures.
