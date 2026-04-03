#!/usr/bin/env bash

# Read JSON input from stdin
input=$(cat)

MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')

# Get git branch information
GIT_BRANCH=""
if git rev-parse &>/dev/null; then
  BRANCH=$(git branch --show-current)
  if [ -n "$BRANCH" ]; then
    GIT_BRANCH=" |  $BRANCH"
  else
    COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null)
    if [ -n "$COMMIT_HASH" ]; then
      GIT_BRANCH=" |  HEAD ($COMMIT_HASH)"
    fi
  fi
fi

# Get token summary from context_window data
percentage=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
percentage=${percentage:-0}

# Calculate total tokens from current usage
total_tokens=$(echo "$input" | jq -r '
  .context_window.current_usage |
  ((.input_tokens // 0) + (.output_tokens // 0) +
   (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))' 2>/dev/null)
total_tokens=${total_tokens:-0}

# Format token display
if [ "$total_tokens" -ge 1000 ]; then
  thousands=$(echo "scale=1; $total_tokens/1000" | bc)
  token_display=$(printf "%.1fK" "$thousands")
else
  token_display="$total_tokens"
fi

# Color coding for percentage
if [ "$percentage" -ge 90 ]; then
  color="\033[31m" # Red
elif [ "$percentage" -ge 70 ]; then
  color="\033[33m" # Yellow
else
  color="\033[32m" # Green
fi

# Format: "123K tkns. (10%)"
TOKEN_COUNT=$(echo -e "${token_display} tkns. (${color}${percentage}%\033[0m)")

echo "󰚩 ${MODEL_DISPLAY} |  ${CURRENT_DIR##*/}${GIT_BRANCH} |  ${TOKEN_COUNT}"