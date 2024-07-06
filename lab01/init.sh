#!/bin/bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "Current directory: $CURRENT_DIR"
LAB_DIR="$CURRENT_DIR"
TARGET_NAME="$1"
TARGET_UEL="$2"
if [ -z "$TARGET_URL" ]; then
  # loop thru all instruction.yaml files and base decode research_target and append to $LAB_DIR/researches/index.txt
  rm -rf $LAB_DIR/researches/index.csv
  for instruction in $(find $LAB_DIR/researches -name instruction.yaml); do
    RESEARCH_TARGET=$(grep research_target $instruction | awk '{print $2}' | base64 -d)
    # append research_name, research_target to $LAB_DIR/researches/index.txt
    RESEARCH_NAME=$(basename $(dirname $instruction))
    echo "$RESEARCH_NAME,$RESEARCH_TARGET" >> $LAB_DIR/researches/index.csv
    # sort and remove duplicates
    sort -u $LAB_DIR/researches/index.csv -o $LAB_DIR/researches/index.csv
  done
  exit 0
fi

echo "Target name: $TARGET_NAME"
echo "Target URL: $TARGET_URL"
ENCODED_TARGET=$(echo "$TARGET_URL" | base64)
echo "Encoded target URL: $ENCODED_TARGET"

cp -r $LAB_DIR/researches/greenhouse $LAB_DIR/researches/research/$TARGET_NAME

> $LAB_DIR/researches/research/$TARGET_NAME/backlogs-index.txt
> $LAB_DIR/researches/research/$TARGET_NAME/results.txt
> $LAB_DIR/researches/research/$TARGET_NAME/targets.txt

cat > $LAB_DIR/researches/research/$TARGET_NAME/instruction.yaml <<EOL
research_target: $ENCODED_TARGET # $TARGET_URL
processing_amount: 200
exclude_response_length: 6248
EOL

rm -rf $LAB_DIR/researches/research/$TARGET_NAME/greenhouse
echo "Research initialized successfully as research /$TARGET_NAME"
