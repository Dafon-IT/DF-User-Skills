<#
.SYNOPSIS
    AnythingLLM User API PowerShell 工具函數

.DESCRIPTION
    提供 AnythingLLM API 使用者級操作的 PowerShell 函數集合。
    包含 Workspace 查詢、Thread 管理和對話功能。

.NOTES
    需要設定環境變數:
    - ANYTHINGLLM_API_KEY: API 認證金鑰 (必要)
    - ANYTHINGLLM_BASE_URL: API 基礎 URL (必要，由管理員提供)

.EXAMPLE
    # 載入模組
    . .\anythingllm-user.ps1
    
    # 設定環境變數
    $env:ANYTHINGLLM_API_KEY = "your-api-key"
    $env:ANYTHINGLLM_BASE_URL = "https://your-server.com/api/v1"
    
    # 使用函數
    Get-AllmWorkspaces
#>

# 確保 UTF-8 編碼
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

#region Configuration

function Get-AllmConfig {
    <#
    .SYNOPSIS
        取得 AnythingLLM API 設定
    #>
    $apiKey = $env:ANYTHINGLLM_API_KEY
    $baseUrl = $env:ANYTHINGLLM_BASE_URL

    if (-not $apiKey) {
        throw "環境變數 ANYTHINGLLM_API_KEY 未設定。請向管理員取得 API Key 並執行: `$env:ANYTHINGLLM_API_KEY = 'your-api-key'"
    }

    if (-not $baseUrl) {
        throw "環境變數 ANYTHINGLLM_BASE_URL 未設定。請向管理員取得 API URL 並執行: `$env:ANYTHINGLLM_BASE_URL = 'https://your-server.com/api/v1'"
    }

    return @{
        ApiKey  = $apiKey
        BaseUrl = $baseUrl
        Headers = @{
            "Accept"        = "application/json"
            "Content-Type"  = "application/json; charset=utf-8"
            "Authorization" = "Bearer $apiKey"
        }
    }
}

#endregion

#region Workspace Functions

