CloudPipe 專案部署指令。Commit + push + 確認線上部署成功。

參數: $ARGUMENTS (可選：專案名稱，如果不在專案目錄內)

## 步驟

### 1. 辨識專案

- 如果有 $ARGUMENTS，用它當專案名稱
- 否則從當前目錄的 `CLAUDE.md`、`package.json`、或 `.pm2-ecosystem.json` 推斷
- 確認這是 CloudPipe 生態系專案（檢查 `C:\Users\jeffb\Desktop\code\cloudpipe\data\deploy\projects.json`）
- 找到對應的 port、pm2Name、workhub 目錄

### 2. Commit + Push

- `git status` 檢查變更
- `git diff --stat` 看改了什麼
- `git log -3 --oneline` 看 commit 風格
- Stage 相關檔案（不要 `git add -A`，避免加到 `.env`、`*.log`、`node_modules/`）
- 寫 conventional commit message（feat/fix/refactor/chore）
- **不加 Co-Authored-By**
- `git push`
- 在步驟 1 看到 `node_modules/`、`.env`、`*.log` 等不該進 repo 的檔案時，停止並提醒使用者加 .gitignore

### 3. 等待 CloudPipe 部署

GitHub push 會觸發 CloudPipe webhook 自動部署。等 10 秒後：

- 檢查 workhub 目錄的 `git log -1 --oneline` 是否是剛推的 commit
- 如果不是，可能 webhook 還沒到，再等 10 秒
- 如果 30 秒後還沒更新，提醒用戶手動 pull

### 4. 確認服務上線

- 如果專案有 `healthEndpoint`，curl 它
- 如果沒有，檢查 `pm2 list | grep {pm2Name}` 確認 online
- 如果服務掛了（不在 PM2 或 errored），嘗試：
  ```
  cd {workhub}/{project}
  pm2 start .pm2-ecosystem.json
  ```

### 5. 驗證

- 跑一個關鍵 API endpoint 確認回應正確
- 如果有 build step（前端），確認 build 產物存在
- 報告部署結果

## 常見問題

| 問題 | 解決 |
|------|------|
| PM2 裡找不到專案 | `pm2 start .pm2-ecosystem.json` |
| workhub 沒更新 | `cd workhub/{project} && git pull` |
| Build 失敗 | 檢查 `pm2 logs {pm2Name} --lines 20` |
| Port 被佔 | 用 `/kill {port}` 釋放 |

## 專案對照表

| 專案 | Port | PM2 Name | Health |
|------|------|----------|--------|
| ReelScript | 4005 | reelscript | /api/health |
| PayGate | 4019 | paygate | /api/health |
| LetMeUse | 4006 | letmeuse | / |
| UpImg | 4007 | upimg | / |
| AutoCard | 4004 | autocard | / |
| MeeTube | 4008 | meetube | /api/health |
| Quickky | 4016 | quickky | / |

workhub 路徑：`C:\Users\jeffb\Desktop\code\workhub\{project}`
CloudPipe projects.json：`C:\Users\jeffb\Desktop\code\cloudpipe\data\deploy\projects.json`
