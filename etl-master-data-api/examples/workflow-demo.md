# ETL 基本資料查詢 工作流程範例

本文件展示 ETL 基本資料查詢 API 的完整使用流程。

## 情境：財務人員查詢相關基本資料

假設財務人員需要：
1. 查詢特定員工的部門資訊
2. 查詢供應商的完整資料
3. 查詢相關的會計科目
4. 查詢帳款類別

---

## PowerShell 完整流程

### Step 1: 環境設定

```powershell
# 設定環境變數
$env:ETL_USERNAME = "replit"
$env:ETL_PASSWORD = "1234"

# 載入模組
. .\scripts\powershell\etl-master-data.ps1
```

### Step 2: 登入取得 Token

```powershell
# 登入
Get-EtlToken

# 輸出：
# ✓ 登入成功，Token 將於 30 分鐘後過期
```

### Step 3: 查詢員工資料

```powershell
# 以員工姓名查詢
$employees = Search-EtlEmployee -EmployeeName "王雅祈"

# 輸出：
# ✓ 查詢成功，共找到 2 筆員工資料
#
# gen01   gen02  gen03  gem02
# -----   -----  -----  -----
# 00063   王雅祈 F000   財務部
# S00063  賴仁祺 BB003  文山分選廠專案

# 顯示詳細資料
$employees | Format-Table -AutoSize
```

### Step 4: 查詢供應商

```powershell
# 以統一編號查詢供應商
$suppliers = Search-EtlSupplier -TaxId "27590900"

# 輸出：
# ✓ 查詢成功，共找到 3 筆供應商資料

# 篩選特定欄位顯示
$suppliers | Select-Object pmc01, pmc03, pmc081, pmc22 | Format-Table -AutoSize
```

### Step 5: 查詢會計科目

```powershell
# 以關鍵字查詢會計科目
$accounts = Search-EtlAccountTitle -AccountName "損益"

# 輸出：
# ✓ 查詢成功，共找到 3 筆會計科目

$accounts | Format-Table -AutoSize
```

### Step 6: 查詢帳款類別

```powershell
# 以類別名稱查詢
$paymentTypes = Search-EtlPaymentType -TypeName "預付"

# 輸出：
# ✓ 查詢成功，共找到 3 筆帳款類別

$paymentTypes | Format-Table -AutoSize
```

### Step 7: 組合查詢與匯出

```powershell
# 查詢所有相關資料並匯出為 JSON
$result = @{
    employees = Search-EtlEmployee -EmployeeName "王"
    suppliers = Search-EtlSupplier -TaxId "27590900"
    accounts = Search-EtlAccountTitle -AccountCode "111"
}

# 匯出為 JSON 檔案
$result | ConvertTo-Json -Depth 3 | Out-File "query-result.json" -Encoding UTF8

Write-Host "✓ 查詢結果已匯出至 query-result.json" -ForegroundColor Green
```

---

## Bash 完整流程

### Step 1: 環境設定

```bash
# 設定環境變數
export ETL_USERNAME="replit"
export ETL_PASSWORD="1234"

# 載入模組
source ./scripts/bash/etl-master-data.sh
```

### Step 2: 登入取得 Token

```bash
# 登入
etl_get_token

# 輸出：
# ✓ 登入成功，Token 將於 30 分鐘後過期
```

### Step 3: 查詢員工資料

```bash
# 以員工姓名查詢
etl_search_employee --name "王雅祈"

# 輸出：
# ✓ 查詢成功，共找到 2 筆員工資料
# [
#   {
#     "gen01": "00063",
#     "gen02": "王雅祈",
#     "gen03": "F000",
#     "gem02": "財務部"
#   },
#   ...
# ]
```

### Step 4: 查詢供應商

```bash
# 以統一編號查詢供應商
etl_search_supplier "27590900"

# 輸出：
# ✓ 查詢成功，共找到 3 筆供應商資料
```

### Step 5: 查詢會計科目

```bash
# 以關鍵字查詢會計科目
etl_search_account_title --name "損益"

# 輸出：
# ✓ 查詢成功，共找到 3 筆會計科目
```

### Step 6: 查詢帳款類別

```bash
# 以類別名稱查詢
etl_search_payment_type --name "預付"

# 輸出：
# ✓ 查詢成功，共找到 3 筆帳款類別
```

