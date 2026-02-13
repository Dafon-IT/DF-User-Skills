---
name: "etl-master-data-api"
description: "ETL 基本資料查詢 API Skill - 協助查詢 ERP 系統基本資料，包含員工、供應商、會計科目、料件、固定資產、帳款類別、客戶、部門、專案、幣別、匯率等 18 種查詢功能，支援 Token 自動管理與過期刷新機制"
---

# ETL 基本資料查詢 API Skill

此 Skill 提供 ETL 基本資料查詢 API 的完整功能，支援 Windows (PowerShell) 和 Linux/macOS (Bash) 雙平台。

## 環境設定

| 環境變數 | 必要性 | 說明 |
|----------|--------|------|
| `ETL_API_BASE_URL` | 選用 | API 基礎 URL，預設 `https://zpos-api-stage.zerozero.com.tw` |
| `ETL_USERNAME` | **必要** | 登入帳號 |
| `ETL_PASSWORD` | **必要** | 登入密碼 |
| `ETL_ACCESS_TOKEN` | 自動 | 登入後自動設定，30 分鐘過期 |
| `ETL_REFRESH_TOKEN` | 自動 | 登入後自動設定，1 小時過期 |
| `ETL_TOKEN_EXPIRES` | 自動 | Token 過期時間 (Unix timestamp) |

### 環境變數設定方式

**PowerShell:**
```powershell
$env:ETL_USERNAME = "your_username"
$env:ETL_PASSWORD = "your_password"
# 選用：自訂 API URL
$env:ETL_API_BASE_URL = "https://zpos-api-stage.zerozero.com.tw"
```

**Bash:**
```bash
export ETL_USERNAME="your_username"
export ETL_PASSWORD="your_password"
# 選用：自訂 API URL
export ETL_API_BASE_URL="https://zpos-api-stage.zerozero.com.tw"
```

## 支援的查詢操作

### 一、基礎資料查詢 (POST 搜尋)

#### 1. 員工資料查詢
- **端點**: `/api/etl/employee/search`
- **方法**: POST
- **參數**: `gen01` (員工編號) / `gen02` (員工姓名)
- **回傳**: 員工編號、姓名、部門代碼、部門名稱

#### 2. 供應商查詢
- **端點**: `/api/etl/supplier/search`
- **方法**: POST
- **參數**: `pmc24` (統一編號)
- **回傳**: 供應商代碼、簡稱、全名、付款條件、統編、幣別等

#### 3. 會計科目查詢
- **端點**: `/api/etl/account-title/search`
- **方法**: POST
- **參數**: `aag01` (科目代碼) / `aag02` (科目名稱)
- **回傳**: 科目代碼、科目名稱

#### 4. 料件查詢
- **端點**: `/api/etl/material/search`
- **方法**: POST
- **參數**: `ima01` (料件編號) / `ima02` (料件名稱)
- **回傳**: 料件編號、料件名稱、規格、計價單位

#### 5. 固定資產查詢
- **端點**: `/api/etl/fixed-asset/search`
- **方法**: POST
- **參數**: `faj02` (資產編號) / `faj06` (資產名稱)
- **回傳**: 資產編號、資產名稱

#### 6. 帳款類別查詢
- **端點**: `/api/etl/payment-type/search`
- **方法**: POST
- **參數**: `apr01` (類別代碼) / `apr02` (類別名稱)
- **回傳**: 類別代碼、類別名稱

#### 7. 客戶查詢
- **端點**: `/api/etl/customer/search`
- **方法**: POST
- **參數**: `occ01` (客戶代號) / `occ02` (客戶名稱)
- **回傳**: 客戶代號、名稱、慣用幣別、銷售分類、地址、收款條件等

#### 8. 匯率查詢
- **端點**: `/api/etl/exchange-rate/search`
- **方法**: POST
- **參數**: `azk02` (匯率日期，格式：YYYY-MM-DD)
- **回傳**: 幣別代碼、日期、買入匯率、賣出匯率

### 二、基礎資料列表 (GET 列表)

#### 9. 部門列表
- **端點**: `/api/etl/department`
- **方法**: GET
- **回傳**: 部門代碼 (`gem01`)、部門名稱 (`gem02`)

