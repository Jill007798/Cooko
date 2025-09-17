import Foundation
import SwiftUI

@MainActor
class FridgeViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadFoodItems()
    }
    
    func loadFoodItems() {
        isLoading = true
        // TODO: Load from Core Data or UserDefaults
        // For now, using sample data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.foodItems = self.sampleFoodItems()
            self.isLoading = false
        }
    }
    
    func addFoodItem(_ item: FoodItem) {
        foodItems.append(item)
        saveFoodItems()
    }
    
    func removeFoodItem(_ item: FoodItem) {
        foodItems.removeAll { $0.id == item.id }
        saveFoodItems()
    }
    
    func updateFoodItem(_ item: FoodItem) {
        if let index = foodItems.firstIndex(where: { $0.id == item.id }) {
            foodItems[index] = item
            saveFoodItems()
        }
    }
    
    private func saveFoodItems() {
        // TODO: Save to Core Data or UserDefaults
    }
    
    private func sampleFoodItems() -> [FoodItem] {
        // TODO: Replace with actual sample data
        return []
    }
}
