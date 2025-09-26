import Foundation

struct APIConfig {
    // 🔒 安全配置：API Key 管理
    // 
    // 開發階段：使用佔位符，不提交到 Git
    // 打包階段：替換為真實的 API Key
    // 
    // 獲取方式：
    // 1. 環境變數（推薦）
    // 2. 直接替換（簡單）
    // 3. 配置文件（進階）
    
    private static let openAIAPIKey: String = {
        // 優先從環境變數讀取
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
           !envKey.isEmpty && envKey != "YOUR_API_KEY_HERE" {
            return envKey
        }
        
        // 備用：直接配置（打包時替換）
        return "YOUR_API_KEY_HERE"
    }()
    
    // 檢查是否已設置 API 密鑰
    static var isAPIKeyConfigured: Bool {
        return !openAIAPIKey.isEmpty && openAIAPIKey != "YOUR_API_KEY_HERE"
    }
    
    // 獲取 API 密鑰（用於服務）
    static func getAPIKey() -> String? {
        return isAPIKeyConfigured ? openAIAPIKey : nil
    }
    
    // 開發用：顯示配置狀態
    static var configurationStatus: String {
        if isAPIKeyConfigured {
            return "✅ API Key 已配置"
        } else {
            return "⚠️ API Key 未配置，使用本地模式"
        }
    }
}
