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

    func markUsed(_ item: FoodItem, amount: Int = 1) {
        guard let idx = items.firstIndex(of: item) else { return }
        var copy = items[idx]
        copy.quantity = max(0, copy.quantity - amount)
        items[idx] = copy
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
            .init(name: "雞蛋", emoji: "🥚", quantity: 8, unit: "顆", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*2)),
            .init(name: "牛奶", emoji: "🥛", quantity: 1, unit: "瓶", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*3)),
            .init(name: "優格", emoji: "🍶", quantity: 2, unit: "盒", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*5)),
            .init(name: "起司", emoji: "🧀", quantity: 1, unit: "塊", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*7)),
            .init(name: "蘋果", emoji: "🍎", quantity: 3, unit: "顆", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*10)),
            .init(name: "葡萄", emoji: "🍇", quantity: 1, unit: "袋", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*4)),
            .init(name: "豆腐", emoji: "🥟", quantity: 2, unit: "盒", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*1)),
            .init(name: "番茄", emoji: "🍅", quantity: 4, unit: "顆", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*6)),
            .init(name: "胡蘿蔔", emoji: "🥕", quantity: 2, unit: "根", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*8)),
            .init(name: "生菜", emoji: "🥬", quantity: 1, unit: "包", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*3)),
            
            // 冷凍食材
            .init(name: "冷凍水餃", emoji: "🥟", quantity: 1, unit: "包", location: .freezer, expiry: Date().addingTimeInterval(60*60*24*30)),
            .init(name: "冷凍蝦", emoji: "🦐", quantity: 1, unit: "包", location: .freezer, expiry: Date().addingTimeInterval(60*60*24*45)),
            .init(name: "冰淇淋", emoji: "🍦", quantity: 1, unit: "盒", location: .freezer, expiry: Date().addingTimeInterval(60*60*24*60)),
            .init(name: "冷凍蔬菜", emoji: "🥦", quantity: 2, unit: "包", location: .freezer, expiry: Date().addingTimeInterval(60*60*24*90)),
            
            // 常溫食材
            .init(name: "香蕉", emoji: "🍌", quantity: 1, unit: "串", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*3)),
            .init(name: "小魚乾", emoji: "🐟", quantity: 1, unit: "盒", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*180)),
            .init(name: "白米", emoji: "🍚", quantity: 1, unit: "包", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*365)),
            .init(name: "義大利麵", emoji: "🍝", quantity: 2, unit: "包", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*365)),
            .init(name: "橄欖油", emoji: "🫒", quantity: 1, unit: "瓶", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*730)),
            .init(name: "洋蔥", emoji: "🧅", quantity: 3, unit: "顆", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*14)),
            .init(name: "馬鈴薯", emoji: "🥔", quantity: 4, unit: "顆", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*21)),
            .init(name: "大蒜", emoji: "🧄", quantity: 1, unit: "包", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*30)),
            .init(name: "檸檬", emoji: "🍋", quantity: 2, unit: "顆", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*7))
        ]
        save()
    }

    var grouped: [(StorageLocation, [FoodItem])] {
        StorageLocation.allCases.map { loc in
            (loc, items.filter { $0.location == loc })
        }
    }
}
