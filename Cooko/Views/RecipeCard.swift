import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        Button {
            // TODO: 顯示食譜詳情
        } label: {
            ZStack {
                // iOS 16 強烈玻璃質感
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
                
                VStack(alignment: .leading, spacing: 12) {
                    // 標題和標籤
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe.title)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.charcoal)
                                .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: 1)
                            
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
                    
                    // 食材列表
                    VStack(alignment: .leading, spacing: 4) {
                        Text("所需食材")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.warmGray)
                        
                        Text(recipe.ingredients.joined(separator: " • "))
                            .font(.caption)
                            .foregroundStyle(Color.charcoal.opacity(0.8))
                            .lineLimit(2)
                    }
                    
                    // 小提示
                    if !recipe.tip.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption2)
                                .foregroundStyle(Color.warnOrange)
                            
                            Text(recipe.tip)
                                .font(.caption2)
                                .foregroundStyle(Color.charcoal.opacity(0.7))
                                .lineLimit(1)
                            
                            Spacer()
                        }
                    }
                }
                .padding(16)
            }
            .frame(height: 140)
        }
    }
}

#Preview {
    RecipeCard(recipe: Recipe(
        title: "蛋炒飯",
        ingredients: ["雞蛋", "白米", "洋蔥", "橄欖油", "鹽"],
        steps: ["1. 熱鍋下油", "2. 炒散雞蛋", "3. 加入洋蔥炒香", "4. 倒入白飯炒勻"],
        tags: ["經典美味", "15分鐘"],
        tip: "用隔夜飯炒更香！"
    ))
    .padding()
    .background(Color.cream)
}
