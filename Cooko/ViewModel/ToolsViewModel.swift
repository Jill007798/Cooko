import Foundation
import SwiftUI

class ToolsViewModel: ObservableObject {
    @Published var tools: [CookingTool] = []
    
    private let userDefaultsKey = "cooking_tools"
    
    init() {
        loadTools()
    }
    
    func loadTools() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedTools = try? JSONDecoder().decode([CookingTool].self, from: data) {
            tools = decodedTools
        } else {
            // 如果沒有儲存的資料，使用預設工具清單
            tools = CookingTool.defaultTools
            saveTools()
        }
    }
    
    func saveTools() {
        if let encoded = try? JSONEncoder().encode(tools) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func toggleToolAvailability(_ tool: CookingTool) {
        if let index = tools.firstIndex(where: { $0.id == tool.id }) {
            tools[index].isAvailable.toggle()
            saveTools()
        }
    }
    
    func getAvailableTools() -> [CookingTool] {
        return tools.filter { $0.isAvailable }
    }
    
    func getUnavailableTools() -> [CookingTool] {
        return tools.filter { !$0.isAvailable }
    }
}
