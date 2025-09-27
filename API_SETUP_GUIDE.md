# ChatGPT API 圖片分析設定指南

## 📋 概述

本應用程式已整合 ChatGPT Vision API 來分析照片中的食材。目前使用假資料進行測試，您可以按照以下步驟配置真實的 API 調用。

## 🔧 設定步驟

### 1. 獲取 OpenAI API Key

1. 前往 [OpenAI Platform](https://platform.openai.com/)
2. 登入或註冊帳號
3. 前往 [API Keys](https://platform.openai.com/api-keys) 頁面
4. 點擊 "Create new secret key"
5. 複製生成的 API Key（格式：`sk-...`）

### 2. 配置 API Key

打開 `Cooko/Services/ImageAnalysisConfig.swift` 文件：

```swift
struct ImageAnalysisConfig {
    // 將這行替換為您的實際 API Key
    static let openAIAPIKey = "YOUR_OPENAI_API_KEY" // 👈 替換這裡
}
```

**範例：**
```swift
static let openAIAPIKey = "sk-1234567890abcdef..."
```

### 3. 驗證設定

編譯並運行應用程式，在控制台查看日誌：

- ✅ `API Key 已配置` - 設定成功
- ❌ `API Key 未配置` - 需要設定 API Key
- ⚠️ `API Key 格式可能不正確` - 檢查 Key 格式

## 🧪 測試功能

### 使用假資料測試
- 目前預設使用假資料，無需 API Key 即可測試完整流程
- 會隨機生成 3-6 種食材供確認

### 使用真實 API 測試
1. 配置 API Key 後，應用程式會自動切換到真實 API
2. 拍照後會發送到 ChatGPT 進行分析
3. 如果 API 調用失敗，會自動回退到假資料

## 📊 API 使用情況

### 模型設定
- **模型**: `gpt-4-vision-preview`
- **最大 Token**: 1000
- **圖片格式**: JPEG (Base64 編碼)
- **圖片品質**: 80% 壓縮

### 成本估算
- 每張圖片約 $0.01-0.02 USD
- 每次分析 3-4 張圖片約 $0.03-0.08 USD

## 🔍 調試功能

### 控制台日誌
應用程式會輸出詳細的調試信息：

```
📸 開始分析 3 張照片
⚠️ API Key 未配置，使用假資料
✅ 分析完成，識別出 5 種食材
```

### 測試工具
可以使用 `APITestHelper` 進行 API 連接測試：

```swift
// 在代碼中調用
let success = await APITestHelper.shared.testAPIConnection()
print("API 測試結果: \(success)")
```

## 🛠️ 故障排除

### 常見問題

1. **API Key 無效**
   - 檢查 Key 是否正確複製
   - 確認 Key 有足夠的額度

2. **網路連接問題**
   - 檢查網路連接
   - 確認防火牆設定

3. **圖片格式問題**
   - 應用程式會自動處理圖片格式
   - 支援 JPEG 和 PNG

### 錯誤代碼

- `invalidURL` - API URL 無效
- `encodingError` - 圖片編碼失敗
- `apiError` - API 調用失敗
- `invalidResponse` - 回應格式錯誤

## 📝 自定義設定

### 修改分析提示詞
在 `ImageAnalysisConfig.swift` 中修改 `analysisPrompt`：

```swift
static let analysisPrompt = """
您的自定義提示詞...
"""
```

### 調整圖片品質
```swift
static let imageCompressionQuality: CGFloat = 0.8 // 0.0-1.0
```

### 修改最大 Token 數
```swift
static let maxTokens = 1000 // 增加可獲得更詳細的分析
```

## 🔒 安全注意事項

1. **不要將 API Key 提交到版本控制**
2. **考慮使用環境變數或配置文件**
3. **定期輪換 API Key**
4. **監控 API 使用情況**

## 📞 支援

如果遇到問題，請檢查：
1. API Key 是否正確設定
2. 網路連接是否正常
3. OpenAI 服務是否可用
4. 控制台錯誤訊息

---

**注意**: 目前使用假資料進行測試，配置 API Key 後即可使用真實的 ChatGPT 分析功能。
