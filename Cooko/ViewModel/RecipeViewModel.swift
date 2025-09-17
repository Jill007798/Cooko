import SwiftUI

@MainActor
final class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = RecipeService()

    func generate(from foods: [FoodItem]) async {
        isLoading = true
        errorMessage = nil
        do {
            // 先用假資料（本地生成），之後再切換真 API
            let result = try await service.mockRecipes(from: foods)
            self.recipes = result
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
