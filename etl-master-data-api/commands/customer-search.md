---
description: 查詢 ETL 客戶資料 - 以客戶代號或名稱搜尋客戶基本資料
argument-hint: [-CustomerId <代號>] [-CustomerName <名稱>]
allowed-tools: Read, Bash(curl:*), Bash(powershell:*)
---

# /etl-customer search - 查詢客戶資料

## 參數說明

| 參數 | 欄位代碼 | 說明 | 範例 |
|------|----------|------|------|
| `-CustomerId` | `occ01` | 客戶代號（支援模糊查詢） | `C001` |
| `-CustomerName` | `occ02` | 客戶名稱（支援模糊查詢） | `大豐` |

> 可同時傳入多個參數進行組合查詢

## 回傳欄位

| 欄位代碼 | 中文說明 |
|----------|----------|
| `occ01` | 客戶代號 |
| `occ02` | 客戶名稱 |
| `occ43` | 銷售分類 |
| `occ231` | 客戶地址 |
| `occ44` | 收款條件類型 |
| `occ45` | 收款條件代碼 |

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

# 以客戶代號查詢
Search-EtlCustomer -CustomerId "C001"

# 以客戶名稱查詢
Search-EtlCustomer -CustomerName "大豐"

# 組合查詢
Search-EtlCustomer -CustomerId "C001" -CustomerName "大豐"
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
if ($CustomerId) { $body.occ01 = $CustomerId }
if ($CustomerName) { $body.occ02 = $CustomerName }

$response = Invoke-RestMethod -Uri "$baseUrl/api/etl/customer/search" `
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

# 以客戶代號查詢
etl_search_customer --id "C001"

# 以客戶名稱查詢
etl_search_customer --name "大豐"
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
json_body="{}"
[ -n "$customer_id" ] && json_body=$(echo "$json_body" | jq --arg v "$customer_id" '. + {occ01: $v}')
[ -n "$customer_name" ] && json_body=$(echo "$json_body" | jq --arg v "$customer_name" '. + {occ02: $v}')

response=$(curl -s -X POST "$BASE_URL/api/etl/customer/search" \
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
    echo "$response" | jq '.'
fi
```

## 回傳範例

```json
{
  "success": true,
  "data": [
    {
      "occ01": "C001",
      "occ02": "大豐環保科技",
      "occ43": "A01",
      "occ231": "台北市信義區...",
      "occ44": "NET",
      "occ45": "30"
    }
  ]
}
```

## 相關指令

- [supplier-search.md](supplier-search.md) - 供應商查詢
- [sales-category-list.md](sales-category-list.md) - 銷售分類列表
- [payment-term-list.md](payment-term-list.md) - 收款條件列表
