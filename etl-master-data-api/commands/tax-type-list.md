---
description: 取得 ETL 稅別列表 - 列出所有稅別資料
argument-hint: (無參數)
allowed-tools: Read, Bash(curl:*), Bash(powershell:*)
---

# /etl-tax-type list - 取得稅別列表

## 參數說明

此為 GET 請求，無需傳入參數。

## 回傳欄位

| 欄位代碼 | 中文說明 |
|----------|----------|
| `gec01` | 稅別代碼 |
| `gec011` | 稅別類型 |
| `gec02` | 稅別名稱 |
| `gec04` | 稅率 |
| `gec06` | 稅別分類 |

## 前置條件

1. 確認已登入（`ETL_ACCESS_TOKEN` 已設定）
2. PowerShell 編碼設定：
   ```powershell
   [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
   $OutputEncoding = [System.Text.Encoding]::UTF8
   ```

## 操作執行

### PowerShell

```powershell
# 載入模組
. .\scripts\powershell\etl-master-data.ps1

# 取得稅別列表
Get-EtlTaxType
```

**完整 PowerShell 程式碼：**
```powershell
# 自動檢查 Token 過期
$currentTime = [DateTimeOffset]::Now.ToUnixTimeSeconds()
if ($env:ETL_TOKEN_EXPIRES -and $currentTime -ge [long]$env:ETL_TOKEN_EXPIRES) {
    Write-Host "Token 已過期，自動刷新中..." -ForegroundColor Yellow
    Update-EtlToken
}

$baseUrl = if ($env:ETL_API_BASE_URL) { $env:ETL_API_BASE_URL } else { "https://zpos-api-stage.zerozero.com.tw" }

$response = Invoke-RestMethod -Uri "$baseUrl/api/etl/tax-type" `
    -Method GET `
    -ContentType "application/json; charset=utf-8" `
    -Headers @{ Authorization = "Bearer $($env:ETL_ACCESS_TOKEN)" }

if ($response.success) {
    Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆稅別資料" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
} else {
    Write-Host "✗ 查詢失敗" -ForegroundColor Red
}
```

### Bash

```bash
# 載入模組
source ./scripts/bash/etl-master-data.sh

# 取得稅別列表
etl_get_tax_type
```

## 回傳範例

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
    },
    {
      "gec01": "T02",
      "gec011": "VAT",
      "gec02": "應稅外加",
      "gec04": 5,
      "gec06": "營業稅"
    }
  ]
}
```

## 相關指令

- [account-title-search.md](account-title-search.md) - 會計科目查詢
