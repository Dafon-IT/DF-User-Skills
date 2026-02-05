# ETL 基本資料查詢 API 錯誤處理

## HTTP 狀態碼

| 狀態碼 | 說明 | 處理方式 |
|--------|------|----------|
| `200` | 成功 | 正常處理回應資料 |
| `400` | 請求格式錯誤 | 檢查 JSON 格式與必要欄位 |
| `401` | 未授權 | Token 無效或過期，需重新登入 |
| `403` | 禁止存取 | 無權限存取該資源 |
| `404` | 資源不存在 | 檢查 API 端點是否正確 |
| `500` | 伺服器錯誤 | 聯繫系統管理員 |

## Token 相關錯誤

### Token 過期 (401)

**症狀：**
```json
{
  "success": false,
  "message": "Token expired",
  "error": "UNAUTHORIZED"
}
```

**處理流程：**
```
1. 檢查 ETL_TOKEN_EXPIRES 是否已過期
2. 嘗試使用 Refresh Token 更新
3. 若 Refresh Token 也過期，重新登入
```

**PowerShell 處理：**
```powershell
# 自動處理 Token 過期
Test-EtlTokenExpiry
```

**Bash 處理：**
```bash
# 自動處理 Token 過期
etl_check_token_expiry
```

### Refresh Token 過期 (401)

**症狀：**
- Access Token 過期
- 使用 Refresh Token 刷新失敗

**處理：**
需要重新使用帳號密碼登入取得新的 Token。

---

## 查詢錯誤

### 無查詢參數 (400)

**症狀：**
```json
{
  "success": false,
  "message": "At least one search parameter is required"
}
```

**處理：**
確保至少提供一個查詢參數。

### 無查詢結果

**回應：**
```json
{
  "success": true,
  "data": []
}
```

**說明：**
這不是錯誤，只是沒有符合條件的資料。

---

## 網路錯誤

### 連線逾時

**PowerShell 處理：**
```powershell
try {
    $response = Invoke-RestMethod -Uri $url -TimeoutSec 30 ...
}
catch [System.Net.WebException] {
    Write-Host "連線逾時，請檢查網路連線" -ForegroundColor Red
}
```

**Bash 處理：**
```bash
response=$(curl -s --connect-timeout 10 --max-time 30 ...)
if [ $? -ne 0 ]; then
    echo "連線失敗，請檢查網路連線"
fi
```

### SSL 憑證錯誤

**PowerShell 處理（僅限測試環境）：**
```powershell
# 警告：不建議在正式環境使用
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
```

**Bash 處理（僅限測試環境）：**
```bash
# 警告：不建議在正式環境使用
curl -k ...
```

---

## 常見問題診斷

### 問題：登入失敗

**檢查項目：**
1. 環境變數 `ETL_USERNAME` 是否設定
2. 環境變數 `ETL_PASSWORD` 是否設定
3. API URL 是否正確
4. 帳號密碼是否正確

**診斷指令（PowerShell）：**
```powershell
Write-Host "Username: $env:ETL_USERNAME"
Write-Host "Password: $(if($env:ETL_PASSWORD){'已設定'}else{'未設定'})"
Write-Host "API URL: $env:ETL_API_BASE_URL"
```

### 問題：查詢回傳空結果

**檢查項目：**
1. 查詢參數是否正確
2. 參數值是否包含前後空白
3. 是否使用正確的欄位代碼

**建議：**
- 嘗試使用更寬鬆的查詢條件
- 確認資料確實存在於系統中

### 問題：中文亂碼

**PowerShell 處理：**
```powershell
# 確保在腳本開頭設定
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
```

**Bash 處理：**
```bash
# 確保終端機使用 UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

---

## 錯誤回報

若遇到無法解決的問題，請提供以下資訊：

1. **錯誤訊息**：完整的錯誤回應內容
2. **執行環境**：Windows/Linux/macOS 版本
3. **執行指令**：使用的查詢指令（隱藏敏感資訊）
4. **時間戳記**：發生錯誤的時間

---

## 最佳實踐

### Token 管理

```
✓ 定期檢查 Token 過期時間
✓ 在 API 呼叫前自動刷新 Token
✓ 妥善保管 Refresh Token
✗ 不要將 Token 寫入日誌
✗ 不要將 Token 提交至版本控制
```

### 錯誤處理

```
✓ 使用 try-catch 包裝 API 呼叫
✓ 提供有意義的錯誤訊息
✓ 記錄錯誤以供診斷
✗ 不要忽略錯誤回應
✗ 不要在錯誤訊息中顯示敏感資訊
```
