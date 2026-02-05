---
description: 查詢 ETL 固定資產 - 以資產編號或名稱搜尋固定資產
argument-hint: [-AssetId <編號>] [-AssetName <名稱>]
allowed-tools: Read, Bash(curl:*), Bash(powershell:*)
---

# /etl-fixed-asset search - 查詢固定資產

## 參數說明

| 參數 | 欄位代碼 | 說明 | 範例 |
|------|----------|------|------|
| `-AssetId` | `faj02` | 資產編號（支援模糊查詢） | `AB` |
| `-AssetName` | `faj06` | 資產名稱（支援模糊查詢） | `堆高機` |

> 可同時傳入多個參數進行組合查詢

## 回傳欄位

| 欄位代碼 | 中文說明 |
|----------|----------|
| `faj02` | 資產編號 |
| `faj06` | 資產名稱 |

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

# 以資產編號查詢
Search-EtlFixedAsset -AssetId "AB"

# 以資產名稱查詢
Search-EtlFixedAsset -AssetName "堆高機"

# 組合查詢
Search-EtlFixedAsset -AssetId "AB" -AssetName "堆高機"
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
if ($AssetId) { $body.faj02 = $AssetId }
if ($AssetName) { $body.faj06 = $AssetName }

$response = Invoke-RestMethod -Uri "$baseUrl/api/etl/fixed-asset/search" `
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

# 以資產編號查詢
etl_search_fixed_asset --id "AB"

# 以資產名稱查詢
etl_search_fixed_asset --name "堆高機"
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
[ -n "$ASSET_ID" ] && json_body=$(echo "$json_body" | jq --arg v "$ASSET_ID" '. + {faj02: $v}')
[ -n "$ASSET_NAME" ] && json_body=$(echo "$json_body" | jq --arg v "$ASSET_NAME" '. + {faj06: $v}')

response=$(curl -s -X POST "$BASE_URL/api/etl/fixed-asset/search" \
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
      "faj02": "AB0010012",
      "faj06": "200型鴨嘴怪手"
    },
    {
      "faj02": "QMAB99002",
      "faj06": "(銀行章) 林盟洲"
    },
    {
      "faj02": "QMAB99003",
      "faj06": "(銀行章) 林盟洲銀行專用章"
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
