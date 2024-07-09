#!/bin/bash

# Exit on error
set -e

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
RESEARCH_NAME="$1"
INSTRUCTION_YAML="$CURRENT_DIR/researches/${RESEARCH_NAME}/instruction.yaml"
GLOBAL_FOLDER="$CURRENT_DIR/global"

# Extract values and assign to variables
echo "Hash is $(yq e '.research_target' "$INSTRUCTION_YAML")"
RESEARCH_TARGET=$(yq e '.research_target' "$INSTRUCTION_YAML" | base64 -d)
echo "RESEARCH_TARGET: $RESEARCH_TARGET"
PROCESSING_AMOUNT=$(yq e '.processing_amount' "$INSTRUCTION_YAML")
EXCLUDE_RESPONSE_LENGTH=$(yq e '.exclude_response_length' "$INSTRUCTION_YAML")
RESEARCH_DIR="$CURRENT_DIR/researches/${RESEARCH_NAME}"
BASE_URL="$RESEARCH_TARGET"
AMOUNT="$PROCESSING_AMOUNT"
GOBUSTER_ERROR_LENGTH="$EXCLUDE_RESPONSE_LENGTH"

# Define file paths
WORD_LIST="$RESEARCH_DIR/targets.txt"
RESULTS_FILE="$RESEARCH_DIR/results.txt"
GOBUSTER_TMP_FILE="$RESEARCH_DIR/.gobuster.tmp.txt"
TAIL_TMP_FILE="$RESEARCH_DIR/.tail.tmp.txt"
TOP_X_LIST="$RESEARCH_DIR/namelist_top_X.txt"
PATTERN_FILE="$GLOBAL_FOLDER/patterns.txt"

# Process backlogs, prepare lab
source "$CURRENT_DIR/prepare.sh"
getItemsFromBacklogs "$GLOBAL_FOLDER/backlogs" $WORD_LIST "$RESEARCH_DIR/backlogs-index.txt"
cleanUpBacklogs "$GLOBAL_FOLDER/backlogs"

echo "Processing $AMOUNT items in $WORD_LIST"
head -n $AMOUNT "$WORD_LIST" > "$TOP_X_LIST"
echo "Total lines in $TOP_X_LIST: $(wc -l < $TOP_X_LIST)"

DELAY=$(( ( RANDOM % 4000 ) + 1000 ))
THREADS=$(( ( RANDOM % 5 ) + 5 ))
gobuster dir -u "$BASE_URL" -w "$TOP_X_LIST" -o "$GOBUSTER_TMP_FILE" --pattern $PATTERN_FILE \
  --exclude-length $GOBUSTER_ERROR_LENGTH \
  --threads $THREADS \
  --random-agent \
  --retry --retry-attempts 3 \
  --delay "${DELAY}ms" \
  --hide-length --expanded --no-status --no-color

NEW_RESULTS=$(wc -l < "$GOBUSTER_TMP_FILE")
if [ -f "$GOBUSTER_TMP_FILE" ]; then
  cat "$GOBUSTER_TMP_FILE" >> "$RESULTS_FILE"
  rm -f "$GOBUSTER_TMP_FILE"
fi

# Sort, remove duplicates, and convert to lowercase in one step
awk '{print tolower($0)}' "$RESULTS_FILE" | sort -u > "$RESULTS_FILE.tmp" && mv "$RESULTS_FILE.tmp" "$RESULTS_FILE"

echo remove $AMOUNT amount of lines from $WORD_LIST
old_wordlist_size=$(wc -l < "$WORD_LIST")
tail -n +$((AMOUNT+1)) "$WORD_LIST" > "$TAIL_TMP_FILE"
cp "$TAIL_TMP_FILE" "$WORD_LIST"
rm -f "$TOP_X_LIST" "$TAIL_TMP_FILE"
new_wordlist_size=$(wc -l < "$WORD_LIST")

#PROCESSED_AMOUNT is the line difference between the original wordlist and the new wordlist
PROCESSED_AMOUNT=$((old_wordlist_size - new_wordlist_size))
echo "Summary: $NEW_RESULTS/$AMOUNT items is positive"
echo "new_results=$NEW_RESULTS" >> "$GITHUB_OUTPUT"
echo "processed_results=$PROCESSED_AMOUNT" >> "$GITHUB_OUTPUT"

exit 0
