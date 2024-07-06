#!/bin/bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
echo "Current directory: $CURRENT_DIR"
LAB_DIR="$CURRENT_DIR"
TARGET="$1"
echo "Target: $TARGET"
ENCODED_TARGET=$(echo -n "$TARGET" | base64)

# Step 2: Base64 encode the TARGET
# Step 3: Determine the next research number
ENCODED_TARGET=$(echo -n "$TARGET" | base64)

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
