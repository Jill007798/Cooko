import Foundation
import SwiftUI

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var filteredRecipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTags: Set<String> = []
    
    private let recipeService = RecipeService()
    
    init() {
        loadRecipes()
    }
    
    func loadRecipes() {
        isLoading = true
        Task {
            do {
                let fetchedRecipes = try await recipeService.fetchRecipes()
                await MainActor.run {
                    self.recipes = fetchedRecipes
                    self.filteredRecipes = fetchedRecipes
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func filterRecipes(by availableIngredients: [FoodItem]) {
        // TODO: Implement recipe filtering based on available ingredients
        filteredRecipes = recipes
    }
    
    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
        applyTagFilter()
    }
    
    private func applyTagFilter() {
        if selectedTags.isEmpty {
            filteredRecipes = recipes
        } else {
            filteredRecipes = recipes.filter { recipe in
                recipe.tags.contains { tag in
                    selectedTags.contains(tag)
                }
            }
        }
    }
}
