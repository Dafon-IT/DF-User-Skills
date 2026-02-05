---
description: 查詢 ETL 匯率資料 - 以日期搜尋當日匯率
argument-hint: -Date <日期 YYYY-MM-DD>
allowed-tools: Read, Bash(curl:*), Bash(powershell:*)
---

# /etl-exchange-rate search - 查詢匯率資料

## 參數說明

| 參數 | 欄位代碼 | 說明 | 範例 |
|------|----------|------|------|
| `-Date` | `azk02` | 匯率日期（格式：YYYY-MM-DD） | `2025-01-15` |

> 此為必要參數，需指定查詢日期

## 回傳欄位

| 欄位代碼 | 中文說明 |
|----------|----------|
| `azk01` | 幣別代碼 |
| `azk02` | 匯率日期 |
| `azk03` | 買入匯率 |
| `azk04` | 賣出匯率 |

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

# 查詢指定日期匯率
Search-EtlExchangeRate -Date "2025-01-15"
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

# 建立查詢參數
$body = @{
    azk02 = $Date
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "$baseUrl/api/etl/exchange-rate/search" `
    -Method POST `
    -ContentType "application/json; charset=utf-8" `
    -Headers @{ Authorization = "Bearer $($env:ETL_ACCESS_TOKEN)" } `
    -Body $body

if ($response.success) {
    Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆匯率資料" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
} else {
    Write-Host "✗ 查詢失敗" -ForegroundColor Red
}
```

### Bash

```bash
# 載入模組
source ./scripts/bash/etl-master-data.sh

# 查詢指定日期匯率
etl_search_exchange_rate "2025-01-15"
```

**完整 Bash 程式碼：**
```bash
# 自動檢查 Token 過期
current_time=$(date +%s)
if [ -n "$ETL_TOKEN_EXPIRES" ] && [ "$current_time" -ge "$ETL_TOKEN_EXPIRES" ]; then
    echo "Token 已過期，自動刷新中..."
    etl_update_token
fi

BASE_URL="${ETL_API_BASE_URL:-https://zpos-api-stage.zerozero.com.tw}"

# 建立查詢參數
json_body="{\"azk02\": \"$date\"}"

response=$(curl -s -X POST "$BASE_URL/api/etl/exchange-rate/search" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $ETL_ACCESS_TOKEN" \
    -d "$json_body")

success=$(echo "$response" | jq -r '.success')
if [ "$success" = "true" ]; then
    count=$(echo "$response" | jq '.data | length')
    echo "✓ 查詢成功，共找到 $count 筆匯率資料"
    echo "$response" | jq '.data'
else
    echo "✗ 查詢失敗"
    echo "$response" | jq '.'
fi
```

## 回傳範例

```json
{
  "success": true,
  "data": [
    {
      "azk01": "USD",
      "azk02": "2025-01-15",
      "azk03": 31.25,
      "azk04": 31.75
    },
    {
      "azk01": "JPY",
      "azk02": "2025-01-15",
      "azk03": 0.205,
      "azk04": 0.215
    }
  ]
}
```

## 相關指令

- [currency-list.md](currency-list.md) - 幣別列表
