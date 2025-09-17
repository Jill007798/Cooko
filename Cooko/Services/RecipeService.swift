import Foundation

class RecipeService {
    // TODO: Replace with actual API implementation
    
    func fetchRecipes() async throws -> [Recipe] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Return sample data for now
        return sampleRecipes()
    }
    
    func fetchRecipesByIngredients(_ ingredients: [String]) async throws -> [Recipe] {
        // TODO: Implement API call to fetch recipes based on available ingredients
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return sampleRecipes()
    }
    
    func fetchRecipeDetails(id: String) async throws -> Recipe {
        // TODO: Implement API call to fetch detailed recipe information
        try await Task.sleep(nanoseconds: 500_000_000)
        return sampleRecipes().first ?? Recipe(
            name: "Sample Recipe",
            description: "A sample recipe",
            ingredients: [],
            instructions: [],
            prepTime: 15,
            cookTime: 30,
            servings: 4,
            difficulty: .easy,
            tags: [],
            imageURL: nil
        )
    }
    
    private func sampleRecipes() -> [Recipe] {
        // TODO: Replace with actual sample data
        return [
            Recipe(
                name: "Sample Recipe 1",
                description: "A delicious sample recipe",
                ingredients: [
                    RecipeIngredient(name: "Tomato", amount: "2", unit: "pieces"),
                    RecipeIngredient(name: "Onion", amount: "1", unit: "piece")
                ],
                instructions: [
                    "Chop the tomatoes",
                    "Dice the onion",
                    "Mix together"
                ],
                prepTime: 10,
                cookTime: 20,
                servings: 2,
                difficulty: .easy,
                tags: ["vegetarian", "quick"],
                imageURL: nil
            )
        ]
    }
}
