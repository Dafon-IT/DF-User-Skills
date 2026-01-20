#!/bin/bash
#
# AnythingLLM User API Bash 工具函數
#
# 提供 AnythingLLM API 使用者級操作的 Bash 函數集合。
# 包含 Workspace 查詢、Thread 管理和對話功能。
#
# 需要設定環境變數:
# - ANYTHINGLLM_API_KEY: API 認證金鑰 (必要)
# - ANYTHINGLLM_BASE_URL: API 基礎 URL (必要，由管理員提供)
#
# 使用方式:
#   source ./anythingllm-user.sh
#   export ANYTHINGLLM_API_KEY="your-api-key"
#   export ANYTHINGLLM_BASE_URL="https://your-server.com/api/v1"
#   allm_get_workspaces

#region Configuration

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# 檢查設定
allm_check_config() {
    if [ -z "$ANYTHINGLLM_API_KEY" ]; then
        echo -e "${RED}✗ 環境變數 ANYTHINGLLM_API_KEY 未設定${NC}"
        echo -e "${GRAY}請向管理員取得 API Key 並執行: export ANYTHINGLLM_API_KEY='your-api-key'${NC}"
        return 1
    fi
    if [ -z "$ANYTHINGLLM_BASE_URL" ]; then
        echo -e "${RED}✗ 環境變數 ANYTHINGLLM_BASE_URL 未設定${NC}"
        echo -e "${GRAY}請向管理員取得 API URL 並執行: export ANYTHINGLLM_BASE_URL='https://your-server.com/api/v1'${NC}"
        return 1
    fi
    return 0
}

#endregion

#region Workspace Functions

# 取得所有 Workspaces
# 用法: allm_get_workspaces
allm_get_workspaces() {
    allm_check_config || return 1
    
    local response
    response=$(curl -s -X GET \
        "${ANYTHINGLLM_BASE_URL}/workspaces" \
        -H "Accept: application/json" \
        -H "Authorization: Bearer ${ANYTHINGLLM_API_KEY}")
    
    echo "$response" | jq . 2>/dev/null || echo "$response"
}

#endregion

#region Thread Functions

