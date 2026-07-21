#!/usr/bin/env bash
# collect-dashboard-data.sh — Collects real project data for OmniState dashboard
# Reads: tasks-history.json, tasks-archive.json, chunks/, project-summary.md, omni_cost.json
# Writes: dashboard-data.json (used by dashboard.html)
set -euo pipefail

PROJECT_DIR="${1:-.}"
OUTPUT_FILE="${2:-dashboard-data.json}"

TASKS_HISTORY="${PROJECT_DIR}/tasks-history.json"
TASKS_ARCHIVE="${PROJECT_DIR}/tasks-archive.json"
PROJECT_SUMMARY="${PROJECT_DIR}/project-summary.md"
OMNI_COST="${PROJECT_DIR}/omni_cost.json"
CHUNKS_DIR="${PROJECT_DIR}/chunks"
CONFIG_FILE="${PROJECT_DIR}/omnistate.config.json"

# --- Helper: safe JSON read ---
json_val() {
    local file="$1" key="$2" default="$3"
    if [ -f "$file" ]; then
        local v
        v=$(python3 -c "
import json, sys
try:
    d = json.load(open('$file'))
    keys = '$key'.split('.')
    for k in keys:
        d = d[k]
    print(d)
except: print('$default')
" 2>/dev/null) || v="$default"
        echo "$v"
    else
        echo "$default"
    fi
}

# --- 1. Project Name ---
PROJECT_NAME="Unknown Project"
if [ -f "$PROJECT_SUMMARY" ]; then
    PROJECT_NAME=$(head -5 "$PROJECT_SUMMARY" | grep -oP '(?<=# ).*' | head -1 || echo "")
fi
if [ -z "$PROJECT_NAME" ] || [ "$PROJECT_NAME" = "Unknown Project" ]; then
    PROJECT_NAME=$(json_val "$CONFIG_FILE" "project_name" "")
fi
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME=$(basename "$(cd "$PROJECT_DIR" && pwd)")
fi

# --- 2. Task Counts ---
ACTIVE_TASKS=0
TOTAL_TASKS=0
DONE_TASKS=0

if [ -f "$TASKS_HISTORY" ]; then
    TOTAL_TASKS=$(python3 -c "
import json
try:
    d = json.load(open('$TASKS_HISTORY'))
    print(len(d.get('tasks', [])))
except: print(0)
" 2>/dev/null || echo "0")
    ACTIVE_TASKS=$(python3 -c "
import json
try:
    d = json.load(open('$TASKS_HISTORY'))
    print(sum(1 for t in d.get('tasks', []) if t.get('status') == 'todo'))
except: print(0)
" 2>/dev/null || echo "0")
    DONE_TASKS=$(python3 -c "
import json
try:
    d = json.load(open('$TASKS_HISTORY'))
    print(sum(1 for t in d.get('tasks', []) if t.get('status') == 'done'))
except: print(0)
" 2>/dev/null || echo "0")
fi

ARCHIVED_TASKS=0
if [ -f "$TASKS_ARCHIVE" ]; then
    ARCHIVED_TASKS=$(python3 -c "
import json
try:
    d = json.load(open('$TASKS_ARCHIVE'))
    print(len(d.get('tasks', [])))
except: print(0)
" 2>/dev/null || echo "0")
fi

# --- 3. Snapshots (count chunks) ---
SNAPSHOTS=0
CHUNK_DATES=()
CHUNK_LABELS=()
if [ -d "$CHUNKS_DIR" ]; then
    SNAPSHOTS=$(find "$CHUNKS_DIR" -name "*.md" -type f 2>/dev/null | wc -l || echo "0")
    # Get last 5 chunks by modification time
    while IFS= read -r chunk; do
        [ -z "$chunk" ] && continue
        DATE_STR=$(date -r "$chunk" "+%b %d" 2>/dev/null || stat -c "%y" "$chunk" 2>/dev/null | cut -d' ' -f1 | xargs -I{} date -d "{}" "+%b %d" 2>/dev/null || echo "")
        LABEL=$(head -3 "$chunk" | grep -oP '(?<=# ).*' | head -1 || basename "$chunk" .md)
        CHUNK_DATES+=("$DATE_STR")
        CHUNK_LABELS+=("$LABEL")
    done < <(ls -t "$CHUNKS_DIR"/*.md 2>/dev/null | head -5)
fi

# --- 4. Token Savings (real calculation) ---
TOTAL_WORDS=0
# Count words in chunks
if [ -d "$CHUNKS_DIR" ]; then
    for f in "$CHUNKS_DIR"/*.md; do
        [ -f "$f" ] || continue
        WORDS=$(wc -w < "$f" 2>/dev/null || echo "0")
        TOTAL_WORDS=$((TOTAL_WORDS + WORDS))
    done
fi
# Count words in archived tasks
if [ -f "$TASKS_ARCHIVE" ]; then
    ARCH_WORDS=$(wc -w < "$TASKS_ARCHIVE" 2>/dev/null || echo "0")
    TOTAL_WORDS=$((TOTAL_WORDS + ARCH_WORDS))
fi

# ~1.3 tokens per word, plus context overhead savings (each chunk = ~4k context saved)
TOKEN_SAVED=$(( (TOTAL_WORDS * 13 / 10) + (SNAPSHOTS * 4000) ))
TOKEN_SAVED_K=$(( TOKEN_SAVED / 1000 ))
[ "$TOKEN_SAVED_K" -eq 0 ] && [ "$TOKEN_SAVED" -gt 0 ] && TOKEN_SAVED_K=1

# --- 5. Chart Data (cumulative savings per chunk) ---
CHART_DATA="[]"
if [ -d "$CHUNKS_DIR" ] && [ "$SNAPSHOTS" -gt 0 ]; then
    CUMULATIVE=0
    CHART_ITEMS=""
    # Process chunks oldest first for cumulative chart
    for f in $(ls -t "$CHUNKS_DIR"/*.md 2>/dev/null | tail -5); do
        [ -f "$f" ] || continue
        WORDS=$(wc -w < "$f" 2>/dev/null || echo "0")
        CHUNK_TOKENS=$(( (WORDS * 13 / 10) + 4000 ))
        CUMULATIVE=$(( CUMULATIVE + CHUNK_TOKENS ))
        CUMUL_K=$(( CUMULATIVE / 1000 ))
        [ -z "$CHART_ITEMS" ] && CHART_ITEMS="$CUMUL_K" || CHART_ITEMS="$CHART_ITEMS,$CUMUL_K"
    done
    CHART_DATA="[$CHART_ITEMS]"
fi

# --- 6. Timeline (last 5 chunks) ---
TIMELINE="[]"
if [ "$SNAPSHOTS" -gt 0 ]; then
    TIMELINE_ITEMS=""
    for i in "${!CHUNK_DATES[@]}"; do
        DATE="${CHUNK_DATES[$i]}"
        LABEL="${CHUNK_LABELS[$i]}"
        [ -z "$DATE" ] && DATE="N/A"
        [ -z "$LABEL" ] && LABEL="Session $((i+1))"
        ITEM="{\"date\":\"$DATE\",\"label\":\"$LABEL\",\"text\":\"Session chunk captured\"}"
        [ -z "$TIMELINE_ITEMS" ] && TIMELINE_ITEMS="$ITEM" || TIMELINE_ITEMS="$TIMELINE_ITEMS,$ITEM"
    done
    TIMELINE="[$TIMELINE_ITEMS]"
fi

# --- 7. Cost Data (from omni_cost.json if exists) ---
COST_TOTAL="0.00"
COST_BY_MODEL="{}"
if [ -f "$OMNI_COST" ]; then
    COST_TOTAL=$(json_val "$OMNI_COST" "total_cost" "0.00")
    COST_BY_MODEL=$(python3 -c "
import json
try:
    d = json.load(open('$OMNI_COST'))
    print(json.dumps(d.get('by_model', {})))
except: print('{}')
" 2>/dev/null || echo "{}")
fi

# --- 8. Architecture (from project-summary.md modules) ---
ARCHITECTURE="[]"
if [ -f "$PROJECT_SUMMARY" ]; then
    ARCHITECTURE=$(python3 -c "
import re
lines = open('$PROJECT_SUMMARY').readlines()
modules = []
in_modules = False
for line in lines:
    if 'Modules' in line or 'modules' in line:
        in_modules = True
        continue
    if in_modules:
        m = re.match(r'\s*-\s*\x60([^\x60]+)\x60\s*:\s*(.*)', line.strip())
        if m:
            modules.append({'role': m.group(1).split('/')[-1][:20], 'text': m.group(2).strip()[:80]})
        elif line.strip() and not line.startswith(' ') and not line.startswith('-'):
            break
if not modules:
    modules = [{'role': 'Project', 'text': 'See project-summary.md'}]
import json
print(json.dumps(modules[:6]))
" 2>/dev/null || echo "[{\"role\":\"Project\",\"text\":\"See project-summary.md\"}]")
fi

# --- Build output JSON ---
cat > "$OUTPUT_FILE" << ENDJSON
{
    "projectName": $(python3 -c "import json; print(json.dumps('$PROJECT_NAME'))" 2>/dev/null || echo "\"$PROJECT_NAME\""),
    "version": "$(json_val "$CONFIG_FILE" "omnistate_version" "1.3.0")",
    "activeTasks": $ACTIVE_TASKS,
    "totalTasks": $((TOTAL_TASKS + ARCHIVED_TASKS)),
    "archivedTasks": $ARCHIVED_TASKS,
    "doneTasks": $DONE_TASKS,
    "snapshots": $SNAPSHOTS,
    "tokenSavings": "${TOKEN_SAVED_K}k",
    "tokenSavingsRaw": $TOKEN_SAVED,
    "costTotal": "$COST_TOTAL",
    "costByModel": $COST_BY_MODEL,
    "lastUpdate": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "timeline": $TIMELINE,
    "architecture": $ARCHITECTURE,
    "chartData": $CHART_DATA
}
ENDJSON

echo "Dashboard data collected → $OUTPUT_FILE"
echo "  Project: $PROJECT_NAME"
echo "  Active: $ACTIVE_TASKS | Archived: $ARCHIVED_TASKS | Snapshots: $SNAPSHOTS"
echo "  Token savings: ~${TOKEN_SAVED_K}k"
