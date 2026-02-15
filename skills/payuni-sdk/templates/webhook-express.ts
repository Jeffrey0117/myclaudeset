/**
 * PAYUNi Webhook - Express 範本
 */

import express from 'express';
import { createWebhookHandler } from '@coursebloom/payuni-sdk';
import {
  createExpressHandler,
  createExpressHealthHandler,
} from '@coursebloom/payuni-sdk/adapters/express';

const router = express.Router();

// 建立 Webhook Handler
const webhookHandler = createWebhookHandler({
  hashKey: process.env.PAYUNI_HASH_KEY!,
  hashIV: process.env.PAYUNI_HASH_IV!,

  // 可選：防重放攻擊
  onDuplicateCheck: async (tradeNo) => {
    // TODO: 檢查是否已處理
    return false;
  },

  onMarkProcessed: async (tradeNo) => {
    // TODO: 標記已處理
  },
});

// POST - 接收 Webhook
router.post(
  '/',
  createExpressHandler(webhookHandler, {
    debug: process.env.NODE_ENV !== 'production',

    onSuccess: async (data) => {
      console.log('[Webhook] 付款成功:', data.orderId);

      // TODO: 更新訂單狀態
    },

    onFailure: async (data) => {
      console.log('[Webhook] 付款失敗:', data.orderId);

      // TODO: 更新訂單狀態
    },

    onError: async (error) => {
      console.error('[Webhook] 錯誤:', error);
    },
  })
);

// GET - 健康檢查
router.get('/', createExpressHealthHandler());

export default router;
