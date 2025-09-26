import SwiftUI

struct FridgeView: View {
    @StateObject var vm = FridgeViewModel()
    @StateObject var recipeVM = RecipeViewModel()
    @StateObject var toolsVM = ToolsViewModel()
    @State private var showAdd = false
    @State private var isEditing = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showRecipeGeneration = false
    @State private var showRecipesPage = false
    @State private var isExpanded = false  // 縮合/展開狀態
    @State private var showRecipeDetail: Recipe? = nil

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
        
        if isExpanded {
            return sortedItems
        } else {
            return Array(sortedItems.prefix(6)) // 只顯示前 6 個（3行 x 2列）
        }
    }

    var body: some View {
        ZStack {
            // 四角不同顏色的背景漸層
            ZStack {
                // 左上角 - 溫暖米色
                RadialGradient(
                    colors: [
                        Color(hex: "#FFEECB").opacity(0.6),
                        Color.clear
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 250
                )
                
                // 右上角 - 清新綠色
                RadialGradient(
                    colors: [
                        Color(hex: "#A8E6CF").opacity(0.8),
                        Color.clear
                    ],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 220
                )
                
                // 左下角 - 柔和藍色
                RadialGradient(
                    colors: [
                        Color(hex: "#87CEEB").opacity(0.7),
                        Color.clear
                    ],
                    center: .bottomLeading,
                    startRadius: 0,
                    endRadius: 200
                )
                
                // 右下角 - 溫馨粉色
                RadialGradient(
                    colors: [
                        Color(hex: "#FFB6C1").opacity(0.8),
                        Color.clear
                    ],
                    center: .bottomTrailing,
                    startRadius: 0,
                    endRadius: 230
                )
                
                // 整體基礎色調
                Color(hex: "#F8F9FA").opacity(0.2)
            }
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
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(GlassEffect.cardMaterial)
                                        .background(
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
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
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
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
                                .frame(width: UIScreen.main.bounds.width * 0.20, height: 35)
                            }
                        }
                        .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            // 縮合模式：AddFoodCard 在最前面，自己占一行
                            if !isExpanded {
                                AddFoodCard {
                                    showAdd = true
                                }
                            }
                            
                            // 食材卡片網格
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
                                        // 點擊食材時不直接減少數量，而是顯示使用確認
                                        // vm.markUsed(item)
                                    }
                                }
                            }
                            
                            // 展開模式：AddFoodCard 在最後面，自己占一行
                            if isExpanded {
                                AddFoodCard {
                                    showAdd = true
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, -20)
                        .id("ingredients-section")
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                        
                        // 顯示更多/更少按鈕
                        if vm.items.count > 6 {
                            if isExpanded {
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
                            
                            // 精選食譜區塊
                            VStack(spacing: 20) {
                                // 精選食譜標題
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("精選食譜")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color.charcoal)
                                        
                                        Text("Featured Recipes")
                                            .font(.caption)
                                            .foregroundStyle(Color.warmGray)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        showRecipesPage = true
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text("查看更多")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                        }
                                        .foregroundStyle(Color.olive)
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                // 精選食譜卡片
                                if recipeVM.recipes.count > 1 {
                                    VStack(spacing: 12) {
                                        ForEach(Array(recipeVM.recipes.dropFirst().prefix(3))) { recipe in
                                            FeaturedRecipeCard(recipe: recipe) {
                                                showRecipeDetail = recipe
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                } else {
                                    // 如果沒有食譜，顯示生成按鈕
                                    VStack(spacing: 16) {
                                        Image(systemName: "book.closed")
                                            .font(.system(size: 40))
                                            .foregroundStyle(Color.warmGray.opacity(0.6))
                                        
                                        Text("還沒有精選食譜")
                                            .font(.headline)
                                            .foregroundStyle(Color.charcoal)
                                        
                                        Text("點擊下方按鈕生成你的專屬食譜")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.warmGray)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(.vertical, 40)
                                }
                            }
                            .padding(.top, -20)
                        
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
                VStack(spacing: 16) {
                    // 生成專屬食譜按鈕（主要 CTA）
                    Button {
                        showRecipeGeneration = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "wand.and.rays")
                                .font(.title2)
                            
                            Text("生成專屬食譜")
                                .fontWeight(.bold)
                                .font(.headline)
                            
                            Text("🍳")
                                .font(.title2)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 18)
                        .background(
                            Capsule()
                                .fill(Color.olive)
                        )
                    }
                    .zIndex(3) // 生成按鈕在最上層
                    
                }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .zIndex(3) // 整個底部功能區塊在最上層
        }
        }
        .sheet(isPresented: $showAdd) {
            AddFoodSheet { vm.add($0) }
        }
        .sheet(isPresented: $showRecipeGeneration) {
            RecipeGenerationSheet(
                isPresented: $showRecipeGeneration,
                foods: vm.items.filter { $0.quantity > 0 }
            ) { request in
                // 生成食譜後跳轉到食譜頁面
                showRecipesPage = true
            }
        }
        .fullScreenCover(isPresented: $showRecipesPage) {
            RecipesView(foods: vm.items.filter { $0.quantity > 0 }) {
                showRecipesPage = false
            }
        }
        .sheet(item: $showRecipeDetail) { recipe in
            RecipeDetailView(recipe: recipe) {
                showRecipeDetail = nil
            }
        }
        .task {
            // 開App打一次（之後可換成真正的靈感API）
            if recipeVM.recipes.isEmpty {
                await recipeVM.generate(from: vm.items)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            // App 進入背景時自動縮回
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // App 回到前景時確保是縮合狀態
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded = false
            }
        }
    }

    private var inspirationCard: some View {
        Group {
            if let r = recipeVM.recipes.first {
                Button {
                    showRecipeDetail = r
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
                            
                            if let firstTag = r.tags.first {
                                TagChip(text: firstTag, color: Color.olive.opacity(0.8))
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
                isExpanded = true
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
                isExpanded = false
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
