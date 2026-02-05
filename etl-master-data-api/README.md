# ETL 基本資料查詢 API Skill

此 Skill 提供 ERP 系統基本資料查詢功能，支援員工、供應商、會計科目、料件、固定資產、帳款類別、客戶、匯率等 **18 種查詢**（8 個 POST 搜尋 + 10 個 GET 列表）。

## 快速開始

### 環境設定

```powershell
# PowerShell
$env:ETL_USERNAME = "your_username"
$env:ETL_PASSWORD = "your_password"
```

```bash
# Bash
export ETL_USERNAME="your_username"
export ETL_PASSWORD="your_password"
```

### 使用方式

**PowerShell:**
```powershell
. .\scripts\powershell\etl-master-data.ps1
Get-EtlToken
Search-EtlEmployee -EmployeeName "王雅祈"
Search-EtlCustomer -CustomerName "大豐"
Get-EtlDepartment
```

**Bash:**
```bash
source ./scripts/bash/etl-master-data.sh
etl_get_token
etl_search_employee --name "王雅祈"
etl_search_customer --name "大豐"
etl_get_department
```

## 支援的查詢

### POST 搜尋 (8 個)

| 查詢類型 | PowerShell 函數 | Bash 函數 |
|----------|-----------------|-----------|
| 員工資料 | `Search-EtlEmployee` | `etl_search_employee` |
| 供應商 | `Search-EtlSupplier` | `etl_search_supplier` |
| 會計科目 | `Search-EtlAccountTitle` | `etl_search_account_title` |
| 料件 | `Search-EtlMaterial` | `etl_search_material` |
| 固定資產 | `Search-EtlFixedAsset` | `etl_search_fixed_asset` |
| 帳款類別 | `Search-EtlPaymentType` | `etl_search_payment_type` |
| 客戶 | `Search-EtlCustomer` | `etl_search_customer` |
| 匯率 | `Search-EtlExchangeRate` | `etl_search_exchange_rate` |

### GET 列表 (10 個)

| 查詢類型 | PowerShell 函數 | Bash 函數 |
|----------|-----------------|-----------|
| 部門 | `Get-EtlDepartment` | `etl_get_department` |
| 銷售分類 | `Get-EtlSalesCategory` | `etl_get_sales_category` |
| 專案編號 | `Get-EtlProject` | `etl_get_project` |
| 到達起運地 | `Get-EtlShippingDestination` | `etl_get_shipping_destination` |
| 貿易條件 | `Get-EtlTradeCondition` | `etl_get_trade_condition` |
| 銀行 | `Get-EtlBank` | `etl_get_bank` |
| 幣別 | `Get-EtlCurrency` | `etl_get_currency` |
| 稅別 | `Get-EtlTaxType` | `etl_get_tax_type` |
| 收款條件 | `Get-EtlPaymentTerm` | `etl_get_payment_term` |
| 銷售單位 | `Get-EtlSalesUnit` | `etl_get_sales_unit` |

## 文檔結構

```
etl-master-data-api/
├── SKILL.md              # Skill 主文件
├── README.md             # 本說明文件
├── commands/             # 指令說明 (18 個)
│   ├── employee-search.md
│   ├── supplier-search.md
│   ├── account-title-search.md
│   ├── material-search.md
│   ├── fixed-asset-search.md
│   ├── payment-type-search.md
│   ├── customer-search.md
│   ├── exchange-rate-search.md
│   ├── department-list.md
│   ├── sales-category-list.md
│   ├── project-list.md
│   ├── shipping-destination-list.md
│   ├── trade-condition-list.md
│   ├── bank-list.md
│   ├── currency-list.md
│   ├── tax-type-list.md
│   ├── payment-term-list.md
│   └── sales-unit-list.md
├── references/           # 參考文件
│   ├── endpoints.md      # API 端點規格
│   └── error-handling.md # 錯誤處理
├── scripts/              # 工具腳本
│   ├── powershell/
│   │   └── etl-master-data.ps1
│   └── bash/
│       └── etl-master-data.sh
└── examples/             # 使用範例
    └── workflow-demo.md
```

## 相關連結

- [SKILL.md](SKILL.md) - 完整 Skill 說明
- [API 端點規格](references/endpoints.md)
- [錯誤處理](references/error-handling.md)
- [工作流程範例](examples/workflow-demo.md)
