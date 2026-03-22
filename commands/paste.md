快速把文字或檔案內容貼到 rawtxt，取得 raw URL。

參數: $ARGUMENTS (可選：檔案路徑 或 直接文字內容，可加 -e 指定過期時間)

Instructions:

1. 解析參數：
   - 如果參數包含 `-e` 或 `--expires`，提取過期時間值 (1h, 6h, 24h, 7d, 30d, forever)
   - 剩餘的參數判斷是檔案路徑還是純文字

2. 取得內容：
   - 如果沒有參數：讀取用戶最近在對話中提到的文字/程式碼，或詢問要貼什麼
   - 如果參數是檔案路徑：用 Read 工具讀取該檔案
   - 如果參數是純文字：直接使用

3. 呼叫 rawtxt API：
   ```bash
   curl -sf -X POST "https://rawtxt.isnowfriend.com/api/paste" \
     -H "Content-Type: application/json" \
     -d '{"content":"<內容>","expiresIn":"<過期時間>"}'
   ```
   注意：用 python3 或 jq 做 JSON escape

4. 解析回傳的 JSON，顯示：
   - Raw URL (主要)
   - View URL
   - 類型、大小、token 數、過期時間

5. 自動複製 raw URL 到剪貼板（如果可以的話）

預設過期時間: 24h

範例：
- `/paste` — 貼最近的程式碼
- `/paste src/config.js` — 貼檔案內容
- `/paste -e forever src/config.js` — 永久貼檔案
- `/paste "hello world"` — 貼純文字
- `/paste -e 7d` — 指定過期時間，然後問要貼什麼

IMPORTANT:
- API endpoint: https://rawtxt.isnowfriend.com/api/paste
- 回傳格式: { success, data: { id, url, rawUrl, contentType, sizeBytes, tokenCount, expiresAt } }
- 大小上限: 1MB
- 如果內容太大或 API 失敗，顯示錯誤訊息
