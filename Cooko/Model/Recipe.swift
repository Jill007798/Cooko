import Foundation

struct Recipe: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var ingredients: [String]
    var steps: [String]
    var tags: [String]     // e.g. ["快過期優先", "健康飲食"]
    var tip: String        // 小精靈一句話
    var requiredTools: [String] = []  // 需要的工具
    var isFeatured: Bool = false      // 是否為精選食譜
    
    // 自定義編碼/解碼，忽略 id 欄位
    enum CodingKeys: String, CodingKey {
        case title, ingredients, steps, tags, tip, requiredTools, isFeatured
    }
    
    // 自定義初始化器，用於創建 Recipe 實例
    init(title: String, ingredients: [String], steps: [String], tags: [String], tip: String, requiredTools: [String] = [], isFeatured: Bool = false) {
        self.id = UUID()
        self.title = title
        self.ingredients = ingredients
        self.steps = steps
        self.tags = tags
        self.tip = tip
        self.requiredTools = requiredTools
        self.isFeatured = isFeatured
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID() // 自動生成新的 ID
        self.title = try container.decode(String.self, forKey: .title)
        self.ingredients = try container.decode([String].self, forKey: .ingredients)
        self.steps = try container.decode([String].self, forKey: .steps)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.tip = try container.decode(String.self, forKey: .tip)
        self.requiredTools = try container.decodeIfPresent([String].self, forKey: .requiredTools) ?? []
        self.isFeatured = try container.decodeIfPresent(Bool.self, forKey: .isFeatured) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(steps, forKey: .steps)
        try container.encode(tags, forKey: .tags)
        try container.encode(tip, forKey: .tip)
        try container.encode(requiredTools, forKey: .requiredTools)
        try container.encode(isFeatured, forKey: .isFeatured)
    }
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
