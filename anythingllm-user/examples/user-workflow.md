# AnythingLLM User API 使用者工作流程範例

此範例展示一般使用者如何使用 AnythingLLM API 進行對話。

---

## 情境：使用者建立對話並與 AI 互動

假設管理員已建立好 Workspace `customer-service`，使用者需要建立自己的 Thread 並開始對話。

---

## Step 1: 設定環境變數

向管理員取得 API Key 和 Base URL 後設定環境變數。

### PowerShell
```powershell
# 設定 API Key (由管理員提供)
$env:ANYTHINGLLM_API_KEY = "your-api-key-from-admin"

# 設定 API Base URL (由管理員提供)
$env:ANYTHINGLLM_BASE_URL = "https://your-server.com/api/v1"

# 設定 UTF-8 編碼 (Windows)
chcp 65001
```

### Bash
```bash
# 設定 API Key (由管理員提供)
export ANYTHINGLLM_API_KEY="your-api-key-from-admin"

# 設定 API Base URL (由管理員提供)
export ANYTHINGLLM_BASE_URL="https://your-server.com/api/v1"
```

---

## Step 2: 查詢可用的 Workspaces

### PowerShell
```powershell
# 載入工具
. .\scripts\powershell\anythingllm-user.ps1

# 測試連線
Test-AllmConnection

# 列出可用 Workspaces
Get-AllmWorkspaces
```

### Bash
```bash
# 載入工具
source ./scripts/bash/anythingllm-user.sh

# 測試連線
allm_test_connection

# 列出可用 Workspaces
allm_get_workspaces
```

**預期輸出:**
```json
{
  "workspaces": [
    {
      "id": 1,
      "name": "customer-service",
      "slug": "customer-service"
    }
  ]
}
```

---

## Step 3: 建立個人 Thread

### PowerShell
```powershell
# 建立 Thread (使用唯一識別碼)
New-AllmThread -WorkspaceSlug "customer-service" -Name "User John Session" -ThreadSlug "user-john-001"
```

### Bash
```bash
# 建立 Thread
allm_new_thread "customer-service" "User John Session" "user-john-001"
```

**預期輸出:**
```
✓ Thread 建立成功
{
  "thread": {
    "id": 1,
    "name": "User John Session",
    "slug": "user-john-001"
  }
}
```

---

## Step 4: 開始對話

### PowerShell
```powershell
# 發送第一則訊息
$response = Send-AllmChat -WorkspaceSlug "customer-service" -ThreadSlug "user-john-001" -Message "你好，我想詢問產品相關問題"
$response.textResponse
```

### Bash
```bash
# 發送第一則訊息
allm_chat "customer-service" "user-john-001" "你好，我想詢問產品相關問題"
```

---

## Step 5: 繼續對話 (測試記憶功能)

### PowerShell
```powershell
# 發送後續訊息
$response = Send-AllmChat -WorkspaceSlug "customer-service" -ThreadSlug "user-john-001" -Message "請問你們的退貨政策是什麼？"
$response.textResponse

# AI 會記住這是同一個對話
$response = Send-AllmChat -WorkspaceSlug "customer-service" -ThreadSlug "user-john-001" -Message "如果超過退貨期限怎麼辦？"
$response.textResponse
```

### Bash
```bash
# 發送後續訊息
allm_chat "customer-service" "user-john-001" "請問你們的退貨政策是什麼？"

# AI 會記住這是同一個對話
allm_chat "customer-service" "user-john-001" "如果超過退貨期限怎麼辦？"
```

---

## Step 6: 使用串流模式 (打字機效果)

### PowerShell
```powershell
# 串流對話 - 可以看到逐字回應
Send-AllmStreamChat -WorkspaceSlug "customer-service" -ThreadSlug "user-john-001" -Message "請詳細說明退貨流程"
```

### Bash
```bash
# 串流對話 - 可以看到逐字回應
allm_stream_chat "customer-service" "user-john-001" "請詳細說明退貨流程"
```

---

## Step 7: 結束對話並清理 Thread (選用)

如果不需要保留對話歷史，可以刪除 Thread。

### PowerShell
```powershell
# 刪除 Thread
Remove-AllmThread -WorkspaceSlug "customer-service" -ThreadSlug "user-john-001"
```

### Bash
```bash
# 刪除 Thread
allm_remove_thread "customer-service" "user-john-001"
```

---

## 重點摘要

| 步驟 | 說明 |
|------|------|
| 1 | 向管理員取得 API Key 和 Base URL |
| 2 | 設定環境變數並測試連線 |
| 3 | 查詢可用的 Workspaces |
| 4 | 建立個人專屬的 Thread |
| 5 | 在 Thread 中進行對話 (具記憶能力) |
| 6 | 可使用串流模式獲得即時回應 |
| 7 | 完成後可選擇刪除 Thread |

---

## 常見問題

### Q: 環境變數設定後仍然無法連線？
A: 請確認：
1. API Key 沒有前後空白
2. Base URL 格式正確 (含 `/api/v1`)
3. 網路可以連線到伺服器

### Q: 中文訊息出現亂碼？
A: Windows 環境請先執行 `chcp 65001` 切換為 UTF-8 編碼

### Q: Thread slug 可以重複嗎？
A: 同一個 Workspace 內不可重複，建議使用唯一識別碼如 `user-{username}-{timestamp}`
