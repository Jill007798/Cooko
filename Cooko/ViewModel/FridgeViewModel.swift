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
            .init(name: "雞蛋", emoji: "🥚", quantity: 5, unit: "顆", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*2)),
            .init(name: "香蕉", emoji: "🍌", quantity: 1, unit: "串", location: .pantry, expiry: Date().addingTimeInterval(60*60*24*3)),
            .init(name: "蘋果", emoji: "🍎", quantity: 1, unit: "顆", location: .fridge, expiry: nil),
            .init(name: "葡萄", emoji: "🍇", quantity: 1, unit: "袋", location: .fridge, expiry: nil),
            .init(name: "豆腐", emoji: nil,  quantity: 1, unit: "盒", location: .fridge, expiry: Date().addingTimeInterval(60*60*24*1)),
            .init(name: "小魚乾", emoji: "🐟", quantity: 1, unit: "盒", location: .pantry, expiry: Date().addingTimeInterval(60*60*24))
        ]
        save()
    }

    var grouped: [(StorageLocation, [FoodItem])] {
        StorageLocation.allCases.map { loc in
            (loc, items.filter { $0.location == loc })
        }
    }
}
