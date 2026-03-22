在專案中使用高質感 icon，統一風格、避免 emoji。

參數: $ARGUMENTS (描述需要的 icon，例如: "user profile icon" 或 "搜尋一個設定齒輪的 icon")

## Icon Library: Lucide

所有專案統一使用 **Lucide Icons** (https://lucide.dev)
- 開源 MIT、24x24 viewBox、stroke-based
- 風格一致：圓角、2px stroke、極簡線條
- 與 Feather Icons 相容但更多圖示 (1500+)

## 使用方式

### 方式 1: Inline SVG（推薦，適合少量 icon）

```html
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
  stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
  width="20" height="20">
  <circle cx="12" cy="8" r="4"/>
  <path d="M20 21a8 8 0 1 0-16 0"/>
</svg>
```

### 方式 2: Icon Map（適合多個 icon 集中管理）

```javascript
const ICONS = {
  user: '<svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M20 21a8 8 0 1 0-16 0"/></svg>',
  search: '<svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>',
}
```

搭配 CSS：
```css
.icon svg {
  width: 20px;
  height: 20px;
  stroke: currentColor;
  stroke-width: 2;
  fill: none;
  stroke-linecap: round;
  stroke-linejoin: round;
}
```

### 方式 3: CDN（適合快速原型）

```html
<script src="https://unpkg.com/lucide@latest"></script>
<script>lucide.createIcons();</script>
<i data-lucide="user"></i>
```

## 常用 Icon 速查

| 用途 | Icon 名稱 | SVG Path |
|------|-----------|----------|
| 使用者 | user | `<circle cx="12" cy="8" r="4"/><path d="M20 21a8 8 0 1 0-16 0"/>` |
| 搜尋 | search | `<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>` |
| 設定 | settings | `<path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z"/><circle cx="12" cy="12" r="3"/>` |
| 餐廳 | utensils | `<path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2"/><path d="M7 2v20"/><path d="M21 15V2a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3zm0 0v7"/>` |
| 電影 | clapperboard | `<rect x="2" y="2" width="20" height="20"/><path d="M7 2v20M17 2v20M2 7h5M17 7h5M2 17h5M17 17h5M2 12h20"/>` |
| 錢 | dollar-sign | `<line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>` |
| 對話 | message-square | `<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>` |
| 心 | heart | `<path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/>` |
| 星星 | star | `<polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>` |
| 複製 | copy | `<rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/>` |
| 鎖 | lock | `<rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>` |
| 分享 | share-2 | `<circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>` |
| 外部連結 | external-link | `<path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/>` |
| 眼睛 | eye | `<path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/>` |

## Instructions

1. 根據 $ARGUMENTS 描述，從 Lucide 找到最適合的 icon
2. 如果速查表有 → 直接提供 SVG path
3. 如果沒有 → 去 https://lucide.dev/icons 搜尋，提供 icon name + SVG path
4. 提供 inline SVG 代碼，可以直接複製貼上使用
5. SVG 預設屬性: `viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"`
6. 根據使用場景建議合適的 size（nav: 18px, button: 16px, hero: 28-56px, badge: 14px）

## 風格原則

- 永遠用 Lucide（不用 Font Awesome, Material Icons, emoji）
- Stroke-based，不用 filled icons
- stroke-width 根據場景調整（小 icon 用 2.5, 大 icon 用 2）
- 顏色用 `currentColor` 繼承父元素
- 不要混用不同 icon library
