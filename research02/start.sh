#!/bin/bash

# Input file containing names to process
WORD_LIST="latest.txt"
# https://raw.githubusercontent.com/jeanphorn/wordlist/master/usernames.txt

INPUT=$1

# Base URL to scan
BASE_URL=$(echo "$INPUT" | base64 -d)

# Calculate the number of items to process
X=$2

GOBUSTER_ERROR_LENGTH=$3

# File paths
RESULTS_FILE="results/list.txt"
GOBUSTER_TMP_FILE=".gobuster.tmp.txt"
TAIL_TMP_FILE=".tail.tmp.txt"
TOP_X_LIST="namelist_top_X.txt"

# Print out how many items will be processed
echo "Processing $X items from $WORD_LIST"

# Create a temporary wordlist file with the top X items
head -n $X "$WORD_LIST" > "$TOP_X_LIST"

# random generate delay from 1000ms to 5000ms
DELAY=$(( ( RANDOM % 4000 ) + 1000 ))
THREADS=$(( ( RANDOM % 5 ) + 2 ))
gobuster dir --random-agent --retry --retry-attempts 3 -u "$BASE_URL" -w "$TOP_X_LIST" -t $THREADS --delay "${DELAY}ms" --no-color -o "$GOBUSTER_TMP_FILE" --exclude-length $GOBUSTER_ERROR_LENGTH

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

# Summary
echo "Total items processed: $X"

# Exit with status 0
exit 0
