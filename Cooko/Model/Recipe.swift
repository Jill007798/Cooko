import Foundation

struct Recipe: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var ingredients: [String]
    var steps: [String]
    var tags: [String]     // e.g. ["快過期優先", "健康飲食"]
    var tip: String        // 小精靈一句話
}