# 建立新的 Thread
# 用法: allm_new_thread "workspace-slug" "thread-name" "thread-slug"
allm_new_thread() {
    local workspace_slug="$1"
    local name="$2"
    local thread_slug="$3"
    
    if [ -z "$workspace_slug" ]; then
        echo -e "${RED}✗ 請提供 Workspace slug${NC}"
        return 1
    fi
    
    allm_check_config || return 1
    
    local body="{}"
    if [ -n "$name" ] && [ -n "$thread_slug" ]; then
        body="{\"name\": \"${name}\", \"slug\": \"${thread_slug}\"}"
    elif [ -n "$name" ]; then
        body="{\"name\": \"${name}\"}"
    elif [ -n "$thread_slug" ]; then
        body="{\"slug\": \"${thread_slug}\"}"
    fi
    
    local response
    response=$(curl -s -X POST \
        "${ANYTHINGLLM_BASE_URL}/workspace/${workspace_slug}/thread/new" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${ANYTHINGLLM_API_KEY}" \
        -d "$body")
    
    echo -e "${GREEN}✓ Thread 建立成功${NC}"
    echo "$response" | jq . 2>/dev/null || echo "$response"
}

# 刪除指定的 Thread
# 用法: allm_remove_thread "workspace-slug" "thread-slug"
allm_remove_thread() {
    local workspace_slug="$1"
    local thread_slug="$2"
    
    if [ -z "$workspace_slug" ] || [ -z "$thread_slug" ]; then
        echo -e "${RED}✗ 請提供 Workspace slug 和 Thread slug${NC}"
        return 1
    fi
    
    allm_check_config || return 1
    
    local response
    response=$(curl -s -X DELETE \
        "${ANYTHINGLLM_BASE_URL}/workspace/${workspace_slug}/thread/${thread_slug}" \
        -H "Accept: application/json" \
        -H "Authorization: Bearer ${ANYTHINGLLM_API_KEY}")
    
    echo -e "${GREEN}✓ Thread '${thread_slug}' 刪除成功${NC}"
    echo "$response" | jq . 2>/dev/null || echo "$response"
}

#endregion

#region Chat Functions

# 發送對話訊息
# 用法: allm_chat "workspace-slug" "thread-slug" "訊息內容"
allm_chat() {
    local workspace_slug="$1"
    local thread_slug="$2"
    local message="$3"
    local mode="${4:-chat}"
    
    if [ -z "$workspace_slug" ] || [ -z "$thread_slug" ] || [ -z "$message" ]; then
        echo -e "${RED}✗ 請提供 Workspace slug、Thread slug 和訊息${NC}"
        return 1
    fi
    
    allm_check_config || return 1
    
    local response
    response=$(curl -s -X POST \
        "${ANYTHINGLLM_BASE_URL}/workspace/${workspace_slug}/thread/${thread_slug}/chat" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${ANYTHINGLLM_API_KEY}" \
        -d "{\"message\": \"${message}\", \"mode\": \"${mode}\"}")
    
    echo "$response" | jq . 2>/dev/null || echo "$response"
}

# 發送串流對話訊息 (打字機效果)
# 用法: allm_stream_chat "workspace-slug" "thread-slug" "訊息內容"
allm_stream_chat() {
    local workspace_slug="$1"
    local thread_slug="$2"
    local message="$3"
    local mode="${4:-chat}"
    
    if [ -z "$workspace_slug" ] || [ -z "$thread_slug" ] || [ -z "$message" ]; then
        echo -e "${RED}✗ 請提供 Workspace slug、Thread slug 和訊息${NC}"
        return 1
    fi
    
    allm_check_config || return 1
    
    echo -n "回應: "
    curl -N -s -X POST \
        "${ANYTHINGLLM_BASE_URL}/workspace/${workspace_slug}/thread/${thread_slug}/stream-chat" \
        -H "Accept: text/event-stream" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${ANYTHINGLLM_API_KEY}" \
        -d "{\"message\": \"${message}\", \"mode\": \"${mode}\"}" | \
    while IFS= read -r line; do
        if [[ "$line" =~ ^data:\ (.+)$ ]]; then
            local data="${BASH_REMATCH[1]}"
            local text
            text=$(echo "$data" | jq -r '.textResponse // empty' 2>/dev/null)
            if [ -n "$text" ]; then
                echo -n "$text"
            fi
        fi
    done
    echo ""
}

#endregion

#region Utility Functions

# 測試 API 連線
# 用法: allm_test_connection
allm_test_connection() {
    allm_check_config || return 1
    
    local response
    response=$(curl -s -X GET \
        "${ANYTHINGLLM_BASE_URL}/workspaces" \
        -H "Accept: application/json" \
        -H "Authorization: Bearer ${ANYTHINGLLM_API_KEY}")
    
    if echo "$response" | grep -q "workspaces"; then
        local count
        count=$(echo "$response" | jq '.workspaces | length' 2>/dev/null || echo "?")
        echo -e "${GREEN}✓ API 連線成功${NC}"
        echo -e "${CYAN}  找到 ${count} 個 Workspace(s)${NC}"
        return 0
    else
        echo -e "${RED}✗ API 連線失敗${NC}"
        echo "$response"
        return 1
    fi
}

# 顯示可用函數
allm_help() {
    echo -e "${CYAN}AnythingLLM User API Bash 工具${NC}"
    echo ""
    echo "Workspace 查詢:"
    echo "  allm_get_workspaces                    取得所有 Workspaces"
    echo ""
    echo "Thread 管理:"
    echo "  allm_new_thread <ws-slug> [name] [slug]  建立新的 Thread"
    echo "  allm_remove_thread <ws-slug> <th-slug>   刪除 Thread"
    echo ""
    echo "對話功能:"
    echo "  allm_chat <ws-slug> <th-slug> <msg>           發送訊息"
    echo "  allm_stream_chat <ws-slug> <th-slug> <msg>    串流訊息"
    echo ""
    echo "工具:"
    echo "  allm_test_connection                   測試 API 連線"
    echo "  allm_help                              顯示此說明"
}

#endregion

echo -e "${CYAN}AnythingLLM User API Bash 工具已載入${NC}"
echo -e "${GRAY}使用 allm_help 查看可用函數${NC}"
