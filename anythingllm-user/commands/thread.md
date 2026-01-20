---
description: 管理 AnythingLLM Thread (新增/刪除)
argument-hint: [action] [workspace-slug] [thread-name] [thread-slug]
allowed-tools: Read, Bash(curl:*), Bash(powershell:*)
---

# AnythingLLM Thread 管理

執行 AnythingLLM Thread 相關操作。Thread 是 Workspace 內的獨立對話串，可用於區分不同使用者或對話情境。

## 參數說明

- `$1` - 操作類型: `new`, `delete`
- `$2` - Workspace 的 slug
- `$3` - Thread 名稱 (new) 或 Thread slug (delete)
- `$4` - Thread 的自訂 slug (僅 new，選用)

## 前置條件

確認環境變數已設定:
```powershell
$env:ANYTHINGLLM_API_KEY
$env:ANYTHINGLLM_BASE_URL
```

## 操作執行

### 建立 Thread (`/anythingllm-thread new <workspace-slug> <name> [thread-slug]`)

**PowerShell:**
```powershell
$headers = @{
    "Accept" = "application/json"
    "Content-Type" = "application/json; charset=utf-8"
    "Authorization" = "Bearer $env:ANYTHINGLLM_API_KEY"
}
$body = '{"name": "$3", "slug": "$4"}'
Invoke-RestMethod -Uri "$env:ANYTHINGLLM_BASE_URL/workspace/$2/thread/new" -Method POST -Headers $headers -Body $body
```

**Bash:**
```bash
curl -X POST "$ANYTHINGLLM_BASE_URL/workspace/$2/thread/new" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ANYTHINGLLM_API_KEY" \
  -d '{"name": "$3", "slug": "$4"}'
```

### 刪除 Thread (`/anythingllm-thread delete <workspace-slug> <thread-slug>`)

**PowerShell:**
```powershell
$headers = @{
    "Accept" = "application/json"
    "Authorization" = "Bearer $env:ANYTHINGLLM_API_KEY"
}
Invoke-RestMethod -Uri "$env:ANYTHINGLLM_BASE_URL/workspace/$2/thread/$3" -Method DELETE -Headers $headers
```

**Bash:**
```bash
curl -X DELETE "$ANYTHINGLLM_BASE_URL/workspace/$2/thread/$3" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $ANYTHINGLLM_API_KEY"
```

## 使用範例

```
/anythingllm-thread new demo-workspace "My Thread" my-thread-001
/anythingllm-thread delete demo-workspace my-thread-001
```

## 注意事項

1. Thread slug 建議使用有意義的識別碼，如 `user-a-session`、`task-12345`
2. 刪除 Thread 會同時刪除該 Thread 中的所有對話歷史
3. 同一 Workspace 中的 Thread slug 必須唯一
