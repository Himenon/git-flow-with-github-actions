# git-flow practice with GitHub Actions

## GitHub Actions ワークフロー

このリポジトリでは、GitHub Actionsワークフローを使用してPull Requestの管理を自動化しています。

---

## 1. PR / ブランチルール (`pr-branch-rule.yml`)

**実行タイミング:** PR作成時

**主な機能:**
- ✅ **ブランチの組み合わせ検証:** PRのブランチの組み合わせが許可されたパターンかを確認
- ⚠️ **警告コメント投稿/更新:** ルール違反の場合、警告コメントを自動投稿または更新
- 🗑️ **警告コメント削除:** 適切な組み合わせに変更された場合、警告コメントを自動削除

**許可されるブランチパターン:**
- `develop/*` → `main` または `release/staging` ✅
- `feature/*` → `develop/*` ✅
- `hotfix/*` → `main` または `release/staging` ✅
- 上記以外の組み合わせ ⚠️ 警告

---

## 2. PR / feature → develop (`pr-feature-to-develop.yml`)

**対象:** `feature/*` ブランチから `develop/*` ブランチへのPull Request

**実行タイミング:** PRオープン、レビュー依頼、レビュー承認時

**主な機能:**

### 📝 初期コメント投稿
- PRオープン時に、セルフレビューとスコープ確認を促すコメントを自動投稿

### 🔄 レビュー管理
- **レビュー再要求時:** 承認通知コメントを自動削除
- **全Approve時:** Squash Mergeを促す通知コメントを自動投稿

---

## 3. PR / develop → main (`pr-develop-to-main.yml`)

**対象:** `develop/*` ブランチから `main` ブランチへのPull Request

**実行タイミング:** PRオープン、再オープン、ready for review、draft変換、同期、ラベル付与時

**主な機能:**

### 📝 PRオープン時のコメント投稿
- PRオープン時またはready for review時に、セルフレビューを促すコメントを自動投稿

### 📊 GitHub Projectsへの自動追加
- PRを自動的に[プロジェクトボード](https://github.com/users/Himenon/projects/2)に追加
- ステータスを「In Progress」に自動設定

### 🏷️ リリース管理ラベルの自動付与
- **Draft状態:** 「開発中」ラベルを付与
- **Ready for review:** 「リリース前」ラベルを付与、「開発中」ラベルを削除

### 🎯 マイルストーンの自動設定
- **Draft状態:** マイルストーン2（開発中）を設定
- **Ready for review:** マイルストーン3（次回リリース）を設定

---

## 4. PR / develop → release/staging (`pr-develop-to-staging.yml`)

**対象:** `develop/*` ブランチから `release/staging` ブランチへのPull Request

**実行タイミング:** PRオープン、再オープン、ready for review、draft変換、同期時

**主な機能:**

### 🏷️ Stagingリリースラベルの管理
- **Ready for review時:** 「Stagingリリース」ラベルを付与
- **Draft時:** 「Stagingリリース」ラベルを削除

### 💬 Staging確認ラベルの付与促進
- PRオープン時に、マージ後にdevelopブランチへ「Staging確認中」ラベルの付与を促すコメントを投稿

---

## 5. チェック / PRタイトルプレフィックス (`pr-title-check.yml`)

**対象:** `main`, `release/staging`, `develop/**` ブランチへのPull Request

**実行タイミング:** PRオープン、編集時

**主な機能:**
- ✅ **PRタイトル検証:** 適切なプレフィックスが付与されているかを確認
- ⚠️ **警告コメント投稿/更新:** プレフィックスがない場合、警告コメントを自動投稿または更新
- 🗑️ **警告コメント削除:** 適切なプレフィックスが付与された場合、警告コメントを自動削除
- ❌ **ワークフロー失敗:** プレフィックスがない場合、ワークフローを失敗させる

**必須プレフィックス:**
- `feat:` - 新機能
- `fix:` - バグ修正
- `docs:` - ドキュメント変更
- `style:` - コードスタイル変更（機能に影響しない）
- `refactor:` - リファクタリング
- `perf:` - パフォーマンス改善
- `test:` - テスト追加・修正
- `chore:` - ビルドプロセスやツールの変更

**例:** `feat: ユーザー認証機能を追加`

---

## 6. マージ後の処理 (`pr-merged.yml`)

**実行タイミング:** PRクローズ時（マージされた場合のみ）

**主な機能:**
- 🏷️ **ラベル更新:** 「リリース前」ラベルを削除し、「completed」ラベルを付与

---

## 7. クローズ後の処理 (`pr-closed.yml`)

**実行タイミング:** PRクローズ時（マージされずにクローズされた場合のみ）

**主な機能:**
- 🗑️ **ラベル削除:** すべてのラベルを削除
- 🗑️ **マイルストーン削除:** 設定されているマイルストーンを削除
- 🗑️ **プロジェクトから削除:** GitHub Projectsからアイテムを削除

---

## 8. [bot] PR作成 (`bot-create-pr.yml`)

**実行方法:** 手動実行（workflow_dispatch）

**入力パラメータ:**
- `source_branch`: PRの元となるブランチ名（必須）
- `target_branch`: PRのマージ先ブランチ名（必須、デフォルト: `develop/main`）
- `pr_title`: PRのタイトル（省略可、省略時はブランチ名を使用）
- `pr_body`: PRの本文（省略可、省略時はデフォルトメッセージ）

**主な機能:**
- 📝 **PR自動作成:** 指定されたブランチ間でPRを自動作成
- 🔑 **GitHub App認証:** GitHub Appトークンを使用した安全な認証

---

## 9. [bot] 空コミット作成 (`bot-empty-commit.yml`)

**実行方法:** 手動実行（workflow_dispatch）

**入力パラメータ:**
- `branch_name`: コミットを追加するブランチ名（必須）

**主な機能:**
- 📝 **空コミット作成:** 指定されたブランチに空コミットを追加
- 🔄 **ワークフロー再実行:** コミットをトリガーとしてワークフローを再実行させることが可能
- 🔑 **GitHub App認証:** GitHub Appトークンを使用した安全な認証

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
