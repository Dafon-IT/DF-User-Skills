<#
.SYNOPSIS
    ETL 基本資料查詢 API PowerShell 工具模組

.DESCRIPTION
    提供 ETL 基本資料查詢 API 的 PowerShell 函數，包含：
    - Token 管理（登入、刷新、自動過期檢查）
    - 員工資料查詢
    - 供應商查詢
    - 會計科目查詢
    - 料件查詢
    - 固定資產查詢
    - 帳款類別查詢
    - 客戶查詢
    - 匯率查詢
    - 部門列表
    - 銷售分類列表
    - 專案編號列表
    - 到達起運地列表
    - 貿易條件列表
    - 銀行列表
    - 幣別列表
    - 稅別列表
    - 收款條件列表
    - 銷售單位列表

.NOTES
    需設定環境變數：
    - ETL_USERNAME: 登入帳號
    - ETL_PASSWORD: 登入密碼
    - ETL_API_BASE_URL: (選用) API 基礎 URL

.EXAMPLE
    # 載入模組
    . .\etl-master-data.ps1

    # 登入
    Get-EtlToken

    # 查詢員工
    Search-EtlEmployee -EmployeeName "王雅祈"
    
    # 查詢客戶
    Search-EtlCustomer -CustomerName "大豐"
    
    # 取得部門列表
    Get-EtlDepartment
#>

# UTF-8 編碼設定
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

#region Configuration

function Get-EtlConfig {
    <#
    .SYNOPSIS
        取得 ETL API 設定
    #>
    return @{
        BaseUrl = if ($env:ETL_API_BASE_URL) { $env:ETL_API_BASE_URL } else { "https://zpos-api-stage.zerozero.com.tw" }
        Username = $env:ETL_USERNAME
        Password = $env:ETL_PASSWORD
        AccessToken = $env:ETL_ACCESS_TOKEN
        RefreshToken = $env:ETL_REFRESH_TOKEN
        TokenExpires = $env:ETL_TOKEN_EXPIRES
    }
}

function Test-EtlConfig {
    <#
    .SYNOPSIS
        檢查必要環境變數是否已設定
    #>
    $config = Get-EtlConfig
    
    if (-not $config.Username) {
        Write-Host "✗ 錯誤：請設定環境變數 ETL_USERNAME" -ForegroundColor Red
        return $false
    }
    
    if (-not $config.Password) {
        Write-Host "✗ 錯誤：請設定環境變數 ETL_PASSWORD" -ForegroundColor Red
        return $false
    }
    
    return $true
}

#endregion

#region Token Functions

