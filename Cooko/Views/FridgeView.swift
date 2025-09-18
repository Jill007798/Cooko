import SwiftUI

struct FridgeView: View {
    @StateObject var vm = FridgeViewModel()
    @StateObject var recipeVM = RecipeViewModel()
    @State private var showAdd = false
    @State private var showAllItems = false

    let columns = [GridItem(.flexible(), spacing: 12),
                   GridItem(.flexible(), spacing: 12),
                   GridItem(.flexible(), spacing: 12)]
    
    var displayedItems: [FoodItem] {
        if showAllItems {
            return vm.items
        } else {
            return Array(vm.items.prefix(9)) // 只顯示前 9 個（3行 x 3列）
        }
    }

    var body: some View {
        ZStack {
            // 垂直線性漸層背景
            LinearGradient(
                colors: [
                    Color(hex: "#FFEECB"),  // top: 0%
                    Color(hex: "#FFFFFF"),  // 37%
                    Color(hex: "#FFFFFF"),  // 63%
                    Color(hex: "#CADABB")   // bottom: 100%
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 背景模糊效果
            Rectangle()
                .fill(GlassEffect.backgroundMaterial)
                .ignoresSafeArea()
                .opacity(0.3)

            VStack(spacing: 0) {
                // 固定標題 - 靠左對齊
                HStack {
                    HeaderLogo()
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.bottom, 16)
                .padding(.horizontal, 20)
                
                ScrollView {
                    VStack(spacing: 20) {
                            // 小靈感標題
                            sectionHeader(title: "小靈感", subtitle: "Daily Inspiration")
                        
                        // 今日靈感內容
                        inspirationCard
                        
                        // 食材分區標題與新增按鈕
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("冰箱有什麼")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.charcoal)
                                
                                Text("Available ingredients")
                                    .font(.caption)
                                    .foregroundStyle(Color.warmGray)
                            }
                            
                            Spacer()
                            
                            // 新增食材按鈕
                            Button {
                                showAdd = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                    Text("新增食材")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(Color.olive)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(.white.opacity(0.8))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.olive.opacity(0.3), lineWidth: 1)
                                        )
                                        .shadow(color: .glassShadow, radius: 4, x: 0, y: 2)
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(displayedItems) { item in
                                FoodCard(item: item) {
                                    vm.markUsed(item)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                            // 顯示更多/更少按鈕
                            if vm.items.count > 9 {
                                if showAllItems {
                                    showLessButton
                                } else {
                                    showMoreButton
                                }
                            }
                            
                            // 推薦食譜區塊
                            if recipeVM.recipes.count > 1 {
                                sectionHeader(title: "推薦食譜", subtitle: "Recommended Recipes")
                                
                                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                    ForEach(Array(recipeVM.recipes.dropFirst())) { recipe in
                                        RecipeCard(recipe: recipe)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        
                        Spacer()
                            .frame(height: 180)
                    }
                }
            }

            // 底部功能區塊
            VStack {
                Spacer()
                
                // 功能按鈕區塊
                HStack(spacing: 20) {
                    // 相機新增食材按鈕
                    Button {
                        showAdd = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.title3)
                            Text("新增食材")
                                .fontWeight(.bold)
                                .font(.subheadline)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color.olive)
                                .overlay(
                                    Capsule()
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .olive.opacity(0.4), radius: 12, x: 0, y: 6)
                                .shadow(color: .glassShadow, radius: 20, x: 0, y: 10)
                        )
                    }
                    
                    // 最愛清單按鈕
                    Button {
                        // TODO: 最愛清單功能
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.title2)
                            Text("最愛")
                                .font(.caption)
                        }
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color.olive.opacity(0.8))
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .olive.opacity(0.4), radius: 8, x: 0, y: 4)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
        }
        .sheet(isPresented: $showAdd) {
            AddFoodSheet { vm.add($0) }
        }
        .task {
            // 開App打一次（之後可換成真正的靈感API）
            if recipeVM.recipes.isEmpty {
                await recipeVM.generate(from: vm.items)
            }
        }
    }

    private var inspirationCard: some View {
        Group {
            if let r = recipeVM.recipes.first {
                Button {
                    // TODO: 顯示食譜詳情
                } label: {
                    ZStack {
                        // iOS 16 強烈玻璃質感
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(GlassEffect.cardMaterial)
                            .background(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(.white.opacity(0.15))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.7), .white.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: .glassShadow, radius: 12, x: 0, y: 6)
                            .shadow(color: .glassShadow.opacity(0.4), radius: 24, x: 0, y: 12)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color.warnOrange)
                                    .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: 1)
                                
                                Text(r.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.charcoal)
                                    .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: 1)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Color.warmGray)
                            }
                            
                            HStack(spacing: 8) {
                                ForEach(r.tags, id: \.self) { tag in
                                    TagChip(text: tag, color: Color.olive.opacity(0.8))
                                }
                                Spacer()
                            }
                        }
                        .padding(16)
                    }
                    .frame(height: 100)
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    
    private var showMoreButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                showAllItems = true
            }
        } label: {
            HStack(spacing: 8) {
                Text("顯示更多")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("(還有 \(vm.items.count - 9) 項)")
                    .font(.caption)
                    .foregroundStyle(Color.olive.opacity(0.7))
                
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .foregroundStyle(Color.olive)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(.white.opacity(0.8))
                    .overlay(
                        Capsule()
                            .stroke(Color.olive.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .glassShadow, radius: 4, x: 0, y: 2)
            )
        }
        .padding(.top, 16)
    }
    
    private var showLessButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                showAllItems = false
            }
        } label: {
            HStack(spacing: 8) {
                Text("顯示更少")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("(收起 \(vm.items.count - 9) 項)")
                    .font(.caption)
                    .foregroundStyle(Color.olive.opacity(0.7))
                
                Image(systemName: "chevron.up")
                    .font(.caption)
            }
            .foregroundStyle(Color.olive)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(.white.opacity(0.8))
                    .overlay(
                        Capsule()
                            .stroke(Color.olive.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .glassShadow, radius: 4, x: 0, y: 2)
            )
        }
        .padding(.top, 16)
    }
    
    private func sectionHeader(title: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.charcoal)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.warmGray)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    FridgeView()
}
