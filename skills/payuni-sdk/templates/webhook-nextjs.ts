/**
 * PAYUNi Webhook - Next.js App Router 範本
 *
 * 檔案位置: app/api/webhooks/payuni/route.ts
 */

import { createWebhookHandler } from '@coursebloom/payuni-sdk';
import {
  createNextjsHandler,
  createNextjsHealthHandler,
} from '@coursebloom/payuni-sdk/adapters/nextjs';

// 建立 Webhook Handler
const webhookHandler = createWebhookHandler({
  hashKey: process.env.PAYUNI_HASH_KEY!,
  hashIV: process.env.PAYUNI_HASH_IV!,

  // 可選：防重放攻擊
  onDuplicateCheck: async (tradeNo) => {
    // TODO: 檢查資料庫是否已處理過此 tradeNo
    // const exists = await db.webhookLog.findUnique({ where: { tradeNo } });
    // return !!exists;
    return false;
  },

  onMarkProcessed: async (tradeNo) => {
    // TODO: 記錄已處理的 tradeNo
    // await db.webhookLog.create({ data: { tradeNo, processedAt: new Date() } });
  },
});

// POST - 接收 Webhook
export const POST = createNextjsHandler(webhookHandler, {
  debug: process.env.NODE_ENV !== 'production',

  onSuccess: async (data) => {
    console.log('[Webhook] 付款成功:', {
      orderId: data.orderId,
      tradeNo: data.tradeNo,
      amount: data.amount,
    });

    // TODO: 更新訂單狀態
    // await db.order.update({
    //   where: { id: data.orderId },
    //   data: {
    //     status: 'paid',
    //     paymentDetails: {
    //       tradeNo: data.tradeNo,
    //       paymentType: data.paymentType,
    //       payTime: data.payTime,
    //     },
    //   },
    // });

    // TODO: 發送付款成功通知
    // await sendPaymentSuccessEmail(data.orderId);
  },

  onFailure: async (data) => {
    console.log('[Webhook] 付款失敗:', {
      orderId: data.orderId,
      message: data.message,
    });

    // TODO: 更新訂單狀態
    // await db.order.update({
    //   where: { id: data.orderId },
    //   data: { status: 'failed' },
    // });
  },

  onError: async (error) => {
    console.error('[Webhook] 處理錯誤:', error);

    // TODO: 記錄錯誤
    // await logError('payuni-webhook', error);
  },
});

// GET - 健康檢查
export const GET = createNextjsHealthHandler();
