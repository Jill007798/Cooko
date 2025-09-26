import SwiftUI

struct GuidedModeView: View {
    let recipe: Recipe
    let onDismiss: () -> Void
    
    @State private var guidedSteps: [GuidedStep] = []
    @State private var currentStepIndex = 0
    @State private var isLoading = false
    
    var currentStep: GuidedStep? {
        guard currentStepIndex < guidedSteps.count else { return nil }
        return guidedSteps[currentStepIndex]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景漸層
                ZStack {
                    RadialGradient(
                        colors: [
                            Color(hex: "#FFEECB").opacity(0.3),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 200
                    )
                    
                    RadialGradient(
                        colors: [
                            Color(hex: "#A8E6CF").opacity(0.4),
                            Color.clear
                        ],
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: 180
                    )
                    
                    Color(hex: "#F8F9FA").opacity(0.3)
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
                
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color.olive)
                        
                        Text("正在為你準備傻瓜模式...")
                            .font(.headline)
                            .foregroundStyle(Color.charcoal)
                        
                        Text("AI 正在優化步驟順序")
                            .font(.subheadline)
                            .foregroundStyle(Color.warmGray)
                    }
                } else if guidedSteps.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.warnOrange)
                        
                        Text("無法載入傻瓜模式")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.charcoal)
                        
                        Text("請檢查網路連線或稍後再試")
                            .font(.subheadline)
                            .foregroundStyle(Color.warmGray)
                            .multilineTextAlignment(.center)
                        
                        // API Key 未配置的提示
                        VStack(spacing: 12) {
                            Text("💡 提示")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.olive)
                            
                            Text("如需使用 AI 功能，請在 APIConfig.swift 中配置 OpenAI API Key")
                                .font(.caption)
                                .foregroundStyle(Color.charcoal.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.olive.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.olive.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                        
                        Button {
                            loadGuidedMode()
                        } label: {
                            Text("重新載入")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color.olive)
                                )
                        }
                    }
                    .padding(.horizontal, 40)
                } else if let step = currentStep {
                    VStack(spacing: 24) {
                        // 進度指示器
                        VStack(spacing: 8) {
                            HStack {
                                Text("步驟 \(currentStepIndex + 1) / \(guidedSteps.count)")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.warmGray)
                                
                                Spacer()
                                
                                Text("\(Int((Double(currentStepIndex + 1) / Double(guidedSteps.count)) * 100))%")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.warmGray)
                            }
                            
                            ProgressView(value: Double(currentStepIndex + 1), total: Double(guidedSteps.count))
                                .tint(Color.olive)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        // 主要指令
                        VStack(spacing: 20) {
                            Text(step.command)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.charcoal)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            // 等待提示（如果有）
                            if let duration = step.durationSec, duration > 0 {
                                VStack(spacing: 12) {
                                    Text("⏰ 需要等待")
                                        .font(.headline)
                                        .foregroundStyle(Color.warnOrange)
                                    
                                    Text(formatTime(duration))
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.charcoal)
                                        .monospacedDigit()
                                    
                                    Text("請自行計時")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.warmGray)
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // 並行提示（如果有）
                            if step.parallelOk {
                                VStack(spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "lightbulb.fill")
                                            .font(.caption)
                                            .foregroundStyle(Color.warnOrange)
                                        
                                        Text("可以同時準備")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color.warnOrange)
                                    }
                                    
                                    Text("趁等待時間準備其他食材或工具")
                                        .font(.caption)
                                        .foregroundStyle(Color.charcoal.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.warnOrange.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.warnOrange.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer()
                        
                        // 控制按鈕
                        HStack(spacing: 16) {
                            if currentStepIndex > 0 {
                                Button {
                                    previousStep()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "chevron.left")
                                            .font(.headline)
                                        
                                        Text("上一步")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundStyle(Color.charcoal)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(.white.opacity(0.8))
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.charcoal.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                            
                            Spacer()
                            
                            if currentStepIndex < guidedSteps.count - 1 {
                                Button {
                                    nextStep()
                                } label: {
                                    HStack(spacing: 8) {
                                        Text("下一步")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.headline)
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(Color.olive)
                                    )
                                }
                            } else {
                                Button {
                                    onDismiss()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.headline)
                                        
                                        Text("完成")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(Color.green)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundStyle(Color.charcoal)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("傻瓜模式")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.charcoal)
                }
            }
        }
        .onAppear {
            loadGuidedMode()
        }
    }
    
    private func loadGuidedMode() {
        isLoading = true
        
        print("🚀 開始載入傻瓜模式")
        print("📋 食譜: \(recipe.title)")
        print("📝 原始步驟數量: \(recipe.steps.count)")
        
        Task {
            do {
                let chatGPTService = ChatGPTService()
                
                // 檢查 API Key 是否已配置
                if chatGPTService.isConfigured {
                    print("✅ API Key 已配置，使用 AI 優化模式")
                    print("🤖 正在呼叫 ChatGPT API...")
                    
                    let guidedRecipe = try await chatGPTService.generateGuidedRecipe(from: recipe)
                    
                    print("🎉 AI 優化完成！")
                    print("📊 優化結果:")
                    print("  - 食譜標題: \(guidedRecipe.title)")
                    print("  - 優化步驟數量: \(guidedRecipe.steps.count)")
                    
                    for (index, step) in guidedRecipe.steps.enumerated() {
                        print("  - 步驟 \(index + 1): \(step.command)")
                        if let duration = step.durationSec {
                            print("    * 需要等待: \(duration) 秒")
                        }
                        if step.parallelOk {
                            print("    * 可並行操作")
                        }
                    }
                    
                    await MainActor.run {
                        self.guidedSteps = guidedRecipe.steps
                        self.isLoading = false
                    }
                } else {
                    print("⚠️ API Key 未配置，使用本地模式")
                    print("🔄 將原始步驟轉換為指導模式...")
                    
                    await MainActor.run {
                        self.guidedSteps = generateLocalGuidedSteps()
                        self.isLoading = false
                        
                        print("📱 本地模式載入完成")
                        print("📊 本地模式結果:")
                        print("  - 步驟數量: \(self.guidedSteps.count)")
                        for (index, step) in self.guidedSteps.enumerated() {
                            print("  - 步驟 \(index + 1): \(step.command)")
                        }
                    }
                }
            } catch {
                print("❌ AI 模式載入失敗: \(error)")
                print("🔄 自動回退到本地模式...")
                
                await MainActor.run {
                    // 如果 AI 模式失敗，回退到本地模式
                    self.guidedSteps = generateLocalGuidedSteps()
                    self.isLoading = false
                    
                    print("📱 本地模式回退完成")
                    print("📊 回退模式結果:")
                    print("  - 步驟數量: \(self.guidedSteps.count)")
                    for (index, step) in self.guidedSteps.enumerated() {
                        print("  - 步驟 \(index + 1): \(step.command)")
                    }
                }
            }
        }
    }
    
    private func generateLocalGuidedSteps() -> [GuidedStep] {
        // 本地模式：將原始步驟轉換為簡單的指導步驟
        return recipe.steps.enumerated().map { index, step in
            GuidedStep(
                id: index + 1,
                command: step,
                durationSec: nil,
                parallelOk: false
            )
        }
    }
    
    private func nextStep() {
        if currentStepIndex < guidedSteps.count - 1 {
            let oldIndex = currentStepIndex
            currentStepIndex += 1
            
            print("➡️ 進入下一步")
            print("  - 從步驟 \(oldIndex + 1) 到步驟 \(currentStepIndex + 1)")
            if let step = currentStep {
                print("  - 新指令: \(step.command)")
                if let duration = step.durationSec {
                    print("  - 需要等待: \(duration) 秒")
                }
                if step.parallelOk {
                    print("  - 可並行操作")
                }
            }
        }
    }
    
    private func previousStep() {
        if currentStepIndex > 0 {
            let oldIndex = currentStepIndex
            currentStepIndex -= 1
            
            print("⬅️ 回到上一步")
            print("  - 從步驟 \(oldIndex + 1) 到步驟 \(currentStepIndex + 1)")
            if let step = currentStep {
                print("  - 當前指令: \(step.command)")
            }
        }
    }
    
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

