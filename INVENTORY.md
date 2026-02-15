# Inventory — myclaudeset

完整內容清單。方便掌握這包有多大、缺什麼、該砍什麼。

**最後更新：2026-02-15**
**總計：~180 files, ~1.0MB**

---

## Skills（15 套, ~105 files, ~590K）

| Skill | Files | Size | 用途 | 常用度 |
|-------|-------|------|------|--------|
| backend-patterns | 1 | 16K | Node.js / Express / API 設計 | ★★★ |
| coding-standards | 1 | 12K | TypeScript / JS 編碼規範 | ★★★ |
| continuous-learning | 3 | 9K | 自動從 session 提取 patterns | ★★ |
| **debugging** | 1 | 4K | 系統化除錯流程（新增） | ★★★ |
| frontend-patterns | 1 | 16K | React / Next.js 前端模式 | ★★★ |
| **git-advanced** | 1 | 4K | Rebase / cherry-pick / conflict（新增） | ★★★ |
| payuni-sdk | 4 | 28K | 藍新金流 SDK 整合 | ★★ |
| remotion | 34 | 161K | Remotion 影片製作 | ★★ |
| security-review | 1 | 16K | 安全審查 checklist | ★★★ |
| strategic-compact | 2 | 8K | 智慧 context 壓縮建議 | ★★ |
| tdd-workflow | 1 | 12K | 測試驅動開發流程 | ★★★ |
| **telegram-bot** | 1 | 4K | Telegraf v4 Bot 開發模式（新增） | ★★★ |
| vercel-react-best-practices | 54 | 310K | Vercel React 最佳實踐（最大） | ★★ |
| verification-loop | 1 | 4K | 驗證迴圈 | ★★ |
| web-design-guidelines | 1 | 4K | Web UI 設計準則 | ★★ |

### 觀察

- `vercel-react-best-practices` 佔了總大小的一半（310K, 54 files），考慮是否真的常用
- `remotion` 也很大（161K, 34 files），如果不常做影片可以考慮移除

---

## Commands（58 files）

### 核心指令（28 個）

| Command | 用途 | 常用度 |
|---------|------|--------|
| /plan | 需求分析 + 實作計畫 | ★★★ |
| /tdd | 測試驅動開發 | ★★★ |
| /push | Git commit + push | ★★★ |
| /code-review | 程式碼審查 | ★★★ |
| /build-fix | 修復 build 錯誤 | ★★★ |
| /verify | 驗證工作完成度 | ★★★ |
| /kill | 精確殺掉特定 port 進程 | ★★★ |
| /server | 啟動 dev server | ★★ |
| /spec | 規格驅動開發 | ★★ |
| /orchestrate | 多 agent 協調 | ★★ |
| /e2e | E2E 測試 (Playwright) | ★★ |
| /refactor-clean | 重構清理 | ★★ |
| /checkpoint | 建立檢查點 | ★★ |
| /eval | 評估 | ★ |
| /learn | 提取可重用 patterns | ★★ |
| /test-coverage | 測試覆蓋率 | ★★ |
| /update-docs | 更新文檔 | ★ |
| /update-codemaps | 更新 codemaps | ★ |
| /mop | 專案清理 | ★★ |
| /remit | 列出 Git commits | ★★ |
| /re | 記錄待辦 | ★★ |
| /load | 讀取待辦 | ★★ |
| /save | 儲存 overview | ★ |
| /remember | 搜尋 claude-mem | ★ |
| /claude-mem | 管理 memory | ★ |
| /rund | 跑 npm run dev | ★★ |
| /rune | 跑 Electron dev | ★ |

### SuperClaude 子指令（/sc:*, 31 個）

| Command | 用途 |
|---------|------|
| /sc:analyze | 程式碼分析 |
| /sc:brainstorm | 需求探索 |
| /sc:build | 建置打包 |
| /sc:cleanup | 清理死碼 |
| /sc:design | 架構設計 |
| /sc:document | 生成文檔 |
| /sc:estimate | 工時估算 |
| /sc:explain | 解釋程式碼 |
| /sc:git | Git 操作 |
| /sc:implement | 功能實作 |
| /sc:improve | 改善品質 |
| /sc:index | 專案索引 |
| /sc:index-repo | Repo 索引（94% token reduction） |
| /sc:load | Session 載入 |
| /sc:pm | 專案管理 agent |
| /sc:recommend | 推薦指令 |
| /sc:reflect | 反思驗證 |
| /sc:research | 深度研究 |
| /sc:save | Session 儲存 |
| /sc:spawn | 任務分配 |
| /sc:spec-panel | 規格審查 |
| /sc:task | 任務執行 |
| /sc:test | 測試 + 覆蓋率 |
| /sc:troubleshoot | 疑難排解 |
| /sc:workflow | 產生工作流程 |
| /sc:agent | Agent 管理 |
| /sc:business-panel | 商業分析 |
| /sc:help | 列出所有 sc 指令 |
| /sc:select-tool | MCP 工具選擇 |
| /sc:sc | SC 調度器 |
| /sc:README | SC 說明 |

---

## Rules（9 files）

| Rule | 用途 |
|------|------|
| agents.md | Agent 協調規則 |
| coding-style.md | 編碼風格（immutability, 小檔案） |
| forbidden-commands.md | 禁用指令（防止殺 node） |
| git-workflow.md | Git 提交規範 |
| hooks.md | Hooks 系統說明 |
| patterns.md | 常用程式碼模式 |
| performance.md | 效能優化 + model 選擇 |
| security.md | 安全準則 |
| testing.md | 測試要求（80%+ 覆蓋率） |

---

## Agents（10 files）

| Agent | 用途 |
|-------|------|
| planner | 實作規劃 |
| architect | 系統架構設計 |
| tdd-guide | 測試驅動開發 |
| code-reviewer | 程式碼審查 |
| security-reviewer | 安全分析 |
| build-error-resolver | 修復 build 錯誤 |
| e2e-runner | E2E 測試 |
| refactor-cleaner | 死碼清理 |
| doc-updater | 文檔更新 |
| **performance-profiler** | 效能分析（新增） |

---

## 瘦身建議

如果覺得太肥，可以優先砍：

| 項目 | 大小 | 理由 |
|------|------|------|
| vercel-react-best-practices | 310K | 佔一半，除非常寫 React |
| remotion | 161K | 除非常做影片 |

砍完可省 ~470K（約 47%）。

---

## 未來想加的

- [ ] docker / deployment skill
- [ ] database patterns skill (PostgreSQL / Prisma)
- [ ] migration-guide agent

## 已移除的

- `clickhouse-io` (12K) — 使用頻率低，2026-02-15 移除
- `eval-harness` (8K) — 使用頻率低，2026-02-15 移除
- `project-guidelines-example` (12K) — 只是範例無實用價值，2026-02-15 移除
