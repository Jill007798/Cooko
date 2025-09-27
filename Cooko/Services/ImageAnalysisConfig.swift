import Foundation

struct ImageAnalysisConfig {
    // MARK: - API 設定
    static let openAIAPIKey = "YOUR_OPENAI_API_KEY" // 請替換為您的 OpenAI API Key
    static let baseURL = "https://api.openai.com/v1/chat/completions"
    static let model = "gpt-4-vision-preview"
    static let maxTokens = 1000
    
    // MARK: - 圖片設定
    static let imageCompressionQuality: CGFloat = 0.8
    static let maxImageSize: CGFloat = 1024 // 最大圖片尺寸
    
    // MARK: - 分析提示詞
    static let analysisPrompt = """
    請分析這些照片中的食材，並以 JSON 格式回傳結果。
    
    要求：
    1. 識別照片中的所有食材
    2. 為每個食材選擇合適的 emoji
    3. 判斷食材的儲存位置（冷藏/冷凍/常溫）
    4. 只回傳食材，不要回傳其他物品
    5. 回傳格式如下：
    
    {
      "foods": [
        {
          "name": "食材名稱",
          "emoji": "🍎",
          "location": "fridge"
        }
      ]
    }
    
    儲存位置對應：
    - fridge: 冷藏（需要冷藏保存的食材）
    - freezer: 冷凍（需要冷凍保存的食材）
    - pantry: 常溫（可以在室溫保存的食材）
    
    請確保回傳的 JSON 格式正確，只包含食材相關的內容。
    """
    
    // MARK: - 錯誤處理
    static let errorMessages = [
        "分析失敗，請重試",
        "網路連線問題，請檢查網路",
        "API 調用失敗，請稍後再試",
        "圖片格式不支援，請重新拍照"
    ]
    
    // MARK: - 驗證 API Key
    static var isAPIKeyConfigured: Bool {
        return !openAIAPIKey.isEmpty && openAIAPIKey != "YOUR_OPENAI_API_KEY"
    }
}
