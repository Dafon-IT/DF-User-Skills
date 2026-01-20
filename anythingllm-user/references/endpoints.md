# AnythingLLM User API 端點參考

## 基礎資訊

- **Base URL**: 由管理員提供 (設定於 `ANYTHINGLLM_BASE_URL` 環境變數)
- **認證方式**: Bearer Token
- **內容類型**: `application/json`

---

## Workspace 端點

### 取得所有 Workspaces

**GET** `/workspaces`

列出所有可用的工作空間。

**回應範例:**
```json
{
  "workspaces": [
    {
      "id": 1,
      "name": "demo-workspace-001",
      "slug": "demo-workspace-001"
    }
  ]
}
```

---

## Thread 端點

### 建立 Thread

**POST** `/workspace/{slug}/thread/new`

在指定 Workspace 中建立新的對話串。

| 參數 | 類型 | 必要 | 說明 |
|------|------|------|------|
| `slug` | string (path) | 是 | Workspace 的 slug |
| `name` | string | 否 | Thread 顯示名稱 |
| `slug` | string (body) | 否 | Thread 的自訂 slug |

**請求範例:**
```json
{
  "name": "User A Thread",
  "slug": "ext-user-a"
}
```

**回應範例:**
```json
{
  "thread": {
    "id": 1,
    "name": "User A Thread",
    "slug": "ext-user-a",
    "workspace_id": 1
  }
}
```

---

### 刪除 Thread

**DELETE** `/workspace/{workspace-slug}/thread/{thread-slug}`

刪除指定的對話串。

| 參數 | 類型 | 必要 | 說明 |
|------|------|------|------|
| `workspace-slug` | string (path) | 是 | Workspace 的 slug |
| `thread-slug` | string (path) | 是 | Thread 的 slug |

---

## Chat 端點

### 發送對話訊息

**POST** `/workspace/{workspace-slug}/thread/{thread-slug}/chat`

在指定 Thread 中發送訊息並取得回應。

| 參數 | 類型 | 必要 | 說明 |
|------|------|------|------|
| `workspace-slug` | string (path) | 是 | Workspace 的 slug |
| `thread-slug` | string (path) | 是 | Thread 的 slug |
| `message` | string | 是 | 使用者訊息內容 |
| `mode` | string | 否 | 對話模式，預設 `chat` |

**請求範例:**
```json
{
  "message": "你好，請問有什麼可以幫助您的？",
  "mode": "chat"
}
```

**回應範例:**
```json
{
  "id": "chat-id",
  "type": "textResponse",
  "textResponse": "您好！我是 AI 助理，很高興為您服務...",
  "sources": [],
  "close": true,
  "error": null
}
```

---

### 串流對話 (打字機效果)

**POST** `/workspace/{workspace-slug}/thread/{thread-slug}/stream-chat`

在指定 Thread 中發送訊息並以 Server-Sent Events (SSE) 串流回應。

| Header | 值 |
|--------|-----|
| `Accept` | `text/event-stream` |

| 參數 | 類型 | 必要 | 說明 |
|------|------|------|------|
| `workspace-slug` | string (path) | 是 | Workspace 的 slug |
| `thread-slug` | string (path) | 是 | Thread 的 slug |
| `message` | string | 是 | 使用者訊息內容 |
| `mode` | string | 否 | 對話模式，預設 `chat` |

**回應格式:** Server-Sent Events (SSE)
```
data: {"id":"...","type":"textResponseChunk","textResponse":"您"}
data: {"id":"...","type":"textResponseChunk","textResponse":"好"}
data: {"id":"...","type":"textResponseChunk","textResponse":"！"}
...
data: {"type":"finalizeResponseStream","close":true}
```

---

## 端點總覽

| 方法 | 端點 | 功能 |
|------|------|------|
| GET | `/workspaces` | 取得所有 Workspaces |
| POST | `/workspace/{slug}/thread/new` | 建立 Thread |
| DELETE | `/workspace/{ws}/thread/{th}` | 刪除 Thread |
| POST | `/workspace/{ws}/thread/{th}/chat` | 發送對話 |
| POST | `/workspace/{ws}/thread/{th}/stream-chat` | 串流對話 |
