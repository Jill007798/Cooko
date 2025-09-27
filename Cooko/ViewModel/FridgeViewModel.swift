import SwiftUI

@MainActor
final class FridgeViewModel: ObservableObject {
    @Published var items: [FoodItem] = []

    private let storageKey = "cooko.items.v1"

    init() {
        load()
        if items.isEmpty { seed() } // 首次跑給一點假資料
    }

    func add(_ item: FoodItem) {
        items.append(item)
        save()
    }

    func update(_ item: FoodItem) {
        guard let idx = items.firstIndex(where: {$0.id == item.id}) else { return }
        items[idx] = item
        save()
    }

    func remove(_ item: FoodItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func markUsed(_ item: FoodItem) {
        // 食材使用功能 - 未來版本可擴展
        // 目前只是標記已使用，不影響數量
    }
    
    func removeAll() {
        items.removeAll()
        save()
    }

    // MARK: - Persist (UserDefaults → 之後可換 CoreData)
    private func save() {
        let data = try? JSONEncoder().encode(items)
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([FoodItem].self, from: data) else { return }
        self.items = decoded
    }

    private func seed() {
        items = [
            // 冷藏食材
            .init(name: "雞蛋", emoji: "🥚", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*2)),
            .init(name: "牛奶", emoji: "🥛", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*3)),
            .init(name: "優格", emoji: "🍶", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*5)),
            .init(name: "起司", emoji: "🧀", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*7)),
            .init(name: "蘋果", emoji: "🍎", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*10)),
            .init(name: "葡萄", emoji: "🍇", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*4)),
            .init(name: "豆腐", emoji: "🥟", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*1)),
            .init(name: "番茄", emoji: "🍅", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*6)),
            .init(name: "胡蘿蔔", emoji: "🥕", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*8)),
            .init(name: "生菜", emoji: "🥬", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*3)),
            
            // 冷凍食材
            .init(name: "冷凍水餃", emoji: "🥟", location: .freezer, expiry: Date().addingTimeInterval(60*60*24*30)),
            .init(name: "冷凍蝦", emoji: "🦐", location: .freezer, expiry: Date().addingTimeInterval(60*60*24*45)),
            .init(name: "冰淇淋", emoji: "🍦", location: .freezer, expiry: Date().addingTimeInterval(60*60*24*60)),
            .init(name: "冷凍蔬菜", emoji: "🥦", location: .freezer, expiry: Date().addingTimeInterval(60*60*24*90)),
            
            // 常溫食材
            .init(name: "香蕉", emoji: "🍌", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*3)),
            .init(name: "小魚乾", emoji: "🐟", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*180)),
            .init(name: "白米", emoji: "🍚", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*365)),
            .init(name: "義大利麵", emoji: "🍝", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*365)),
            .init(name: "橄欖油", emoji: "🫒", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*730)),
            .init(name: "洋蔥", emoji: "🧅", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*14)),
            .init(name: "馬鈴薯", emoji: "🥔", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*21)),
            .init(name: "大蒜", emoji: "🧄", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*30)),
            .init(name: "檸檬", emoji: "🍋", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*7)),
            
            // 沒有emoji的食材（會排在最後）
            .init(name: "有機胡蘿蔔", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*5)),
            .init(name: "新鮮菠菜", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*1))
        ]
        save()
    }

    var grouped: [(StorageLocation, [FoodItem])] {
        StorageLocation.allCases.map { loc in
            (loc, items.filter { $0.location == loc })
        }
    }
}
