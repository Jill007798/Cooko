import Foundation

struct APIConfig {
    // 請將此處替換為您的實際 OpenAI API 密鑰
    // 您可以在 https://platform.openai.com/api-keys 獲取
    static let openAIAPIKey = "YOUR_API_KEY_HERE"
    
    // 檢查是否已設置 API 密鑰
    static var isAPIKeyConfigured: Bool {
        return !openAIAPIKey.isEmpty && openAIAPIKey != "YOUR_API_KEY_HERE"
    }
    
    // 獲取 API 密鑰（用於服務）
    static func getAPIKey() -> String? {
        return isAPIKeyConfigured ? openAIAPIKey : nil
    }
}
