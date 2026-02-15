列出最近的 Git commits，清楚排版顯示詳細資訊

## 執行步驟

### 1. 檢查 Git 倉庫
確認當前目錄是 git 倉庫

### 2. 執行 git log
使用以下命令列出最近 30 筆 commits：

```bash
git log --oneline --graph --decorate --all -30
```

### 3. 詳細版本
如需更多細節，也執行：

```bash
git log --format="%C(yellow)%h%C(reset) %C(cyan)%ad%C(reset) %C(green)%an%C(reset)%n  %s%n" --date=short -20
```

### 4. 輸出格式
將結果以清晰的表格或列表呈現給用戶，包含：
- Commit hash (短)
- 日期
- 作者
- Commit 訊息
- 分支/標籤資訊

IMPORTANT: 如果不是 git 倉庫，告知用戶並停止執行。
