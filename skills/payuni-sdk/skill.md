# PAYUNi 金流串接助手

當使用者需要串接 PAYUNi (統一金流) 時，提供專業的開發指引與程式碼生成。

## 觸發條件

在以下情況自動觸發此 Skill：
- 使用者提到 "PAYUNi"、"統一金流"、"金流串接"、"付款整合"
- 使用者詢問付款 Webhook 處理
- 使用者需要實作結帳功能

## SDK 資訊

PAYUNi SDK 位於 `packages/payuni-sdk/`，提供：

### 核心功能
- `createPayuniClient()` - 建立客戶端
- `createWebhookHandler()` - Webhook 處理
- 金額計算工具 (`calculateFinalPrice`, `validatePrice`)

### 框架適配器
- `@coursebloom/payuni-sdk/adapters/nextjs` - Next.js App Router
- `@coursebloom/payuni-sdk/adapters/express` - Express/Fastify
- `@coursebloom/payuni-sdk/adapters/generic` - 通用 HTTP

## 引導流程

### 步驟 1: 確認環境變數

確認使用者已設定以下環境變數：

```env
PAYUNI_MERCHANT_ID=你的商店代號
PAYUNI_HASH_KEY=你的HashKey
PAYUNI_HASH_IV=你的HashIV
PAYUNI_TEST_MODE=true  # 可選，預設根據 NODE_ENV
```

### 步驟 2: 詢問框架

詢問使用者使用的框架：
1. Next.js App Router (推薦)
2. Next.js Pages Router
3. Express/Fastify
4. 其他

### 步驟 3: 生成程式碼

根據框架生成對應的程式碼。

## 程式碼模板

### Next.js App Router - Webhook

```typescript
// app/api/webhooks/payuni/route.ts
import { createWebhookHandler } from '@coursebloom/payuni-sdk';
import { createNextjsHandler, createNextjsHealthHandler } from '@coursebloom/payuni-sdk/adapters/nextjs';

const webhookHandler = createWebhookHandler({
  hashKey: process.env.PAYUNI_HASH_KEY!,
  hashIV: process.env.PAYUNI_HASH_IV!,
  // 可選：防重放攻擊
  onDuplicateCheck: async (tradeNo) => {
    // 檢查是否已處理過
    return false;
  },
  onMarkProcessed: async (tradeNo) => {
    // 標記已處理
  },
});

export const POST = createNextjsHandler(webhookHandler, {
  debug: process.env.NODE_ENV !== 'production',
  onSuccess: async (data) => {
    // 更新訂單狀態
    console.log('付款成功:', data.orderId);
    // await db.order.update({ where: { id: data.orderId }, data: { status: 'paid' } });
  },
  onFailure: async (data) => {
    // 記錄失敗
    console.log('付款失敗:', data.orderId);
  },
  onError: async (error) => {
    // 錯誤處理
    console.error('Webhook 錯誤:', error);
  },
});

export const GET = createNextjsHealthHandler();
```

### Next.js App Router - 建立付款

```typescript
// app/api/checkout/route.ts
import { NextResponse } from 'next/server';
import { createPayuniClientFromEnv } from '@coursebloom/payuni-sdk';

export async function POST(request: Request) {
  const { orderId, amount, productName } = await request.json();

  const payuni = createPayuniClientFromEnv();

  const payment = payuni.createPayment({
    orderId,
    amount,
    productName,
    returnUrl: `${process.env.NEXT_PUBLIC_SITE_URL}/checkout/result`,
    notifyUrl: `${process.env.NEXT_PUBLIC_SITE_URL}/api/webhooks/payuni`,
    paymentMethods: ['credit', 'atm', 'cvs'], // 可選
  });

  // 回傳表單 HTML (自動提交)
  return new Response(payment.toFormHtml(), {
    headers: { 'Content-Type': 'text/html' },
  });

  // 或回傳 redirect URL
  // return NextResponse.json({ redirectUrl: payment.toRedirectUrl() });
}
```

### 金額計算

```typescript
import {
  calculateFinalPrice,
  validatePrice,
  formatAmount,
} from '@coursebloom/payuni-sdk';

// 計算最終價格
const finalPrice = calculateFinalPrice({
  item: {
    originalPrice: 1000,
    salePrice: 800,
    saleQuota: 100,
  },
  currentSales: 50,
  discount: {
    type: 'percentage',
    value: 10,
    isActive: true,
  },
  shippingFee: 60,
});

console.log(formatAmount(finalPrice)); // NT$780

// 驗證金額
const validation = validatePrice(clientPrice, finalPrice);
if (!validation.valid) {
  throw new Error(validation.error);
}
```

### Express

```typescript
import express from 'express';
import { createWebhookHandler } from '@coursebloom/payuni-sdk';
import { createExpressHandler } from '@coursebloom/payuni-sdk/adapters/express';

const app = express();
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

const webhookHandler = createWebhookHandler({
  hashKey: process.env.PAYUNI_HASH_KEY!,
  hashIV: process.env.PAYUNI_HASH_IV!,
});

app.post('/api/webhooks/payuni', createExpressHandler(webhookHandler, {
  onSuccess: async (data) => {
    await updateOrderStatus(data.orderId, 'paid');
  },
}));
```

## 常見問題

### Q: 如何測試 Webhook？

1. 使用 PAYUNi 測試環境（設定 `PAYUNI_TEST_MODE=true`）
2. 使用 ngrok 或 localtunnel 將本地服務暴露到外網
3. 在 PAYUNi 後台設定測試 Webhook URL

### Q: 如何防止重複處理？

使用 `onDuplicateCheck` 和 `onMarkProcessed` 回調：

```typescript
const webhookHandler = createWebhookHandler({
  hashKey: '...',
  hashIV: '...',
  onDuplicateCheck: async (tradeNo) => {
    const exists = await db.webhookLog.findUnique({
      where: { tradeNo },
    });
    return !!exists;
  },
  onMarkProcessed: async (tradeNo) => {
    await db.webhookLog.create({
      data: { tradeNo, processedAt: new Date() },
    });
  },
});
```

### Q: 如何處理訂閱付款？

使用 `createSubscriptionWebhookHandler`：

```typescript
import { createSubscriptionWebhookHandler } from '@coursebloom/payuni-sdk';

const subscriptionHandler = createSubscriptionWebhookHandler({
  hashKey: '...',
  hashIV: '...',
});

// 處理訂閱 webhook
const result = await subscriptionHandler.process(encryptInfo);
if (result.success) {
  const { periodOrderNo, currentPeriod, nextAuthDate } = result.data;
  // 更新訂閱狀態
}
```

## 測試指引

1. **單元測試**：測試金額計算邏輯
2. **整合測試**：使用 PAYUNi 測試環境進行完整付款流程測試
3. **Webhook 測試**：模擬 PAYUNi 的 Webhook 請求

## 相關文件

- PAYUNi 官方文件: https://docs.payuni.com.tw/
- SDK README: `packages/payuni-sdk/README.md`
