#!/bin/bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "Current directory: $CURRENT_DIR"
LAB_DIR="$CURRENT_DIR"
TARGET="$1"
if [ -z "$TARGET" ]; then
  # loop thru all instruction.yaml files and base decode research_target and append to $LAB_DIR/researches/index.txt
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

echo "Target: $TARGET"
ENCODED_TARGET=$(echo "$TARGET" | base64)
echo "Encoded target: $ENCODED_TARGET"

LAST_RESEARCH=$(basename $(find $LAB_DIR/researches -maxdepth 1 -type d | sort | tail -n 1))
# Step 3: Determine the next research number
NEXT_RESEARCH_NUM=$(printf "%02d" $((10#${LAST_RESEARCH: -2} + 1)))

LAST_RESEARCH=$(basename $(find $LAB_DIR/researches -type d | sort | tail -n 1))
# Step 4: Copy the template research directory to the new research directory
NEXT_RESEARCH_NUM=$(printf "%02d" $((10#${LAST_RESEARCH: -2} + 1)))

cp -r $LAB_DIR/researches/research01 $LAB_DIR/researches/research$NEXT_RESEARCH_NUM

> $LAB_DIR/researches/research$NEXT_RESEARCH_NUM/backlogs-index.txt
> $LAB_DIR/researches/research$NEXT_RESEARCH_NUM/results.txt
> $LAB_DIR/researches/research$NEXT_RESEARCH_NUM/targets.txt

cat > $LAB_DIR/researches/research$NEXT_RESEARCH_NUM/instruction.yaml <<EOL
research_target: $ENCODED_TARGET # $TARGET
processing_amount: 200
exclude_response_length: 6248
EOL

rm -rf $LAB_DIR/researches/research$NEXT_RESEARCH_NUM/research01
echo "Research initialized successfully as research $NEXT_RESEARCH_NUM"
