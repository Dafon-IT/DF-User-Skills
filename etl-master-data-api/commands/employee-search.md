---
description: 查詢 ETL 員工資料 - 以員工編號或姓名搜尋員工基本資料
argument-hint: [-EmployeeId <編號>] [-EmployeeName <姓名>]
allowed-tools: Read, Bash(curl:*), Bash(powershell:*)
---

# /etl-employee search - 查詢員工資料

## 參數說明

| 參數 | 欄位代碼 | 說明 | 範例 |
|------|----------|------|------|
| `-EmployeeId` | `gen01` | 員工編號（支援模糊查詢） | `00063` |
| `-EmployeeName` | `gen02` | 員工姓名（支援模糊查詢） | `王雅祈` |

> 可同時傳入多個參數進行組合查詢

## 回傳欄位

| 欄位代碼 | 中文說明 |
|----------|----------|
| `gen01` | 員工編號 |
| `gen02` | 員工姓名 |
| `gen03` | 部門代碼 |
| `gem02` | 部門名稱 |

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

# 以員工編號查詢
Search-EtlEmployee -EmployeeId "00063"

# 以員工姓名查詢
Search-EtlEmployee -EmployeeName "王雅祈"

# 組合查詢
Search-EtlEmployee -EmployeeId "00063" -EmployeeName "王雅祈"
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
if ($EmployeeId) { $body.gen01 = $EmployeeId }
if ($EmployeeName) { $body.gen02 = $EmployeeName }

$response = Invoke-RestMethod -Uri "$baseUrl/api/etl/employee/search" `
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

# 以員工編號查詢
etl_search_employee --id "00063"

# 以員工姓名查詢
etl_search_employee --name "王雅祈"
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
[ -n "$EMPLOYEE_ID" ] && json_body=$(echo "$json_body" | jq --arg v "$EMPLOYEE_ID" '. + {gen01: $v}')
[ -n "$EMPLOYEE_NAME" ] && json_body=$(echo "$json_body" | jq --arg v "$EMPLOYEE_NAME" '. + {gen02: $v}')

response=$(curl -s -X POST "$BASE_URL/api/etl/employee/search" \
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
      "gen01": "00063",
      "gen02": "王雅祈",
      "gen03": "F000",
      "gem02": "財務部"
    },
    {
      "gen01": "S00063",
      "gen02": "賴仁祺",
      "gen03": "BB003",
      "gem02": "文山分選廠專案"
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