#### 10. 銷售分類列表
- **端點**: `/api/etl/sales-category`
- **方法**: GET
- **回傳**: 分類代碼 (`oab01`)、分類名稱 (`oab02`)

#### 11. 專案編號列表
- **端點**: `/api/etl/project`
- **方法**: GET
- **回傳**: 專案代碼 (`pja01`)、專案名稱 (`pja02`)、WBS 代碼 (`wbs_code`)

#### 12. 到達起運地列表
- **端點**: `/api/etl/shipping-destination`
- **方法**: GET
- **回傳**: 起運地代碼 (`oac01`)、起運地名稱 (`oac02`)

#### 13. 貿易條件列表
- **端點**: `/api/etl/trade-condition`
- **方法**: GET
- **回傳**: 條件代碼 (`tc_its01`)、條件說明 (`tc_its02`)

#### 14. 銀行列表
- **端點**: `/api/etl/bank`
- **方法**: GET
- **回傳**: 銀行代碼 (`nma01`)、銀行名稱 (`nma02`)

#### 15. 幣別列表
- **端點**: `/api/etl/currency`
- **方法**: GET
- **回傳**: 幣別代碼 (`azi01`)、幣別名稱 (`azi02`)

#### 16. 稅別列表
- **端點**: `/api/etl/tax-type`
- **方法**: GET
- **回傳**: 稅別代碼 (`gec01`)、類型 (`gec011`)、稅別名稱 (`gec02`)、稅率 (`gec04`)

#### 17. 收款條件列表
- **端點**: `/api/etl/payment-term`
- **方法**: GET
- **回傳**: 條件代碼 (`oag01`)、條件說明 (`oag02`)

#### 18. 銷售單位列表
- **端點**: `/api/etl/sales-unit`
- **方法**: GET
- **回傳**: 單位代碼 (`gfe01`)、單位名稱 (`gfe02`)

## 欄位代碼對照表

### 基礎資料欄位

| 查詢類型 | 欄位代碼 | 中文說明 |
|----------|----------|----------|
| **員工** | `gen01` | 員工編號 |
| | `gen02` | 員工姓名 |
| | `gen03` | 部門代碼 |
| | `gem02` | 部門名稱 |
| **供應商** | `pmc01` | 供應商代碼 |
| | `pmc03` | 供應商簡稱 |
| | `pmc081` | 供應商全名 |
| | `pmc17` | 付款條件 |
| | `pmc24` | 統一編號 |
| | `pmc49` | 付款方式 |
| | `pmc22` | 幣別 |
| | `pmc47` | 科目代碼 |
| **會計科目** | `aag01` | 科目代碼 |
| | `aag02` | 科目名稱 |
| **料件** | `ima01` | 料件編號 |
| | `ima02` | 料件名稱 |
| | `ima021` | 規格 |
| | `ima908` | 計價單位 |
| **固定資產** | `faj02` | 資產編號 |
| | `faj06` | 資產名稱 |
| **帳款類別** | `apr01` | 類別代碼 |
| | `apr02` | 類別名稱 |

### 銷售相關欄位

| 查詢類型 | 欄位代碼 | 中文說明 |
|----------|----------|----------|
| **客戶** | `occ01` | 客戶代號 |
| | `occ02` | 客戶名稱 |
| | `occ42` | 慣用幣別 |
| | `occ43` | 銷售分類 |
| | `occ231` | 客戶地址 |
| | `occ44` | 收款條件類型 |
| | `occ45` | 收款條件代碼 |
| **部門** | `gem01` | 部門代碼 |
| | `gem02` | 部門名稱 |
| **銷售分類** | `oab01` | 分類代碼 |
| | `oab02` | 分類名稱 |
| **專案** | `pja01` | 專案代碼 |
| | `pja02` | 專案名稱 |
| | `wbs_code` | WBS 代碼 |
| **起運地** | `oac01` | 起運地代碼 |
| | `oac02` | 起運地名稱 |
| **貿易條件** | `tc_its01` | 條件代碼 |
| | `tc_its02` | 條件說明 |
| **銀行** | `nma01` | 銀行代碼 |
| | `nma02` | 銀行名稱 |
| **幣別** | `azi01` | 幣別代碼 |
| | `azi02` | 幣別名稱 |
| **匯率** | `azk01` | 幣別代碼 |
| | `azk02` | 匯率日期 |
| | `azk03` | 買入匯率 |
| | `azk04` | 賣出匯率 |
| **稅別** | `gec01` | 稅別代碼 |
| | `gec011` | 稅別類型 |
| | `gec02` | 稅別名稱 |
| | `gec04` | 稅率 |
| | `gec06` | 稅別分類 |
| **收款條件** | `oag01` | 條件代碼 |
| | `oag02` | 條件說明 |
| **銷售單位** | `gfe01` | 單位代碼 |
| | `gfe02` | 單位名稱 |

