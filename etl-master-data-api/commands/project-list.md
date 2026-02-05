---
description: 取得 ETL 專案編號列表 - 列出所有專案資料
argument-hint: (無參數)
allowed-tools: Read, Bash(curl:*), Bash(powershell:*)
---

# /etl-project list - 取得專案編號列表

## 參數說明

此為 GET 請求，無需傳入參數。

## 回傳欄位

| 欄位代碼 | 中文說明 |
|----------|----------|
| `pja01` | 專案代碼 |
| `pja02` | 專案名稱 |
| `wbs_code` | WBS 代碼 |

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

# 取得專案編號列表
Get-EtlProject
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

$response = Invoke-RestMethod -Uri "$baseUrl/api/etl/project" `
    -Method GET `
    -ContentType "application/json; charset=utf-8" `
    -Headers @{ Authorization = "Bearer $($env:ETL_ACCESS_TOKEN)" }

if ($response.success) {
    Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆專案資料" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
} else {
    Write-Host "✗ 查詢失敗" -ForegroundColor Red
}
```

### Bash

```bash
# 載入模組
source ./scripts/bash/etl-master-data.sh

# 取得專案編號列表
etl_get_project
```

## 回傳範例

```json
{
  "success": true,
  "data": [
    {
      "pja01": "P2025001",
      "pja02": "2025年度系統升級專案",
      "wbs_code": "WBS-001"
    },
    {
      "pja01": "P2025002",
      "pja02": "新廠區建置專案",
      "wbs_code": "WBS-002"
    }
  ]
}
```

## 相關指令

- [department-list.md](department-list.md) - 部門列表
