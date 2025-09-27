import Foundation
import UIKit

class APITestHelper {
    static let shared = APITestHelper()
    
    private init() {}
    
    // MARK: - 測試 API 連接
    func testAPIConnection() async -> Bool {
        guard ImageAnalysisConfig.isAPIKeyConfigured else {
            print("❌ API Key 未配置")
            return false
        }
        
        // 創建一個測試圖片
        let testImage = createTestImage()
        
        do {
            let results = try await ImageAnalysisService.shared.analyzeFoodImages([testImage])
            print("✅ API 測試成功，識別出 \(results.count) 種食材")
            results.forEach { food in
                print("  - \(food.emoji) \(food.name) (\(food.location.rawValue))")
            }
            return true
        } catch {
            print("❌ API 測試失敗: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - 創建測試圖片
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // 繪製一個簡單的測試圖片
            UIColor.systemBlue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // 添加文字
            let text = "測試圖片"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24),
                .foregroundColor: UIColor.white
            ]
            
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    // MARK: - 驗證 API Key 格式
    func validateAPIKey(_ key: String) -> Bool {
        // 簡單的 API Key 格式驗證
        return key.hasPrefix("sk-") && key.count > 20
    }
    
    // MARK: - 顯示 API 狀態
    func getAPIStatus() -> String {
        if !ImageAnalysisConfig.isAPIKeyConfigured {
            return "❌ API Key 未配置"
        } else if validateAPIKey(ImageAnalysisConfig.openAIAPIKey) {
            return "✅ API Key 已配置"
        } else {
            return "⚠️ API Key 格式可能不正確"
        }
    }
}

// MARK: - 調試用的擴展
extension ImageAnalysisService {
    func debugAnalyzeWithMockData() -> [AnalyzedFood] {
        return generateMockAnalysis()
    }
    
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
}
