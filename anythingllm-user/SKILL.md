---
name: "AnythingLLM User API"
description: "協助使用者操作 AnythingLLM API 的基本功能，包括查詢 Workspace、管理 Thread 和進行對話。支援 PowerShell 和 Bash 雙平台。"
---

# AnythingLLM User API Skill

此 Skill 提供 AnythingLLM API 的使用者級功能，適合一般使用者進行對話操作。

## 環境設定

使用者需要設定以下環境變數：

| 變數名稱 | 必要性 | 說明 |
|----------|--------|------|
| `ANYTHINGLLM_API_KEY` | 必要 | API 認證金鑰 |
| `ANYTHINGLLM_BASE_URL` | 必要 | API 基礎 URL (由管理員提供) |

### 設定方式

**PowerShell:**
```powershell
$env:ANYTHINGLLM_API_KEY = "your-api-key"
$env:ANYTHINGLLM_BASE_URL = "https://your-server.com/api/v1"
```

**Bash:**
```bash
export ANYTHINGLLM_API_KEY="your-api-key"
export ANYTHINGLLM_BASE_URL="https://your-server.com/api/v1"
```

## 支援的操作

### 1. Workspace 查詢
- **列出 Workspaces**: 查看可用的工作空間

### 2. Thread 管理
- **建立 Thread**: 為使用者建立獨立對話串
- **刪除 Thread**: 移除指定對話串

### 3. 對話功能
- **一般對話**: 發送訊息並取得完整回應
- **串流對話**: 打字機效果的即時回應

## 執行指引

當使用者請求執行 API 操作時：

1. **確認環境變數**: 先確認 `ANYTHINGLLM_API_KEY` 和 `ANYTHINGLLM_BASE_URL` 已設定
2. **識別作業系統**: 判斷使用者的作業系統 (Windows/Linux/macOS)
3. **選擇對應腳本**: 使用 PowerShell (Windows) 或 Bash (Unix) 腳本
4. **處理中文編碼**: Windows 環境需先執行 `chcp 65001` 確保 UTF-8 編碼

## API 認證格式

所有請求需包含以下 Header：
```
Authorization: Bearer {API_KEY}
Content-Type: application/json
```

## 相關資源

- **端點參考**: `references/endpoints.md`
- **PowerShell 腳本**: `scripts/powershell/anythingllm-user.ps1`
- **Bash 腳本**: `scripts/bash/anythingllm-user.sh`
- **使用範例**: `examples/user-workflow.md`

## 注意事項

此 Skill 僅提供使用者級功能，不包含管理功能：
- ❌ 新增 Workspace
- ❌ 刪除 Workspace
- ❌ 更新系統提示詞

如需管理功能，請聯繫系統管理員。
