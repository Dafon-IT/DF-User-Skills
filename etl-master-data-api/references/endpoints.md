# ETL 基本資料查詢 API 端點規格

## 基礎資訊

| 項目 | 說明 |
|------|------|
| **Base URL** | `https://zpos-api-stage.zerozero.com.tw` |
| **認證方式** | Bearer Token (JWT) |
| **Content-Type** | `application/json; charset=utf-8` |

## 認證端點

### POST /api/auth/login

取得 Access Token 與 Refresh Token。

**Request:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

| Token 類型 | 有效期 |
|------------|--------|
| Access Token | 30 分鐘 |
| Refresh Token | 1 小時 |

---

### POST /api/auth/refresh

使用 Refresh Token 更新 Access Token。

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Request:**
```json
{
  "refreshToken": "string"
}
```

**Response:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## 查詢端點

> 所有查詢端點皆需要 Authorization Header

### POST /api/etl/employee/search

查詢員工資料。

**Request:**
```json
{
  "gen01": "string (選用) - 員工編號",
  "gen02": "string (選用) - 員工姓名"
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "gen01": "00063",
      "gen02": "王雅祈",
      "gen03": "F000",
      "gem02": "財務部"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `gen01` | 員工編號 |
| `gen02` | 員工姓名 |
| `gen03` | 部門代碼 |
| `gem02` | 部門名稱 |

---

### POST /api/etl/supplier/search

查詢供應商資料。

**Request:**
```json
{
  "pmc24": "string (必要) - 統一編號"
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "pmc01": "C091200188",
      "pmc03": "大豐營運中心",
      "pmc081": "大豐營運中心",
      "pmc17": "A01003",
      "pmc24": "27590900",
      "pmc49": "P01",
      "pmc22": "NTD",
      "pmc47": "2XXX"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `pmc01` | 供應商代碼 |
| `pmc03` | 供應商簡稱 |
| `pmc081` | 供應商全名 |
| `pmc17` | 付款條件 |
| `pmc24` | 統一編號 |
| `pmc49` | 付款方式 |
| `pmc22` | 幣別 |
| `pmc47` | 科目代碼 |

---

### POST /api/etl/account-title/search

查詢會計科目。

**Request:**
```json
{
  "aag01": "string (選用) - 科目代碼",
  "aag02": "string (選用) - 科目名稱"
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "aag01": "1111000",
      "aag02": "透過損益按公允價值衡量之金融資產-流動"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `aag01` | 科目代碼 |
| `aag02` | 科目名稱 |

---

### POST /api/etl/material/search

查詢料件資料。

**Request:**
```json
{
  "ima01": "string (選用) - 料件編號",
  "ima02": "string (選用) - 料件名稱"
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "ima01": "0101001001002",
      "ima02": "紙管",
      "ima021": "φ76×500mm",
      "ima908": "支"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `ima01` | 料件編號 |
| `ima02` | 料件名稱 |
| `ima021` | 規格 |
| `ima908` | 計價單位 |

---

### POST /api/etl/fixed-asset/search

查詢固定資產。

**Request:**
```json
{
  "faj02": "string (選用) - 資產編號",
  "faj06": "string (選用) - 資產名稱"
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "faj02": "AB0010012",
      "faj06": "200型鴨嘴怪手"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `faj02` | 資產編號 |
| `faj06` | 資產名稱 |

---

### POST /api/etl/payment-type/search

查詢帳款類別。

**Request:**
```json
{
  "apr01": "string (選用) - 類別代碼",
  "apr02": "string (選用) - 類別名稱"
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "apr01": "01",
      "apr02": "進貨-大豐環保"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `apr01` | 類別代碼 |
| `apr02` | 類別名稱 |

---

### POST /api/etl/customer/search

查詢客戶資料。

**Request:**
```json
{
  "occ01": "string (選用) - 客戶代號",
  "occ02": "string (選用) - 客戶名稱"
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "occ01": "C001",
      "occ02": "大豐環保科技",
      "occ42": "NTD",
      "occ43": "A01",
      "occ231": "台北市信義區...",
      "occ44": "NET",
      "occ45": "30"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `occ01` | 客戶代號 |
| `occ02` | 客戶名稱 |
| `occ42` | 慣用幣別 |
| `occ43` | 銷售分類 |
| `occ231` | 客戶地址 |
| `occ44` | 收款條件類型 |
| `occ45` | 收款條件代碼 |

---

### POST /api/etl/exchange-rate/search

查詢匯率資料。

**Request:**
```json
{
  "azk02": "string (必要) - 匯率日期 (YYYY-MM-DD)"
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "azk01": "USD",
      "azk02": "2025-01-15",
      "azk03": 31.25,
      "azk04": 31.75
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `azk01` | 幣別代碼 |
| `azk02` | 匯率日期 |
| `azk03` | 買入匯率 |
| `azk04` | 賣出匯率 |

---

## GET 列表端點

> 所有列表端點皆需要 Authorization Header，無需傳入參數

### GET /api/etl/department

取得部門列表。

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "gem01": "F000",
      "gem02": "財務部"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `gem01` | 部門代碼 |
| `gem02` | 部門名稱 |

---

### GET /api/etl/sales-category

取得銷售分類列表。

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "oab01": "A01",
      "oab02": "一般銷售"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `oab01` | 分類代碼 |
| `oab02` | 分類名稱 |

---

### GET /api/etl/project

取得專案編號列表。

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "pja01": "P2025001",
      "pja02": "2025年度系統升級專案",
      "wbs_code": "WBS-001"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `pja01` | 專案代碼 |
| `pja02` | 專案名稱 |
| `wbs_code` | WBS 代碼 |

---

### GET /api/etl/shipping-destination

取得到達起運地列表。

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "oac01": "TPE",
      "oac02": "台北"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `oac01` | 起運地代碼 |
| `oac02` | 起運地名稱 |

---

### GET /api/etl/trade-condition

取得貿易條件列表。

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "tc_its01": "FOB",
      "tc_its02": "Free On Board 離岸價"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `tc_its01` | 條件代碼 |
| `tc_its02` | 條件說明 |

---

### GET /api/etl/bank

取得銀行列表。

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "nma01": "004",
      "nma02": "臺灣銀行"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `nma01` | 銀行代碼 |
| `nma02` | 銀行名稱 |

---

### GET /api/etl/currency

取得幣別列表。

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "azi01": "NTD",
      "azi02": "新台幣"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `azi01` | 幣別代碼 |
| `azi02` | 幣別名稱 |

---

### GET /api/etl/tax-type

取得稅別列表。

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "gec01": "T01",
      "gec011": "VAT",
      "gec02": "應稅內含",
      "gec04": 5,
      "gec06": "營業稅"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `gec01` | 稅別代碼 |
| `gec011` | 稅別類型 |
| `gec02` | 稅別名稱 |
| `gec04` | 稅率 |
| `gec06` | 稅別分類 |

---

### GET /api/etl/payment-term

取得收款條件列表。

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "oag01": "NET30",
      "oag02": "月結30天"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `oag01` | 條件代碼 |
| `oag02` | 條件說明 |

---

### GET /api/etl/sales-unit

取得銷售單位列表。

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "gfe01": "PCS",
      "gfe02": "個"
    }
  ]
}
```

| 回傳欄位 | 說明 |
|----------|------|
| `gfe01` | 單位代碼 |
| `gfe02` | 單位名稱 |

---

## 通用回應格式

### 成功回應
```json
{
  "success": true,
  "data": [...]
}
```

### 錯誤回應
```json
{
  "success": false,
  "message": "錯誤訊息",
  "error": "錯誤代碼"
}
```

## 端點總覽

| 端點 | 方法 | 說明 |
|------|------|------|
| `/api/auth/login` | POST | 登入取得 Token |
| `/api/auth/refresh` | POST | 刷新 Token |
| `/api/etl/employee/search` | POST | 查詢員工資料 |
| `/api/etl/supplier/search` | POST | 查詢供應商 |
| `/api/etl/account-title/search` | POST | 查詢會計科目 |
| `/api/etl/material/search` | POST | 查詢料件 |
| `/api/etl/fixed-asset/search` | POST | 查詢固定資產 |
| `/api/etl/payment-type/search` | POST | 查詢帳款類別 |
| `/api/etl/customer/search` | POST | 查詢客戶資料 |
| `/api/etl/exchange-rate/search` | POST | 查詢匯率 |
| `/api/etl/department` | GET | 取得部門列表 |
| `/api/etl/sales-category` | GET | 取得銷售分類列表 |
| `/api/etl/project` | GET | 取得專案編號列表 |
| `/api/etl/shipping-destination` | GET | 取得到達起運地列表 |
| `/api/etl/trade-condition` | GET | 取得貿易條件列表 |
| `/api/etl/bank` | GET | 取得銀行列表 |
| `/api/etl/currency` | GET | 取得幣別列表 |
| `/api/etl/tax-type` | GET | 取得稅別列表 |
| `/api/etl/payment-term` | GET | 取得收款條件列表 |
| `/api/etl/sales-unit` | GET | 取得銷售單位列表 |
