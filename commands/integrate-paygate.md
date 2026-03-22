PayGate 付費訂閱整合指令。自動把 PayGate 訂閱系統加到當前專案。

參數: $ARGUMENTS (產品名稱，例如: myapp)

## 概覽

PayGate 是 CloudPipe 統一付費閘道。整合後你的產品可以：
- 定義方案（Free / Pro / Premium 等）
- 接收付款後的 subscription webhook
- 查詢用戶訂閱狀態（tier、quotas、到期日）

PayGate URL: `https://paygate.isnowfriend.com`（prod）/ `http://localhost:4019`（dev）
Auth: `Authorization: Bearer {PAYGATE_TOKEN}`

## Step 1: 定義方案

跟用戶確認產品要幾個 tier，每個 tier 的：
- 名稱（free / pro / premium 等）
- 月費（TWD）
- Quotas（產品自訂 JSON，例如 `{ "credits_per_month": 80 }`）
- Checkout URL（PAYUNi 週期扣款連結，如果有的話）

Plan ID 格式：`{product}:{tier}:{cycle}`，例如 `myapp:pro:monthly`

## Step 2: 建立 Seed Script

在 PayGate 專案 `C:\Users\jeffb\Desktop\code\cloudpipe\projects\paygate\data\` 建立 `seed-{product}.js`：

```javascript
#!/usr/bin/env node
const PAYGATE_URL = process.env.PAYGATE_URL || 'http://localhost:4019';
const PAYGATE_TOKEN = '86198f5fd474462c9057dc89170161819ef646ed0401c8a1519675de47a1c12b';

const plans = [
  {
    id: '{product}:free:monthly',
    product: '{product}',
    tier: 'free',
    display_name: 'Free',
    billing_cycle: 'monthly',
    price: 0,
    quotas: JSON.stringify({ /* 產品自訂 quota */ }),
    checkout_url: null,
  },
  {
    id: '{product}:pro:monthly',
    product: '{product}',
    tier: 'pro',
    display_name: 'Pro',
    billing_cycle: 'monthly',
    price: 150, // TWD
    quotas: JSON.stringify({ /* 產品自訂 quota */ }),
    checkout_url: 'https://api.payuni.com.tw/api/period/...', // PAYUNi 連結
  },
];

// 生成 webhook secret: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
const WEBHOOK_SECRET = '用上面指令生成';

const hook = {
  product: '{product}',
  url: 'https://{domain}/api/webhooks/paygate',
  secret: WEBHOOK_SECRET,
  events: JSON.stringify([
    'subscription.activated',
    'subscription.expired',
    'subscription.cancelled',
  ]),
};

