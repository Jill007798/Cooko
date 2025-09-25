import Foundation

class ChatGPTService: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init() {
        self.apiKey = APIConfig.openAIAPIKey
    }
    
    var isConfigured: Bool {
        return APIConfig.isAPIKeyConfigured
    }
    
    struct ChatGPTRequest: Codable {
        let model: String
        let messages: [Message]
        let maxTokens: Int
        let temperature: Double
        
        enum CodingKeys: String, CodingKey {
            case model, messages, temperature
            case maxTokens = "max_tokens"
        }
    }
    
    struct Message: Codable {
        let role: String
        let content: String
    }
    
    struct ChatGPTResponse: Codable {
        let choices: [Choice]
    }
    
    struct Choice: Codable {
        let message: Message
    }
    
    func generateRecipeSuggestion(from ingredients: [FoodItem]) async -> String? {
        let ingredientNames = ingredients.map { $0.name }.joined(separator: ", ")
        
        let prompt = """
        根據以下食材：\(ingredientNames)
        
        請提供一個簡單的食譜建議，包含：
        1. 料理名稱
        2. 所需材料（基於提供的食材）
        3. 簡單的烹飪步驟（3-5步）
        
        請用繁體中文回答，內容要簡潔實用。
        """
        
        return await sendRequest(prompt: prompt)
    }
    
    func generateCookingTip() async -> String? {
        let prompt = """
        請提供一個實用的廚房小貼士或烹飪技巧，用繁體中文回答，內容要簡潔有趣。
        """
        
        return await sendRequest(prompt: prompt)
    }
    
    func generateRecipeSuggestion(from ingredients: [FoodItem], tools: [CookingTool], preferences: [PreferenceOption]) async -> String? {
        let ingredientNames = ingredients.map { "\($0.name)（\($0.quantity)\($0.unit)）" }.joined(separator: "、")
        let toolNames = tools.map { "\($0.emoji)\($0.name)" }.joined(separator: "、")
        let preferenceNames = preferences.map { "\($0.emoji)\($0.title)" }.joined(separator: "、")
        
        let prompt = """
        根據以下資訊生成4道食譜：
        
        食材：\(ingredientNames)
        可用工具：\(toolNames)
        偏好：\(preferenceNames)
        
        請為每道食譜提供：
        1. 料理名稱
        2. 所需材料（基於提供的食材）
        3. 烹飪步驟（3-5步）
        4. 標籤（如：健康飲食、快速省時、創意料理等）
        5. 小貼士
        
        請用繁體中文回答，內容要實用且符合用戶偏好。
        """
        
        return await sendRequest(prompt: prompt)
    }
    
    private func sendRequest(prompt: String) async -> String? {
        guard isConfigured else {
            print("🚫 ChatGPT API Key not configured")
            return nil
        }
        
        guard let url = URL(string: baseURL) else { 
            print("❌ Invalid API URL: \(baseURL)")
            return nil 
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ChatGPTRequest(
            model: "gpt-3.5-turbo",
            messages: [
                Message(role: "user", content: prompt)
            ],
            maxTokens: 500,
            temperature: 0.7
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            
            // 記錄請求內容
            print("📤 ChatGPT API Request:")
            print("URL: \(baseURL)")
            print("Model: \(requestBody.model)")
            print("Max Tokens: \(requestBody.maxTokens)")
            print("Temperature: \(requestBody.temperature)")
            print("Prompt: \(prompt)")
            print("Request Body: \(String(data: request.httpBody!, encoding: .utf8) ?? "Failed to encode")")
            print("---")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // 記錄響應狀態
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 ChatGPT API Response:")
                print("Status Code: \(httpResponse.statusCode)")
                print("Response Headers: \(httpResponse.allHeaderFields)")
            }
            
            // 記錄響應內容
            let responseString = String(data: data, encoding: .utf8) ?? "Failed to decode response"
            print("Response Body: \(responseString)")
            print("---")
            
            let chatGPTResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
            let content = chatGPTResponse.choices.first?.message.content
            
            print("✅ ChatGPT API Success - Content Length: \(content?.count ?? 0)")
            print("Generated Content: \(content ?? "No content")")
            print("==========================================")
            
            return content
            
        } catch {
            print("❌ ChatGPT API Error: \(error)")
            print("Error Details: \(error.localizedDescription)")
            print("==========================================")
            return nil
        }
    }
}
