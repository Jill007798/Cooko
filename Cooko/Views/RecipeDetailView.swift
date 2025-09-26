import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    let onDismiss: () -> Void
    @State private var showGuidedMode = false
    
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
                        // 食譜標題區域
                        VStack(spacing: 16) {
                            Text(recipe.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.charcoal)
                                .multilineTextAlignment(.center)
                            
                            // 標籤
                            HStack(spacing: 8) {
                                ForEach(recipe.tags, id: \.self) { tag in
                                    TagChip(text: tag, color: Color.olive.opacity(0.8))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // 小精靈語
                        if !recipe.tip.isEmpty {
                            HStack(spacing: 12) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.warnOrange)
                                
                                Text(recipe.tip)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.charcoal)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white.opacity(0.6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.warnOrange.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: .glassShadow, radius: 4, x: 0, y: 2)
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // 食材清單
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("食材清單")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.charcoal)
                                
                                Spacer()
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { index, ingredient in
                                    HStack(spacing: 8) {
                                        Text("\(index + 1)")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                            .frame(width: 20, height: 20)
                                            .background(
                                                Circle()
                                                    .fill(Color.olive)
                                            )
                                        
                                        Text(ingredient)
                                            .font(.subheadline)
                                            .foregroundStyle(Color.charcoal)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.white.opacity(0.6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.olive.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 製作步驟
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("製作步驟")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.charcoal)
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 16) {
                                if recipe.steps.isEmpty {
                                    // 如果沒有步驟，顯示提示訊息
                                    VStack(spacing: 12) {
                                        Image(systemName: "exclamationmark.triangle")
                                            .font(.title2)
                                            .foregroundStyle(Color.warnOrange)
                                        
                                        Text("此食譜暫無詳細步驟")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.charcoal)
                                        
                                        Text("請稍後再試或選擇其他食譜")
                                            .font(.caption)
                                            .foregroundStyle(Color.warmGray)
                                    }
                                    .padding(.vertical, 20)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.white.opacity(0.6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.warnOrange.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                } else {
                                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                                        HStack(alignment: .center, spacing: 16) {
                                            // 步驟編號
                                            Text("\(index + 1)")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.white)
                                                .frame(width: 32, height: 32)
                                                .background(
                                                    Circle()
                                                        .fill(Color.olive)
                                                        .shadow(color: .olive.opacity(0.3), radius: 4, x: 0, y: 2)
                                                )
                                            
                                            // 步驟內容
                                            Text(step)
                                                .font(.subheadline)
                                                .foregroundStyle(Color.charcoal)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(.white.opacity(0.6))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.olive.opacity(0.2), lineWidth: 1)
                                                )
                                                .shadow(color: .glassShadow, radius: 2, x: 0, y: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 使用工具提醒
                        if !recipe.requiredTools.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("需要工具")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.charcoal)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "wrench.and.screwdriver")
                                        .font(.title3)
                                        .foregroundStyle(Color.olive)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(recipe.requiredTools, id: \.self) { tool in
                                            HStack(spacing: 6) {
                                                Text(tool)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                Capsule()
                                                    .fill(Color.olive.opacity(0.1))
                                                    .overlay(
                                                        Capsule()
                                                            .stroke(Color.olive.opacity(0.3), lineWidth: 1)
                                                    )
                                            )
                                            .foregroundStyle(Color.olive)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundStyle(Color.charcoal)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showGuidedMode = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            
                            Text("傻瓜模式")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.charcoal)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $showGuidedMode) {
                GuidedModeView(recipe: recipe) {
                    showGuidedMode = false
                }
            }
        }
    }
}

#Preview {
    RecipeDetailView(
        recipe: Recipe(
            title: "完美蛋炒飯",
            ingredients: ["雞蛋 3顆", "白米飯 2碗", "洋蔥 1/4顆", "橄欖油 2大匙", "鹽 適量", "胡椒粉 少許", "蔥花 適量"],
            steps: [
                "熱鍋下油，將雞蛋打散炒至半熟盛起",
                "同鍋下洋蔥丁炒至透明出香味",
                "倒入白飯用鍋鏟壓散炒勻",
                "加入炒蛋、鹽、胡椒粉調味",
                "最後撒上蔥花即可起鍋"
            ],
            tags: ["經典美味", "15分鐘", "家常料理"],
            tip: "用隔夜飯炒更香！記得要大火快炒",
            requiredTools: ["🍳 平底鍋", "🥄 鍋鏟", "🔥 瓦斯爐"]
        )
    ) {
        // Preview dismiss action
    }
}
