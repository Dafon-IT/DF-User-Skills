---
description: 發送 AnythingLLM 對話訊息 (一般/串流)
argument-hint: [workspace-slug] [thread-slug] [message] [--stream]
allowed-tools: Read, Bash(curl:*), Bash(powershell:*)
---

# AnythingLLM 對話

在指定的 Workspace Thread 中發送訊息並取得 AI 回應。

## 參數說明

- `$1` - Workspace 的 slug
- `$2` - Thread 的 slug
- `$3` - 訊息內容
- `--stream` - (選用) 使用串流模式 (打字機效果)

## 前置條件

1. 確認環境變數已設定:
```powershell
$env:ANYTHINGLLM_API_KEY
$env:ANYTHINGLLM_BASE_URL
```

2. Windows 環境需先設定 UTF-8 編碼:
```powershell
chcp 65001
```

## 操作執行

### 一般對話 (`/anythingllm-chat <workspace> <thread> <message>`)

**PowerShell:**
```powershell
chcp 65001
$headers = @{
    "Accept" = "application/json"
    "Content-Type" = "application/json; charset=utf-8"
    "Authorization" = "Bearer $env:ANYTHINGLLM_API_KEY"
}
$body = '{"message": "$3", "mode": "chat"}'
$response = Invoke-RestMethod -Uri "$env:ANYTHINGLLM_BASE_URL/workspace/$1/thread/$2/chat" -Method POST -Headers $headers -Body $body
$response.textResponse
```

**Bash:**
```bash
curl -X POST "$ANYTHINGLLM_BASE_URL/workspace/$1/thread/$2/chat" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ANYTHINGLLM_API_KEY" \
  -d '{"message": "$3", "mode": "chat"}'
```

### 串流對話 (`/anythingllm-chat <workspace> <thread> <message> --stream`)

**PowerShell (使用 curl):**
```powershell
chcp 65001
curl.exe -N -X POST "$env:ANYTHINGLLM_BASE_URL/workspace/$1/thread/$2/stream-chat" `
  -H "Accept: text/event-stream" `
  -H "Content-Type: application/json; charset=utf-8" `
  -H "Authorization: Bearer $env:ANYTHINGLLM_API_KEY" `
  -d "{`"message`": `"$3`", `"mode`": `"chat`"}"
```

**Bash:**
```bash
curl -N -X POST "$ANYTHINGLLM_BASE_URL/workspace/$1/thread/$2/stream-chat" \
  -H "Accept: text/event-stream" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ANYTHINGLLM_API_KEY" \
  -d '{"message": "$3", "mode": "chat"}'
```

## 使用範例

```
/anythingllm-chat demo-workspace my-thread "你好，請自我介紹"
/anythingllm-chat demo-workspace my-thread "請詳細說明" --stream
```

## 對話模式

| 模式 | 說明 |
|------|------|
| `chat` | 一般對話模式，AI 會記住對話歷史 |
| `query` | 查詢模式，適合單次問答 |

## 回應格式

### 一般對話回應
```json
{
  "id": "chat-id",
  "type": "textResponse",
  "textResponse": "AI 的回應內容...",
  "sources": [],
  "close": true,
  "error": null
}
```

### 串流對話回應 (SSE)
```
data: {"id":"...","type":"textResponseChunk","textResponse":"你"}
data: {"id":"...","type":"textResponseChunk","textResponse":"好"}
data: {"type":"finalizeResponseStream","close":true}
```
