---
description: 查詢 AnythingLLM Workspaces
allowed-tools: Read, Bash(curl:*), Bash(powershell:*)
---

# AnythingLLM Workspace 查詢

查詢可用的 AnythingLLM Workspaces。

## 前置條件

確認環境變數已設定:
```powershell
$env:ANYTHINGLLM_API_KEY
$env:ANYTHINGLLM_BASE_URL
```

## 操作執行

### 列出所有 Workspaces (`/anythingllm-workspace list`)

**PowerShell:**
```powershell
$headers = @{
    "Accept" = "application/json"
    "Authorization" = "Bearer $env:ANYTHINGLLM_API_KEY"
}
Invoke-RestMethod -Uri "$env:ANYTHINGLLM_BASE_URL/workspaces" -Method GET -Headers $headers
```

**Bash:**
```bash
curl -X GET "$ANYTHINGLLM_BASE_URL/workspaces" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $ANYTHINGLLM_API_KEY"
```

## 使用範例

```
/anythingllm-workspace list
```

## 回應格式

```json
{
  "workspaces": [
    {
      "id": 1,
      "name": "demo-workspace",
      "slug": "demo-workspace"
    }
  ]
}
```
