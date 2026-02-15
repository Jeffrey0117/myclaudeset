專案清理 (Project Mop-up)

整理當前專案，確保乾淨整潔。

## 執行步驟

### 1. 整理文檔
- 找出散落的文檔檔案 (*.md, *.txt, *.doc*)
- 建立 `docs/` 資料夾（如不存在）
- 將文檔移至適當位置：
  - README.md 留在根目錄
  - CHANGELOG.md, LICENSE 等留在根目錄
  - 其他文檔移至 `docs/`

### 2. 清理測試/暫存檔案
刪除以下類型的檔案（確認後）：
- `*.tmp`, `*.temp`
- `*.log` (非重要的)
- `*.bak`, `*.backup`
- `__pycache__/`, `.pytest_cache/`
- `node_modules/.cache/`
- `.DS_Store`, `Thumbs.db`
- 空資料夾

### 3. 資安檢查 - 確保 .gitignore 包含
檢查並更新 .gitignore，確保包含：
```
# 環境變數與密鑰
.env
.env.*
*.pem
*.key
*credentials*
*secret*
api_key*

# IDE
.idea/
.vscode/
*.swp

# 系統
.DS_Store
Thumbs.db

# 依賴
node_modules/
venv/
__pycache__/

# Build
dist/
build/
*.egg-info/
```

### 4. 確認已追蹤的敏感檔案
執行 `git ls-files` 檢查是否有敏感檔案已被追蹤，如有則警告用戶。

### 5. 輸出報告
列出：
- 移動了哪些檔案
- 刪除了哪些檔案
- .gitignore 新增了哪些項目
- 發現的潛在問題

IMPORTANT: 刪除檔案前務必確認，敏感操作要詢問用戶。