function Get-EtlToken {
    <#
    .SYNOPSIS
        登入取得 Token
    .DESCRIPTION
        使用帳號密碼登入，取得 Access Token 與 Refresh Token，
        並自動設定環境變數 ETL_ACCESS_TOKEN、ETL_REFRESH_TOKEN、ETL_TOKEN_EXPIRES
    .EXAMPLE
        Get-EtlToken
    #>
    
    if (-not (Test-EtlConfig)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/auth/login"
    
    $body = @{
        username = $config.Username
        password = $config.Password
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method POST `
            -ContentType "application/json; charset=utf-8" `
            -Body $body
        
        $env:ETL_ACCESS_TOKEN = $response.accessToken
        $env:ETL_REFRESH_TOKEN = $response.refreshToken
        $env:ETL_TOKEN_EXPIRES = [DateTimeOffset]::Now.AddMinutes(30).ToUnixTimeSeconds()
        
        Write-Host "✓ 登入成功，Token 將於 30 分鐘後過期" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ 登入失敗：$($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Update-EtlToken {
    <#
    .SYNOPSIS
        使用 Refresh Token 更新 Access Token
    .EXAMPLE
        Update-EtlToken
    #>
    
    $config = Get-EtlConfig
    
    if (-not $config.RefreshToken) {
        Write-Host "✗ 無 Refresh Token，請重新登入" -ForegroundColor Red
        return Get-EtlToken
    }
    
    $url = "$($config.BaseUrl)/api/auth/refresh"
    
    $body = @{
        refreshToken = $config.RefreshToken
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method POST `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" } `
            -Body $body
        
        $env:ETL_ACCESS_TOKEN = $response.accessToken
        $env:ETL_REFRESH_TOKEN = $response.refreshToken
        $env:ETL_TOKEN_EXPIRES = [DateTimeOffset]::Now.AddMinutes(30).ToUnixTimeSeconds()
        
        Write-Host "✓ Token 刷新成功" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ Token 刷新失敗，嘗試重新登入..." -ForegroundColor Yellow
        return Get-EtlToken
    }
}

function Test-EtlTokenExpiry {
    <#
    .SYNOPSIS
        檢查 Token 是否過期，若過期則自動刷新
    .EXAMPLE
        Test-EtlTokenExpiry
    #>
    
    $config = Get-EtlConfig
    
    if (-not $config.AccessToken) {
        Write-Host "尚未登入，正在登入..." -ForegroundColor Yellow
        return Get-EtlToken
    }
    
    if ($config.TokenExpires) {
        $currentTime = [DateTimeOffset]::Now.ToUnixTimeSeconds()
        if ($currentTime -ge [long]$config.TokenExpires) {
            Write-Host "Token 已過期，正在刷新..." -ForegroundColor Yellow
            return Update-EtlToken
        }
    }
    
    return $true
}

#endregion

#region Search Functions

function Search-EtlEmployee {
    <#
    .SYNOPSIS
        查詢員工資料
    .PARAMETER EmployeeId
        員工編號 (gen01)
    .PARAMETER EmployeeName
        員工姓名 (gen02)
    .EXAMPLE
        Search-EtlEmployee -EmployeeId "00063"
        Search-EtlEmployee -EmployeeName "王雅祈"
    #>
    param(
        [string]$EmployeeId,
        [string]$EmployeeName
    )
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/employee/search"
    
    $body = @{}
    if ($EmployeeId) { $body.gen01 = $EmployeeId }
    if ($EmployeeName) { $body.gen02 = $EmployeeName }
    
    if ($body.Count -eq 0) {
        Write-Host "✗ 請至少提供一個查詢參數" -ForegroundColor Red
        return
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method POST `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" } `
            -Body ($body | ConvertTo-Json)
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆員工資料" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Search-EtlSupplier {
    <#
    .SYNOPSIS
        查詢供應商資料
    .PARAMETER TaxId
        統一編號 (pmc24)
    .EXAMPLE
        Search-EtlSupplier -TaxId "27590900"
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$TaxId
    )
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/supplier/search"
    
    $body = @{
        pmc24 = $TaxId
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method POST `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" } `
            -Body $body
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆供應商資料" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Search-EtlAccountTitle {
    <#
    .SYNOPSIS
        查詢會計科目
    .PARAMETER AccountCode
        科目代碼 (aag01)
    .PARAMETER AccountName
        科目名稱 (aag02)
    .EXAMPLE
        Search-EtlAccountTitle -AccountCode "9110"
        Search-EtlAccountTitle -AccountName "損益"
    #>
    param(
        [string]$AccountCode,
        [string]$AccountName
    )
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/account-title/search"
    
    $body = @{}
    if ($AccountCode) { $body.aag01 = $AccountCode }
    if ($AccountName) { $body.aag02 = $AccountName }
    
    if ($body.Count -eq 0) {
        Write-Host "✗ 請至少提供一個查詢參數" -ForegroundColor Red
        return
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method POST `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" } `
            -Body ($body | ConvertTo-Json)
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆會計科目" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Search-EtlMaterial {
    <#
    .SYNOPSIS
        查詢料件資料
    .PARAMETER MaterialId
        料件編號 (ima01)
    .PARAMETER MaterialName
        料件名稱 (ima02)
    .EXAMPLE
        Search-EtlMaterial -MaterialId "0101003001"
        Search-EtlMaterial -MaterialName "紙管"
    #>
    param(
        [string]$MaterialId,
        [string]$MaterialName
    )
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/material/search"
    
    $body = @{}
    if ($MaterialId) { $body.ima01 = $MaterialId }
    if ($MaterialName) { $body.ima02 = $MaterialName }
    
    if ($body.Count -eq 0) {
        Write-Host "✗ 請至少提供一個查詢參數" -ForegroundColor Red
        return
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method POST `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" } `
            -Body ($body | ConvertTo-Json)
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆料件資料" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Search-EtlFixedAsset {
    <#
    .SYNOPSIS
        查詢固定資產
    .PARAMETER AssetId
        資產編號 (faj02)
    .PARAMETER AssetName
        資產名稱 (faj06)
    .EXAMPLE
        Search-EtlFixedAsset -AssetId "AB"
        Search-EtlFixedAsset -AssetName "堆高機"
    #>
    param(
        [string]$AssetId,
        [string]$AssetName
    )
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/fixed-asset/search"
    
    $body = @{}
    if ($AssetId) { $body.faj02 = $AssetId }
    if ($AssetName) { $body.faj06 = $AssetName }
    
    if ($body.Count -eq 0) {
        Write-Host "✗ 請至少提供一個查詢參數" -ForegroundColor Red
        return
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method POST `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" } `
            -Body ($body | ConvertTo-Json)
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆固定資產" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Search-EtlPaymentType {
    <#
    .SYNOPSIS
        查詢帳款類別
    .PARAMETER TypeCode
        類別代碼 (apr01)
    .PARAMETER TypeName
        類別名稱 (apr02)
    .EXAMPLE
        Search-EtlPaymentType -TypeCode "01"
        Search-EtlPaymentType -TypeName "預付"
    #>
    param(
        [string]$TypeCode,
        [string]$TypeName
    )
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/payment-type/search"
    
    $body = @{}
    if ($TypeCode) { $body.apr01 = $TypeCode }
    if ($TypeName) { $body.apr02 = $TypeName }
    
    if ($body.Count -eq 0) {
        Write-Host "✗ 請至少提供一個查詢參數" -ForegroundColor Red
        return
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method POST `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" } `
            -Body ($body | ConvertTo-Json)
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆帳款類別" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Search-EtlCustomer {
    <#
    .SYNOPSIS
        查詢客戶資料
    .PARAMETER CustomerId
        客戶代號 (occ01)
    .PARAMETER CustomerName
        客戶名稱 (occ02)
    .EXAMPLE
        Search-EtlCustomer -CustomerId "C001"
        Search-EtlCustomer -CustomerName "大豐"
    #>
    param(
        [string]$CustomerId,
        [string]$CustomerName
    )
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/customer/search"
    
    $body = @{}
    if ($CustomerId) { $body.occ01 = $CustomerId }
    if ($CustomerName) { $body.occ02 = $CustomerName }
    
    if ($body.Count -eq 0) {
        Write-Host "✗ 請至少提供一個查詢參數" -ForegroundColor Red
        return
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method POST `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" } `
            -Body ($body | ConvertTo-Json)
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆客戶資料" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Search-EtlExchangeRate {
    <#
    .SYNOPSIS
        查詢匯率資料
    .PARAMETER Date
        匯率日期 (azk02)，格式：YYYY-MM-DD
    .EXAMPLE
        Search-EtlExchangeRate -Date "2025-01-15"
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Date
    )
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/exchange-rate/search"
    
    $body = @{
        azk02 = $Date
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method POST `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" } `
            -Body $body
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆匯率資料" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

#endregion

#region GET List Functions

function Get-EtlDepartment {
    <#
    .SYNOPSIS
        取得部門列表
    .EXAMPLE
        Get-EtlDepartment
    #>
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/department"
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method GET `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" }
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆部門資料" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-EtlSalesCategory {
    <#
    .SYNOPSIS
        取得銷售分類列表
    .EXAMPLE
        Get-EtlSalesCategory
    #>
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/sales-category"
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method GET `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" }
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆銷售分類" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-EtlProject {
    <#
    .SYNOPSIS
        取得專案編號列表
    .EXAMPLE
        Get-EtlProject
    #>
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/project"
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method GET `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" }
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆專案資料" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-EtlShippingDestination {
    <#
    .SYNOPSIS
        取得到達起運地列表
    .EXAMPLE
        Get-EtlShippingDestination
    #>
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/shipping-destination"
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method GET `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" }
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆起運地資料" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-EtlTradeCondition {
    <#
    .SYNOPSIS
        取得貿易條件列表
    .EXAMPLE
        Get-EtlTradeCondition
    #>
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/trade-condition"
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method GET `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" }
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆貿易條件" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-EtlBank {
    <#
    .SYNOPSIS
        取得銀行列表
    .EXAMPLE
        Get-EtlBank
    #>
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/bank"
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method GET `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" }
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆銀行資料" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-EtlCurrency {
    <#
    .SYNOPSIS
        取得幣別列表
    .EXAMPLE
        Get-EtlCurrency
    #>
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/currency"
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method GET `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" }
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆幣別資料" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-EtlTaxType {
    <#
    .SYNOPSIS
        取得稅別列表
    .EXAMPLE
        Get-EtlTaxType
    #>
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/tax-type"
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method GET `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" }
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆稅別資料" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-EtlPaymentTerm {
    <#
    .SYNOPSIS
        取得收款條件列表
    .EXAMPLE
        Get-EtlPaymentTerm
    #>
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/payment-term"
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method GET `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" }
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆收款條件" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-EtlSalesUnit {
    <#
    .SYNOPSIS
        取得銷售單位列表
    .EXAMPLE
        Get-EtlSalesUnit
    #>
    
    if (-not (Test-EtlTokenExpiry)) { return }
    
    $config = Get-EtlConfig
    $url = "$($config.BaseUrl)/api/etl/sales-unit"
    
    try {
        $response = Invoke-RestMethod -Uri $url `
            -Method GET `
            -ContentType "application/json; charset=utf-8" `
            -Headers @{ Authorization = "Bearer $($config.AccessToken)" }
        
        if ($response.success) {
            Write-Host "✓ 查詢成功，共找到 $($response.data.Count) 筆銷售單位" -ForegroundColor Green
            return $response.data
        } else {
            Write-Host "✗ 查詢失敗" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ API 呼叫失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

#endregion

#region Helper Functions

function Show-EtlMasterDataHelp {
    <#
    .SYNOPSIS
        顯示模組使用說明
    #>
    
    $help = @"
╔══════════════════════════════════════════════════════════════════╗
║           ETL 基本資料查詢 API PowerShell 工具模組               ║
╠══════════════════════════════════════════════════════════════════╣
║ 環境變數設定：                                                   ║
║   `$env:ETL_USERNAME = "your_username"                           ║
║   `$env:ETL_PASSWORD = "your_password"                           ║
╠══════════════════════════════════════════════════════════════════╣
║ 可用函數：                                                       ║
║                                                                  ║
║ 【認證管理】                                                     ║
║   Get-EtlToken          - 登入取得 Token                         ║
║   Update-EtlToken       - 刷新 Token                             ║
║   Test-EtlTokenExpiry   - 檢查 Token 是否過期                    ║
║                                                                  ║
║ 【資料查詢 (POST)】                                              ║
║   Search-EtlEmployee    - 查詢員工資料                           ║
║     -EmployeeId <編號>  -EmployeeName <姓名>                     ║
║                                                                  ║
║   Search-EtlSupplier    - 查詢供應商                             ║
║     -TaxId <統一編號>                                            ║
║                                                                  ║
║   Search-EtlAccountTitle - 查詢會計科目                          ║
║     -AccountCode <代碼>  -AccountName <名稱>                     ║
║                                                                  ║
║   Search-EtlMaterial    - 查詢料件                               ║
║     -MaterialId <編號>  -MaterialName <名稱>                     ║
║                                                                  ║
║   Search-EtlFixedAsset  - 查詢固定資產                           ║
║     -AssetId <編號>     -AssetName <名稱>                        ║
║                                                                  ║
║   Search-EtlPaymentType - 查詢帳款類別                           ║
║     -TypeCode <代碼>    -TypeName <名稱>                         ║
║                                                                  ║
║   Search-EtlCustomer    - 查詢客戶資料                           ║
║     -CustomerId <代號>  -CustomerName <名稱>                     ║
║                                                                  ║
║   Search-EtlExchangeRate - 查詢匯率                              ║
║     -Date <日期 YYYY-MM-DD>                                      ║
║                                                                  ║
║ 【資料列表 (GET)】                                               ║
║   Get-EtlDepartment         - 取得部門列表                       ║
║   Get-EtlSalesCategory      - 取得銷售分類列表                   ║
║   Get-EtlProject            - 取得專案編號列表                   ║
║   Get-EtlShippingDestination - 取得到達起運地列表                ║
║   Get-EtlTradeCondition     - 取得貿易條件列表                   ║
║   Get-EtlBank               - 取得銀行列表                       ║
║   Get-EtlCurrency           - 取得幣別列表                       ║
║   Get-EtlTaxType            - 取得稅別列表                       ║
║   Get-EtlPaymentTerm        - 取得收款條件列表                   ║
║   Get-EtlSalesUnit          - 取得銷售單位列表                   ║
╚══════════════════════════════════════════════════════════════════╝
"@
    
    Write-Host $help -ForegroundColor Cyan
}

#endregion

# 模組載入訊息
Write-Host "ETL 基本資料查詢模組已載入 (18 種查詢功能)。輸入 Show-EtlMasterDataHelp 查看使用說明。" -ForegroundColor Cyan
