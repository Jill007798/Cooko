import Foundation

struct Recipe: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let ingredients: [RecipeIngredient]
    let instructions: [String]
    let prepTime: Int // in minutes
    let cookTime: Int // in minutes
    let servings: Int
    let difficulty: Difficulty
    let tags: [String]
    let imageURL: String?
    
    enum Difficulty: String, CaseIterable, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }
}

struct RecipeIngredient: Identifiable, Codable {
    let id = UUID()
    let name: String
    let amount: String
    let unit: String
}

extension Recipe {
    var totalTime: Int {
        prepTime + cookTime
    }
}
