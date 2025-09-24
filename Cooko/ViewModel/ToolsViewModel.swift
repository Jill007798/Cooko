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
            // 更新微波爐的 emoji（從麻糬串改為旋風）
            updateMicrowaveEmoji()
        } else {
            // 如果沒有儲存的資料，使用預設工具清單
            tools = CookingTool.defaultTools
            saveTools()
        }
    }
    
    private func updateMicrowaveEmoji() {
        // 找到微波爐工具並更新 emoji
        for i in 0..<tools.count {
            if tools[i].name == "微波爐" && tools[i].emoji == "🍡" {
                tools[i] = CookingTool(emoji: "🌀", name: tools[i].name, englishName: tools[i].englishName, isAvailable: tools[i].isAvailable)
                saveTools()
                break
            }
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
            
            // 動態排序：被選中的排在左邊，未選中的排在右邊
            sortToolsByAvailability()
            saveTools()
        }
    }
    
    private func sortToolsByAvailability() {
        // 被選中的工具排在前面（左邊），未選中的排在後面（右邊）
        tools.sort { tool1, tool2 in
            if tool1.isAvailable != tool2.isAvailable {
                return tool1.isAvailable // 被選中的排在前面
            }
            // 如果狀態相同，保持原有順序
            return false
        }
    }
    
    func getAvailableTools() -> [CookingTool] {
        return tools.filter { $0.isAvailable }
    }
    
    func getUnavailableTools() -> [CookingTool] {
        return tools.filter { !$0.isAvailable }
    }
}
