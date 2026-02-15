精確殺掉特定端口的 Node 進程，避免誤殺 Claude Code 自己。

參數: $ARGUMENTS (端口號，例如: 3000)

Instructions:
1. 如果沒有提供端口號參數，詢問用戶要殺哪個端口
2. 使用 `netstat -ano | findstr :端口號` 找出佔用該端口的進程 PID
3. 顯示找到的進程資訊給用戶確認
4. 使用 `taskkill /f /pid <PID>` 殺掉該進程
5. 確認進程已被終止

IMPORTANT:
- 絕對不要使用 `taskkill /f /im node.exe`，這會殺掉所有 node 進程包括 Claude Code
- 只殺掉用戶指定端口的進程
- 如果找不到該端口的進程，告知用戶
