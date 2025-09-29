import SwiftUI

struct FoodConfirmationView: View {
    @Binding var isPresented: Bool
    @State private var analyzedFoods: [AnalyzedFood]
    @State private var capturedImages: [UIImage]
    let onConfirm: ([AnalyzedFood]) -> Void
    
    init(
        isPresented: Binding<Bool>,
        analyzedFoods: [AnalyzedFood],
        capturedImages: [UIImage],
        onConfirm: @escaping ([AnalyzedFood]) -> Void
    ) {
        self._isPresented = isPresented
        self._analyzedFoods = State(wrappedValue: analyzedFoods)
        self.capturedImages = capturedImages
        self.onConfirm = onConfirm
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 標題區域
                headerSection
                
                // 照片預覽區域
                if !capturedImages.isEmpty {
                    photoPreviewSection
                }
                
                // 食材清單區域
                foodListSection
                
                // 統計和操作區域
                statsAndActionsSection
            }
            .background(Color(hex: "#F8F9FA"))
            .navigationBarHidden(true)
        }
        .onAppear {
            print("🔍 FoodConfirmationView - onAppear: analyzedFoods count = \(analyzedFoods.count)")
            print("🔍 FoodConfirmationView - onAppear: analyzedFoods = \(analyzedFoods.map { $0.name })")
        }
    }
    
    // MARK: - 標題區域
    private var headerSection: some View {
        VStack(spacing: 16) {
            // 關閉按鈕和標題
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundStyle(Color.warmGray)
                }
                
                Spacer()
                
                Text("確認食材")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.charcoal)
                
                Spacer()
                
                // 佔位符，保持標題居中
                Color.clear
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // 說明文字
            VStack(spacing: 8) {
                Text("請問是這些嗎？")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.charcoal)
                
                Text("請檢查並選擇要新增的食材")
                    .font(.subheadline)
                    .foregroundStyle(Color.warmGray)
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - 照片預覽區域
    private var photoPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分析的照片")
                .font(.headline)
                .foregroundStyle(Color.charcoal)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(capturedImages.enumerated()), id: \.offset) { index, image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - 食材清單區域
    private var foodListSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(analyzedFoods.enumerated()), id: \.element.id) { index, food in
                    foodItemRow(food: food, index: index)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(maxHeight: 400)
    }
    
    // MARK: - 食材項目
    private func foodItemRow(food: AnalyzedFood, index: Int) -> some View {
        HStack(spacing: 12) {
            // 選擇按鈕
            Button(action: {
                analyzedFoods[index].isSelected.toggle()
            }) {
                Image(systemName: analyzedFoods[index].isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(analyzedFoods[index].isSelected ? Color.olive : Color.warmGray)
            }
            .buttonStyle(.plain)
            
            // 食材圖示
            Text(food.emoji)
                .font(.title)
            
            // 食材資訊
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.headline)
                    .foregroundStyle(Color.charcoal)
                
                Text(food.location.rawValue)
                    .font(.caption)
                    .foregroundStyle(Color.warmGray)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(analyzedFoods[index].isSelected ? Color.olive.opacity(0.1) : Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(analyzedFoods[index].isSelected ? Color.olive.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
    }
    
    // MARK: - 統計和操作區域
    private var statsAndActionsSection: some View {
        VStack(spacing: 16) {
            // 統計信息
            HStack {
                Text("已選擇 \(analyzedFoods.filter { $0.isSelected }.count) / \(analyzedFoods.count) 項")
                    .font(.caption)
                    .foregroundStyle(Color.warmGray)
                
                Spacer()
                
                if !analyzedFoods.isEmpty {
                    Button("全選") {
                        for index in analyzedFoods.indices {
                            analyzedFoods[index].isSelected = true
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(Color.olive)
                }
            }
            .padding(.horizontal, 20)
            
            // 操作按鈕
            VStack(spacing: 12) {
                // 確認按鈕
                Button(action: {
                    let selectedFoods = analyzedFoods.filter { $0.isSelected }
                    onConfirm(selectedFoods)
                    isPresented = false
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.headline)
                        
                        Text("確認新增食材")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(analyzedFoods.contains { $0.isSelected } ? Color.olive : Color.gray)
                    )
                }
                .buttonStyle(.plain)
                .disabled(!analyzedFoods.contains { $0.isSelected })
                
                // 取消按鈕
                Button(action: {
                    isPresented = false
                }) {
                    Text("取消")
                        .font(.subheadline)
                        .foregroundStyle(Color.warmGray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}

// MARK: - 預覽
#Preview {
    FoodConfirmationView(
        isPresented: .constant(true),
        analyzedFoods: [
            AnalyzedFood(name: "蘋果", emoji: "🍎", location: .fridge),
            AnalyzedFood(name: "香蕉", emoji: "🍌", location: .fridge),
            AnalyzedFood(name: "胡蘿蔔", emoji: "🥕", location: .fridge),
            AnalyzedFood(name: "馬鈴薯", emoji: "🥔", location: .pantry),
            AnalyzedFood(name: "雞蛋", emoji: "🥚", location: .fridge)
        ],
        capturedImages: [],
        onConfirm: { selectedFoods in
            print("確認新增 \(selectedFoods.count) 種食材")
        }
    )
}
