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
    
    private func sendRequest(prompt: String) async -> String? {
        guard isConfigured else {
            print("ChatGPT API Key not configured")
            return nil
        }
        
        guard let url = URL(string: baseURL) else { return nil }
        
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
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
            
            return response.choices.first?.message.content
            
        } catch {
            print("ChatGPT API Error: \(error)")
            return nil
        }
    }
}
