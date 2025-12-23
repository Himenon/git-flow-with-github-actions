#!/bin/bash

# デバッグ用スクリプト
# PRクローズ時の処理をテスト

# 環境変数を設定
# export GITHUB_TOKEN="${GITHUB_TOKEN:-your_token_here}"
export PR_NUMBER="18"
export REPO="Himenon/michibiki"

echo "=========================================="
echo "PR Cleanup Debug Script"
echo "=========================================="
echo "PR_NUMBER: $PR_NUMBER"
echo "REPO: $REPO"
echo "Owner: ${REPO%/*}"
echo "Repo Name: ${REPO#*/}"
echo ""

# ========== Labels ==========
echo "=========================================="
echo "Step 1: Labels"
echo "=========================================="
echo "Fetching labels..."
echo "DEBUG: Running command: gh pr view $PR_NUMBER --repo $REPO --json labels | jq -r '.labels[].name'"
LABELS=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json labels | jq -r '.labels[].name' 2>&1)
echo "Raw labels output:"
echo "$LABELS"
echo ""

LABELS_CSV=$(echo "$LABELS" | tr '\n' ',' | sed 's/,$//')
echo "Labels CSV: '$LABELS_CSV'"
echo ""

if [ -n "$LABELS_CSV" ]; then
  echo "Attempting to remove labels: $LABELS_CSV"
  # gh pr edit $PR_NUMBER --repo $REPO --remove-label "$LABELS_CSV" || echo "⚠️ Label removal failed"
else
  echo "No labels to remove"
fi
echo ""

# ========== Milestone ==========
echo "=========================================="
echo "Step 2: Milestone"
echo "=========================================="
echo "Fetching milestone..."
echo "DEBUG: Running command: gh pr view $PR_NUMBER --repo $REPO --json milestone | jq -r '.milestone.title // \"none\"'"
MILESTONE=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json milestone | jq -r '.milestone.title // "none"' 2>&1)
echo "Current milestone: $MILESTONE"
echo ""

if [ "$MILESTONE" != "none" ]; then
  echo "Attempting to remove milestone..."
  # gh pr edit $PR_NUMBER --repo $REPO --milestone "" || echo "⚠️ Milestone removal failed"
else
  echo "No milestone to remove"
fi
echo ""

# ========== Projects ==========
echo "=========================================="
echo "Step 3: Projects"
echo "=========================================="
echo "Fetching project items..."

# GraphQL クエリの実行
QUERY_RESULT=$(gh api graphql -f query='query($owner:String!,$repo:String!,$number:Int!){repository(owner:$owner,name:$repo){pullRequest(number:$number){projectItems(first:10){nodes{id}}}}}' \
  -f owner="${REPO%/*}" -f repo="${REPO#*/}" -F number=$PR_NUMBER)

echo "GraphQL Response:"
echo "$QUERY_RESULT" | jq .
echo ""

# プロジェクトアイテムIDを抽出
PROJECT_ITEMS=$(echo "$QUERY_RESULT" | jq -r '.data.repository.pullRequest.projectItems.nodes[].id')
echo "Project Item IDs:"
echo "$PROJECT_ITEMS"
echo ""

if [ -n "$PROJECT_ITEMS" ]; then
  echo "Number of project items: $(echo "$PROJECT_ITEMS" | wc -l | tr -d ' ')"
  echo ""
  
  # 各アイテムを個別に処理
  COUNTER=1
  echo "$PROJECT_ITEMS" | while read -r ITEM_ID; do
    if [ -n "$ITEM_ID" ]; then
      echo "[$COUNTER] Processing item: $ITEM_ID"
      # コメントアウトして実際の削除は行わない（デバッグ用）
      # gh api graphql -f query='mutation($itemId:ID!){deleteProjectV2Item(input:{itemId:$itemId}){deletedItemId}}' -f itemId="$ITEM_ID" 2>&1 || echo "⚠️ Failed to delete item: $ITEM_ID"
      echo "  → Would delete item: $ITEM_ID"
      COUNTER=$((COUNTER + 1))
    fi
  done
  echo ""
  echo "✓ All project items processed"
else
  echo "No project items to remove"
fi
echo ""

echo "=========================================="
echo "Debug script completed"
echo "=========================================="