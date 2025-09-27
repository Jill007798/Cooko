import Foundation

enum StorageLocation: String, Codable, CaseIterable {
    case fridge = "冷藏"
    case freezer = "冷凍"
    case pantry  = "常溫"
}

struct FoodItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var emoji: String?     // 有就顯示，無則顯示 icon
    var location: StorageLocation
    var expiry: Date?      // 可為空
    var createdAt = Date()

    var isExpiringSoon: Bool {
        guard let d = expiry else { return false }
        return Calendar.current.dateComponents([.day], from: Date(), to: d).day ?? 99 <= 2
    }
}
