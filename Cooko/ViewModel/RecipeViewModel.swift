import SwiftUI

@MainActor
final class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = RecipeService()
    private let storageKey = "cooko.featured_recipes.v1"

    func generate(from foods: [FoodItem]) async {
        isLoading = true
        errorMessage = nil
        do {
            // 使用新的 generateRecipes 方法，會自動選擇 ChatGPT 或模擬數據
            let result = try await service.generateRecipes(from: foods)
            // 過濾掉沒有步驟的食譜
            self.recipes = result.filter { !$0.steps.isEmpty }
        } catch {
            self.errorMessage = error.localizedDescription
            // 如果 ChatGPT 失敗，回退到模擬數據
            do {
                let fallbackResult = try await service.mockRecipes(from: foods)
                // 過濾掉沒有步驟的食譜
                self.recipes = fallbackResult.filter { !$0.steps.isEmpty }
                self.errorMessage = nil
            } catch {
                self.errorMessage = "無法生成食譜建議"
            }
        }
        
        // 生成新食譜後，重新加載精選狀態
        loadFeaturedRecipes()
        
        isLoading = false
    }
    
    // 精選食譜管理
    func toggleFeatured(_ recipe: Recipe) {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        recipes[index].isFeatured.toggle()
        saveFeaturedRecipes()
    }
    
    var featuredRecipes: [Recipe] {
        recipes.filter { $0.isFeatured }
    }
    
    private func saveFeaturedRecipes() {
        let featuredIds = recipes.filter { $0.isFeatured }.map { $0.id }
        UserDefaults.standard.set(featuredIds.map { $0.uuidString }, forKey: storageKey)
    }
    
    func loadFeaturedRecipes() {
        guard let featuredIds = UserDefaults.standard.array(forKey: storageKey) as? [String] else { return }
        let featuredUUIDs = featuredIds.compactMap { UUID(uuidString: $0) }
        
        for i in 0..<recipes.count {
            if featuredUUIDs.contains(recipes[i].id) {
                recipes[i].isFeatured = true
            }
        }
    }
}
