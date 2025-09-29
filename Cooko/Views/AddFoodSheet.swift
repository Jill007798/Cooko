import SwiftUI
import PhotosUI

struct AddFoodSheet: View {
    @Binding var isPresented: Bool
    @State private var selectedMethod: AddFoodMethod = .manual
    @State private var foodName = ""
    @State private var isShowingCamera = false
    @State private var isShowingScanner = false
    @State private var isShowingReceiptScanner = false
    @State private var capturedImages: [UIImage] = []
    @State private var isShowingImagePicker = false
    @State private var isShowingPhotoPicker = false
    @State private var selectedPhotos: [PHPickerResult] = []
    @State private var isAnalyzing = false
    @State private var showFoodConfirmation = false
    @State private var isShowingManualInput = false
    @State private var analyzedFoods: [AnalyzedFood] = []
    @State private var confirmationData: ConfirmationData?
    @State private var showNoFoodAlert = false
    @StateObject private var imageAnalysisService = ImageAnalysisService.shared
    
    struct ConfirmationData: Identifiable {
        let id = UUID()
        let analyzedFoods: [AnalyzedFood]
        let capturedImages: [UIImage]
    }
    
    enum AddFoodMethod: String, CaseIterable {
        case manual = "手動輸入"
        case camera = "拍照AI分析"
        case receipt = "掃發票"
        case card = "綁定載具"
        
        var icon: String {
            switch self {
            case .manual: return "keyboard"
            case .camera: return "camera"
            case .receipt: return "doc.text.viewfinder"
            case .card: return "creditcard"
            }
        }
        
        var description: String {
            switch self {
            case .manual: return "手動輸入食材名稱"
            case .camera: return "拍照識別食材，可累積多張照片"
            case .receipt: return "掃描發票自動提取食材清單"
            case .card: return "綁定載具自動同步購買紀錄"
            }
        }
        
        var color: Color {
            switch self {
            case .manual: return Color(hex: "#8B9DC3") // 莫蘭迪藍
            case .camera: return Color(hex: "#A8C8A8") // 莫蘭迪綠
            case .receipt: return Color(hex: "#D4A5A5") // 莫蘭迪粉
            case .card: return Color(hex: "#B8A9C9") // 莫蘭迪紫
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 標題區域
                HStack {
                    // 左上角關閉按鈕
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.warmGray)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color.warmGray.opacity(0.1))
                            )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // 標題
                VStack(spacing: 8) {
                    Text("新增食材")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.charcoal)
                    
