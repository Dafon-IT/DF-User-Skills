---
description: 取得 ETL 收款條件列表 - 列出所有收款條件資料
argument-hint: (無參數)
allowed-tools: Read, Bash(curl:*), Bash(powershell:*)
---

# /etl-payment-term list - 取得收款條件列表

## 參數說明

此為 GET 請求，無需傳入參數。

## 回傳欄位

| 欄位代碼 | 中文說明 |
|----------|----------|
| `oag01` | 條件代碼 |
| `oag02` | 條件說明 |

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

# 取得收款條件列表
Get-EtlPaymentTerm
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

$response = Invoke-RestMethod -Uri "$baseUrl/api/etl/payment-term" `
    -Method GET `
    -ContentType "application/json; charset=utf-8" `
    -Headers @{ Authorization = "Bearer $($env:ETL_ACCESS_TOKEN)" }

if ($response.success) {
    Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆收款條件" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
} else {
    Write-Host "✗ 查詢失敗" -ForegroundColor Red
}
```

### Bash

```bash
# 載入模組
source ./scripts/bash/etl-master-data.sh

# 取得收款條件列表
etl_get_payment_term
```

## 回傳範例

```json
{
  "success": true,
  "data": [
    {
      "oag01": "NET30",
      "oag02": "月結30天"
    },
    {
      "oag01": "NET60",
      "oag02": "月結60天"
    }
  ]
}
```

## 相關指令

- [customer-search.md](customer-search.md) - 客戶查詢
- [payment-type-search.md](payment-type-search.md) - 帳款類別查詢
