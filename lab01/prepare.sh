#!/bin/bash

function getItemsFromBacklogs() {
  local global_backlog_folder=$1
  local wordlist=$2
  local index_file=$3

  if [ ! -s "$wordlist" ]; then
    echo "Index file $index_file"
    # Find all .txt files in the backlogs folder
    local unused_files=($(comm -23 <(ls "$global_backlog_folder/"*.txt | sort) <(sort "$index_file")))

    if [ ${#unused_files[@]} -eq 0 ]; then
      echo "No unused backlog files found. Exiting..."
      exit 0
    fi

    local file=${unused_files[0]}
    # Append to wordlist, removing blank lines
    grep -v '^$' "$file" >> "$wordlist"
    # Mark as used by adding to index.txt
    echo "$(basename "$file")" >> "$index_file"
    
    sort -u "$index_file" -o "$index_file"

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
