import SwiftUI

struct RecipesView: View {
    @StateObject private var recipeVM = RecipeViewModel()
    @State private var showGenerationSheet = false
    @State private var showRecipeDetail: Recipe?
    @State private var showSuccessBanner = false
    @State private var generatedRecipeCount = 0
    
    let foods: [FoodItem]
    let onBack: () -> Void
    
    var body: some View {
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
            
            VStack(spacing: 0) {
                // 頂部標題區域
                VStack(spacing: 16) {
                    HStack {
                        Button {
                            onBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundStyle(Color.charcoal)
                        }
                        
                        Spacer()
                        
                        Text("推薦食譜")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.charcoal)
                        
                        Spacer()
                        
                        Button {
                            showGenerationSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundStyle(Color.olive)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    // 成功生成提示 Banner
                    if showSuccessBanner {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.green)
                            
                            Text("Cooko 幫你生成了 \(generatedRecipeCount) 道專屬食譜 🎉")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.charcoal)
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSuccessBanner = false
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.caption)
                                    .foregroundStyle(Color.warmGray)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white.opacity(0.9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.green.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .glassShadow, radius: 4, x: 0, y: 2)
                        )
                        .padding(.horizontal, 20)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                    }
                }
                
                // 食譜列表
                if recipeVM.isLoading {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(Color.olive)
                        
                        Text("正在為你生成專屬食譜...")
                            .font(.subheadline)
                            .foregroundStyle(Color.warmGray)
                        
                        Spacer()
                    }
                } else if recipeVM.recipes.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.warmGray.opacity(0.6))
                        
                        Text("還沒有食譜")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.charcoal)
                        
                        Text("點擊右上角 + 按鈕生成你的專屬食譜")
                            .font(.subheadline)
                            .foregroundStyle(Color.warmGray)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(recipeVM.recipes.enumerated()), id: \.element.id) { index, recipe in
                                RecipeListCard(recipe: recipe) {
                                    showRecipeDetail = recipe
                                }
                                .opacity(0)
                                .offset(y: 20)
                                .onAppear {
                                    withAnimation(.easeOut(duration: 0.6).delay(Double(index) * 0.1)) {
                                        // 淡入動畫
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .sheet(isPresented: $showGenerationSheet) {
            RecipeGenerationSheet(
                isPresented: $showGenerationSheet,
                foods: foods
            ) { request in
                generateRecipes(with: request)
            }
        }
        .sheet(item: $showRecipeDetail) { recipe in
            RecipeDetailView(recipe: recipe) {
                showRecipeDetail = nil
            }
        }
        .onAppear {
            if recipeVM.recipes.isEmpty {
                Task {
                    await recipeVM.generate(from: foods)
                }
            }
        }
    }
    
    private func generateRecipes(with request: RecipeGenerationRequest) {
        generatedRecipeCount = Int.random(in: 3...6)
        
        // 顯示成功 Banner
        withAnimation(.easeInOut(duration: 0.5)) {
            showSuccessBanner = true
        }
        
        // 3秒後自動隱藏 Banner
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showSuccessBanner = false
            }
        }
        
        // 重新生成食譜
        Task {
            await recipeVM.generate(from: foods)
        }
    }
}

// 食譜列表卡片
struct RecipeListCard: View {
    let recipe: Recipe
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 玻璃質感背景
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(GlassEffect.cardMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.white.opacity(0.15))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.7), .white.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .glassShadow, radius: 8, x: 0, y: 4)
                    .shadow(color: .glassShadow.opacity(0.3), radius: 20, x: 0, y: 8)
                
                VStack(alignment: .leading, spacing: 16) {
                    // 標題和標籤
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recipe.title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.charcoal)
                                .multilineTextAlignment(.leading)
                            
                            HStack(spacing: 6) {
                                ForEach(recipe.tags, id: \.self) { tag in
                                    TagChip(text: tag, color: Color.olive.opacity(0.8))
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(Color.warmGray)
                    }
                    
                    // 食材清單（簡短版）
                    VStack(alignment: .leading, spacing: 6) {
                        Text("所需食材")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.warmGray)
                        
                        Text(recipe.ingredients.prefix(3).joined(separator: " • "))
                            .font(.subheadline)
                            .foregroundStyle(Color.charcoal.opacity(0.8))
                            .lineLimit(2)
                        
                        if recipe.ingredients.count > 3 {
                            Text("+ \(recipe.ingredients.count - 3) 更多食材")
                                .font(.caption)
                                .foregroundStyle(Color.olive)
                        }
                    }
                    
                    // 小精靈語和工具提醒
                    HStack(spacing: 12) {
                        if !recipe.tip.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Color.warnOrange)
                                
                                Text(recipe.tip)
                                    .font(.caption)
                                    .foregroundStyle(Color.charcoal.opacity(0.7))
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                        
                        if !recipe.requiredTools.isEmpty {
                            HStack(spacing: 4) {
                                ForEach(recipe.requiredTools.prefix(3), id: \.self) { tool in
                                    Text(tool)
                                        .font(.caption2)
                                }
                                
                                if recipe.requiredTools.count > 3 {
                                    Text("+\(recipe.requiredTools.count - 3)")
                                        .font(.caption2)
                                        .foregroundStyle(Color.warmGray)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .frame(height: 160)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RecipesView(
        foods: [
            FoodItem(name: "雞蛋", emoji: "🥚", quantity: 3, unit: "顆", location: .fridge, expiry: Date().addingTimeInterval(86400 * 3)),
            FoodItem(name: "白米", emoji: "🍚", quantity: 1, unit: "杯", location: .pantry, expiry: Date().addingTimeInterval(86400 * 7))
        ]
    ) {
        // Preview back action
    }
}