### Step 7: 批次查詢腳本

```bash
#!/bin/bash
# batch-query.sh - 批次查詢腳本

source ./scripts/bash/etl-master-data.sh

echo "=== ETL 基本資料批次查詢 ==="
echo ""

# 登入
etl_get_token
echo ""

# 查詢員工
echo "--- 員工資料 ---"
etl_search_employee --name "王" > employees.json
echo ""

# 查詢供應商
echo "--- 供應商資料 ---"
etl_search_supplier "27590900" > suppliers.json
echo ""

# 查詢會計科目
echo "--- 會計科目 ---"
etl_search_account_title --code "111" > accounts.json
echo ""

echo "✓ 批次查詢完成，結果已儲存至 JSON 檔案"
```

---

## 錯誤處理範例

### PowerShell 錯誤處理

```powershell
try {
    # 嘗試查詢
    $result = Search-EtlEmployee -EmployeeName "不存在的員工"
    
    if ($result.Count -eq 0) {
        Write-Host "查無資料，請調整查詢條件" -ForegroundColor Yellow
    } else {
        $result | Format-Table -AutoSize
    }
}
catch {
    Write-Host "發生錯誤：$($_.Exception.Message)" -ForegroundColor Red
    
    # 嘗試重新登入
    Write-Host "嘗試重新登入..." -ForegroundColor Yellow
    Get-EtlToken
}
```

### Bash 錯誤處理

```bash
#!/bin/bash

# 查詢並處理錯誤
result=$(etl_search_employee --name "不存在的員工" 2>&1)

if echo "$result" | grep -q "查詢成功"; then
    count=$(echo "$result" | grep -oP '共找到 \K\d+')
    if [ "$count" -eq "0" ]; then
        echo "查無資料，請調整查詢條件"
    else
        echo "$result"
    fi
else
    echo "發生錯誤：$result"
    echo "嘗試重新登入..."
    etl_get_token
fi
```

---

## 進階用法

### 結合 etl-dictionary-api 使用

由於兩個 Skill 共用相同的認證機制，可以在同一個工作階段中交替使用：

```powershell
# 載入兩個模組
. .\etl-dictionary-api\scripts\powershell\etl-dictionary.ps1
. .\etl-master-data-api\scripts\powershell\etl-master-data.ps1

# 登入（只需一次）
Get-EtlToken

# 使用 etl-dictionary-api 查詢資料表定義
Search-EtlTable -Keyword "員工"

# 使用 etl-master-data-api 查詢實際資料
Search-EtlEmployee -EmployeeName "王雅祈"
```

### 定時刷新 Token

```powershell
# 設定定時器每 25 分鐘刷新 Token
$timer = New-Object System.Timers.Timer
$timer.Interval = 25 * 60 * 1000  # 25 分鐘
$timer.AutoReset = $true
$timer.Enabled = $true

Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action {
    Write-Host "$(Get-Date) - 自動刷新 Token..." -ForegroundColor Cyan
    Update-EtlToken
}

Write-Host "Token 自動刷新已啟用（每 25 分鐘）" -ForegroundColor Green
```

---

## 常用查詢速查表

| 查詢類型 | PowerShell | Bash |
|----------|------------|------|
| 員工（編號） | `Search-EtlEmployee -EmployeeId "00063"` | `etl_search_employee --id "00063"` |
| 員工（姓名） | `Search-EtlEmployee -EmployeeName "王"` | `etl_search_employee --name "王"` |
| 供應商 | `Search-EtlSupplier -TaxId "27590900"` | `etl_search_supplier "27590900"` |
| 會計科目（代碼） | `Search-EtlAccountTitle -AccountCode "111"` | `etl_search_account_title --code "111"` |
| 會計科目（名稱） | `Search-EtlAccountTitle -AccountName "損益"` | `etl_search_account_title --name "損益"` |
| 料件（編號） | `Search-EtlMaterial -MaterialId "0101"` | `etl_search_material --id "0101"` |
| 料件（名稱） | `Search-EtlMaterial -MaterialName "紙管"` | `etl_search_material --name "紙管"` |
| 固定資產 | `Search-EtlFixedAsset -AssetName "堆高機"` | `etl_search_fixed_asset --name "堆高機"` |
| 帳款類別 | `Search-EtlPaymentType -TypeName "預付"` | `etl_search_payment_type --name "預付"` |
