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
            // 使用新的 generateRecipes 方法，會自動選擇 ChatGPT 或模擬數據
            let result = try await service.generateRecipes(from: foods)
            self.recipes = result
        } catch {
            self.errorMessage = error.localizedDescription
            // 如果 ChatGPT 失敗，回退到模擬數據
            do {
                let fallbackResult = try await service.mockRecipes(from: foods)
                self.recipes = fallbackResult
                self.errorMessage = nil
            } catch {
                self.errorMessage = "無法生成食譜建議"
            }
        }
        isLoading = false
    }
}
