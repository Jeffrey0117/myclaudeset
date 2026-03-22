掃描專案中的 hardcoded 使用者路徑，找出部署到其他機器時會壞掉的地方。

參數: $ARGUMENTS (可選: 掃描路徑，預設為當前目錄。加 --fix 自動修復)

Instructions:

## 1. 確定掃描目標

- 如果有 $ARGUMENTS 且不是 `--fix`，以該路徑為掃描根目錄
- 如果在遠端配對模式，用 `remote_execute_command` 執行掃描
- 否則用本地 Bash 工具

## 2. 掃描 hardcoded 路徑

用以下 PowerShell 指令掃描（Windows）：

```powershell
Get-ChildItem -Path <目標路徑> -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $_.Extension -match '\.(ts|js|py|json|env|bat|yaml|yml|toml|cfg|ini|sh)$' -and $_.FullName -notmatch 'node_modules|\\\.git\\|dist\\|\.next|build\\|__pycache__' } |
  Select-String -Pattern 'C:\\Users\\[^\\]+\\|C:/Users/[^/]+/|/home/[^/]+/|/Users/[^/]+/' -ErrorAction SilentlyContinue |
  Select-Object -First 50 |
  ForEach-Object { "$($_.RelativePath):$($_.LineNumber): $($_.Line.Trim())" }
```

Linux/Mac 替代：
```bash
grep -rn --include='*.{ts,js,py,json,env,bat,yaml,yml,toml,sh}' \
  -E '(/home/[^/]+/|/Users/[^/]+/|C:/Users/[^/]+/)' <目標路徑> \
  --exclude-dir={node_modules,.git,dist,.next,build,__pycache__} | head -50
```

## 3. 分類結果

將找到的 hardcoded 路徑分類：

| 類別 | 說明 | 建議修復 |
|------|------|----------|
| **環境變數** | 可用 env var 取代 | `process.env.HOME` 或 `os.homedir()` |
| **SDK/Library 路徑** | 本地開發 SDK 參照 | 改用 `pip install` / `npm install` 或 `try/except` 可選 import |
| **資料目錄** | 資料/媒體路徑 | 用相對路徑或 `path.resolve(__dirname, ...)` |
| **設定檔** | .env / config 裡的絕對路徑 | 改用相對路徑或環境變數 |

## 4. 輸出報告

格式：
```
🔍 Path Check Report
━━━━━━━━━━━━━━━━━━━━

找到 N 個 hardcoded 使用者路徑：

📁 project-name/file.py:42
   MEEI_PATH = "C:/Users/jeffb/Desktop/code/meei/python/src"
   → 建議：改用 try/except optional import 或環境變數 MEEI_SDK_PATH

📁 project-name/config.json:8
   "dataDir": "C:/Users/jeffb/data"
   → 建議：改用相對路徑 "./data"

━━━━━━━━━━━━━━━━━━━━
⚠️ 這些路徑在部署到其他機器時會失效！
```

## 5. 自動修復 (--fix)

如果使用者加了 `--fix` 參數：

1. 對每個找到的問題，套用安全的修復策略：
   - **Python `sys.path` 插入** → 包在 `try/except ImportError` 裡，fallback 到 pip 安裝的版本
   - **絕對路徑常數** → 改成 `os.environ.get("VAR_NAME", <相對路徑 fallback>)`
   - **JSON/config 路徑** → 提示使用者，不自動改（怕改壞）

2. 修改前一定先讀取完整檔案內容
3. 修改後列出 diff 摘要

IMPORTANT:
- 不要漏掉 .env 和 .env.example 檔案
- 掃描時注意 Windows (C:\Users) 和 Unix (/home, /Users) 兩種格式
- 如果是遠端配對模式，用 remote_* 工具操作
- --fix 只修改安全的項目，不確定的標記為 ⚠️ 需手動檢查
