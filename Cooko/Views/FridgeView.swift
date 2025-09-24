import SwiftUI

struct FridgeView: View {
    @StateObject var vm = FridgeViewModel()
    @StateObject var recipeVM = RecipeViewModel()
    @StateObject var toolsVM = ToolsViewModel()
    @State private var showAdd = false
    @State private var showAllItems = false
    @State private var isEditing = false
    @State private var scrollOffset: CGFloat = 0

    let columns = [GridItem(.flexible(), spacing: 12),
                   GridItem(.flexible(), spacing: 12)]
    
    // 計算標題透明度
    var headerOpacity: Double {
        let maxOffset: CGFloat = 100 // 滾動100點後完全透明
        let opacity = max(0, 1 - scrollOffset / maxOffset)
        return min(1, opacity)
    }
    
    var displayedItems: [FoodItem] {
        // 先過濾掉數量為0的食材
        let filteredItems = vm.items.filter { $0.quantity > 0 }
        
        let sortedItems = filteredItems.sorted { item1, item2 in
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
                    Color(hex: "#FFEECB"),  // top: 淺米色
                    Color(hex: "#F5F5F5"),  // 中間: 淺灰白
                    Color(hex: "#E8F5E8"),  // 中下: 淺綠白
                    Color(hex: "#CADABB")   // bottom: 淺綠色
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false) // 不攔截觸控事件
            .zIndex(-1)
            

            VStack(spacing: 0) {
                // 固定標題 - 靠左對齊
                HStack {
                    HeaderLogo()
                        .opacity(headerOpacity)
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.bottom, 16)
                .padding(.horizontal, 20)
                
                
                ScrollViewReader { mainProxy in
                    ScrollView {
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                        }
                        .frame(height: 0)
                        
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
                                // 注意期限說明 - 與食材卡片格式相同
                                ZStack {
                                    // 圓角背景塊
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(GlassEffect.cardMaterial)
                                        .background(
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                    .fill(.white.opacity(0.1))
                                                
                                                // 右方橘色漸層
                                                VStack {
                                                    HStack {
                                                        Spacer()
                                                        LinearGradient(
                                                            colors: [
                                                                Color(hex: "#FF8C00").opacity(0.6),
                                                                Color(hex: "#FF8C00").opacity(0.4),
                                                                Color(hex: "#FF8C00").opacity(0.2),
                                                                Color.clear
                                                            ],
                                                            startPoint: .topTrailing,
                                                            endPoint: .bottomLeading
                                                        )
                                                        .frame(width: 30, height: 30)
                                                        .cornerRadius(12)
                                                        .clipped()
                                                    }
                                                    Spacer()
                                                }
                                            }
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [.white.opacity(0.6), .white.opacity(0.2)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1.5
                                                )
                                        )
                                        .shadow(color: .glassShadow, radius: 8, x: 0, y: 4)
                                        .shadow(color: .glassShadow.opacity(0.3), radius: 20, x: 0, y: 8)
                                    
                                    // 文字內容
                                    Text("注意期限")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.charcoal)
                                        .minimumScaleFactor(0.8)
                                        .lineLimit(1)
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.20, height: 45)
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
                        .id("ingredients-section")
                        
                            // 顯示更多/更少按鈕
                            if vm.items.count > 6 {
                                if showAllItems {
                                    showLessButton(scrollProxy: mainProxy)
                                        .padding(.top, -30)
                                } else {
                                    showMoreButton
                                        .padding(.top, -30)
                                }
                            }
                            
                            // 工具區塊
                            sectionHeader(title: "可用廚房工具", subtitle: "Available Kitchen Tools")
                            
                            ScrollViewReader { proxy in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(toolsVM.tools) { tool in
                                            ToolCard(tool: tool) {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    toolsVM.toggleToolAvailability(tool)
                                                }
                                            }
                                            .id(tool.id)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                                .onAppear {
                                    // 應用載入時自動滾動到最左邊
                                    if let firstTool = toolsVM.tools.first {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            proxy.scrollTo(firstTool.id, anchor: .leading)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, -20)
                            
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
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                }
                }
            }

            // 底部白色漸層覆蓋層
            LinearGradient(
                colors: [Color.white.opacity(0), Color.white.opacity(1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: UIScreen.main.bounds.width, height: 200)
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 160)
            .ignoresSafeArea(.all, edges: .bottom)
            .allowsHitTesting(false) // 不攔截觸控事件，讓按鈕可以正常點擊
            .zIndex(0) // 降低zIndex，讓按鈕在上層

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
                    .zIndex(2) // 新增食材按鈕在最上層
                    
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
            .padding(.bottom, 20)
            .zIndex(3) // 整個底部功能區塊在最上層
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
    
    private func showLessButton(scrollProxy: ScrollViewProxy) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                showAllItems = false
            }
            // 延遲一點時間讓動畫完成後再滾動
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    scrollProxy.scrollTo("ingredients-section", anchor: .top)
                }
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

// 滾動位置追蹤的 PreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    FridgeView()
}
