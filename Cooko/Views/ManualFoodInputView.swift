import SwiftUI

struct ManualFoodInputView: View {
    @Binding var isPresented: Bool
    @State private var foodName = ""
    
    let onConfirm: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 標題區域
                headerSection
                
                // 輸入表單區域
                formSection
                
                // 底部按鈕區域
                bottomSection
            }
            .background(Color(hex: "#F8F9FA"))
            .navigationBarHidden(true)
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
                
                Text("手動輸入食材")
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
                Text("請輸入食材名稱")
                    .font(.subheadline)
                    .foregroundStyle(Color.charcoal)
                
                Text("可以隨意輸入，我們會透過 AI 分析並優化食材資訊")
                    .font(.caption)
                    .foregroundStyle(Color.warmGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - 表單區域
    private var formSection: some View {
        VStack(spacing: 24) {
            // 食材名稱輸入
            VStack(alignment: .leading, spacing: 12) {
                Text("食材名稱")
                    .font(.headline)
                    .foregroundStyle(Color.charcoal)
                
                        TextField("請輸入食材名稱", text: $foodName, axis: .vertical)
                            .textFieldStyle(ManualInputTextFieldStyle())
                            .lineLimit(5...10)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 底部區域
    private var bottomSection: some View {
        VStack(spacing: 16) {
            Spacer()
            
            // 確認按鈕
            Button(action: {
                if foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    showEmptyInputAlert()
                } else {
                    onConfirm(foodName.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "wand.and.rays")
                        .font(.headline)
                    
                    Text("AI 分析並新增")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(isValidInput ? Color.olive : Color.gray)
                )
            }
            .buttonStyle(.plain)
            
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
    
    // MARK: - 計算屬性
    private var isValidInput: Bool {
        !foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - 輔助方法
    private func showEmptyInputAlert() {
        let alert = UIAlertController(
            title: "請輸入食材名稱",
            message: "請在輸入框中輸入要分析的食材名稱。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        
        // 顯示 alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
}

// MARK: - 自定義文字輸入框樣式
struct ManualInputTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(minHeight: 120) // 設定最小高度支援多行
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.warmGray.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}


// MARK: - 預覽
#Preview {
    ManualFoodInputView(
        isPresented: .constant(true),
        onConfirm: { name in
            print("新增食材: \(name)")
        }
    )
}
