---
description: 取得 ETL 到達起運地列表 - 列出所有起運地資料
argument-hint: (無參數)
allowed-tools: Read, Bash(curl:*), Bash(powershell:*)
---

# /etl-shipping-destination list - 取得到達起運地列表

## 參數說明

此為 GET 請求，無需傳入參數。

## 回傳欄位

| 欄位代碼 | 中文說明 |
|----------|----------|
| `oac01` | 起運地代碼 |
| `oac02` | 起運地名稱 |

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

# 取得到達起運地列表
Get-EtlShippingDestination
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

$response = Invoke-RestMethod -Uri "$baseUrl/api/etl/shipping-destination" `
    -Method GET `
    -ContentType "application/json; charset=utf-8" `
    -Headers @{ Authorization = "Bearer $($env:ETL_ACCESS_TOKEN)" }

if ($response.success) {
    Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆起運地資料" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
} else {
    Write-Host "✗ 查詢失敗" -ForegroundColor Red
}
```

### Bash

```bash
# 載入模組
source ./scripts/bash/etl-master-data.sh

# 取得到達起運地列表
etl_get_shipping_destination
```

## 回傳範例

```json
{
  "success": true,
  "data": [
    {
      "oac01": "TPE",
      "oac02": "台北"
    },
    {
      "oac01": "KHH",
      "oac02": "高雄"
    }
  ]
}
```

## 相關指令

- [trade-condition-list.md](trade-condition-list.md) - 貿易條件列表
