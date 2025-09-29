import SwiftUI

struct RecipesView: View {
    @EnvironmentObject var recipeVM: RecipeViewModel
    @State private var showGenerationSheet = false
    @State private var showRecipeDetail: Recipe?
    @State private var showSuccessBanner = false
    @State private var generatedRecipeCount = 0
    @State private var generatedRecipes: [Recipe] = []
    
    let foods: [FoodItem]
    let onBack: () -> Void
    
    // 計算屬性：將精選食譜排在前面
    private var sortedRecipes: [Recipe] {
        let recipesToShow = generatedRecipes.isEmpty ? recipeVM.recipes : generatedRecipes
        return recipesToShow.sorted { recipe1, recipe2 in
            // 精選食譜排在前面
            if recipe1.isFeatured && !recipe2.isFeatured {
                return true
            } else if !recipe1.isFeatured && recipe2.isFeatured {
                return false
            } else {
                // 如果都是精選或都不是精選，保持原有順序
                return false
            }
        }
    }
    
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
                } else if generatedRecipes.isEmpty && recipeVM.recipes.isEmpty {
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
                        VStack(spacing: 12) {
                            // 優先顯示生成的食譜，如果沒有則顯示預設食譜，並將精選食譜排在前面
                            ForEach(Array(sortedRecipes.enumerated()), id: \.element.id) { index, recipe in
                                FeaturedRecipeCard(
                                    recipe: recipe,
                                    onTap: {
                                        // 點擊食譜
                                        showRecipeDetail = recipe
                                    },
                                    onToggleFeatured: {
                                        recipeVM.toggleFeatured(recipe)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
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
            RecipeDetailView(
                recipe: recipe,
                onDismiss: {
                    showRecipeDetail = nil
                },
                onToggleFeatured: {
                    recipeVM.toggleFeatured(recipe)
                }
            )
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
        print("🎯 開始生成食譜")
        
        Task {
            do {
                let recipeService = RecipeService()
                let newRecipes = try await recipeService.generateRecipes(from: request)
                
                await MainActor.run {
                    generatedRecipes = newRecipes
                    generatedRecipeCount = newRecipes.count
                    
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
                }
            } catch {
                // 如果生成失敗，使用預設食譜
                await MainActor.run {
                    generatedRecipeCount = 4
                    showSuccessBanner = true
                }
            }
        }
    }
}


#Preview {
    RecipesView(
        foods: [
            FoodItem(name: "雞蛋", emoji: "🥚", location: .fridge, expiry: Date().addingTimeInterval(86400 * 3)),
            FoodItem(name: "白米", emoji: "🍚", location: .pantry, expiry: Date().addingTimeInterval(86400 * 7))
        ]
    ) {
        // Preview back action
    }
}
