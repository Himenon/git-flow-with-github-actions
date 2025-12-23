# !/bin/bash

# 環境変数を設定
# export GITHUB_TOKEN="your_gh_project_token_here"
export PROJECT_ID="PVT_kwHOAGZ3Xc4BLIWA"
export PROJECT_NUMBER="2"  # プロジェクト番号（Project URLの最後の数字）
export PR_URL="https://github.com/Himenon/michibiki/pull/1"
export OWNER="Himenon"

# Item IDを取得（プロジェクト番号を使用）
echo "Fetching items from project #$PROJECT_NUMBER..."
ITEM_ID=$(gh project item-list $PROJECT_NUMBER --owner $OWNER --format json | jq -r ".items[] | select(.content.url == \"$PR_URL\") | .id")
echo "Item ID: $ITEM_ID"

# Todoステータスに更新（Item IDが取得できた場合のみ）
if [ -n "$ITEM_ID" ]; then
  echo "Updating status to Todo..."
  gh project item-edit --id $ITEM_ID --field-id PVTSSF_lAHOAGZ3Xc4BLIWAzg6y8i0 --project-id $PROJECT_ID --single-select-option-id f75ad846
  echo "Status updated to Todo"
else
  echo "Item ID not found"
fi