import Foundation

struct Recipe: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var ingredients: [String]
    var steps: [String]
    var tags: [String]     // e.g. ["快過期優先", "健康飲食"]
    var tip: String        // 小精靈一句話
    var requiredTools: [String] = []  // 需要的工具
}

// 偏好選擇選項
struct PreferenceOption: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let emoji: String
    var isSelected: Bool = false
}

// 食譜生成請求
struct RecipeGenerationRequest {
    let foods: [FoodItem]
    let selectedTools: [CookingTool]
    let preferences: [PreferenceOption]
}
