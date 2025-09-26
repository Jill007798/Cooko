import Foundation

enum GuidedModeError: Error, LocalizedError {
    case apiError(String)
    case parseError(String)
    
    var errorDescription: String? {
        switch self {
        case .apiError(let message):
            return "API 錯誤: \(message)"
        case .parseError(let message):
            return "解析錯誤: \(message)"
        }
    }
}

class ChatGPTService: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init() {
        self.apiKey = APIConfig.getAPIKey() ?? ""
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
    
    func generateGuidedRecipe(from recipe: Recipe) async throws -> GuidedRecipe {
        let ingredients = recipe.ingredients.joined(separator: "、")
        let originalSteps = recipe.steps.joined(separator: "\n")
        
        let prompt = """
        你是一個料理助手。
        請將以下食譜轉換成「逐步口令模式」，並同時考慮時間管理。

        食譜名稱：\(recipe.title)
        食材：\(ingredients)
        原始步驟：
        \(originalSteps)

        規則：
        - 步驟要依照「最長時間的動作優先」來排序，例如泡米需要 30 分鐘，要最先做。
        - 每一步必須用一句話，動詞開頭。
        - 語氣簡短清楚，像語音助手下指令。
        - 對需要等待的步驟（例如浸泡、燉煮），要在適當時機插入「同時」可以做的事情。
        - 回傳的步驟編號要依序排列。

        請回傳 JSON 格式：
        {
          "title": "食譜名稱",
          "steps": [
            {"id": 1, "command": "先把米洗乾淨，泡在水裡 30 分鐘。", "duration_sec": 1800, "parallel_ok": true},
            {"id": 2, "command": "泡米的時候，切好所有蔬菜。"},
            {"id": 3, "command": "醃雞腿十五分鐘。", "duration_sec": 900, "parallel_ok": true}
          ]
        }
        """
        
        guard let response = await sendRequest(prompt: prompt) else {
            throw GuidedModeError.apiError("無法取得 AI 回應")
        }
        
        // 嘗試解析 JSON 回應
        guard let jsonData = response.data(using: .utf8) else {
            throw GuidedModeError.parseError("無法解析回應資料")
        }
        
        do {
            let guidedRecipe = try JSONDecoder().decode(GuidedRecipe.self, from: jsonData)
            return guidedRecipe
        } catch {
            print("❌ JSON 解析失敗: \(error)")
            print("原始回應: \(response)")
            
            // 如果 JSON 解析失敗，嘗試從文字中提取 JSON
            if let jsonString = extractJSONFromText(response) {
                if let jsonData = jsonString.data(using: .utf8),
                   let guidedRecipe = try? JSONDecoder().decode(GuidedRecipe.self, from: jsonData) {
                    return guidedRecipe
                }
            }
            
            throw GuidedModeError.parseError("無法解析 AI 回應為有效格式")
        }
    }
    
    private func extractJSONFromText(_ text: String) -> String? {
        // 尋找 JSON 區塊
        if let startRange = text.range(of: "{", options: .regularExpression),
           let endRange = text.range(of: "}", options: .regularExpression, range: startRange.upperBound..<text.endIndex) {
            return String(text[startRange.lowerBound...endRange.upperBound])
        }
        
        return nil
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