// 資料模型
struct GuidedRecipe: Codable {
    let title: String
    let steps: [GuidedStep]
}

struct GuidedStep: Codable {
    let id: Int
    let command: String
    let durationSec: Int?
    let parallelOk: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, command
        case durationSec = "duration_sec"
        case parallelOk = "parallel_ok"
    }
    
    // 自定義初始化器，用於創建 GuidedStep 實例
    init(id: Int, command: String, durationSec: Int? = nil, parallelOk: Bool = false) {
        self.id = id
        self.command = command
        self.durationSec = durationSec
        self.parallelOk = parallelOk
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.command = try container.decode(String.self, forKey: .command)
        self.durationSec = try container.decodeIfPresent(Int.self, forKey: .durationSec)
        self.parallelOk = try container.decodeIfPresent(Bool.self, forKey: .parallelOk) ?? false
    }
}

#Preview {
    GuidedModeView(
        recipe: Recipe(
            title: "完美蛋炒飯",
            ingredients: ["雞蛋 3顆", "白米飯 2碗", "洋蔥 1/4顆", "橄欖油 2大匙", "鹽 適量"],
            steps: [
                "熱鍋下油，將雞蛋打散炒至半熟盛起",
                "同鍋下洋蔥丁炒至透明出香味",
                "倒入白飯用鍋鏟壓散炒勻",
                "加入炒蛋、鹽、胡椒粉調味",
                "最後撒上蔥花即可起鍋"
            ],
            tags: ["經典美味", "15分鐘", "家常料理"],
            tip: "用隔夜飯炒更香！",
            requiredTools: ["🍳 平底鍋", "🥄 鍋鏟", "🔥 瓦斯爐"]
        )
    ) {
        // Preview dismiss action
    }
}
