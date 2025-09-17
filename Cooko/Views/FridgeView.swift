import SwiftUI

struct FridgeView: View {
    @StateObject var vm = FridgeViewModel()
    @StateObject var recipeVM = RecipeViewModel()
    @State private var showAdd = false

    let columns = [GridItem(.flexible(), spacing: 12),
                   GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack {
            // iOS 16 玻璃質感背景
            LinearGradient(
                colors: [
                    Color.cream,
                    Color.cream.opacity(0.8),
                    Color.glassCream
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 背景模糊效果
            Rectangle()
                .fill(GlassEffect.backgroundMaterial)
                .ignoresSafeArea()
                .opacity(0.3)

            ScrollView {
                VStack(spacing: 20) {
                    HeaderLogo()

                    // 今日靈感（小卡）
                    inspirationCard

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(vm.items) { item in
                            FoodCard(item: item) {
                                vm.markUsed(item)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
                .padding(.top, 12)
            }

            // 浮動新增按鈕 - iOS 16 玻璃質感
            VStack {
                Spacer()
                Button {
                    showAdd = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
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
                .padding(.bottom, 32)
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
                    
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("今日靈感")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.warmGray)
                                .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: 1)
                            
                            Text(r.title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.charcoal)
                                .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: 1)
                            
                            Text(r.tip)
                                .font(.footnote)
                                .foregroundStyle(Color.charcoal.opacity(0.8))
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Button {
                            // 之後：跳到食譜詳頁
                        } label: {
                            Text("更多")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.olive)
                                        .shadow(color: .olive.opacity(0.4), radius: 6, x: 0, y: 3)
                                )
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(20)
                }
                .frame(height: 120)
                .padding(.horizontal, 20)
            }
        }
    }
}
