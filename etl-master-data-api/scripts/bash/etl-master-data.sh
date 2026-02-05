#!/bin/bash
# ==============================================================================
# ETL 基本資料查詢 API Bash 工具模組
# ==============================================================================
# 
# 提供 ETL 基本資料查詢 API 的 Bash 函數，包含：
# - Token 管理（登入、刷新、自動過期檢查）
# - 員工資料查詢
# - 供應商查詢
# - 會計科目查詢
# - 料件查詢
# - 固定資產查詢
# - 帳款類別查詢
# - 客戶查詢
# - 匯率查詢
# - 部門列表
# - 銷售分類列表
# - 專案編號列表
# - 到達起運地列表
# - 貿易條件列表
# - 銀行列表
# - 幣別列表
# - 稅別列表
# - 收款條件列表
# - 銷售單位列表
#
# 需設定環境變數：
# - ETL_USERNAME: 登入帳號
# - ETL_PASSWORD: 登入密碼
# - ETL_API_BASE_URL: (選用) API 基礎 URL
#
# 使用方式：
#   source ./etl-master-data.sh
#   etl_get_token
#   etl_search_employee --name "王雅祈"
#   etl_search_customer --name "大豐"
#   etl_get_department
# ==============================================================================

# 預設 API URL
ETL_API_BASE_URL="${ETL_API_BASE_URL:-https://zpos-api-stage.zerozero.com.tw}"

# ==============================================================================
# 輔助函數
# ==============================================================================

# 檢查必要環境變數
etl_check_config() {
    if [ -z "$ETL_USERNAME" ]; then
        echo "✗ 錯誤：請設定環境變數 ETL_USERNAME" >&2
        return 1
    fi
    
    if [ -z "$ETL_PASSWORD" ]; then
        echo "✗ 錯誤：請設定環境變數 ETL_PASSWORD" >&2
        return 1
    fi
    
    return 0
}

# 檢查 jq 是否已安裝
etl_check_jq() {
    if ! command -v jq &> /dev/null; then
        echo "✗ 錯誤：需要安裝 jq 工具" >&2
        echo "  Ubuntu/Debian: sudo apt-get install jq" >&2
        echo "  macOS: brew install jq" >&2
        return 1
    fi
    return 0
}

# ==============================================================================
# Token 管理函數
# ==============================================================================

