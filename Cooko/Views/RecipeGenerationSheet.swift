import SwiftUI

struct RecipeGenerationSheet: View {
    @Binding var isPresented: Bool
    @StateObject private var toolsVM = ToolsViewModel()
    @State private var preferences: [PreferenceOption] = [
        PreferenceOption(title: "健康飲食", emoji: "🥗"),
        PreferenceOption(title: "快速省時", emoji: "⚡"),
        PreferenceOption(title: "創意料理", emoji: "🎨"),
        PreferenceOption(title: "家常風味", emoji: "🏠")
    ]
    @State private var isGenerating = false
    @State private var showRecipesPage = false
    
    let foods: [FoodItem]
    let onGenerate: (RecipeGenerationRequest) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景漸層
                LinearGradient(
                    colors: [
                        Color(hex: "#FFEECB"),
                        Color(hex: "#F5F5F5"),
                        Color(hex: "#E8F5E8")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 標題區域
                        VStack(spacing: 8) {
                            Text("生成專屬食譜")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.charcoal)
                            
                            Text("告訴 Cooko 你的偏好，我們來為你量身打造美味食譜")
                                .font(.subheadline)
                                .foregroundStyle(Color.warmGray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // 偏好選擇區塊
                        VStack(alignment: .leading, spacing: 16) {
                            Text("選擇偏好")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.charcoal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(preferences.indices, id: \.self) { index in
                                    PreferenceChip(
                                        preference: $preferences[index],
                                        onTap: {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                preferences[index].isSelected.toggle()
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 工具確認區塊
                        VStack(alignment: .leading, spacing: 16) {
                            Text("確認工具")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.charcoal)
                            
                            Text("已選擇的廚房工具")
                                .font(.subheadline)
                                .foregroundStyle(Color.warmGray)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(toolsVM.getAvailableTools()) { tool in
                                        ToolConfirmationChip(tool: tool) {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                toolsVM.toggleToolAvailability(tool)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 食材預覽
                        VStack(alignment: .leading, spacing: 16) {
                            Text("可用食材")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.charcoal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(foods.filter { $0.quantity > 0 }) { food in
                                    Text(food.name)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color.olive.opacity(0.2))
                                        )
                                        .foregroundStyle(Color.olive)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                    .foregroundStyle(Color.warmGray)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        generateRecipes()
                    } label: {
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("送出生成")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.olive)
                            .shadow(color: .olive.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                    .disabled(isGenerating)
                }
            }
        }
        .onAppear {
            toolsVM.loadTools()
        }
    }
    
    private func generateRecipes() {
        isGenerating = true
        
        let request = RecipeGenerationRequest(
            foods: foods,
            selectedTools: toolsVM.getAvailableTools(),
            preferences: preferences.filter { $0.isSelected }
        )
        
        // 模擬生成延遲
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isGenerating = false
            onGenerate(request)
            isPresented = false
        }
    }
}

// 偏好選擇芯片
struct PreferenceChip: View {
    @Binding var preference: PreferenceOption
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Text(preference.emoji)
                    .font(.title2)
                
                Text(preference.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(preference.isSelected ? .white : Color.olive)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(preference.isSelected ? Color.olive : Color.olive.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.olive.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// 工具確認芯片
struct ToolConfirmationChip: View {
    let tool: CookingTool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 6) {
                Text(tool.emoji)
                    .font(.title3)
                
                Text(tool.name)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.olive)
                    .shadow(color: .olive.opacity(0.3), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RecipeGenerationSheet(
        isPresented: .constant(true),
        foods: [
            FoodItem(name: "雞蛋", emoji: "🥚", quantity: 3, unit: "顆", location: .fridge, expiry: Date().addingTimeInterval(86400 * 3)),
            FoodItem(name: "白米", emoji: "🍚", quantity: 1, unit: "杯", location: .pantry, expiry: Date().addingTimeInterval(86400 * 7))
        ]
    ) { _ in
        // Preview action
    }
}
