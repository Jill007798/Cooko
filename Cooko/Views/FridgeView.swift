import SwiftUI

struct FridgeView: View {
    @StateObject var vm = FridgeViewModel()
    @StateObject var recipeVM = RecipeViewModel()
    @State private var showAdd = false

    let columns = [GridItem(.flexible(), spacing: 12),
                   GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack {
            // 極淺木紋感（先用純色模擬，之後可換圖）
            Color.cream.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    HeaderLogo()

                    // 今日靈感（小卡）
                    inspirationCard

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(vm.items) { item in
                            FoodCard(item: item) {
                                vm.markUsed(item)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
                .padding(.top, 8)
            }

            // 浮動新增按鈕
            VStack {
                Spacer()
                Button {
                    showAdd = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("新增食材")
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.olive))
                    .shadow(radius: 6, y: 3)
                }
                .padding(.bottom, 24)
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
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.4)))
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("今日靈感")
                                .font(.subheadline).foregroundStyle(Color.warmGray)
                            Text(r.title)
                                .font(.title3).bold().foregroundStyle(Color.charcoal)
                            Text(r.tip)
                                .font(.footnote).foregroundStyle(Color.charcoal.opacity(0.8))
                        }
                        Spacer()
                        Button {
                            // 之後：跳到食譜詳頁
                        } label: {
                            Text("更多")
                                .font(.caption).bold()
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color.olive))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(16)
                }
                .frame(height: 110)
                .padding(.horizontal, 16)
            }
        }
    }
}