                    Text("選擇新增食材的方式")
                        .font(.subheadline)
                        .foregroundStyle(Color.warmGray)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // 方法選擇
                VStack(spacing: 16) {
                    ForEach(AddFoodMethod.allCases, id: \.self) { method in
                        MethodCard(
                            method: method,
                            isSelected: selectedMethod == method,
                            onTap: {
                                selectedMethod = method
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // 拍照功能區域
                if selectedMethod == .camera {
                    if isAnalyzing {
                        analyzingSection
                    } else {
                        cameraSection
                    }
                } else {
                    Spacer()
                }
                
                // 底部按鈕
                VStack(spacing: 12) {
                    Button(action: {
                        if selectedMethod == .camera {
                            handleCameraSubmit()
                        } else {
                            handleMethodSelection()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: buttonIcon)
                                .font(.headline)
                            
                            Text(buttonText)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(buttonColor)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isButtonDisabled)
                    
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
            .background(Color(hex: "#F8F9FA"))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: .constant(nil)) { image in
                if let image = image {
                    capturedImages.append(image)
                }
            }
        }
        .sheet(isPresented: $isShowingPhotoPicker) {
            PhotoPicker(selectedPhotos: $selectedPhotos)
        }
        .onChange(of: selectedPhotos) { _, newPhotos in
            Task {
                for photo in newPhotos {
                    await withCheckedContinuation { continuation in
                        photo.itemProvider.loadDataRepresentation(forTypeIdentifier: "public.image") { data, error in
                            if let data = data, let image = UIImage(data: data) {
                                capturedImages.append(image)
                            }
                            continuation.resume()
                        }
                    }
                }
                selectedPhotos = []
            }
        }
                   .sheet(item: $confirmationData) { data in
                       FoodConfirmationView(
                           isPresented: Binding(
                               get: { confirmationData != nil },
                               set: { if !$0 { confirmationData = nil } }
                           ),
                           analyzedFoods: data.analyzedFoods,
                           capturedImages: data.capturedImages,
                           onConfirm: handleFoodConfirmation
                       )
                   }
        .alert("未檢測到食材", isPresented: $showNoFoodAlert) {
            Button("重新選擇") {
                resetCameraState()
            }
        } message: {
            Text("很抱歉，我們沒有分析出任何食材。請重新嘗試或選擇其他新增方式。")
        }
        .sheet(isPresented: $isShowingScanner) {
            ScannerView { result in
                // TODO: 處理掃描結果
                print("掃描結果: \(result)")
            }
        }
        .sheet(isPresented: $isShowingReceiptScanner) {
            ReceiptScannerView { result in
                // TODO: 處理發票掃描結果
                print("發票掃描結果: \(result)")
            }
        }
        .sheet(isPresented: $isShowingManualInput) {
            ManualFoodInputView(
                isPresented: $isShowingManualInput,
                onConfirm: { name in
                    isShowingManualInput = false
                    handleManualFoodInput(name: name)
                }
            )
        }
    }
    
    private func handleMethodSelection() {
        switch selectedMethod {
        case .manual:
            isShowingManualInput = true
        case .camera:
            showCameraOptions()
        case .receipt:
            isShowingReceiptScanner = true
        case .card:
            // TODO: 顯示載具綁定頁面
            print("💳 綁定載具")
        }
    }
    
    private func showCameraOptions() {
        // 顯示相機選項的 ActionSheet
        let alert = UIAlertController(title: "選擇照片來源", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "拍照", style: .default) { _ in
            isShowingImagePicker = true
        })
        
        alert.addAction(UIAlertAction(title: "從相簿選擇", style: .default) { _ in
            isShowingPhotoPicker = true
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
    
    private func handleCameraSubmit() {
        guard !capturedImages.isEmpty else { return }
        
        // 開始分析
        isAnalyzing = true
        print("📸 開始分析 \(capturedImages.count) 張照片")
        
        Task {
            do {
                // 調用圖片分析服務
                let results = try await imageAnalysisService.analyzeFoodImages(capturedImages)
                
                await MainActor.run {
                    if results.isEmpty {
                        // 沒有分析出任何食材，直接顯示 alert
                        showNoFoodDetectedAlert()
                        isAnalyzing = false
                    } else {
                        analyzedFoods = results
                        isAnalyzing = false
                        print("✅ 分析完成，識別出 \(results.count) 種食材")
                        // 延遲一點點時間確保 analyzedFoods 已經設置
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            confirmationData = ConfirmationData(
                                analyzedFoods: results,
                                capturedImages: capturedImages
                            )
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    print("❌ 分析失敗: \(error.localizedDescription)")
                    // 這裡可以顯示錯誤提示給用戶
                }
            }
        }
    }
    
    private func resetCameraState() {
        capturedImages.removeAll()
        analyzedFoods.removeAll()
        showFoodConfirmation = false
        isAnalyzing = false
    }
    
    private func handleFoodConfirmation(_ selectedFoods: [AnalyzedFood]) {
        // 檢查是否有選中的食材
        if selectedFoods.isEmpty {
            print("⚠️ 沒有選中任何食材")
            resetCameraState()
            return
        }
        
        // 將選中的食材添加到冰箱
        for food in selectedFoods {
            // TODO: 實際添加到 FridgeViewModel
            print("✅ 新增食材: \(food.name) (\(food.emoji))")
        }
        
        // 重置狀態並關閉
        resetCameraState()
        confirmationData = nil
        isPresented = false
    }
    
    private func handleManualFoodInput(name: String) {
        // 開始 AI 分析手動輸入的食材
        isAnalyzing = true
        print("🤖 開始 AI 分析手動輸入: \(name)")
        
        Task {
            do {
                // 調用圖片分析服務來分析文字輸入
                let results = try await imageAnalysisService.analyzeFoodText(name)
                
                await MainActor.run {
                    print("🔍 AddFoodSheet - handleManualFoodInput: results.isEmpty = \(results.isEmpty)")
                    if results.isEmpty {
                        // 沒有分析出任何食材，直接顯示 alert
                        showNoFoodDetectedAlert()
                        isAnalyzing = false
                        print("🔍 AddFoodSheet - handleManualFoodInput: showNoFoodDetectedAlert called, showFoodConfirmation = \(showFoodConfirmation)")
                    } else {
                        analyzedFoods = results
                        isAnalyzing = false
                        print("🔍 AddFoodSheet - handleManualFoodInput: analyzedFoods set, count = \(analyzedFoods.count)")
                        // 延遲一點點時間確保 analyzedFoods 已經設置
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            confirmationData = ConfirmationData(
                                analyzedFoods: results,
                                capturedImages: []
                            )
                            print("🔍 AddFoodSheet - handleManualFoodInput: confirmationData set")
                        }
                    }
                }
            } catch {
                print("❌ AI 分析失敗: \(error)")
                
                // 如果 API 失敗，使用預設格式
                await MainActor.run {
                    let fallbackFood = AnalyzedFood(
                        name: name,
                        emoji: "🥬",
                        location: .fridge
                    )
                    analyzedFoods = [fallbackFood]
                    isAnalyzing = false
                    print("🔍 AddFoodSheet - handleManualFoodInput (catch): analyzedFoods set, count = \(analyzedFoods.count)")
                    // 延遲一點點時間確保 analyzedFoods 已經設置
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        confirmationData = ConfirmationData(
                            analyzedFoods: [fallbackFood],
                            capturedImages: []
                        )
                        print("🔍 AddFoodSheet - handleManualFoodInput (catch): confirmationData set")
                    }
                }
            }
        }
    }
    
    // MARK: - 輔助方法
    private func showNoFoodDetectedAlert() {
        showNoFoodAlert = true
    }
    
    // MARK: - 計算屬性
    private var buttonIcon: String {
        if selectedMethod == .camera {
            if isAnalyzing {
                return "hourglass"
            } else {
                return "camera"
            }
        } else {
            return selectedMethod.icon
        }
    }
    
    private var buttonText: String {
        if selectedMethod == .camera {
            if isAnalyzing {
                return "分析中..."
            } else {
                return "分析照片並新增食材"
            }
        } else {
            return "使用 \(selectedMethod.rawValue)"
        }
    }
    
    private var buttonColor: Color {
        if selectedMethod == .camera {
            if isAnalyzing {
                return Color.gray
            } else {
                return capturedImages.isEmpty ? Color.gray : selectedMethod.color
            }
        } else {
            return selectedMethod.color
        }
    }
    
    private var isButtonDisabled: Bool {
        if selectedMethod == .camera {
            if isAnalyzing {
                return true
            } else {
                return capturedImages.isEmpty
            }
        } else {
            return false
        }
    }
    
    private var cameraSection: some View {
        VStack(spacing: 20) {
            // 已拍照片縮圖區域
            if !capturedImages.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("已拍照片 (\(capturedImages.count))")
                            .font(.headline)
                            .foregroundStyle(Color.charcoal)
                        
                        Spacer()
                        
                        Button("清除全部") {
                            capturedImages.removeAll()
                        }
                        .font(.caption)
                        .foregroundStyle(.red)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(capturedImages.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    Button(action: {
                                        capturedImages.remove(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption)
                                            .foregroundStyle(.white)
                                            .background(
                                                Circle()
                                                    .fill(.black.opacity(0.6))
                                            )
                                    }
                                    .offset(x: 8, y: -8)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // 拍照按鈕區域
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    // 拍照按鈕
                    Button(action: {
                        isShowingImagePicker = true
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                            
                            Text("拍照")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                        }
                        .frame(width: 80, height: 80)
                        .background(
                            Circle()
                                .fill(Color.olive)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // 相簿按鈕
                    Button(action: {
                        isShowingPhotoPicker = true
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title)
                                .foregroundStyle(.white)
                            
                            Text("相簿")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                        }
                        .frame(width: 80, height: 80)
                        .background(
                            Circle()
                                .fill(Color.olive)
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                Text("可以累積多張照片，最後一起分析")
                    .font(.caption)
                    .foregroundStyle(Color.warmGray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
    }
    
    private var analyzingSection: some View {
        VStack(spacing: 30) {
            // 分析動畫
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.olive.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .stroke(Color.olive, lineWidth: 3)
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(isAnalyzing ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnalyzing)
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.olive)
                }
                
                VStack(spacing: 8) {
                    Text("AI 分析中...")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.charcoal)
                    
                    Text("正在識別照片中的食材")
                        .font(.subheadline)
                        .foregroundStyle(Color.warmGray)
                }
            }
            
            // 照片預覽
            if !capturedImages.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("分析的照片")
                        .font(.headline)
                        .foregroundStyle(Color.charcoal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(capturedImages.enumerated()), id: \.offset) { index, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .opacity(0.7)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .padding(.vertical, 40)
    }
    
}

struct MethodCard: View {
    let method: AddFoodSheet.AddFoodMethod
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 圖標
                ZStack {
                    Circle()
                        .fill(method.color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: method.icon)
                        .font(.title2)
                        .foregroundStyle(method.color)
                }
                
                // 內容
                VStack(alignment: .leading, spacing: 4) {
                    Text(method.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.charcoal)
                    
                    Text(method.description)
                        .font(.subheadline)
                        .foregroundStyle(Color.warmGray)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // 選擇指示器
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(method.color)
                } else {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundStyle(Color.warmGray.opacity(0.5))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? method.color.opacity(0.05) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? method.color : Color.warmGray.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// 暫時的佔位視圖
struct CameraView: View {
    let onResult: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("拍照AI分析")
                    .font(.title)
                    .padding()
                
                Text("此功能將在後續版本中實現")
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button("關閉") {
                    dismiss()
                }
                .padding()
            }
            .navigationTitle("拍照識別")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ScannerView: View {
    let onResult: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("掃描功能")
                    .font(.title)
                    .padding()
                
                Text("此功能將在後續版本中實現")
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button("關閉") {
                    dismiss()
                }
                .padding()
            }
            .navigationTitle("掃描")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ReceiptScannerView: View {
    let onResult: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("發票掃描")
                    .font(.title)
                    .padding()
                
                Text("此功能將在後續版本中實現")
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button("關閉") {
                    dismiss()
                }
                .padding()
            }
            .navigationTitle("發票掃描")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AddFoodSheet(isPresented: .constant(true))
}