---
description: 查詢 ETL 供應商資料 - 以統一編號搜尋供應商基本資料
argument-hint: -TaxId <統一編號>
allowed-tools: Read, Bash(curl:*), Bash(powershell:*)
---

# /etl-supplier search - 查詢供應商資料

## 參數說明

| 參數 | 欄位代碼 | 說明 | 範例 |
|------|----------|------|------|
| `-TaxId` | `pmc24` | 統一編號（支援模糊查詢） | `27590900` |

## 回傳欄位

| 欄位代碼 | 中文說明 |
|----------|----------|
| `pmc01` | 供應商代碼 |
| `pmc03` | 供應商簡稱 |
| `pmc081` | 供應商全名 |
| `pmc17` | 付款條件 |
| `pmc24` | 統一編號 |
| `pmc49` | 付款方式 |
| `pmc22` | 幣別 |
| `pmc47` | 科目代碼 |

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

# 以統一編號查詢
Search-EtlSupplier -TaxId "27590900"
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

$body = @{
    pmc24 = $TaxId
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "$baseUrl/api/etl/supplier/search" `
    -Method POST `
    -ContentType "application/json; charset=utf-8" `
    -Headers @{ Authorization = "Bearer $($env:ETL_ACCESS_TOKEN)" } `
    -Body $body

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

# 以統一編號查詢
etl_search_supplier "27590900"
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
TAX_ID="$1"

response=$(curl -s -X POST "$BASE_URL/api/etl/supplier/search" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $ETL_ACCESS_TOKEN" \
    -d "{\"pmc24\": \"$TAX_ID\"}")

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
      "pmc01": "C091200188",
      "pmc03": "大豐營運中心",
      "pmc081": "大豐營運中心",
      "pmc17": "A01003",
      "pmc24": "27590900",
      "pmc49": "P01",
      "pmc22": "NTD",
      "pmc47": "2XXX"
    },
    {
      "pmc01": "C111100504",
      "pmc03": "大豐環保",
      "pmc081": "大豐環保科技股份有限公司",
      "pmc17": "C30060",
      "pmc24": "27590900",
      "pmc49": "P01",
      "pmc22": "NTD",
      "pmc47": "2XXX"
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
