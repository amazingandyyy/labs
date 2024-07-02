#!/bin/bash

# https://github.com/kkrypt0nn/wordlists/blob/main/wordlists/languages/english.txt DONE
# https://github.com/kkrypt0nn/wordlists/tree/main/tools DONE
# https://github.com/topics/wordlists
# https://github.com/six2dez/OneListForAll/blob/main/dict/common_short.txt
BACKLOGS_FOLDER="backlogs"
WORD_LIST="latest.txt"
# https://raw.githubusercontent.com/jeanphorn/wordlist/master/usernames.txt

if [ ! -s "$WORD_LIST" ]; then
  echo "latest.txt is empty, find the first txt file under the backlogs folder to append to latest.txt."
  # move the first txt file under the backlogs folder to become latest.txt
  # if nothing inside the backlogs folder, then exit 0
  if [ ! "$(ls -A backlogs)" ]; then
    echo "No files in the backlogs folder. Exiting..."
    exit 0
  fi

  file=$(ls backlogs | head -n 1)
  mkdir -p backlogs/archived
  mv backlogs/$file backlogs/archived/$file
  # append to latest.txt
  cat "backlogs/archived/$file" >> "$WORD_LIST"
  # if latest.txt is empty, then exit 0
  if [ ! -s "$WORD_LIST" ]; then
    echo "latest.txt is empty after moving from backlogs. Exiting..."
    exit 0
  fi
fi

# print useful information
echo "Checking for special characters in $BACKLOGS_FOLDER/*.txt files..."

# Remove any line that has special characters in BACKLOGS_FOLDER/*.txt
for file in $BACKLOGS_FOLDER/*.txt; do
  grep -Ev '[^a-zA-Z0-9]' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
done

echo "Checking for files with over 10000 lines in $BACKLOGS_FOLDER/*.txt files..."

# If any *.txt file under the backlogs folder has over 10000 lines, break into multiple files
for file in $BACKLOGS_FOLDER/*.txt; do
  if [ $(wc -l < "$file") -gt 10000 ]; then
    split -l 10000 "$file" "${file%.txt}_part"
    rm "$file"
    for part in ${file%.txt}_part*; do
      mv "$part" "$part.txt"
    done
  fi
done
