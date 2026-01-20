# AnythingLLM User API 工具

這是一個用於操作 AnythingLLM API 的使用者級工具集，支援 PowerShell 和 Bash 雙平台。

> ⚠️ **注意**: 此工具僅提供使用者級功能，不包含 Workspace 管理功能。

## 快速開始

### 1. 取得設定資訊

向系統管理員取得以下資訊：
- **API Key**: 您的專屬認證金鑰
- **API Base URL**: API 伺服器位址

### 2. 設定環境變數

**PowerShell (Windows):**
```powershell
$env:ANYTHINGLLM_API_KEY = "your-api-key"
$env:ANYTHINGLLM_BASE_URL = "https://your-server.com/api/v1"
```

**Bash (Linux/macOS):**
```bash
export ANYTHINGLLM_API_KEY="your-api-key"
export ANYTHINGLLM_BASE_URL="https://your-server.com/api/v1"
```

### 3. 測試連線

**PowerShell:**
```powershell
. .\scripts\powershell\anythingllm-user.ps1
Test-AllmConnection
```

**Bash:**
```bash
source ./scripts/bash/anythingllm-user.sh
allm_test_connection
```

---

## 斜線指令 (Slash Commands)

在 Claude/Copilot 對話中可直接使用以下指令：

### `/anythingllm-workspace` - Workspace 查詢

| 指令 | 說明 |
|------|------|
| `/anythingllm-workspace list` | 列出所有可用 Workspaces |

**範例：**
```
/anythingllm-workspace list
```

### `/anythingllm-thread` - Thread 管理

| 指令 | 說明 |
|------|------|
| `/anythingllm-thread new <workspace> <name> [slug]` | 建立新的 Thread |
| `/anythingllm-thread delete <workspace> <thread-slug>` | 刪除指定 Thread |

**範例：**
```
/anythingllm-thread new demo-workspace "My Thread" my-thread-001
/anythingllm-thread delete demo-workspace my-thread-001
```

### `/anythingllm-chat` - 對話功能

| 指令 | 說明 |
|------|------|
| `/anythingllm-chat <workspace> <thread> <message>` | 發送訊息 |
| `/anythingllm-chat <workspace> <thread> <message> --stream` | 串流模式 (打字機效果) |

**範例：**
```
/anythingllm-chat demo-workspace my-thread "你好，請自我介紹"
/anythingllm-chat demo-workspace my-thread "請詳細說明" --stream
```

---

## 功能概覽

| 功能 | PowerShell | Bash |
|------|------------|------|
| 列出 Workspaces | `Get-AllmWorkspaces` | `allm_get_workspaces` |
| 建立 Thread | `New-AllmThread` | `allm_new_thread` |
| 刪除 Thread | `Remove-AllmThread` | `allm_remove_thread` |
| 發送對話 | `Send-AllmChat` | `allm_chat` |
| 串流對話 | `Send-AllmStreamChat` | `allm_stream_chat` |

---

## 使用範例

### 完整對話流程

**PowerShell:**
```powershell
# 載入工具
. .\scripts\powershell\anythingllm-user.ps1

# 查詢可用 Workspace
Get-AllmWorkspaces

# 建立 Thread
New-AllmThread -WorkspaceSlug "demo-workspace" -Name "My Session" -ThreadSlug "my-session-001"

# 發送訊息
Send-AllmChat -WorkspaceSlug "demo-workspace" -ThreadSlug "my-session-001" -Message "你好"

# 串流對話
Send-AllmStreamChat -WorkspaceSlug "demo-workspace" -ThreadSlug "my-session-001" -Message "請詳細說明"

# 刪除 Thread (選用)
Remove-AllmThread -WorkspaceSlug "demo-workspace" -ThreadSlug "my-session-001"
```

**Bash:**
```bash
# 載入工具
source ./scripts/bash/anythingllm-user.sh

# 查詢可用 Workspace
allm_get_workspaces

# 建立 Thread
allm_new_thread "demo-workspace" "My Session" "my-session-001"

# 發送訊息
allm_chat "demo-workspace" "my-session-001" "你好"

# 串流對話
allm_stream_chat "demo-workspace" "my-session-001" "請詳細說明"

# 刪除 Thread (選用)
allm_remove_thread "demo-workspace" "my-session-001"
```

---

## 目錄結構

```
anythingllm-user/
├── SKILL.md                          # Skill 定義檔
├── README.md                         # 本文件
├── LICENSE                           # MIT License
├── .env.example                      # 環境變數範本
├── scripts/
│   ├── powershell/
│   │   └── anythingllm-user.ps1     # PowerShell 工具函數
│   └── bash/
│       └── anythingllm-user.sh      # Bash 工具函數
├── commands/                         # 指令說明文件
├── references/                       # API 參考文件
└── examples/                         # 完整範例
```

---

## 常見問題

### Windows 中文亂碼

執行以下指令切換為 UTF-8 編碼：
```powershell
chcp 65001
```

### 環境變數未設定

確認已設定以下環境變數：
```powershell
$env:ANYTHINGLLM_API_KEY    # 必要
$env:ANYTHINGLLM_BASE_URL   # 必要
```

### API 連線失敗

1. 確認 API Key 正確 (向管理員確認)
2. 確認 Base URL 格式正確 (含 `/api/v1`)
3. 確認網路可連線至伺服器

---

## 相關文件

- [API 端點參考](references/endpoints.md)
- [使用者工作流程範例](examples/user-workflow.md)

---

## 授權

MIT License - 詳見 [LICENSE](LICENSE)
