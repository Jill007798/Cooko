import SwiftUI

struct AddFoodSheet: View {
    @Binding var isPresented: Bool
    @State private var selectedMethod: AddFoodMethod = .manual
    @State private var foodName = ""
    @State private var isShowingCamera = false
    @State private var isShowingScanner = false
    @State private var isShowingReceiptScanner = false
    
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
            case .camera: return "拍照識別食材並自動填入"
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
                
                Spacer()
                
                // 底部按鈕
                VStack(spacing: 12) {
                    Button(action: {
                        handleMethodSelection()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: selectedMethod.icon)
                                .font(.headline)
                            
                            Text("使用 \(selectedMethod.rawValue)")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(selectedMethod.color)
                        )
                    }
                    .buttonStyle(.plain)
                    
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
        .sheet(isPresented: $isShowingCamera) {
            CameraView { result in
                // TODO: 處理拍照結果
                print("拍照結果: \(result)")
            }
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
    }
    
    private func handleMethodSelection() {
        switch selectedMethod {
        case .manual:
            // TODO: 顯示手動輸入表單
            print("📝 手動輸入")
        case .camera:
            isShowingCamera = true
        case .receipt:
            isShowingReceiptScanner = true
        case .card:
            // TODO: 顯示載具綁定頁面
            print("💳 綁定載具")
        }
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