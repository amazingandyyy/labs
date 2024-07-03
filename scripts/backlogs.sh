#!/bin/bash

function getItemsFromBacklogs() {
  local wordlist=$1
  local backlogs_folder=$2

  if [ ! -s "$wordlist" ]; then
      echo "latest.txt is empty, find the first txt file under the $backlogs_folder folder to append to latest.txt."
      # move the first txt file under the backlogs folder to become latest.txt
      # if nothing inside the backlogs folder, then exit 0
      if [ ! "$(ls -A $backlogs_folder)" ]; then
        echo "No files in the $backlogs_folder folder. Exiting..."
        exit 0
      fi

      file=$(ls $backlogs_folder | head -n 1)
      mkdir -p $backlogs_folder/archived
      mv $backlogs_folder/$file $backlogs_folder/archived/$file
      # append to latest.txt
      # remove blank lines and append to wordlist, don't use sed
      cat "$backlogs_folder/archived/$file" | grep -v '^$' >> "$wordlist"

      # if latest.txt is empty, then exit 0
      if [ ! -s "$wordlist" ]; then
        echo "latest.txt is empty after moving from $backlogs_folder. Exiting..."
        exit 0
      fi
    fi
}

function cleanUpBacklogs() {
  local backlogs_folder=$1

  # print useful information
  echo "Checking for special characters in $backlogs_folder/*.txt files..."

  # Remove any line that has special characters in BACKLOGS_FOLDER/*.txt
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
