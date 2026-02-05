---
description: 取得 ETL 銷售單位列表 - 列出所有銷售單位資料
argument-hint: (無參數)
allowed-tools: Read, Bash(curl:*), Bash(powershell:*)
---

# /etl-sales-unit list - 取得銷售單位列表

## 參數說明

此為 GET 請求，無需傳入參數。

## 回傳欄位

| 欄位代碼 | 中文說明 |
|----------|----------|
| `gfe01` | 單位代碼 |
| `gfe02` | 單位名稱 |

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

# 取得銷售單位列表
Get-EtlSalesUnit
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

$response = Invoke-RestMethod -Uri "$baseUrl/api/etl/sales-unit" `
    -Method GET `
    -ContentType "application/json; charset=utf-8" `
    -Headers @{ Authorization = "Bearer $($env:ETL_ACCESS_TOKEN)" }

if ($response.success) {
    Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆銷售單位" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
} else {
    Write-Host "✗ 查詢失敗" -ForegroundColor Red
}
```

### Bash

```bash
# 載入模組
source ./scripts/bash/etl-master-data.sh

# 取得銷售單位列表
etl_get_sales_unit
```

## 回傳範例

```json
{
  "success": true,
  "data": [
    {
      "gfe01": "PCS",
      "gfe02": "個"
    },
    {
      "gfe01": "KG",
      "gfe02": "公斤"
    },
    {
      "gfe01": "SET",
      "gfe02": "組"
    }
  ]
}
```

## 相關指令

- [material-search.md](material-search.md) - 料件查詢
