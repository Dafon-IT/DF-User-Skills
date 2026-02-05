---
description: 查詢 ETL 會計科目 - 以科目代碼或名稱搜尋會計科目
argument-hint: [-AccountCode <代碼>] [-AccountName <名稱>]
allowed-tools: Read, Bash(curl:*), Bash(powershell:*)
---

# /etl-account-title search - 查詢會計科目

## 參數說明

| 參數 | 欄位代碼 | 說明 | 範例 |
|------|----------|------|------|
| `-AccountCode` | `aag01` | 科目代碼（支援模糊查詢） | `9110` |
| `-AccountName` | `aag02` | 科目名稱（支援模糊查詢） | `損益` |

> 可同時傳入多個參數進行組合查詢

## 回傳欄位

| 欄位代碼 | 中文說明 |
|----------|----------|
| `aag01` | 科目代碼 |
| `aag02` | 科目名稱 |

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

# 以科目代碼查詢
Search-EtlAccountTitle -AccountCode "9110"

# 以科目名稱查詢
Search-EtlAccountTitle -AccountName "損益"

# 組合查詢
Search-EtlAccountTitle -AccountCode "9110" -AccountName "損益"
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
$body = @{}
if ($AccountCode) { $body.aag01 = $AccountCode }
if ($AccountName) { $body.aag02 = $AccountName }

$response = Invoke-RestMethod -Uri "$baseUrl/api/etl/account-title/search" `
    -Method POST `
    -ContentType "application/json; charset=utf-8" `
    -Headers @{ Authorization = "Bearer $($env:ETL_ACCESS_TOKEN)" } `
    -Body ($body | ConvertTo-Json)

if ($response.success) {
    Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆資料" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
} else {
    Write-Host "✗ 查詢失敗" -ForegroundColor Red
}
```

### Bash

```bash
# 載入模組
source ./scripts/bash/etl-master-data.sh

# 以科目代碼查詢
etl_search_account_title --code "9110"

# 以科目名稱查詢
etl_search_account_title --name "損益"
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

# 建立查詢參數 JSON
json_body="{}"
[ -n "$ACCOUNT_CODE" ] && json_body=$(echo "$json_body" | jq --arg v "$ACCOUNT_CODE" '. + {aag01: $v}')
[ -n "$ACCOUNT_NAME" ] && json_body=$(echo "$json_body" | jq --arg v "$ACCOUNT_NAME" '. + {aag02: $v}')

response=$(curl -s -X POST "$BASE_URL/api/etl/account-title/search" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $ETL_ACCESS_TOKEN" \
    -d "$json_body")

success=$(echo "$response" | jq -r '.success')
if [ "$success" = "true" ]; then
    count=$(echo "$response" | jq '.data | length')
    echo "✓ 查詢成功，共找到 $count 筆資料"
    echo "$response" | jq '.data'
else
    echo "✗ 查詢失敗"
fi
```

## 回傳範例

```json
{
  "success": true,
  "data": [
    {
      "aag01": "1111000",
      "aag02": "透過損益按公允價值衡量之金融資產-流動"
    },
    {
      "aag01": "1112000",
      "aag02": "透過損益按公允價值衡量之金融資產評價調整-流動"
    },
    {
      "aag01": "591100017",
      "aag02": "製造費-【消耗品費用】"
    }
  ]
}
```

## 錯誤處理

| 錯誤情況 | 處理方式 |
|----------|----------|
| Token 過期 | 自動呼叫 `Update-EtlToken` 刷新 |
| 無查詢結果 | 回傳空陣列 `data: []` |
| 認證失敗 | 提示重新登入 |
