import SwiftUI

struct RecipeGenerationSheet: View {
    @Binding var isPresented: Bool
    @StateObject private var toolsVM = ToolsViewModel()
    @State private var preferences: [PreferenceOption] = [
        PreferenceOption(title: "健康飲食", emoji: "🥗"),
        PreferenceOption(title: "快速省時", emoji: "⚡"),
        PreferenceOption(title: "創意料理", emoji: "🎨"),
        PreferenceOption(title: "今天想吃素", emoji: "🌱"),
        PreferenceOption(title: "寶寶粥", emoji: "👶"),
        PreferenceOption(title: "高蛋白", emoji: "💪")
    ]
    @State private var selectedFoods: Set<UUID> = []
    @State private var isGenerating = false
    @State private var showRecipesPage = false
    
    let foods: [FoodItem]
    let onGenerate: (RecipeGenerationRequest) -> Void
    
    init(isPresented: Binding<Bool>, foods: [FoodItem], onGenerate: @escaping (RecipeGenerationRequest) -> Void) {
        self._isPresented = isPresented
        self.foods = foods
        self.onGenerate = onGenerate
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 簡化版背景漸層 - 類似首頁但更簡單
                ZStack {
                    // 左上角 - 溫暖米色（簡化版）
                    RadialGradient(
                        colors: [
                            Color(hex: "#FFEECB").opacity(0.3),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 200
                    )
                    
                    // 右下角 - 清新綠色（簡化版）
                    RadialGradient(
                        colors: [
                            Color(hex: "#A8E6CF").opacity(0.4),
                            Color.clear
                        ],
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: 180
                    )
                    
                    // 整體基礎色調
                    Color(hex: "#F8F9FA").opacity(0.3)
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
                
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
                VStack(alignment: .leading, spacing: 4) {
                    Text("選擇偏好")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.charcoal)
                    
                    Text("Customize your meal preferences")
                        .font(.subheadline)
                        .foregroundStyle(Color.warmGray)
                }
                
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 120), spacing: 12)
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
                        
                        // 工具選擇區塊
                        VStack(alignment: .leading, spacing: 16) {
                            Text("選擇工具")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.charcoal)
                            
                            Text("選擇你擁有的廚房工具")
                                .font(.subheadline)
                                .foregroundStyle(Color.warmGray)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(toolsVM.tools) { tool in
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
                        
                        // 食材選擇
                        VStack(alignment: .leading, spacing: 16) {
                            Text("選擇食材")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.charcoal)
                            
                            Text("選擇要使用的食材")
                                .font(.subheadline)
                                .foregroundStyle(Color.warmGray)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(foods.filter { $0.quantity > 0 }) { food in
                                    FoodSelectionChip(
                                        food: food,
                                        isSelected: selectedFoods.contains(food.id),
                                        onToggle: {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                if selectedFoods.contains(food.id) {
                                                    selectedFoods.remove(food.id)
                                                } else {
                                                    selectedFoods.insert(food.id)
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 20)
                        
                        // 送出生成按鈕 - 放在畫面最下方
                        Button {
                            generateRecipes()
                        } label: {
                            HStack(spacing: 8) {
                                if isGenerating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                } else {
                                    Image(systemName: "wand.and.rays")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Text("送出生成")
                                        .fontWeight(.bold)
                                        .font(.headline)
                                }
                            }
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color.olive)
                                .shadow(color: .olive.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                        .disabled(isGenerating)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear {
            // 預設全選所有食材
            selectedFoods = Set(foods.filter { $0.quantity > 0 }.map { $0.id })
            toolsVM.loadTools()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.warmGray)
                }
            }
        }
    }
    
    private func generateRecipes() {
        isGenerating = true
        
        let selectedIngredients = foods.filter { $0.quantity > 0 && selectedFoods.contains($0.id) }
        let selectedTools = toolsVM.getAvailableTools()
        let selectedPreferences = preferences.filter { $0.isSelected }
        
        let request = RecipeGenerationRequest(
            foods: selectedIngredients,
            selectedTools: selectedTools,
            preferences: selectedPreferences
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
                    .font(.title3)
                
                Text(preference.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(preference.isSelected ? .white : Color.warmGray.opacity(0.7))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(preference.isSelected ? 
                          AnyShapeStyle(LinearGradient(
                              colors: [Color.olive, Color.olive.opacity(0.8)],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing
                          )) : 
                          AnyShapeStyle(Color.warmGray.opacity(0.15))
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                preference.isSelected ? 
                                Color.olive.opacity(0.8) : 
                                Color.warmGray.opacity(0.3), 
                                lineWidth: preference.isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: preference.isSelected ? 
                        Color.olive.opacity(0.3) : 
                        Color.clear, 
                        radius: preference.isSelected ? 4 : 0, 
                        x: 0, 
                        y: preference.isSelected ? 2 : 0
                    )
            )
            .scaleEffect(preference.isSelected ? 1.0 : 0.95)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: preference.isSelected)
    }
}

// 食材選擇芯片
struct FoodSelectionChip: View {
    let food: FoodItem
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 6) {
                if let emoji = food.emoji {
                    Text(emoji)
                        .font(.caption)
                        .opacity(isSelected ? 1.0 : 0.6)
                }
                
                Text(food.name)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .medium)
            }
            .foregroundStyle(isSelected ? .white : Color.warmGray.opacity(0.7))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? 
                          AnyShapeStyle(LinearGradient(
                              colors: [Color.olive, Color.olive.opacity(0.8)],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing
                          )) : 
                          AnyShapeStyle(Color.warmGray.opacity(0.15))
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                isSelected ? 
                                Color.olive.opacity(0.8) : 
                                Color.warmGray.opacity(0.3), 
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? 
                        Color.olive.opacity(0.3) : 
                        Color.clear, 
                        radius: isSelected ? 3 : 0, 
                        x: 0, 
                        y: isSelected ? 1 : 0
                    )
            )
            .scaleEffect(isSelected ? 1.0 : 0.95)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
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
                    .opacity(tool.isAvailable ? 1.0 : 0.6)
                
                Text(tool.name)
                    .font(.caption)
                    .fontWeight(tool.isAvailable ? .semibold : .medium)
            }
            .foregroundStyle(tool.isAvailable ? .white : Color.warmGray.opacity(0.7))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(tool.isAvailable ? Color.olive : Color.warmGray.opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(
                                tool.isAvailable ? Color.olive.opacity(0.8) : Color.warmGray.opacity(0.4), 
                                lineWidth: tool.isAvailable ? 2 : 1
                            )
                    )
                    .shadow(
                        color: tool.isAvailable ? .olive.opacity(0.4) : .clear, 
                        radius: tool.isAvailable ? 4 : 0, 
                        x: 0, 
                        y: tool.isAvailable ? 2 : 0
                    )
            )
            .scaleEffect(tool.isAvailable ? 1.0 : 0.95)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: tool.isAvailable)
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