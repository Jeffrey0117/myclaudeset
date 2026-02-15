---
name: telegram-bot
description: Telegram Bot 開發模式（Telegraf v4）。Handler、middleware、keyboard、message 類型處理。
---

# Telegram Bot Patterns (Telegraf v4)

## Bot Structure

```
src/
├── bot.ts              # createBot() — middleware + handler registration
├── commands/           # /command handlers
├── handlers/           # Message type handlers (text, photo, document)
├── middleware/          # Auth, rate limit, error handling
└── types/context.ts    # BotContext type extension
```

## Command Handler Template

```typescript
import type { BotContext } from '../types/context.js'

export async function myCommand(ctx: BotContext): Promise<void> {
  const chatId = ctx.chat?.id
  if (!chatId) return

  const text = (ctx.message && 'text' in ctx.message) ? ctx.message.text ?? '' : ''
  const args = text.replace(/^\/mycommand\s*/, '').trim()

  await ctx.reply('Response', { parse_mode: 'Markdown' })
}
```

## Message Types

| Type | Telegraf Event | Key Fields |
|------|---------------|------------|
| Text | `bot.on('text')` | `ctx.message.text` |
| Photo | `bot.on('photo')` | `ctx.message.photo` (array, last = largest) |
| Document | `bot.on('document')` | `ctx.message.document.file_id`, `.mime_type` |
| Voice | `bot.on('voice')` | `ctx.message.voice.file_id` |
| Callback | `bot.on('callback_query')` | `ctx.callbackQuery.data` |

### Handler Registration Order (IMPORTANT)
```typescript
// Specific handlers FIRST
bot.on('callback_query', callbackHandler)
bot.on('photo', photoHandler)
bot.on('document', documentHandler)
// Catch-all LAST
bot.on('text', messageHandler)
```

## File Download Pattern

```typescript
const fileLink = await ctx.telegram.getFileLink(fileId)
const response = await fetch(fileLink.href)
const buffer = Buffer.from(await response.arrayBuffer())
await writeFile(tempPath, buffer)
```

## Inline Keyboard

```typescript
import { Markup } from 'telegraf'

// Button grid
const keyboard = Markup.inlineKeyboard([
  [Markup.button.callback('Option A', 'action:a')],
  [Markup.button.callback('Option B', 'action:b')],
])

await ctx.reply('Choose:', keyboard)

// Handle callback
bot.on('callback_query', async (ctx) => {
  const data = (ctx.callbackQuery as { data?: string }).data
  if (data?.startsWith('action:')) {
    const value = data.split(':')[1]
    await ctx.answerCbQuery()
    await ctx.editMessageText(`Selected: ${value}`)
  }
})
```

## Middleware Pattern

```typescript
export function myMiddleware() {
  return async (ctx: BotContext, next: () => Promise<void>) => {
    // Before handler
    const start = Date.now()

    await next()

    // After handler
    console.log(`Request took ${Date.now() - start}ms`)
  }
}
```

## Common Gotchas

| Problem | Solution |
|---------|----------|
| `editMessageText` throws "message is not modified" | Catch and ignore |
| Message > 4096 chars | Split with `splitText()` |
| Photo has multiple sizes | Use last element (largest) |
| `bot.on('text')` catches commands | Check `!text.startsWith('/')` |
| Callback query timeout | Always call `ctx.answerCbQuery()` |
| Rate limit (30 msg/sec per chat) | Debounce message edits |
| File download fails | Files expire after ~1 hour, download immediately |

## Telegram Limits

| Limit | Value |
|-------|-------|
| Message length | 4096 chars |
| Caption length | 1024 chars |
| Inline keyboard buttons per row | 8 |
| File download size | 20MB |
| Messages per second (per chat) | 30 |
| Messages per second (global) | 30 |
| Bot API polling timeout | 30s default |
