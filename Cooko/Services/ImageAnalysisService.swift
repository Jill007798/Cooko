import Foundation
import UIKit

class ImageAnalysisService: ObservableObject {
    static let shared = ImageAnalysisService()
    
    private init() {}
    
    // MARK: - API Configuration
    private let apiKey = ImageAnalysisConfig.openAIAPIKey
    private let baseURL = ImageAnalysisConfig.baseURL
    
    // MARK: - 分析照片中的食材
    func analyzeFoodImages(_ images: [UIImage]) async throws -> [AnalyzedFood] {
        // 檢查是否配置了 API Key
        if !ImageAnalysisConfig.isAPIKeyConfigured {
            print("⚠️ API Key 未配置，使用假資料")
            return generateMockAnalysis()
        }
        
        // 使用真實 API 調用
        do {
            let imageData = try await convertImagesToBase64(images)
            let prompt = createAnalysisPrompt()
            
            let request = ImageAnalysisRequest(
                model: ImageAnalysisConfig.model,
                messages: [
                    ImageAnalysisMessage(
                        role: "user",
                        content: [
                            ImageAnalysisContent(
                                type: "text",
                                text: prompt
                            )
                        ] + imageData.map { data in
                            ImageAnalysisContent(
                                type: "image_url",
                                image_url: ImageAnalysisImageURL(url: data)
                            )
                        }
                    )
                ],
                max_tokens: ImageAnalysisConfig.maxTokens
            )
            
            return try await performAPIRequest(request)
        } catch {
            print("❌ API 調用失敗，回退到假資料: \(error.localizedDescription)")
            return generateMockAnalysis()
        }
    }
    
    // MARK: - 生成假資料
    private func generateMockAnalysis() -> [AnalyzedFood] {
        let mockFoods = [
            ("蘋果", "🍎", StorageLocation.fridge),
            ("香蕉", "🍌", StorageLocation.fridge),
            ("胡蘿蔔", "🥕", StorageLocation.fridge),
            ("馬鈴薯", "🥔", StorageLocation.pantry),
            ("雞蛋", "🥚", StorageLocation.fridge),
            ("牛奶", "🥛", StorageLocation.fridge),
            ("起司", "🧀", StorageLocation.fridge),
            ("番茄", "🍅", StorageLocation.fridge),
            ("洋蔥", "🧅", StorageLocation.pantry),
            ("大蒜", "🧄", StorageLocation.pantry)
        ]
        
        // 隨機選擇 3-6 個食材
        let selectedCount = Int.random(in: 3...6)
        let shuffled = mockFoods.shuffled()
        let selected = Array(shuffled.prefix(selectedCount))
        
        return selected.map { name, emoji, location in
            AnalyzedFood(
                name: name,
                emoji: emoji,
                location: location
            )
        }
    }
    
    // MARK: - 真實 API 調用方法（準備好但暫時註解）
    private func convertImagesToBase64(_ images: [UIImage]) async throws -> [String] {
        return images.compactMap { image in
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
            return "data:image/jpeg;base64,\(imageData.base64EncodedString())"
        }
    }
    
    private func createAnalysisPrompt() -> String {
        return ImageAnalysisConfig.analysisPrompt
    }
    
    private func performAPIRequest(_ request: ImageAnalysisRequest) async throws -> [AnalyzedFood] {
        guard let url = URL(string: baseURL) else {
            throw ImageAnalysisError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw ImageAnalysisError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ImageAnalysisError.apiError
        }
        
        let apiResponse = try JSONDecoder().decode(ImageAnalysisAPIResponse.self, from: data)
        
        guard let content = apiResponse.choices.first?.message.content,
              let jsonData = content.data(using: .utf8) else {
            throw ImageAnalysisError.invalidResponse
        }
        
        let analysisResult = try JSONDecoder().decode(ImageAnalysisResult.self, from: jsonData)
        
        return analysisResult.foods.map { food in
            AnalyzedFood(
                name: food.name,
                emoji: food.emoji,
                location: StorageLocation(rawValue: food.location) ?? .fridge
            )
        }
    }
}

// MARK: - 資料模型
struct AnalyzedFood: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var emoji: String
    var location: StorageLocation
    var isSelected: Bool = true
    
    static func == (lhs: AnalyzedFood, rhs: AnalyzedFood) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - API 請求模型
struct ImageAnalysisRequest: Codable {
    let model: String
    let messages: [ImageAnalysisMessage]
    let max_tokens: Int
}

struct ImageAnalysisMessage: Codable {
    let role: String
    let content: [ImageAnalysisContent]
}

struct ImageAnalysisContent: Codable {
    let type: String
    let text: String?
    let image_url: ImageAnalysisImageURL?
    
    init(type: String, text: String? = nil, image_url: ImageAnalysisImageURL? = nil) {
        self.type = type
        self.text = text
        self.image_url = image_url
    }
}

struct ImageAnalysisImageURL: Codable {
    let url: String
}

// MARK: - API 回應模型
struct ImageAnalysisAPIResponse: Codable {
    let choices: [ImageAnalysisChoice]
}

struct ImageAnalysisChoice: Codable {
    let message: ImageAnalysisResponseMessage
}

struct ImageAnalysisResponseMessage: Codable {
    let content: String
}

struct ImageAnalysisResult: Codable {
    let foods: [ImageAnalysisFood]
}

struct ImageAnalysisFood: Codable {
    let name: String
    let emoji: String
    let location: String
}

// MARK: - 錯誤處理
enum ImageAnalysisError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case apiError
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無效的 API URL"
        case .encodingError:
            return "編碼錯誤"
        case .apiError:
            return "API 調用失敗"
        case .invalidResponse:
            return "無效的回應格式"
        }
    }
}
