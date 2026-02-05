# ETL 基本資料查詢 API Skill

此 Skill 提供 ERP 系統基本資料查詢功能，支援員工、供應商、會計科目、料件、固定資產、帳款類別等六種查詢。

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
```

**Bash:**
```bash
source ./scripts/bash/etl-master-data.sh
etl_get_token
etl_search_employee --name "王雅祈"
```

## 支援的查詢

| 查詢類型 | PowerShell 函數 | Bash 函數 |
|----------|-----------------|-----------|
| 員工資料 | `Search-EtlEmployee` | `etl_search_employee` |
| 供應商 | `Search-EtlSupplier` | `etl_search_supplier` |
| 會計科目 | `Search-EtlAccountTitle` | `etl_search_account_title` |
| 料件 | `Search-EtlMaterial` | `etl_search_material` |
| 固定資產 | `Search-EtlFixedAsset` | `etl_search_fixed_asset` |
| 帳款類別 | `Search-EtlPaymentType` | `etl_search_payment_type` |

## 文檔結構

```
etl-master-data-api/
├── SKILL.md              # Skill 主文件
├── README.md             # 本說明文件
├── commands/             # 指令說明
│   ├── employee-search.md
│   ├── supplier-search.md
│   ├── account-title-search.md
│   ├── material-search.md
│   ├── fixed-asset-search.md
│   └── payment-type-search.md
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
