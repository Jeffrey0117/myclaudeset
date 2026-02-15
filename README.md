# myclaudeset

我的 Claude Code 全域設定包。跨機器同步 skills、commands、rules、agents 和 settings。

## 快速安裝

```bash
git clone https://github.com/Jeffrey0117/myclaudeset.git
```

**Linux / Mac:**
```bash
bash myclaudeset/install.sh
```

**Windows (PowerShell 管理員):**
```powershell
powershell myclaudeset/install.ps1
```

安裝腳本會：
1. 備份現有的 `~/.claude/` 設定
2. 建立 symlink 指向此 repo 的各目錄
3. 之後 `git pull` 就能同步更新

## 內容概覽

| 類型 | 數量 | 大小 | 說明 |
|------|------|------|------|
| Skills | 15 套 (107 files) | ~620K | 開發模式、框架知識、最佳實踐 |
| Commands | 28 + 31 sc/ | ~58 files | 自訂 slash commands |
| Rules | 9 個 | ~9 files | 編碼規範、安全、git 流程 |
| Agents | 9 個 | ~9 files | 專用 agent 定義 |
| Settings | 1 個 | settings.json | hooks、權限、偏好 |

**總計：186 files, ~1.1MB**

詳細清單見 [INVENTORY.md](INVENTORY.md)。

## 更新流程

在主機修改後：
```bash
cd myclaudeset
git add -A && git commit -m "update: ..." && git push
```

其他機器：
```bash
cd myclaudeset && git pull
```

因為是 symlink，pull 完就立刻生效，不需要重新安裝。

## 注意事項

- `settings.json` 包含 hooks 設定，不同機器的路徑可能不同（例如 hook script 的絕對路徑）
- Windows symlink 需要管理員權限或開啟開發者模式
- 不包含 `~/.claude/projects/`（per-project memory）和 `~/.claude/plugins/`（第三方 plugin）
