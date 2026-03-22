LetMeUse 認證整合指令。自動把 LetMeUse 登入系統加到當前專案。

參數: $ARGUMENTS (專案名稱 網域，例如: myapp https://myapp.com)

## Step 1: 註冊 App

呼叫 `letmeuse_create_app` MCP 工具：
- name: 從 $ARGUMENTS 取，或用當前專案名稱
- domains: `["https://{domain}", "http://localhost:{PORT}"]`
- webhookUrl: `"https://{domain}/api/webhooks/letmeuse"`（如果有後端）

存下回傳的 `id`（前端 data-app-id 用）和 `secret`（webhook 驗證用）。

## Step 2: 環境變數

加到 `.env.local` 或 `.env`：
```
NEXT_PUBLIC_LETMEUSE_APP_ID=app_XXX      # 前端用
LETMEUSE_APP_SECRET=xxx                   # webhook HMAC 驗證用
LETMEUSE_BASE_URL=https://letmeuse.isnowfriend.com
```

## Step 3: Script Tag

加到 layout 或 HTML `<head>`：

```html
<script src="https://letmeuse.isnowfriend.com/letmeuse.js"
  data-app-id="app_XXX"
  data-theme="dark"
  data-accent="#2d7a2d"
  data-locale="zh"
  data-mode="modal">
</script>
```

### 屬性說明

| 屬性 | 必填 | 值 | 預設 | 說明 |
|------|------|-----|------|------|
| `data-app-id` | **是** | `"app_XXX"` | — | Step 1 拿到的 app ID |
| `data-theme` | 否 | `light` / `dark` / `auto` | `light` | auto 會偵測 host page |
| `data-accent` | 否 | CSS 色碼 | `#2563eb`（藍） | **一定要改成網站品牌色！** 預設藍色會跟你的網站不搭 |
| `data-locale` | 否 | `en` / `zh` | `en` | 繁體中文選 `zh` |
| `data-mode` | 否 | `modal` / `redirect` | `modal` | modal = 彈窗，redirect = 跳頁 |

## Step 4: 前端 Auth

偵測框架，選擇對應模式：

### React / Next.js

生成 `src/hooks/useLetMeUse.ts`：

```typescript
"use client"
import { useState, useEffect, useCallback } from 'react'

interface LetMeUseUser {
  id: string; email: string; name: string; avatar?: string
}

export function useLetMeUse() {
  const [user, setUser] = useState<LetMeUseUser | null>(null)
  const [token, setToken] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    let unsubscribe: (() => void) | undefined
    let attempts = 0

    const tryInit = () => {
      const sdk = window.letmeuse
      // ⚠️ ready 和 user 是「屬性」，不是方法！
      if (!sdk || !sdk.ready) {
        if (++attempts < 50) setTimeout(tryInit, 100)
        else setIsLoading(false) // 5 秒後降級為 guest
        return
      }
      setUser(sdk.user)
      setToken(sdk.getToken())
      setIsLoading(false)
      unsubscribe = sdk.onAuthChange((newUser) => {
        setUser(newUser)
        setToken(sdk.getToken())
      })
    }
    tryInit()
    return () => unsubscribe?.()
  }, [])

  const login = useCallback(() => window.letmeuse?.login(), [])
  const logout = useCallback(() => window.letmeuse?.logout(), [])
  const openProfile = useCallback(() => window.letmeuse?.openProfile(), [])

  return { user, token, isLoading, login, logout, openProfile }
}
```

也考慮生成 `src/contexts/AuthContext.tsx` 包裝 useLetMeUse，提供全域 auth 狀態。

### Vanilla JS

```javascript
function waitForLetMeUse() {
  return new Promise(resolve => {
    if (window.letmeuse?.ready) return resolve()
    const check = setInterval(() => {
      if (window.letmeuse?.ready) { clearInterval(check); resolve() }
    }, 100)
    setTimeout(() => { clearInterval(check); resolve() }, 5000)
  })
}

await waitForLetMeUse()
letmeuse.onAuthChange(user => {
  if (user) {
    const token = letmeuse.getToken()
    // sync to backend...
  }
})
```

## Step 5: 後端 JWT Middleware

生成 JWT 解碼工具。LetMeUse 是內部信任模型，**不需要驗證簽章**，只要 decode base64url payload。

```typescript
export function decodeLetMeUseToken(token: string) {
  try {
    const [, payloadPart] = token.split('.')
    const payload = JSON.parse(
      Buffer.from(payloadPart, 'base64url').toString('utf-8')
    )
    // payload = { sub, email, name, role, permissions, app, iat, exp }
    if (payload.exp && payload.exp * 1000 < Date.now()) return null
    return payload
  } catch { return null }
}

export function extractBearerToken(authHeader: string | null): string | null {
  if (!authHeader?.startsWith('Bearer ')) return null
  return authHeader.slice(7)
}
```

## Step 6: Webhook Handler

生成 `POST /api/webhooks/letmeuse` 端點：

```typescript
import crypto from 'crypto'

export async function POST(request: Request) {
  const body = await request.text()
  const signature = request.headers.get('X-LetMeUse-Signature')

  // 驗證 HMAC-SHA256（用 app SECRET，不是 app ID）
  const hmac = crypto.createHmac('sha256', process.env.LETMEUSE_APP_SECRET!)
  hmac.update(body)
  const expected = hmac.digest('hex')
  if (signature !== expected) {
    return Response.json({ error: 'Invalid signature' }, { status: 401 })
  }

  const { event, payload, timestamp, appId } = JSON.parse(body)

  switch (event) {
    case 'user.registered':
      // 建立本地用戶
      break
    case 'user.updated':
      // 更新 email/name
      break
    case 'user.login':
      // 更新 lastLoginAt
      break
    case 'user.deleted':
      // 停用帳號
      break
    // 其他: user.disabled, user.enabled, user.email_verified, user.password_reset
  }

  return Response.json({ received: true })
}
```

Webhook headers:
- `X-LetMeUse-Signature`: HMAC-SHA256 hex digest of body
- `X-LetMeUse-Event`: event type string
- Retry: 3 次 [0s, 2s, 5s]，每次 10s timeout

## Step 7: Auth Callback Route

生成用戶同步 API，前端登入後呼叫：

```typescript
export async function GET(request: Request) {
  const token = extractBearerToken(request.headers.get('Authorization'))
  if (!token) return Response.json({ error: 'Unauthorized' }, { status: 401 })

  const payload = decodeLetMeUseToken(token)
  if (!payload) return Response.json({ error: 'Invalid token' }, { status: 401 })

  // 用 payload.sub (userId) 查找或建立本地用戶
  const user = await findOrCreateUser({
    lmuUserId: payload.sub,
    email: payload.email,
    name: payload.name,
  })

  return Response.json({ success: true, data: user })
}
```

## 常見錯誤（必讀）

| 錯誤 | 為什麼會壞 | 正確做法 |
|------|-----------|---------|
| `letmeuse.ready()` | ready 是屬性 | `letmeuse.ready` |
| `letmeuse.user()` 或 `letmeuse.getUser()` | user 是屬性 | `letmeuse.user` |
| `letmeuse.isReady()` | 不存在這個方法 | `letmeuse.ready` |
| 忘記設 `data-accent` | 預設藍色跟你的網站不搭 | 設成網站品牌色 |
| 忘記設 `data-theme="dark"` | 深色網站配淺色彈窗很醜 | 用 `dark` 或 `auto` |
| 從 onAuthChange 拿 token | callback 傳的是 user 物件 | 另外呼叫 `getToken()` |
| 自己存 token 到 localStorage | SDK 已自動管理 `lmu_{appId}_*` | 用 `getToken()` |
| 驗證 JWT 簽章 | 沒必要，浪費 CPU | 只 decode base64url payload |
| 用 app ID 驗 webhook | 應該用 app SECRET | `createHmac('sha256', secret)` |

## 參考實作

- **duk.tw**（React / Next.js）完整範例：
  - Hook: `C:\Users\jeffb\Desktop\code\upimg-nextjs\src\hooks\useLetMeUse.ts`
  - Context: `C:\Users\jeffb\Desktop\code\upimg-nextjs\src\contexts\AuthContext.tsx`
  - Webhook: `C:\Users\jeffb\Desktop\code\upimg-nextjs\src\app\api\webhooks\letmeuse\route.ts`
  - Layout SDK: `C:\Users\jeffb\Desktop\code\upimg-nextjs\src\app\layout.tsx`

- **Quickky**（Vanilla JS / Fastify）完整範例：
  - Frontend: `C:\Users\jeffb\Desktop\code\quickky\public\app.js`
  - Middleware: `C:\Users\jeffb\Desktop\code\quickky\src\middleware\auth.js`
  - Auth route: `C:\Users\jeffb\Desktop\code\quickky\src\routes\auth.js`
