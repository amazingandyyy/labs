#!/bin/bash

set -x
REPO_DIR="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)")"
RESEARCH_DIR="${REPO_DIR}/lab01/researches/$1"

# File paths
WORD_LIST="$RESEARCH_DIR/latest.txt"
BACKLOGS_FOLDER="$RESEARCH_DIR/backlogs"
RESULTS_FILE="$RESEARCH_DIR/results/list.txt"
GOBUSTER_TMP_FILE="$RESEARCH_DIR/.gobuster.tmp.txt"
TAIL_TMP_FILE="$RESEARCH_DIR/.tail.tmp.txt"
TOP_X_LIST="$RESEARCH_DIR/namelist_top_X.txt"
PATTERN_FILE="$RESEARCH_DIR/patterns.txt"

# research parameters
BASE_URL=$(echo "$2" | base64 -d)
AMOUNT=$3
GOBUSTER_ERROR_LENGTH=$4
set +x

# deal with backlogs
source "${REPO_DIR}"/scripts/backlogs.sh
getItemsFromBacklogs $WORD_LIST $BACKLOGS_FOLDER
cleanUpBacklogs $BACKLOGS_FOLDER

# Print out how many items will be processed
echo "Processing $AMOUNT items in $WORD_LIST"

# Create a temporary wordlist file with the top X items
head -n $AMOUNT "$WORD_LIST" > "$TOP_X_LIST"

# random generate delay from 1000ms to 5000ms
DELAY=$(( ( RANDOM % 4000 ) + 1000 ))
THREADS=$(( ( RANDOM % 5 ) + 2 ))
gobuster dir -u "$BASE_URL" -w "$TOP_X_LIST" -o "$GOBUSTER_TMP_FILE" --pattern $PATTERN_FILE \
  --exclude-length $GOBUSTER_ERROR_LENGTH \
  --threads $THREADS \
  --random-agent \
  --retry --retry-attempts 3 \
  --delay "${DELAY}ms" \
  --hide-length \
  --no-color \
  --expanded \
  --no-status
  #  --quiet \
  #  --no-progress \

# Check if gobuster ran successfully
if [ $? -eq 0 ]; then
  # Append gobuster.tmp.txt to results/results.txt if it exists
  if [ -f "$GOBUSTER_TMP_FILE" ]; then
    cat "$GOBUSTER_TMP_FILE" >> "$RESULTS_FILE" && rm -rf "$GOBUSTER_TMP_FILE"
    # sort
    sort -u "$RESULTS_FILE" -o "$RESULTS_FILE"
    # remove duplicates
    awk '!seen[$0]++' "$RESULTS_FILE" > "$RESULTS_FILE.tmp" && mv "$RESULTS_FILE.tmp" "$RESULTS_FILE"
  fi

  # Create a new temporary file for tail operation
  tail -n +$((X + 1)) "$WORD_LIST" > "$TAIL_TMP_FILE"

  # Overwrite the original wordlist with the tail tmp file
  cp "$TAIL_TMP_FILE" "$WORD_LIST"

  # Clean up temporary wordlist file and tail tmp file
  rm -f "$TOP_X_LIST" "$TAIL_TMP_FILE"
else
  echo "Gobuster encountered an error. Exiting."
  rm -f "$TOP_X_LIST" "$GOBUSTER_TMP_FILE"
  exit 1
fi

## check each line of $RESULTS_FILE, if each line is base64 encoded, if not encode it
#while IFS= read -r line; do
#  if [[ ! "$line" =~ ^[a-zA-Z0-9/+]{43}=$ ]]; then
#    echo "$line" | base64 >> "$RESULTS_FILE"
#  fi
#done < "$RESULTS_FILE"

# Summary
echo "Total items processed: $X"

# Exit with status 0
exit 0
