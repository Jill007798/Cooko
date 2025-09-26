import SwiftUI

struct FeaturedRecipeCard: View {
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
                
                HStack(alignment: .top, spacing: 16) {
                    // 左側：標題和標籤
                    VStack(alignment: .leading, spacing: 12) {
                        Text(recipe.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.charcoal)
                            .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: 1)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 8) {
                            ForEach(recipe.tags.prefix(3), id: \.self) { tag in
                                TagChip(text: tag, color: Color.olive.opacity(0.8))
                            }
                        }
                        
                        // 小提示
                        if !recipe.tip.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.warnOrange)
                                
                                Text(recipe.tip)
                                    .font(.caption)
                                    .foregroundStyle(Color.charcoal.opacity(0.7))
                                    .lineLimit(2)
                                
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 右側：食材列表
                    VStack(alignment: .leading, spacing: 8) {
                        Text("所需食材")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.warmGray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(recipe.ingredients.prefix(4), id: \.self) { ingredient in
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.olive.opacity(0.6))
                                        .frame(width: 4, height: 4)
                                    
                                    Text(ingredient)
                                        .font(.caption)
                                        .foregroundStyle(Color.charcoal.opacity(0.8))
                                        .lineLimit(1)
                                    
                                    Spacer()
                                }
                            }
                            
                            if recipe.ingredients.count > 4 {
                                Text("+ \(recipe.ingredients.count - 4) 更多")
                                    .font(.caption2)
                                    .foregroundStyle(Color.olive)
                                    .padding(.top, 2)
                            }
                        }
                    }
                    .frame(width: 120, alignment: .leading)
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity, minHeight: 160)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            FeaturedRecipeCard(recipe: Recipe(
                title: "完美蛋炒飯",
                ingredients: ["雞蛋", "白米", "洋蔥", "橄欖油", "鹽"],
                steps: ["1. 熱鍋下油", "2. 炒散雞蛋", "3. 加入洋蔥炒香", "4. 倒入白飯炒勻"],
                tags: ["經典美味", "15分鐘"],
                tip: "用隔夜飯炒更香！"
            )) {
                // Preview action
            }
            
            FeaturedRecipeCard(recipe: Recipe(
                title: "清爽蔬菜沙拉",
                ingredients: ["生菜", "番茄", "胡蘿蔔", "橄欖油"],
                steps: ["1. 蔬菜洗淨切絲", "2. 調製油醋醬", "3. 拌勻即可"],
                tags: ["超健康", "5分鐘"],
                tip: "新鮮蔬菜最美味！"
            )) {
                // Preview action
            }
        }
        .padding(.horizontal, 20)
    }
    .background(Color.gray.opacity(0.1))
}
