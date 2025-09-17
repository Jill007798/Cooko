import Foundation

struct FoodItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let category: FoodCategory
    let expirationDate: Date
    let quantity: String
    let unit: String
    let addedDate: Date
    
    enum FoodCategory: String, CaseIterable, Codable {
        case vegetables = "Vegetables"
        case fruits = "Fruits"
        case dairy = "Dairy"
        case meat = "Meat"
        case grains = "Grains"
        case spices = "Spices"
        case other = "Other"
    }
}

extension FoodItem {
    var isExpired: Bool {
        expirationDate < Date()
    }
    
    var daysUntilExpiration: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
    }
}
