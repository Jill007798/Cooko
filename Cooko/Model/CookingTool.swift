import Foundation

struct CookingTool: Identifiable, Codable {
    let id = UUID()
    let emoji: String
    let name: String
    let englishName: String
    var isAvailable: Bool
    
    init(emoji: String, name: String, englishName: String, isAvailable: Bool = false) {
        self.emoji = emoji
        self.name = name
        self.englishName = englishName
        self.isAvailable = isAvailable
    }
}

// 預設工具清單
extension CookingTool {
    static let defaultTools: [CookingTool] = [
        CookingTool(emoji: "🍚", name: "電鍋", englishName: "Rice Cooker"),
        CookingTool(emoji: "🍳", name: "炒鍋", englishName: "Wok"),
        CookingTool(emoji: "🍳", name: "平底鍋", englishName: "Frying Pan"),
        CookingTool(emoji: "🍞", name: "烤箱", englishName: "Oven"),
        CookingTool(emoji: "🍟", name: "氣炸鍋", englishName: "Air Fryer"),
        CookingTool(emoji: "🥣", name: "料理棒", englishName: "Hand Blender"),
        CookingTool(emoji: "🥤", name: "果汁機", englishName: "Blender"),
        CookingTool(emoji: "🧁", name: "攪拌機", englishName: "Mixer / Stand Mixer"),
        CookingTool(emoji: "🔌", name: "電磁爐", englishName: "Induction Cooker / Portable Cooker"),
        CookingTool(emoji: "🍲", name: "慢燉鍋", englishName: "Slow Cooker"),
        CookingTool(emoji: "🍵", name: "快煮壺", englishName: "Electric Kettle"),
        CookingTool(emoji: "🍡", name: "微波爐", englishName: "Microwave")
    ]
}