## Token 自動管理機制

本 Skill 實作 Token 自動過期檢查與刷新機制：

```
API 呼叫 → Test-EtlTokenExpiry (檢查過期)
                    ↓
    $env:ETL_TOKEN_EXPIRES < 當前時間?
                    ↓
         是 → Update-EtlToken → 更新 Token + Expires
         否 → 繼續執行 API 呼叫
```

- Access Token 有效期：**30 分鐘**
- Refresh Token 有效期：**1 小時**
- 每次成功登入/刷新後，自動設定 `ETL_TOKEN_EXPIRES` 為當前時間 + 30 分鐘

## 執行指引

1. **確認環境變數** - 確保 `ETL_USERNAME` 和 `ETL_PASSWORD` 已設定
2. **識別作業系統** - 判斷使用者環境為 Windows 或 Linux/macOS
3. **選擇對應腳本**
   - Windows: `scripts/powershell/etl-master-data.ps1`
   - Linux/macOS: `scripts/bash/etl-master-data.sh`
4. **處理編碼** - PowerShell 需設定 UTF-8 編碼以正確顯示中文
5. **執行前檢查** - 腳本會自動檢查 Token 是否過期並刷新

## API 認證格式

所有 API 請求需在 Header 中包含：
```
Authorization: Bearer {accessToken}
```

## 相關資源

- **指令文檔**: [commands/](commands/) - 各查詢操作的詳細指令說明
  - **基礎資料查詢 (POST)**
    - [employee-search.md](commands/employee-search.md) - 員工資料查詢
    - [supplier-search.md](commands/supplier-search.md) - 供應商查詢
    - [account-title-search.md](commands/account-title-search.md) - 會計科目查詢
    - [material-search.md](commands/material-search.md) - 料件查詢
    - [fixed-asset-search.md](commands/fixed-asset-search.md) - 固定資產查詢
    - [payment-type-search.md](commands/payment-type-search.md) - 帳款類別查詢
    - [customer-search.md](commands/customer-search.md) - 客戶查詢
    - [exchange-rate-search.md](commands/exchange-rate-search.md) - 匯率查詢
  - **基礎資料列表 (GET)**
    - [department-list.md](commands/department-list.md) - 部門列表
    - [sales-category-list.md](commands/sales-category-list.md) - 銷售分類列表
    - [project-list.md](commands/project-list.md) - 專案編號列表
    - [shipping-destination-list.md](commands/shipping-destination-list.md) - 到達起運地列表
    - [trade-condition-list.md](commands/trade-condition-list.md) - 貿易條件列表
    - [bank-list.md](commands/bank-list.md) - 銀行列表
    - [currency-list.md](commands/currency-list.md) - 幣別列表
    - [tax-type-list.md](commands/tax-type-list.md) - 稅別列表
    - [payment-term-list.md](commands/payment-term-list.md) - 收款條件列表
    - [sales-unit-list.md](commands/sales-unit-list.md) - 銷售單位列表
- **API 參考**: [references/endpoints.md](references/endpoints.md) - 完整 API 端點規格
- **錯誤處理**: [references/error-handling.md](references/error-handling.md) - 錯誤代碼與診斷
- **工具腳本**: [scripts/](scripts/) - PowerShell 與 Bash 實作
- **使用範例**: [examples/workflow-demo.md](examples/workflow-demo.md) - 完整工作流程

## 與 etl-dictionary-api 的關係

本 Skill 與 `etl-dictionary-api` 共用相同的認證機制和 API 基礎架構。若已透過 `etl-dictionary-api` 登入並取得 Token，可直接使用該 Token 進行本 Skill 的查詢操作。
