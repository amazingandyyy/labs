#!/bin/bash

input_file=$1

# Check if the input file exists
if [[ ! -f "$input_file" ]]; then
  echo "Input file does not exist."
  exit 1
fi

temp_file="$(mktemp)"

# Process each line in the input file
while IFS= read -r url; do
  # Normalize URL by removing 'http(s)://' and 'www.'
  # Remove protocol and optional 'www.'
  normalized_url=$(echo "$url" | awk -F/ '{sub(/^(http:|https:)?\/\//, "", $1); sub(/^www\./, "", $1); print $1}')

  # Extract the domain part before the first slash (to remove any path)
  domain_only=$(echo "$normalized_url" | cut -d'/' -f1)

  # Extract the domain without the TLD
  main_domain=$(echo "$domain_only" | awk -F'.' '{if (NF > 1) print $(NF-1)}')

  # Check if the domain extraction was successful and if not, skip to the next line
  if [[ -z "$main_domain" ]]; then
    continue
  fi

  # Print the domain before writing to the file
  echo "Extracted domain: $main_domain"

  # Write the extracted domain to the temp file
  echo "$main_domain" >> "$temp_file"
done < "$input_file"

# Replace the original file with the new file
mv "$temp_file" "$input_file"

echo "Domains have been extracted and the original file has been updated."
