#!/bin/bash

function getItemsFromBacklogs() {
  local global_backlog_folder=$1
  local wordlist=$2
  local index_file=$3

  if [ ! -s "$wordlist" ]; then
    echo "Index file $index_file"
    # Find the first .txt files that's not in $index_file
    file=$(find "$global_backlog_folder" -type f -name '*.txt' | grep -vxFf "$index_file" | head -n 1)
    if [ -z "$file" ]; then
      echo "No more files to process. Exiting..."
      exit 0
    fi
    echo "Moving content in $file to $wordlist"
    # Append to wordlist, removing blank lines
    grep -v '^$' "$file" >> "$wordlist"
    # Mark as used by adding to index.txt
    echo "Adding $(basename "$file") to $index_file"
    echo "$(basename "$file")" >> "$index_file"

    # Sort and remove duplicates and remove blank lines
    sort -u "$wordlist" -o "$wordlist"  # sort and remove duplicates
    grep -v '^$' "$wordlist" > "${wordlist}.tmp" && mv "${wordlist}.tmp" "$wordlist"  # remove blank lines

    if [ ! -s "$wordlist" ]; then
      echo "Wordlist is empty after appending. Exiting..."
      exit 0
    fi
  fi
}

function cleanUpBacklogs() {
  local backlogs_folder=$1

  # Remove any line that has special characters in BACKLOGS_FOLDER/*.txt
  echo "Checking for special characters in $backlogs_folder/*.txt files..."
  for file in $backlogs_folder/*.txt; do
    grep -Ev '[^a-zA-Z0-9]' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
  done

  echo "Checking for files with over 10000 lines in $backlogs_folder/*.txt files..."

  # If any *.txt file under the backlogs folder has over 10000 lines, break into multiple files
  for file in $backlogs_folder/*.txt; do
    if [ $(wc -l < "$file") -gt 10000 ]; then
      split -l 10000 "$file" "${file%.txt}_part"
      rm "$file"
      for part in ${file%.txt}_part*; do
        mv "$part" "$part.txt"
      done
    fi
  done
}