function Get-AllmWorkspaces {
    <#
    .SYNOPSIS
        取得所有 Workspaces

    .EXAMPLE
        Get-AllmWorkspaces
    #>
    $config = Get-AllmConfig
    $url = "$($config.BaseUrl)/workspaces"

    try {
        $response = Invoke-RestMethod -Uri $url -Method GET -Headers $config.Headers
        return $response.workspaces
    }
    catch {
        Write-Host "✗ 取得 Workspaces 失敗: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

#endregion

#region Thread Functions

function New-AllmThread {
    <#
    .SYNOPSIS
        在指定 Workspace 中建立新的 Thread

    .PARAMETER WorkspaceSlug
        Workspace 的 slug

    .PARAMETER Name
        Thread 顯示名稱

    .PARAMETER ThreadSlug
        Thread 的自訂 slug

    .EXAMPLE
        New-AllmThread -WorkspaceSlug "my-workspace" -Name "User A Thread" -ThreadSlug "ext-user-a"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspaceSlug,

        [Parameter(Mandatory = $false)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string]$ThreadSlug
    )

    $config = Get-AllmConfig
    $url = "$($config.BaseUrl)/workspace/$WorkspaceSlug/thread/new"
    
    $bodyObj = @{}
    if ($Name) { $bodyObj.name = $Name }
    if ($ThreadSlug) { $bodyObj.slug = $ThreadSlug }
    
    $body = $bodyObj | ConvertTo-Json -Compress

    try {
        $response = Invoke-RestMethod -Uri $url -Method POST -Headers $config.Headers -Body $body
        Write-Host "✓ Thread 建立成功" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Host "✗ 建立 Thread 失敗: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

function Remove-AllmThread {
    <#
    .SYNOPSIS
        刪除指定的 Thread

    .PARAMETER WorkspaceSlug
        Workspace 的 slug

    .PARAMETER ThreadSlug
        Thread 的 slug

    .EXAMPLE
        Remove-AllmThread -WorkspaceSlug "my-workspace" -ThreadSlug "ext-user-a"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspaceSlug,

        [Parameter(Mandatory = $true)]
        [string]$ThreadSlug
    )

    $config = Get-AllmConfig
    $url = "$($config.BaseUrl)/workspace/$WorkspaceSlug/thread/$ThreadSlug"

    try {
        $response = Invoke-RestMethod -Uri $url -Method DELETE -Headers $config.Headers
        Write-Host "✓ Thread '$ThreadSlug' 刪除成功" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Host "✗ 刪除 Thread 失敗: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

#endregion

#region Chat Functions

function Send-AllmChat {
    <#
    .SYNOPSIS
        發送對話訊息

    .PARAMETER WorkspaceSlug
        Workspace 的 slug

    .PARAMETER ThreadSlug
        Thread 的 slug

    .PARAMETER Message
        訊息內容

    .PARAMETER Mode
        對話模式，預設 "chat"

    .EXAMPLE
        Send-AllmChat -WorkspaceSlug "my-workspace" -ThreadSlug "ext-user-a" -Message "你好"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspaceSlug,

        [Parameter(Mandatory = $true)]
        [string]$ThreadSlug,

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$Mode = "chat"
    )

    $config = Get-AllmConfig
    $url = "$($config.BaseUrl)/workspace/$WorkspaceSlug/thread/$ThreadSlug/chat"
    $body = @{
        message = $Message
        mode    = $Mode
    } | ConvertTo-Json -Compress

    try {
        $response = Invoke-RestMethod -Uri $url -Method POST -Headers $config.Headers -Body $body
        return $response
    }
    catch {
        Write-Host "✗ 發送訊息失敗: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

function Send-AllmStreamChat {
    <#
    .SYNOPSIS
        發送串流對話訊息 (打字機效果)

    .PARAMETER WorkspaceSlug
        Workspace 的 slug

    .PARAMETER ThreadSlug
        Thread 的 slug

    .PARAMETER Message
        訊息內容

    .PARAMETER Mode
        對話模式，預設 "chat"

    .EXAMPLE
        Send-AllmStreamChat -WorkspaceSlug "my-workspace" -ThreadSlug "ext-user-a" -Message "請介紹自己"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspaceSlug,

        [Parameter(Mandatory = $true)]
        [string]$ThreadSlug,

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$Mode = "chat"
    )

    $config = Get-AllmConfig
    $url = "$($config.BaseUrl)/workspace/$WorkspaceSlug/thread/$ThreadSlug/stream-chat"
    
    $body = @{
        message = $Message
        mode    = $Mode
    } | ConvertTo-Json -Compress

    # 使用 curl 處理 SSE 串流
    $curlCmd = "curl.exe -N -s -X POST `"$url`" -H `"Accept: text/event-stream`" -H `"Content-Type: application/json; charset=utf-8`" -H `"Authorization: Bearer $($config.ApiKey)`" -d '$body'"
    
    Write-Host "回應: " -NoNewline
    Invoke-Expression $curlCmd | ForEach-Object {
        if ($_ -match '^data: (.+)$') {
            $data = $Matches[1] | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($data.textResponse) {
                Write-Host $data.textResponse -NoNewline
            }
        }
    }
    Write-Host ""
}

#endregion

#region Utility Functions

function Test-AllmConnection {
    <#
    .SYNOPSIS
        測試 API 連線

    .EXAMPLE
        Test-AllmConnection
    #>
    try {
        $workspaces = Get-AllmWorkspaces
        Write-Host "✓ API 連線成功" -ForegroundColor Green
        Write-Host "  找到 $($workspaces.Count) 個 Workspace(s)" -ForegroundColor Cyan
        return $true
    }
    catch {
        Write-Host "✗ API 連線失敗: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

#endregion

# 匯出函數
Export-ModuleMember -Function @(
    'Get-AllmConfig',
    'Get-AllmWorkspaces',
    'New-AllmThread',
    'Remove-AllmThread',
    'Send-AllmChat',
    'Send-AllmStreamChat',
    'Test-AllmConnection'
) -ErrorAction SilentlyContinue

Write-Host "AnythingLLM User API PowerShell 工具已載入" -ForegroundColor Cyan
Write-Host "使用 Test-AllmConnection 測試連線" -ForegroundColor Gray

