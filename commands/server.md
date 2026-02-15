啟動開發伺服器

指定 Port：$ARGUMENTS（若未指定則用預設值）

## 執行步驟

### 1. 檢測專案類型與設定
依序檢查以下檔案，判斷專案類型：

**檢查 package.json**
- 有 `scripts.dev` → 優先使用 (Vite, Next.js 等)
- 有 `scripts.start` → 次優先
- 有 `scripts.serve` → 備選

**檢查框架特徵**
- `vite.config.*` → Vite 專案
- `next.config.*` → Next.js 專案
- `nuxt.config.*` → Nuxt 專案
- `angular.json` → Angular 專案
- `manage.py` → Django 專案
- `requirements.txt` + Flask → Flask 專案
- `go.mod` → Go 專案
- `Cargo.toml` → Rust 專案

### 2. 啟動優先順序

1. **package.json scripts** (如有)
   ```bash
   npm run dev -- --port <PORT>
   # 或
   npm run start -- --port <PORT>
   ```

2. **Python 專案**
   ```bash
   # Django
   python manage.py runserver <PORT>
   # Flask
   flask run --port <PORT>
   # 簡單 HTTP
   python -m http.server <PORT>
   ```

3. **Go 專案**
   ```bash
   go run .
   ```

4. **Fallback - 靜態檔案伺服器**
   ```bash
   # 優先 (較新、功能多)
   npx serve -p <PORT>
   # 備選
   npx live-server --port=<PORT>
   # 備選
   npx http-server -p <PORT>
   ```

### 3. Port 處理
- 若用戶指定 port → 使用指定值
- 若未指定 → 使用框架預設值（通常 3000, 5173, 8000, 8080）
- 若 port 被佔用 → 提示用戶或自動 +1

### 4. 啟動後
- 顯示存取網址
- 提示如何停止伺服器 (Ctrl+C)

IMPORTANT: 啟動前先確認專案類型，避免用錯命令。
