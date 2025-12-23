# git-flow practice with GitHub Actions

## GitHub Actions ワークフロー

このリポジトリでは、以下のGitHub Actionsワークフローを使用してPull Requestの管理を自動化しています。

### 1. PR / feature ブランチ (`pr-feature-branch.yml`)

**対象:** `feature/*` ブランチからのPull Request

**実行タイミング:** PR作成、再オープン、ready for review、同期、編集時

**主な機能:**
- ✅ **ベースブランチの検証:** `feature/*` ブランチのPRは `develop/*` ブランチに向けて作成されているかを確認
- ⚠️ **警告コメント投稿:** ベースブランチが `develop/*` でない場合、警告コメントを自動投稿
- 🗑️ **警告コメント削除:** 適切なベースブランチに変更された場合、警告コメントを自動削除

**ブランチルール:**
- `feature/*` → `develop/*` ✅ 推奨
- `feature/*` → その他 ⚠️ 警告

---

### 2. PR / develop ブランチ (`pr-develop-branch.yml`)

**対象:** `develop/*` ブランチからのPull Request

**実行タイミング:** PR作成、再オープン、ready for review、同期、編集時

**主な機能:**
- ✅ **ベースブランチの検証:** `develop/*` ブランチのPRは `main` または `release/staging` ブランチに向けて作成されているかを確認
- ⚠️ **警告コメント投稿:** ベースブランチが許可されていない場合、警告コメントを自動投稿
- 🗑️ **警告コメント削除:** 適切なベースブランチに変更された場合、警告コメントを自動削除

**ブランチルール:**
- `develop/*` → `main` ✅ 推奨
- `develop/*` → `release/staging` ✅ 推奨
- `develop/*` → その他 ⚠️ 警告

---

### 3. PR / develop → main (`pr-develop-to-main.yml`)

**対象:** `develop/*` ブランチから `main` ブランチへのPull Request

**実行タイミング:** PRオープン、再オープン、ready for review、draft変換、同期時

**主な機能:**

#### 📝 PRオープン時のコメント投稿
- PRオープン時またはready for review時に、セルフレビューを促すコメントを自動投稿

#### 📊 GitHub Projectsへの自動追加
- PRを自動的に[プロジェクトボード](https://github.com/users/Himenon/projects/2)に追加
- ステータスを「In Progress」に自動設定

#### 🏷️ リリース管理ラベルの自動付与
- **Draft状態:** 「開発中」ラベルを付与
- **Ready for review:** 「リリース前」ラベルを付与、「開発中」ラベルを削除

#### 🎯 マイルストーンの自動設定
- **Draft状態:** マイルストーン2を設定
- **Ready for review:** マイルストーン3を設定

#### 💬 Draft変換時の通知
- PRがDraftに変換されたときに通知コメントを自動投稿

---

### 4. PR / develop → release/staging (`pr-develop-to-staging.yml`)

**対象:** `develop/*` ブランチから `release/staging` ブランチへのPull Request

**実行タイミング:** PRオープン、再オープン、ready for review、draft変換、同期時

**主な機能:**

#### 🏷️ Stagingリリースラベルの管理
- **Ready for review時:** 「Stagingリリース」ラベルを付与
- **Draft時:** 「Stagingリリース」ラベルを削除

---

## ブランチ戦略

このプロジェクトでは以下のブランチ戦略を採用しています:

```
feature/* → develop/* → main
                     ↘ release/staging
```

### ブランチの説明

- **`feature/*`**: 新機能や修正を開発するブランチ
- **`develop/*`**: 機能をまとめて開発・テストするブランチ
- **`main`**: 本番環境にデプロイされるブランチ
- **`release/staging`**: Staging環境にデプロイされるブランチ

### Pull Requestのルール

1. **feature → develop**: 機能開発が完了したら、`develop/*` ブランチにPRを作成
2. **develop → main**: 本番リリース時は `main` ブランチにPRを作成
3. **develop → release/staging**: Stagingリリース時は `release/staging` ブランチにPRを作成

---

## ワークフローの利用方法

1. 適切なブランチ命名規則に従ってブランチを作成
2. Pull Requestを作成すると、自動的に該当するワークフローが実行されます
3. ワークフローからのコメントや警告を確認し、必要に応じて対応してください
4. ベースブランチが正しくない場合は、GitHubのPR画面から変更可能です

---

## 必要な権限とシークレット

ワークフローが正常に動作するには、以下のシークレットが必要です:

- `GITHUB_TOKEN`: GitHub Actions デフォルトトークン（自動提供）
- `GH_APP_ID`: GitHub App ID
- `GH_APP_PRIVATE_KEY`: GitHub App 秘密鍵
- `GH_PROJECT_TOKEN`: GitHub Projects へのアクセス権限を持つトークン

---

## ライセンス

本プロジェクトのライセンスについては、リポジトリの LICENSE ファイルを参照してください。