async function seed() {
  const headers = {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${PAYGATE_TOKEN}`,
  };

  console.log(`Seeding ${'{product}'} plans into PayGate...`);

  for (const plan of plans) {
    const res = await fetch(`${PAYGATE_URL}/api/plans`, {
      method: 'POST', headers, body: JSON.stringify(plan),
    });
    console.log(`  Plan ${plan.id}: ${res.status}`, await res.json());
  }

  const hookRes = await fetch(`${PAYGATE_URL}/api/hooks`, {
    method: 'POST', headers, body: JSON.stringify(hook),
  });
  console.log(`  Hook: ${hookRes.status}`, await hookRes.json());

  console.log('\nDone!');
  console.log('PAYUNi notify URL: https://paygate.isnowfriend.com/api/webhook/payuni');
}

seed().catch(console.error);
```

執行：`node data/seed-{product}.js`

## Step 3: 環境變數

在產品專案加環境變數：

```
PAYGATE_WEBHOOK_SECRET=xxx    # Step 2 生成的 webhook secret
```

## Step 4: Webhook Handler

偵測產品的框架，生成對應的 webhook handler：

### Python (FastAPI)

建立 `api/webhook_routes.py` 或加到現有 router：

```python
import hashlib, hmac, json, os
from datetime import datetime
from fastapi import APIRouter, Request, HTTPException

router = APIRouter(prefix="/api/webhooks", tags=["webhooks"])

PAYGATE_WEBHOOK_SECRET = os.environ.get("PAYGATE_WEBHOOK_SECRET", "")


def _verify_signature(body: bytes, signature: str) -> bool:
    if not signature.startswith("sha256="):
        return False
    calculated = hmac.new(
        PAYGATE_WEBHOOK_SECRET.encode(), body, hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(calculated, signature[7:])


@router.post("/paygate")
async def paygate_webhook(request: Request):
    body = await request.body()
    signature = request.headers.get("X-Webhook-Signature", "")

    if not _verify_signature(body, signature):
        raise HTTPException(status_code=401, detail="Invalid signature")

    payload = json.loads(body)
    event = payload.get("event", "")
    data = payload.get("data", {})
    sub = data.get("subscription", {})
    plan = data.get("plan", {})
    email = sub.get("email", "")

    if event == "subscription.activated":
        tier = sub.get("tier", plan.get("tier", ""))
        quotas = plan.get("quotas", {})
        if isinstance(quotas, str):
            quotas = json.loads(quotas)
        # TODO: upsert 本地訂閱記錄
        print(f"[PayGate] activated: {email} → {tier}")

    elif event in ("subscription.expired", "subscription.cancelled"):
        # TODO: 降級為 free
        print(f"[PayGate] {event}: {email}")

    return {"success": True}
```

### Node.js (Express / raw http)

```javascript
const crypto = require('crypto');

function verifySignature(body, signature, secret) {
  if (!signature.startsWith('sha256=')) return false;
  const calculated = crypto.createHmac('sha256', secret).update(body).digest('hex');
  return crypto.timingSafeEqual(
    Buffer.from(calculated, 'hex'),
    Buffer.from(signature.slice(7), 'hex')
  );
}

// Express:
app.post('/api/webhooks/paygate', express.raw({ type: '*/*' }), (req, res) => {
  const body = req.body;
  const signature = req.headers['x-webhook-signature'] || '';

  if (!verifySignature(body, signature, process.env.PAYGATE_WEBHOOK_SECRET)) {
    return res.status(401).json({ error: 'Invalid signature' });
  }

  const { event, data } = JSON.parse(body);
  const { subscription, plan } = data;

  switch (event) {
    case 'subscription.activated':
      // upsert 本地訂閱記錄
      break;
    case 'subscription.expired':
    case 'subscription.cancelled':
      // 降級為 free
      break;
  }

  res.json({ success: true });
});
```

### Next.js (App Router)

```typescript
// app/api/webhooks/paygate/route.ts
import crypto from 'crypto'

function verifySignature(body: string, signature: string): boolean {
  if (!signature.startsWith('sha256=')) return false
  const secret = process.env.PAYGATE_WEBHOOK_SECRET!
  const calculated = crypto.createHmac('sha256', secret).update(body).digest('hex')
  return crypto.timingSafeEqual(
    Buffer.from(calculated, 'hex'),
    Buffer.from(signature.slice(7), 'hex')
  )
}

export async function POST(request: Request) {
  const body = await request.text()
  const signature = request.headers.get('X-Webhook-Signature') || ''

  if (!verifySignature(body, signature)) {
    return Response.json({ error: 'Invalid signature' }, { status: 401 })
  }

  const { event, data } = JSON.parse(body)
  const { subscription, plan } = data

  switch (event) {
    case 'subscription.activated':
      // upsert 本地訂閱記錄
      break
    case 'subscription.expired':
    case 'subscription.cancelled':
      // 降級為 free
      break
  }

  return Response.json({ success: true })
}
```

## Step 5: 查詢訂閱狀態

PayGate 提供公開 API（不需 auth）：

```
GET https://paygate.isnowfriend.com/api/subscription/check?email={email}&product={product}
```

回傳：
```json
// 有訂閱
{ "active": true, "tier": "pro", "plan_id": "myapp:pro:monthly", "quotas": { ... }, "end_date": "2025-07-01T..." }

// 無訂閱
{ "active": false }
```

### 兩種用法

**方式 A：直接 call PayGate**（簡單，但每次都是外部 HTTP 請求）

```python
# Python
import httpx
resp = httpx.get(f"https://paygate.isnowfriend.com/api/subscription/check?email={email}&product=myapp")
sub = resp.json()
tier = sub.get("tier", "free") if sub.get("active") else "free"
```

**方式 B：本地快取**（推薦，webhook 同步 + 本地查詢更快）

收到 webhook 時 upsert 本地 Subscription 表，查詢時讀本地 DB。
ReelScript 用的就是這種方式（見 Step 4 的 TODO 區塊）。

## Step 6: Pricing 頁面（可選）

如果產品有前端，生成定價頁：

- 從 PayGate 拉方案：`GET /api/plans?product={product}`
- 每個付費方案的 `checkout_url` 導向 PAYUNi
- Free 方案不需要按鈕
- 提示：「請使用與本站相同的 Email 付款，否則無法自動對應訂閱」

## Webhook Payload 格式

PayGate 發出的 webhook：

```json
{
  "event": "subscription.activated",
  "timestamp": "2025-06-01T12:00:00.000Z",
  "data": {
    "subscription": {
      "id": "sub_abc123",
      "email": "user@example.com",
      "product": "myapp",
      "plan_id": "myapp:pro:monthly",
      "tier": "pro",
      "status": "active",
      "start_date": "2025-06-01T...",
      "end_date": "2025-07-01T..."
    },
    "plan": {
      "id": "myapp:pro:monthly",
      "product": "myapp",
      "tier": "pro",
      "price": 150,
      "billing_cycle": "monthly",
      "quotas": { "credits_per_month": 80 }
    }
  }
}
```

Headers:
- `X-Webhook-Signature`: `sha256={hmac_hex}`（用 hook secret 簽 body）
- `X-Webhook-Event`: event type
- `X-Webhook-Delivery`: delivery ID

重試策略：30s → 2m → 10m → 30m → 2h → 12h（最多 6 次）

## Events

| Event | 觸發時機 |
|-------|---------|
| `subscription.activated` | 新訂閱或續訂成功 |
| `subscription.expired` | 訂閱到期（expire-check 觸發） |
| `subscription.cancelled` | 手動取消訂閱 |

## 常見錯誤

| 錯誤 | 正確做法 |
|------|---------|
| Webhook secret 寫成 PAYGATE_TOKEN | 兩個是不同的。secret 是 hook 專用，token 是 admin API 用 |
| 忘記驗 webhook 簽章 | 一定要驗 `X-Webhook-Signature`，否則任何人都能偽造 |
| 用 product 當 plan_id 查詢 | plan_id 格式是 `product:tier:cycle` |
| 前端直接 call PayGate admin API | Admin API 需要 PAYGATE_TOKEN，不該暴露在前端 |
| checkout_url 寫死在前端 | 從 seed script 或 PayGate API 拿，方便後續換金流 |
| 假設 quotas 是 object | 可能是 JSON string，要先 parse |

## 參考實作

- **ReelScript**（Python / FastAPI + SvelteKit）完整範例：
  - Seed: `C:\Users\jeffb\Desktop\code\cloudpipe\projects\paygate\data\seed-reelscript.js`
  - Webhook: `C:\ReelScript\backend\api\webhook_routes.py`
  - Quota: `C:\ReelScript\backend\api\quota_routes.py`
  - Model: `C:\ReelScript\backend\models\database.py`（Subscription class）
  - Pricing: `C:\ReelScript\frontend\src\routes\pricing\+page.svelte`

## PayGate Admin API 參考

| Method | Path | Auth | 用途 |
|--------|------|------|------|
| POST | `/api/plans` | bearer | 建立/更新方案 |
| GET | `/api/plans?product=` | none | 列出方案 |
| POST | `/api/hooks` | bearer | 註冊 outgoing webhook |
| GET | `/api/hooks?product=` | bearer | 列出 hooks |
| GET | `/api/subscription/check?email=&product=` | none | 查詢訂閱狀態 |
| POST | `/api/subscribe` | bearer | 手動建立訂閱 |
| GET | `/api/purchases/check?email=&product=` | none | 查詢購買紀錄 |
| POST | `/api/activate` | bearer | 手動啟用購買 |
| GET | `/api/admin/stats` | bearer | 管理統計 |
| GET | `/api/admin/webhook-log` | bearer | Webhook 投遞紀錄 |
| POST | `/api/subscriptions/expire-check` | bearer | 觸發到期檢查 |
