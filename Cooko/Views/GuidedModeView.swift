import SwiftUI
import AudioToolbox

struct GuidedModeView: View {
    let recipe: Recipe
    let onDismiss: () -> Void
    
    @State private var guidedSteps: [GuidedStep] = []
    @State private var currentStepIndex = 0
    @State private var isLoading = false
    
    // 計時器相關狀態
    @State private var timer: Timer?
    @State private var remainingTime: Int = 0
    @State private var isTimerRunning = false
    
    
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
                    GeometryReader { geometry in
                        let isLandscape = geometry.size.width > geometry.size.height
                        
                        if isLandscape {
                            // 橫螢幕布局
                            HStack(spacing: 40) {
                                // 左側：進度和控制
                                VStack(spacing: 24) {
                                    // 進度指示器
                                    VStack(spacing: 12) {
                                        Text("步驟 \(currentStepIndex + 1) / \(guidedSteps.count)")
                                            .font(.headline)
                                            .foregroundStyle(Color.charcoal)
                                        
                                        Text("\(Int((Double(currentStepIndex + 1) / Double(guidedSteps.count)) * 100))%")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.olive)
                                        
                                        ProgressView(value: Double(currentStepIndex + 1), total: Double(guidedSteps.count))
                                            .tint(Color.olive)
                                            .scaleEffect(x: 1, y: 2, anchor: .center)
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    Spacer()
                                    
                                    // 控制按鈕
                                    VStack(spacing: 16) {
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
                                                    Text("完成")
                                                        .font(.headline)
                                                        .fontWeight(.semibold)
                                                    
                                                    Image(systemName: "checkmark")
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
                                        }
                                    }
                                }
                                .frame(width: geometry.size.width * 0.35)
                                
                                // 右側：主要內容
                                VStack(spacing: 20) {
                                    Spacer()
                                    
                                    // 主要指令
                                    VStack(spacing: 20) {
                                        Text(formatCommandText(step.command))
                                            .font(.system(size: 48))
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.charcoal)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 20)
                                        
                                        // 等待提示（如果有）
                                        if let duration = step.durationSec, duration > 0 {
                                            VStack(spacing: 12) {
                                                Text("⏰ 需要等待")
                                                    .font(.system(size: 32))
                                                    .foregroundStyle(Color.warnOrange)
                                                
                                                Text(isTimerRunning ? formatTime(remainingTime) : formatTime(duration))
                                                    .font(.system(size: 80))
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(isTimerRunning ? Color.olive : Color.charcoal)
                                                    .monospacedDigit()
                                                
                                                Button(action: {
                                                    if isTimerRunning {
                                                        stopTimer()
                                                    } else {
                                                        startTimer(duration: duration)
                                                    }
                                                }) {
                                                    HStack(spacing: 8) {
                                                        Image(systemName: isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                                                            .font(.title2)
                                                        Text(isTimerRunning ? "暫停計時" : "開始計時")
                                                            .font(.system(size: 24))
                                                            .fontWeight(.semibold)
                                                    }
                                                    .foregroundStyle(.white)
                                                    .padding(.horizontal, 20)
                                                    .padding(.vertical, 12)
                                                    .background(
                                                        Capsule()
                                                            .fill(isTimerRunning ? Color.warnOrange : Color.olive)
                                                    )
                                                }
                                            }
                                            .padding(.horizontal, 20)
                                        }
                                        
                                        // 並行提示（只有在有等待時間時才顯示）
                                        if step.parallelOk && step.durationSec != nil && step.durationSec! > 0 {
                                            VStack(spacing: 8) {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "lightbulb.fill")
                                                        .font(.headline)
                                                        .foregroundStyle(Color.warnOrange)
                                                    
                                                    Text("可以同時準備")
                                                        .font(.system(size: 24))
                                                        .fontWeight(.medium)
                                                        .foregroundStyle(Color.warnOrange)
                                                }
                                                
                                                Text("趁等待時間準備其他食材或工具")
                                                    .font(.system(size: 20))
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
                                }
                                .frame(width: geometry.size.width * 0.65)
                            }
                            .padding(.horizontal, 20)
                        } else {
                            // 直螢幕布局（原有布局）
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
                            Text(formatCommandText(step.command))
                                .font(.system(size: 36))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.charcoal)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            // 等待提示（如果有）
                            if let duration = step.durationSec, duration > 0 {
                                VStack(spacing: 12) {
                                    Text("⏰ 需要等待")
                                        .font(.system(size: 28))
                                        .foregroundStyle(Color.warnOrange)
                                    
                                    Text(isTimerRunning ? formatTime(remainingTime) : formatTime(duration))
                                        .font(.system(size: 64))
                                        .fontWeight(.bold)
                                        .foregroundStyle(isTimerRunning ? Color.olive : Color.charcoal)
                                        .monospacedDigit()
                                    
                                    Button(action: {
                                        if isTimerRunning {
                                            stopTimer()
                                        } else {
                                            startTimer(duration: duration)
                                        }
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                                                .font(.title3)
                                            Text(isTimerRunning ? "暫停計時" : "開始計時")
                                                .font(.system(size: 20))
                                                .fontWeight(.semibold)
                                        }
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(isTimerRunning ? Color.warnOrange : Color.olive)
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // 並行提示（只有在有等待時間時才顯示）
                            if step.parallelOk && step.durationSec != nil && step.durationSec! > 0 {
                                VStack(spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "lightbulb.fill")
                                            .font(.caption)
                                            .foregroundStyle(Color.warnOrange)
                                        
                                        Text("可以同時準備")
                                            .font(.system(size: 18))
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color.warnOrange)
                                    }
                                    
                                    Text("趁等待時間準備其他食材或工具")
                                        .font(.system(size: 16))
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
        .onDisappear {
            stopTimer()
        }
    }
    
    private func loadGuidedMode() {
        isLoading = true
        
        // 載入傻瓜模式
        
        Task {
            do {
                let chatGPTService = ChatGPTService()
                
                // 檢查 API Key 是否已配置
                if chatGPTService.isConfigured {
                    let guidedRecipe = try await chatGPTService.generateGuidedRecipe(from: recipe)
                    
                    await MainActor.run {
                        self.guidedSteps = guidedRecipe.steps
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.guidedSteps = generateLocalGuidedSteps()
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    // 如果 AI 模式失敗，回退到本地模式
                    self.guidedSteps = generateLocalGuidedSteps()
                    self.isLoading = false
                }
            }
        }
    }
    
    private func generateLocalGuidedSteps() -> [GuidedStep] {
        // 本地模式：將原始步驟轉換為智能的指導步驟
        var guidedSteps: [GuidedStep] = []
        
        for (index, step) in recipe.steps.enumerated() {
            let command = step.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 智能分析步驟，添加時間和並行提示
            var durationSec: Int? = nil
            var parallelOk = false
            
            // 分析是否需要等待時間
            if command.contains("蒸") || command.contains("煮") || command.contains("燉") || command.contains("泡") {
                if command.contains("15分鐘") || command.contains("15分") {
                    durationSec = 900
                } else if command.contains("10分鐘") || command.contains("10分") {
                    durationSec = 600
                } else if command.contains("20分鐘") || command.contains("20分") {
                    durationSec = 1200
                } else if command.contains("30分鐘") || command.contains("30分") {
                    durationSec = 1800
                } else if command.contains("5分鐘") || command.contains("5分") {
                    durationSec = 300
                } else {
                    durationSec = 600 // 預設6分鐘
                }
                parallelOk = true
            }
            
            // 分析是否可以並行操作（只有在有等待時間時才顯示並行提示）
            if durationSec != nil && (command.contains("切") || command.contains("洗") || command.contains("準備") || command.contains("調味")) {
                parallelOk = true
            }
            
            guidedSteps.append(GuidedStep(
                id: index + 1,
                command: command,
                durationSec: durationSec,
                parallelOk: parallelOk
            ))
        }
        
        return guidedSteps
    }
    
    private func nextStep() {
        if currentStepIndex < guidedSteps.count - 1 {
            // 停止當前計時器
            stopTimer()
            
            let oldIndex = currentStepIndex
            currentStepIndex += 1
            
            // 進入下一步
        }
    }
    
    private func previousStep() {
        if currentStepIndex > 0 {
            // 停止當前計時器
            stopTimer()
            
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
    
    // 計時器功能
    private func startTimer(duration: Int) {
        remainingTime = duration
        isTimerRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                // 時間到，停止計時並響鈴
                stopTimer()
                playAlarm()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }
    
    private func playAlarm() {
        // 使用系統音效響鈴 10 秒
        var alarmCount = 0
        let _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            alarmCount += 1
            
            // 播放系統音效
            AudioServicesPlaySystemSound(1005) // 系統通知音
            
            if alarmCount >= 20 { // 0.5秒 * 20 = 10秒
                timer.invalidate()
            }
        }
    }
    
    // 格式化指令文字，讓每個句子換行
    private func formatCommandText(_ command: String) -> String {
        // 將常見的標點符號替換為換行符號
        let formatted = command
            .replacingOccurrences(of: "。", with: "。\n")
            .replacingOccurrences(of: "！", with: "！\n")
            .replacingOccurrences(of: "？", with: "？\n")
            .replacingOccurrences(of: "，", with: "，\n")
            .replacingOccurrences(of: "；", with: "；\n")
            .replacingOccurrences(of: "：", with: "：\n")
        
        // 清理多餘的換行符號
        let cleaned = formatted
            .replacingOccurrences(of: "\n\n", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned
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
