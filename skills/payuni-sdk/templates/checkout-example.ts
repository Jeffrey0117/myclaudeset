/**
 * PAYUNi 結帳範例 - Next.js App Router
 *
 * 檔案位置: app/api/checkout/route.ts
 */

import { NextResponse } from 'next/server';
import {
  createPayuniClientFromEnv,
  calculateFinalPrice,
  validatePrice,
  formatAmount,
} from '@coursebloom/payuni-sdk';

// 結帳請求參數
interface CheckoutRequest {
  orderId: string;
  productId: string;
  quantity: number;
  discountCode?: string;
  shippingMethod?: 'standard' | 'express';
}

export async function POST(request: Request) {
  try {
    const body: CheckoutRequest = await request.json();
    const { orderId, productId, quantity, discountCode, shippingMethod } = body;

    // 1. 查詢商品資訊
    // const product = await db.product.findUnique({ where: { id: productId } });
    const product = {
      id: productId,
      name: '範例商品',
      originalPrice: 1000,
      salePrice: 800,
      saleQuota: 100,
    };

    // 2. 查詢目前銷售數量
    // const salesCount = await db.order.count({
    //   where: { productId, status: 'paid' },
    // });
    const salesCount = 50;

    // 3. 查詢折扣碼
    let discount = null;
    if (discountCode) {
      // discount = await db.discountCode.findUnique({
      //   where: { code: discountCode },
      // });
      discount = {
        type: 'percentage' as const,
        value: 10,
        isActive: true,
      };
    }

    // 4. 計算運費
    const shippingFee = shippingMethod === 'express' ? 100 : 60;

    // 5. 計算最終價格
    const finalPrice = calculateFinalPrice({
      item: {
        originalPrice: product.originalPrice * quantity,
        salePrice: product.salePrice ? product.salePrice * quantity : null,
        saleQuota: product.saleQuota,
      },
      currentSales: salesCount,
      discount,
      shippingFee,
    });

    console.log('[Checkout] 計算價格:', {
      product: product.name,
      quantity,
      finalPrice: formatAmount(finalPrice),
    });

    // 6. 建立付款請求
    const payuni = createPayuniClientFromEnv();

    const payment = payuni.createPayment({
      orderId,
      amount: finalPrice,
      productName: `${product.name} x ${quantity}`,
      returnUrl: `${process.env.NEXT_PUBLIC_SITE_URL}/checkout/result?orderId=${orderId}`,
      notifyUrl: `${process.env.NEXT_PUBLIC_SITE_URL}/api/webhooks/payuni`,
      paymentMethods: ['credit', 'atm', 'cvs'],
      orderRemark: discountCode ? `折扣碼: ${discountCode}` : undefined,
      custom1: productId,
      custom2: String(quantity),
    });

    // 7. 建立訂單記錄
    // await db.order.create({
    //   data: {
    //     id: orderId,
    //     productId,
    //     quantity,
    //     amount: finalPrice,
    //     discountCode,
    //     shippingMethod,
    //     status: 'pending',
    //   },
    // });

    // 8. 回傳付款表單 HTML (自動導向 PAYUNi)
    return new Response(payment.toFormHtml(), {
      headers: { 'Content-Type': 'text/html; charset=utf-8' },
    });

    // 或者回傳 JSON 讓前端處理導向
    // return NextResponse.json({
    //   success: true,
    //   redirectUrl: payment.toRedirectUrl(),
    //   orderSummary: {
    //     orderId,
    //     productName: product.name,
    //     quantity,
    //     finalPrice,
    //     formattedPrice: formatAmount(finalPrice),
    //   },
    // });
  } catch (error) {
    console.error('[Checkout] 錯誤:', error);

    return NextResponse.json(
      { error: '結帳處理失敗' },
      { status: 500 }
    );
  }
}

/**
 * 結帳結果頁面範例
 *
 * 檔案位置: app/checkout/result/page.tsx
 */
/*
export default async function CheckoutResultPage({
  searchParams,
}: {
  searchParams: { orderId?: string };
}) {
  const { orderId } = searchParams;

  if (!orderId) {
    return <div>找不到訂單</div>;
  }

  // 查詢訂單狀態
  // const order = await db.order.findUnique({ where: { id: orderId } });

  return (
    <div>
      <h1>訂單狀態</h1>
      <p>訂單編號: {orderId}</p>
      {/* 根據訂單狀態顯示不同內容 *\/}
    </div>
  );
}
*/
