import SwiftUI

struct FridgeView: View {
    @StateObject var vm = FridgeViewModel()
    @StateObject var recipeVM = RecipeViewModel()
    @State private var showAdd = false
    @State private var showAllItems = false
    @State private var isEditing = false

    let columns = [GridItem(.flexible(), spacing: 12),
                   GridItem(.flexible(), spacing: 12)]
    
    var displayedItems: [FoodItem] {
        let sortedItems = vm.items.sorted { item1, item2 in
            // 1. 即將過期的優先
            if item1.isExpiringSoon != item2.isExpiringSoon {
                return item1.isExpiringSoon
            }
            
            // 2. 有emoji的優先
            if (item1.emoji != nil) != (item2.emoji != nil) {
                return item1.emoji != nil
            }
            
            // 3. 短名稱優先（3字以下）
            if (item1.name.count <= 3) != (item2.name.count <= 3) {
                return item1.name.count <= 3
            }
            
            // 4. 按名稱字母順序
            return item1.name < item2.name
        }
        
        if showAllItems {
            return sortedItems
        } else {
            return Array(sortedItems.prefix(6)) // 只顯示前 6 個（3行 x 2列）
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
                    VStack(spacing: 40) {
                            // 小靈感標題
                            sectionHeader(title: "嘿！你可以試試...", subtitle: "Daily Inspiration")
                        
                        // 今日靈感內容
                        inspirationCard
                            .padding(.top, -20)
                        
                        // 食材分區標題
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
                            
                            if isEditing {
                                // 編輯模式按鈕
                                HStack(spacing: 12) {
                                    Button("全部刪除") {
                                        vm.removeAll()
                                        isEditing = false
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    
                                    Button("完成編輯") {
                                        isEditing = false
                                    }
                                    .font(.caption)
                                    .foregroundStyle(Color.olive)
                                }
                            } else {
                                // 注意期限說明
                                HStack(spacing: 4) {
                                    Rectangle()
                                        .fill(Color(hex: "#F9D080"))
                                        .frame(width: 8, height: 8)
                                        .cornerRadius(2)
                                    
                                    Text("注意期限")
                                        .font(.caption)
                                        .foregroundStyle(Color.charcoal.opacity(0.7))
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(displayedItems) { item in
                                FoodCard(
                                    item: item,
                                    isEditing: isEditing,
                                    onIncrease: { vm.increaseQuantity(item) },
                                    onDecrease: { vm.decreaseQuantity(item) },
                                    onDelete: { vm.remove(item) },
                                    onEnterEditMode: { isEditing = true }
                                ) {
                                    vm.markUsed(item)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, -20)
                        
                            // 顯示更多/更少按鈕
                            if vm.items.count > 6 {
                                if showAllItems {
                                    showLessButton
                                } else {
                                    showMoreButton
                                }
                            }
                            
                            // 推薦食譜區塊
                            if recipeVM.recipes.count > 1 {
                                sectionHeader(title: "推薦食譜", subtitle: "Recommended Recipes")
                                
                                LazyVGrid(columns: [GridItem(.flexible(), spacing: 24)], spacing: 24) {
                                    ForEach(Array(recipeVM.recipes.dropFirst().prefix(4))) { recipe in
                                        RecipeCard(recipe: recipe)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, -20)
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
                .background(
                    // 底部白色漸層覆蓋層
                    LinearGradient(
                        colors: [Color.white.opacity(0), Color.white.opacity(1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: UIScreen.main.bounds.width, height: 240)
                    .ignoresSafeArea(.container, edges: .bottom)
                )
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
                            
                            ForEach(r.tags, id: \.self) { tag in
                                TagChip(text: tag, color: Color.olive.opacity(0.8))
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color.warmGray)
                        }
                        .padding(16)
                    }
                    .frame(height: 60)
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
                
                Text("(還有 \(vm.items.count - 6) 項)")
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
                
                Text("(收起 \(vm.items.count - 6) 項)")
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