# 登入取得 Token
etl_get_token() {
    etl_check_config || return 1
    etl_check_jq || return 1
    
    local response
    response=$(curl -s -X POST "$ETL_API_BASE_URL/api/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\": \"$ETL_USERNAME\", \"password\": \"$ETL_PASSWORD\"}")
    
    local access_token refresh_token
    access_token=$(echo "$response" | jq -r '.accessToken // empty')
    refresh_token=$(echo "$response" | jq -r '.refreshToken // empty')
    
    if [ -n "$access_token" ] && [ "$access_token" != "null" ]; then
        export ETL_ACCESS_TOKEN="$access_token"
        export ETL_REFRESH_TOKEN="$refresh_token"
        export ETL_TOKEN_EXPIRES=$(($(date +%s) + 1800))  # 30 分鐘後過期
        echo "✓ 登入成功，Token 將於 30 分鐘後過期"
        return 0
    else
        echo "✗ 登入失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 刷新 Token
etl_update_token() {
    etl_check_jq || return 1
    
    if [ -z "$ETL_REFRESH_TOKEN" ]; then
        echo "✗ 無 Refresh Token，請重新登入" >&2
        etl_get_token
        return $?
    fi
    
    local response
    response=$(curl -s -X POST "$ETL_API_BASE_URL/api/auth/refresh" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN" \
        -d "{\"refreshToken\": \"$ETL_REFRESH_TOKEN\"}")
    
    local access_token refresh_token
    access_token=$(echo "$response" | jq -r '.accessToken // empty')
    refresh_token=$(echo "$response" | jq -r '.refreshToken // empty')
    
    if [ -n "$access_token" ] && [ "$access_token" != "null" ]; then
        export ETL_ACCESS_TOKEN="$access_token"
        export ETL_REFRESH_TOKEN="$refresh_token"
        export ETL_TOKEN_EXPIRES=$(($(date +%s) + 1800))
        echo "✓ Token 刷新成功"
        return 0
    else
        echo "✗ Token 刷新失敗，嘗試重新登入..." >&2
        etl_get_token
        return $?
    fi
}

# 檢查 Token 是否過期
etl_check_token_expiry() {
    if [ -z "$ETL_ACCESS_TOKEN" ]; then
        echo "尚未登入，正在登入..."
        etl_get_token
        return $?
    fi
    
    if [ -n "$ETL_TOKEN_EXPIRES" ]; then
        local current_time
        current_time=$(date +%s)
        if [ "$current_time" -ge "$ETL_TOKEN_EXPIRES" ]; then
            echo "Token 已過期，正在刷新..."
            etl_update_token
            return $?
        fi
    fi
    
    return 0
}

# ==============================================================================
# 查詢函數
# ==============================================================================

# 查詢員工資料
# 用法: etl_search_employee [--id <編號>] [--name <姓名>]
etl_search_employee() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local employee_id="" employee_name=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --id) employee_id="$2"; shift 2 ;;
            --name) employee_name="$2"; shift 2 ;;
            *) echo "未知參數: $1" >&2; return 1 ;;
        esac
    done
    
    if [ -z "$employee_id" ] && [ -z "$employee_name" ]; then
        echo "✗ 請至少提供一個查詢參數 (--id 或 --name)" >&2
        return 1
    fi
    
    # 建立 JSON body
    local json_body="{}"
    [ -n "$employee_id" ] && json_body=$(echo "$json_body" | jq --arg v "$employee_id" '. + {gen01: $v}')
    [ -n "$employee_name" ] && json_body=$(echo "$json_body" | jq --arg v "$employee_name" '. + {gen02: $v}')
    
    local response
    response=$(curl -s -X POST "$ETL_API_BASE_URL/api/etl/employee/search" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN" \
        -d "$json_body")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆員工資料"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 查詢供應商
# 用法: etl_search_supplier <統一編號>
etl_search_supplier() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local tax_id="$1"
    
    if [ -z "$tax_id" ]; then
        echo "✗ 請提供統一編號" >&2
        echo "用法: etl_search_supplier <統一編號>" >&2
        return 1
    fi
    
    local response
    response=$(curl -s -X POST "$ETL_API_BASE_URL/api/etl/supplier/search" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN" \
        -d "{\"pmc24\": \"$tax_id\"}")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆供應商資料"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 查詢會計科目
# 用法: etl_search_account_title [--code <代碼>] [--name <名稱>]
etl_search_account_title() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local account_code="" account_name=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --code) account_code="$2"; shift 2 ;;
            --name) account_name="$2"; shift 2 ;;
            *) echo "未知參數: $1" >&2; return 1 ;;
        esac
    done
    
    if [ -z "$account_code" ] && [ -z "$account_name" ]; then
        echo "✗ 請至少提供一個查詢參數 (--code 或 --name)" >&2
        return 1
    fi
    
    local json_body="{}"
    [ -n "$account_code" ] && json_body=$(echo "$json_body" | jq --arg v "$account_code" '. + {aag01: $v}')
    [ -n "$account_name" ] && json_body=$(echo "$json_body" | jq --arg v "$account_name" '. + {aag02: $v}')
    
    local response
    response=$(curl -s -X POST "$ETL_API_BASE_URL/api/etl/account-title/search" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN" \
        -d "$json_body")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆會計科目"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 查詢料件
# 用法: etl_search_material [--id <編號>] [--name <名稱>]
etl_search_material() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local material_id="" material_name=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --id) material_id="$2"; shift 2 ;;
            --name) material_name="$2"; shift 2 ;;
            *) echo "未知參數: $1" >&2; return 1 ;;
        esac
    done
    
    if [ -z "$material_id" ] && [ -z "$material_name" ]; then
        echo "✗ 請至少提供一個查詢參數 (--id 或 --name)" >&2
        return 1
    fi
    
    local json_body="{}"
    [ -n "$material_id" ] && json_body=$(echo "$json_body" | jq --arg v "$material_id" '. + {ima01: $v}')
    [ -n "$material_name" ] && json_body=$(echo "$json_body" | jq --arg v "$material_name" '. + {ima02: $v}')
    
    local response
    response=$(curl -s -X POST "$ETL_API_BASE_URL/api/etl/material/search" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN" \
        -d "$json_body")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆料件資料"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 查詢固定資產
# 用法: etl_search_fixed_asset [--id <編號>] [--name <名稱>]
etl_search_fixed_asset() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local asset_id="" asset_name=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --id) asset_id="$2"; shift 2 ;;
            --name) asset_name="$2"; shift 2 ;;
            *) echo "未知參數: $1" >&2; return 1 ;;
        esac
    done
    
    if [ -z "$asset_id" ] && [ -z "$asset_name" ]; then
        echo "✗ 請至少提供一個查詢參數 (--id 或 --name)" >&2
        return 1
    fi
    
    local json_body="{}"
    [ -n "$asset_id" ] && json_body=$(echo "$json_body" | jq --arg v "$asset_id" '. + {faj02: $v}')
    [ -n "$asset_name" ] && json_body=$(echo "$json_body" | jq --arg v "$asset_name" '. + {faj06: $v}')
    
    local response
    response=$(curl -s -X POST "$ETL_API_BASE_URL/api/etl/fixed-asset/search" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN" \
        -d "$json_body")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆固定資產"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 查詢帳款類別
# 用法: etl_search_payment_type [--code <代碼>] [--name <名稱>]
etl_search_payment_type() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local type_code="" type_name=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --code) type_code="$2"; shift 2 ;;
            --name) type_name="$2"; shift 2 ;;
            *) echo "未知參數: $1" >&2; return 1 ;;
        esac
    done
    
    if [ -z "$type_code" ] && [ -z "$type_name" ]; then
        echo "✗ 請至少提供一個查詢參數 (--code 或 --name)" >&2
        return 1
    fi
    
    local json_body="{}"
    [ -n "$type_code" ] && json_body=$(echo "$json_body" | jq --arg v "$type_code" '. + {apr01: $v}')
    [ -n "$type_name" ] && json_body=$(echo "$json_body" | jq --arg v "$type_name" '. + {apr02: $v}')
    
    local response
    response=$(curl -s -X POST "$ETL_API_BASE_URL/api/etl/payment-type/search" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN" \
        -d "$json_body")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆帳款類別"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 查詢客戶資料
# 用法: etl_search_customer [--id <代號>] [--name <名稱>]
etl_search_customer() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local customer_id="" customer_name=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --id) customer_id="$2"; shift 2 ;;
            --name) customer_name="$2"; shift 2 ;;
            *) echo "未知參數: $1" >&2; return 1 ;;
        esac
    done
    
    if [ -z "$customer_id" ] && [ -z "$customer_name" ]; then
        echo "✗ 請至少提供一個查詢參數 (--id 或 --name)" >&2
        return 1
    fi
    
    local json_body="{}"
    [ -n "$customer_id" ] && json_body=$(echo "$json_body" | jq --arg v "$customer_id" '. + {occ01: $v}')
    [ -n "$customer_name" ] && json_body=$(echo "$json_body" | jq --arg v "$customer_name" '. + {occ02: $v}')
    
    local response
    response=$(curl -s -X POST "$ETL_API_BASE_URL/api/etl/customer/search" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN" \
        -d "$json_body")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆客戶資料"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 查詢匯率資料
# 用法: etl_search_exchange_rate <日期 YYYY-MM-DD>
etl_search_exchange_rate() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local date="$1"
    
    if [ -z "$date" ]; then
        echo "✗ 請提供匯率日期 (格式：YYYY-MM-DD)" >&2
        echo "用法: etl_search_exchange_rate <日期>" >&2
        return 1
    fi
    
    local response
    response=$(curl -s -X POST "$ETL_API_BASE_URL/api/etl/exchange-rate/search" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN" \
        -d "{\"azk02\": \"$date\"}")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆匯率資料"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# ==============================================================================
# GET 列表函數
# ==============================================================================

# 取得部門列表
# 用法: etl_get_department
etl_get_department() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local response
    response=$(curl -s -X GET "$ETL_API_BASE_URL/api/etl/department" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆部門資料"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 取得銷售分類列表
# 用法: etl_get_sales_category
etl_get_sales_category() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local response
    response=$(curl -s -X GET "$ETL_API_BASE_URL/api/etl/sales-category" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆銷售分類"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 取得專案編號列表
# 用法: etl_get_project
etl_get_project() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local response
    response=$(curl -s -X GET "$ETL_API_BASE_URL/api/etl/project" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆專案資料"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 取得到達起運地列表
# 用法: etl_get_shipping_destination
etl_get_shipping_destination() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local response
    response=$(curl -s -X GET "$ETL_API_BASE_URL/api/etl/shipping-destination" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆起運地資料"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 取得貿易條件列表
# 用法: etl_get_trade_condition
etl_get_trade_condition() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local response
    response=$(curl -s -X GET "$ETL_API_BASE_URL/api/etl/trade-condition" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆貿易條件"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 取得銀行列表
# 用法: etl_get_bank
etl_get_bank() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local response
    response=$(curl -s -X GET "$ETL_API_BASE_URL/api/etl/bank" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆銀行資料"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 取得幣別列表
# 用法: etl_get_currency
etl_get_currency() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local response
    response=$(curl -s -X GET "$ETL_API_BASE_URL/api/etl/currency" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆幣別資料"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 取得稅別列表
# 用法: etl_get_tax_type
etl_get_tax_type() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local response
    response=$(curl -s -X GET "$ETL_API_BASE_URL/api/etl/tax-type" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆稅別資料"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 取得收款條件列表
# 用法: etl_get_payment_term
etl_get_payment_term() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local response
    response=$(curl -s -X GET "$ETL_API_BASE_URL/api/etl/payment-term" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆收款條件"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# 取得銷售單位列表
# 用法: etl_get_sales_unit
etl_get_sales_unit() {
    etl_check_token_expiry || return 1
    etl_check_jq || return 1
    
    local response
    response=$(curl -s -X GET "$ETL_API_BASE_URL/api/etl/sales-unit" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ETL_ACCESS_TOKEN")
    
    local success count
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" = "true" ]; then
        count=$(echo "$response" | jq '.data | length')
        echo "✓ 查詢成功，共找到 $count 筆銷售單位"
        echo "$response" | jq '.data'
    else
        echo "✗ 查詢失敗" >&2
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi
}

# ==============================================================================
# 說明函數
# ==============================================================================

etl_master_data_help() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════╗
║           ETL 基本資料查詢 API Bash 工具模組                     ║
╠══════════════════════════════════════════════════════════════════╣
║ 環境變數設定：                                                   ║
║   export ETL_USERNAME="your_username"                            ║
║   export ETL_PASSWORD="your_password"                            ║
╠══════════════════════════════════════════════════════════════════╣
║ 可用函數：                                                       ║
║                                                                  ║
║ 【認證管理】                                                     ║
║   etl_get_token          - 登入取得 Token                        ║
║   etl_update_token       - 刷新 Token                            ║
║   etl_check_token_expiry - 檢查 Token 是否過期                   ║
║                                                                  ║
║ 【資料查詢 (POST)】                                              ║
║   etl_search_employee    - 查詢員工資料                          ║
║     --id <編號>  --name <姓名>                                   ║
║                                                                  ║
║   etl_search_supplier    - 查詢供應商                            ║
║     <統一編號>                                                   ║
║                                                                  ║
║   etl_search_account_title - 查詢會計科目                        ║
║     --code <代碼>  --name <名稱>                                 ║
║                                                                  ║
║   etl_search_material    - 查詢料件                              ║
║     --id <編號>  --name <名稱>                                   ║
║                                                                  ║
║   etl_search_fixed_asset - 查詢固定資產                          ║
║     --id <編號>  --name <名稱>                                   ║
║                                                                  ║
║   etl_search_payment_type - 查詢帳款類別                         ║
║     --code <代碼>  --name <名稱>                                 ║
║                                                                  ║
║   etl_search_customer    - 查詢客戶資料                          ║
║     --id <代號>  --name <名稱>                                   ║
║                                                                  ║
║   etl_search_exchange_rate - 查詢匯率                            ║
║     <日期 YYYY-MM-DD>                                            ║
║                                                                  ║
║ 【資料列表 (GET)】                                               ║
║   etl_get_department         - 取得部門列表                      ║
║   etl_get_sales_category     - 取得銷售分類列表                  ║
║   etl_get_project            - 取得專案編號列表                  ║
║   etl_get_shipping_destination - 取得到達起運地列表              ║
║   etl_get_trade_condition    - 取得貿易條件列表                  ║
║   etl_get_bank               - 取得銀行列表                      ║
║   etl_get_currency           - 取得幣別列表                      ║
║   etl_get_tax_type           - 取得稅別列表                      ║
║   etl_get_payment_term       - 取得收款條件列表                  ║
║   etl_get_sales_unit         - 取得銷售單位列表                  ║
╚══════════════════════════════════════════════════════════════════╝
EOF
}

# 模組載入訊息
echo "ETL 基本資料查詢模組已載入 (18 種查詢功能)。輸入 etl_master_data_help 查看使用說明。"
