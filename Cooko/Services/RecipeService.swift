import Foundation

struct RecipeService {
    private let chatGPTService = ChatGPTService()

    // 使用 ChatGPT 生成食譜建議
    func generateRecipes(from foods: [FoodItem]) async throws -> [Recipe] {
        // 如果 ChatGPT 已配置，使用 AI 生成
        if chatGPTService.isConfigured {
            return try await generateWithChatGPT(from: foods)
        } else {
            // 否則使用模擬數據
            return try await mockRecipes(from: foods)
        }
    }
    
    // 使用完整資訊生成食譜（包含偏好、工具、食材）
    func generateRecipes(from request: RecipeGenerationRequest) async throws -> [Recipe] {
        print("🍳 RecipeService: 開始生成食譜")
        print("📋 請求內容:")
        print("  - 食材數量: \(request.foods.count)")
        print("  - 食材列表: \(request.foods.map { "\($0.name)（\($0.quantity)\($0.unit)）" }.joined(separator: ", "))")
        print("  - 選擇工具: \(request.selectedTools.map { "\($0.emoji)\($0.name)" }.joined(separator: ", "))")
        print("  - 選擇偏好: \(request.preferences.map { "\($0.emoji)\($0.title)" }.joined(separator: ", "))")
        print("---")
        
        // 如果 ChatGPT 已配置，使用 AI 生成
        if chatGPTService.isConfigured {
            print("🤖 使用 ChatGPT API 生成食譜")
            let recipes = try await generateWithChatGPT(from: request)
            print("✅ ChatGPT 生成完成，返回 \(recipes.count) 道食譜")
            return recipes
        } else {
            print("📝 使用模擬數據生成食譜")
            let recipes = try await mockRecipes(from: request)
            print("✅ 模擬數據生成完成，返回 \(recipes.count) 道食譜")
            return recipes
        }
    }
    
    // ChatGPT 生成食譜
    private func generateWithChatGPT(from foods: [FoodItem]) async throws -> [Recipe] {
        // 生成靈感卡片
        let inspirationContent = await chatGPTService.generateCookingTip() ?? "今天來點創意料理吧！"
        let inspiration = Recipe(
            title: inspirationContent,
            ingredients: [],
            steps: [],
            tags: ["AI推薦", "創意"],
            tip: "點擊查看完整食譜"
        )
        
        // 生成具體食譜
        let recipeContent = await chatGPTService.generateRecipeSuggestion(from: foods) ?? "根據您的食材，建議製作簡單的家常菜。"
        
        // 解析 AI 回應並創建食譜
        let aiRecipe = Recipe(
            title: "AI推薦料理",
            ingredients: foods.map { $0.name },
            steps: recipeContent.components(separatedBy: "\n").filter { !$0.isEmpty },
            tags: ["AI生成", "個性化"],
            tip: recipeContent
        )
        
        return [inspiration, aiRecipe]
    }
    
    // ChatGPT 生成食譜（完整版本）
    private func generateWithChatGPT(from request: RecipeGenerationRequest) async throws -> [Recipe] {
        print("🤖 ChatGPT 生成食譜開始")
        
        // 準備食材列表
        let foodList = request.foods.map { "\($0.name)（\($0.quantity)\($0.unit)）" }.joined(separator: "、")
        
        // 準備工具列表
        let toolList = request.selectedTools.map { "\($0.emoji)\($0.name)" }.joined(separator: "、")
        
        // 準備偏好列表
        let preferenceList = request.preferences.map { "\($0.emoji)\($0.title)" }.joined(separator: "、")
        
        print("📝 準備 ChatGPT 請求參數:")
        print("  - 食材: \(foodList)")
        print("  - 工具: \(toolList)")
        print("  - 偏好: \(preferenceList)")
        
        // 生成靈感卡片
        print("💡 生成靈感卡片...")
        let inspirationContent = await chatGPTService.generateCookingTip() ?? "今天來點創意料理吧！"
        let inspiration = Recipe(
            title: inspirationContent,
            ingredients: [],
            steps: [],
            tags: ["AI推薦", "創意"],
            tip: "點擊查看完整食譜"
        )
        print("✅ 靈感卡片: \(inspiration.title)")
        
        // 生成具體食譜
        print("🍽️ 生成具體食譜...")
        let recipeContent = await chatGPTService.generateRecipeSuggestion(
            from: request.foods,
            tools: request.selectedTools,
            preferences: request.preferences
        ) ?? "根據您的食材、工具和偏好，建議製作簡單的家常菜。"
        
        print("📄 AI 回應內容: \(recipeContent)")
        
        // 解析 AI 回應並創建食譜
        let aiRecipe = Recipe(
            title: "AI推薦料理",
            ingredients: request.foods.map { $0.name },
            steps: recipeContent.components(separatedBy: "\n").filter { !$0.isEmpty },
            tags: ["AI生成", "個性化"],
            tip: recipeContent
        )
        
        print("✅ ChatGPT 生成完成:")
        print("  - 靈感卡片: \(inspiration.title)")
        print("  - AI 食譜: \(aiRecipe.title)")
        print("  - 總步驟數: \(aiRecipe.steps.count)")
        print("==========================================")
        
        return [inspiration, aiRecipe]
    }

    // 模擬食譜（備用）
    func mockRecipes(from foods: [FoodItem]) async throws -> [Recipe] {
        let dailyTips = [
            ("🍌 香蕉果昔", "5分鐘完成", "超簡單"),
            ("🥚 滑嫩蒸蛋", "超營養", "10分鐘"),
            ("🍳 完美蛋炒飯", "經典美味", "15分鐘"),
            ("🥗 清爽沙拉", "超健康", "5分鐘"),
            ("🍲 暖胃蔬菜湯", "暖胃又營養", "20分鐘"),
            ("🍳 完美荷包蛋", "完美早餐", "5分鐘"),
            ("🍓 繽紛水果優格", "超清爽", "3分鐘"),
            ("🥬 香蒜炒青菜", "簡單美味", "8分鐘"),
            ("🥚 完美水煮蛋", "完美蛋白質", "12分鐘"),
            ("🍚 一鍋炒飯", "一鍋搞定", "15分鐘"),
            ("🍲 暖身蛋花湯", "暖身又營養", "10分鐘"),
            ("🥒 清爽涼拌菜", "清爽開胃", "5分鐘"),
            ("🍳 香嫩蛋餅", "香嫩可口", "8分鐘"),
            ("🍎 繽紛水果拼盤", "超新鮮", "3分鐘"),
            ("🥚 滑嫩蒸蛋羹", "滑嫩美味", "15分鐘"),
            ("🍜 暖胃湯麵", "暖胃飽足", "12分鐘"),
            ("🍤 義式蒜香蝦仁麵", "異國風味", "15分鐘"),
            ("🥘 韓式豆腐湯", "健康美味", "10分鐘"),
            ("🥔 法式馬鈴薯泥", "濃郁香滑", "20分鐘"),
            ("🍚 日式小魚乾炒飯", "營養滿分", "12分鐘")
        ]
        
        let randomTip = dailyTips.randomElement() ?? ("來點香蕉果昔", "5分鐘完成", "超簡單")
        
        // 生成小靈感
        let inspiration = Recipe(title: randomTip.0,
                                ingredients: [],
                                steps: [],
                                tags: [randomTip.1, randomTip.2],
                                tip: "點擊查看完整食譜")
        
        // 根據食材生成具體食譜
        let recipes = generateRecipesFromFoods(foods)
        
        return [inspiration] + recipes
    }
    
    // 模擬食譜（完整版本）
    func mockRecipes(from request: RecipeGenerationRequest) async throws -> [Recipe] {
        print("📝 開始生成模擬食譜")
        
        let dailyTips = [
            ("🍌 香蕉果昔", "5分鐘完成", "超簡單"),
            ("🥚 滑嫩蒸蛋", "超營養", "10分鐘"),
            ("🍳 完美蛋炒飯", "經典美味", "15分鐘"),
            ("🥗 清爽沙拉", "超健康", "5分鐘"),
            ("🍲 暖胃蔬菜湯", "暖胃又營養", "20分鐘"),
            ("🍳 完美荷包蛋", "完美早餐", "5分鐘"),
            ("🍓 繽紛水果優格", "超清爽", "3分鐘"),
            ("🥬 香蒜炒青菜", "簡單美味", "8分鐘"),
            ("🥚 完美水煮蛋", "完美蛋白質", "12分鐘"),
            ("🍚 一鍋炒飯", "一鍋搞定", "15分鐘"),
            ("🍲 暖身蛋花湯", "暖身又營養", "10分鐘"),
            ("🥒 清爽涼拌菜", "清爽開胃", "5分鐘"),
            ("🍳 香嫩蛋餅", "香嫩可口", "8分鐘"),
            ("🍎 繽紛水果拼盤", "超新鮮", "3分鐘"),
            ("🥚 滑嫩蒸蛋羹", "滑嫩美味", "15分鐘"),
            ("🍜 暖胃湯麵", "暖胃飽足", "12分鐘"),
            ("🍤 義式蒜香蝦仁麵", "異國風味", "15分鐘"),
            ("🥘 韓式豆腐湯", "健康美味", "10分鐘"),
            ("🥔 法式馬鈴薯泥", "濃郁香滑", "20分鐘"),
            ("🍚 日式小魚乾炒飯", "營養滿分", "12分鐘")
        ]
        
        let randomTip = dailyTips.randomElement() ?? ("來點香蕉果昔", "5分鐘完成", "超簡單")
        print("🎲 隨機選擇靈感: \(randomTip.0)")
        
        // 根據食材、工具和偏好生成具體食譜
        print("🔍 根據請求參數過濾食譜...")
        let recipes = generateRecipesFromRequest(request)
        
        print("✅ 模擬食譜生成完成:")
        print("  - 生成食譜數量: \(recipes.count)")
        for (index, recipe) in recipes.enumerated() {
            print("  - 食譜 \(index + 1): \(recipe.title)")
            print("    * 標籤: \(recipe.tags.joined(separator: ", "))")
            print("    * 食材: \(recipe.ingredients.joined(separator: ", "))")
            print("    * 步驟數: \(recipe.steps.count)")
            print("    * 小貼士: \(recipe.tip)")
            if !recipe.requiredTools.isEmpty {
                print("    * 所需工具: \(recipe.requiredTools.joined(separator: ", "))")
            }
            print("    ---")
        }
        print("==========================================")
        
        return recipes
    }
    
    private func generateRecipesFromFoods(_ foods: [FoodItem]) -> [Recipe] {
        // 根據食材組合生成食譜
        let recipes = [
            Recipe(
                title: "完美蛋炒飯",
                ingredients: ["雞蛋", "白米", "洋蔥", "橄欖油", "鹽", "胡椒粉"],
                steps: [
                    "熱鍋下油，將雞蛋打散炒至半熟盛起",
                    "同鍋下洋蔥丁炒至透明出香味",
                    "倒入白飯用鍋鏟壓散炒勻",
                    "加入炒蛋、鹽、胡椒粉調味",
                    "最後撒上蔥花即可起鍋"
                ],
                tags: ["經典美味", "15分鐘", "家常料理"],
                tip: "用隔夜飯炒更香！"
            ),
            Recipe(
                title: "清爽蔬菜沙拉",
                ingredients: ["生菜", "番茄", "胡蘿蔔", "橄欖油", "檸檬", "鹽"],
                steps: [
                    "生菜洗淨撕成小片，番茄切塊",
                    "胡蘿蔔刨絲，所有蔬菜混合",
                    "調製檸檬油醋醬：橄欖油+檸檬汁+鹽",
                    "淋上醬汁拌勻即可享用"
                ],
                tags: ["超健康", "5分鐘", "健康飲食"],
                tip: "新鮮蔬菜最美味！"
            ),
            Recipe(
                title: "滑嫩蒸蛋羹",
                ingredients: ["雞蛋", "牛奶", "鹽", "蔥花"],
                steps: [
                    "雞蛋打散加入牛奶和鹽調味",
                    "過篩去除氣泡，倒入蒸碗",
                    "蓋上保鮮膜，蒸鍋大火蒸15分鐘",
                    "出鍋撒上蔥花即可"
                ],
                tags: ["超營養", "15分鐘", "簡單易做"],
                tip: "蒸蛋要小火慢蒸！"
            ),
            Recipe(
                title: "繽紛水果優格",
                ingredients: ["優格", "香蕉", "葡萄", "蘋果"],
                steps: [
                    "香蕉切片，葡萄對半切，蘋果切丁",
                    "將切好的水果放入碗中",
                    "淋上優格拌勻",
                    "冷藏30分鐘後享用更美味"
                ],
                tags: ["超清爽", "3分鐘", "健康飲食"],
                tip: "冰涼的優格最解膩！"
            ),
            Recipe(
                title: "暖胃番茄蛋花湯",
                ingredients: ["番茄", "雞蛋", "鹽", "蔥", "香油"],
                steps: [
                    "番茄切塊，熱鍋下油炒出汁水",
                    "加入適量清水煮開",
                    "雞蛋打散，慢慢倒入湯中攪拌",
                    "調味後撒蔥花，淋香油即可"
                ],
                tags: ["暖胃湯品", "10分鐘", "家常料理"],
                tip: "番茄要炒出香味！"
            ),
            Recipe(
                title: "香蒜炒菠菜",
                ingredients: ["菠菜", "大蒜", "橄欖油", "鹽", "香油"],
                steps: [
                    "菠菜洗淨切段，大蒜拍碎切末",
                    "熱鍋下油爆香蒜末",
                    "下菠菜大火快炒至軟",
                    "調味後淋香油即可起鍋"
                ],
                tags: ["健康蔬菜", "5分鐘", "健康飲食"],
                tip: "大火快炒保持脆嫩！"
            ),
            Recipe(
                title: "義式蒜香蝦仁麵",
                ingredients: ["義大利麵", "冷凍蝦", "大蒜", "橄欖油", "洋蔥", "檸檬"],
                steps: [
                    "義大利麵煮熟瀝乾備用",
                    "熱鍋下橄欖油，爆香洋蔥和大蒜",
                    "加入冷凍蝦炒至變色",
                    "放入麵條拌炒，擠入檸檬汁調味"
                ],
                tags: ["快速省時", "家常料理", "創意料理"],
                tip: "可以加入一些冷凍蔬菜增加營養與顏色"
            ),
            Recipe(
                title: "韓式豆腐湯",
                ingredients: ["豆腐", "洋蔥", "大蒜", "蔥", "鹽", "香油"],
                steps: [
                    "豆腐切塊，洋蔥切絲，大蒜切末",
                    "熱鍋下油爆香洋蔥和大蒜",
                    "加入清水煮開，放入豆腐",
                    "調味後撒蔥花，淋香油即可"
                ],
                tags: ["健康飲食", "簡單易做", "家常料理"],
                tip: "豆腐要輕輕放入避免破碎"
            ),
            Recipe(
                title: "法式馬鈴薯泥",
                ingredients: ["馬鈴薯", "牛奶", "奶油", "鹽", "黑胡椒"],
                steps: [
                    "馬鈴薯去皮切塊，水煮至軟爛",
                    "瀝乾水分，加入牛奶和奶油",
                    "用壓泥器壓成泥狀",
                    "調味後拌勻即可"
                ],
                tags: ["家常料理", "簡單易做", "創意料理"],
                tip: "趁熱壓泥效果最好"
            ),
            Recipe(
                title: "日式小魚乾炒飯",
                ingredients: ["白米", "小魚乾", "雞蛋", "蔥", "醬油", "香油"],
                steps: [
                    "熱鍋下油炒散雞蛋盛起",
                    "同鍋下小魚乾炒香",
                    "倒入白飯炒散，加入炒蛋",
                    "淋醬油調味，撒蔥花即可"
                ],
                tags: ["家常料理", "快速省時", "健康飲食"],
                tip: "小魚乾要先泡水去鹹味"
            )
        ]
        
        // 根據現有食材選擇適合的食譜（最多2道）
        let availableFoods = foods.map { $0.name }
        let suitableRecipes = recipes.filter { recipe in
            recipe.ingredients.contains { ingredient in
                availableFoods.contains { food in
                    food.contains(ingredient) || ingredient.contains(food)
                }
            }
        }
        
        return Array(suitableRecipes.prefix(4))
    }
    
    private func generateRecipesFromRequest(_ request: RecipeGenerationRequest) -> [Recipe] {
        // 根據食材、工具和偏好生成食譜
        let availableFoods = request.foods.map { $0.name }
        let availableTools = request.selectedTools.map { $0.name }
        let selectedPreferences = request.preferences.map { $0.title }
        
        print("🔍 開始過濾食譜:")
        print("  - 可用食材: \(availableFoods.joined(separator: ", "))")
        print("  - 可用工具: \(availableTools.joined(separator: ", "))")
        print("  - 選擇偏好: \(selectedPreferences.joined(separator: ", "))")
        
        // 基礎食譜庫
        let baseRecipes = [
            Recipe(
                title: "蛋炒飯",
                ingredients: ["雞蛋", "白米", "洋蔥", "橄欖油", "鹽"],
                steps: [
                    "1. 熱鍋下油，炒散雞蛋",
                    "2. 加入洋蔥炒香",
                    "3. 倒入白飯炒勻",
                    "4. 調味即可"
                ],
                tags: ["經典美味", "15分鐘"],
                tip: "用隔夜飯炒更香！",
                requiredTools: ["平底鍋", "鍋鏟"]
            ),
            Recipe(
                title: "蔬菜沙拉",
                ingredients: ["生菜", "番茄", "胡蘿蔔", "橄欖油", "檸檬"],
                steps: [
                    "1. 所有蔬菜洗淨切絲",
                    "2. 調製油醋醬",
                    "3. 拌勻即可享用"
                ],
                tags: ["超健康", "5分鐘"],
                tip: "新鮮蔬菜最美味！",
                requiredTools: ["沙拉碗", "刀"]
            ),
            Recipe(
                title: "蒸蛋羹",
                ingredients: ["雞蛋", "牛奶", "鹽"],
                steps: [
                    "1. 雞蛋打散加牛奶",
                    "2. 過篩去氣泡",
                    "3. 蒸15分鐘即可"
                ],
                tags: ["超營養", "15分鐘"],
                tip: "蒸蛋要小火慢蒸！",
                requiredTools: ["蒸鍋", "碗"]
            ),
            Recipe(
                title: "水果優格",
                ingredients: ["優格", "香蕉", "葡萄"],
                steps: [
                    "1. 水果切塊",
                    "2. 加入優格拌勻",
                    "3. 冷藏後享用"
                ],
                tags: ["超清爽", "3分鐘"],
                tip: "冰涼的優格最解膩！",
                requiredTools: ["碗", "刀"]
            ),
            Recipe(
                title: "番茄蛋花湯",
                ingredients: ["番茄", "雞蛋", "鹽", "蔥"],
                steps: [
                    "1. 番茄切塊炒出汁",
                    "2. 加水煮開",
                    "3. 倒入蛋液攪拌",
                    "4. 調味即可"
                ],
                tags: ["暖胃湯品", "10分鐘"],
                tip: "番茄要炒出香味！",
                requiredTools: ["湯鍋", "鍋鏟"]
            ),
            Recipe(
                title: "蒜炒菠菜",
                ingredients: ["菠菜", "大蒜", "橄欖油", "鹽"],
                steps: [
                    "1. 菠菜洗淨切段",
                    "2. 熱鍋爆香蒜末",
                    "3. 下菠菜快炒",
                    "4. 調味即可"
                ],
                tags: ["健康蔬菜", "5分鐘"],
                tip: "大火快炒保持脆嫩！",
                requiredTools: ["平底鍋", "鍋鏟"]
            ),
            Recipe(
                title: "蒸蛋",
                ingredients: ["雞蛋", "水", "鹽", "蔥花"],
                steps: [
                    "1. 雞蛋打散加水",
                    "2. 過篩去氣泡",
                    "3. 蒸12分鐘",
                    "4. 撒蔥花即可"
                ],
                tags: ["超營養", "12分鐘"],
                tip: "蒸蛋要蓋保鮮膜！",
                requiredTools: ["蒸鍋", "碗"]
            ),
            Recipe(
                title: "炒青菜",
                ingredients: ["青菜", "大蒜", "橄欖油", "鹽"],
                steps: [
                    "1. 青菜洗淨切段",
                    "2. 熱鍋爆香蒜末",
                    "3. 下青菜快炒",
                    "4. 調味即可"
                ],
                tags: ["健康蔬菜", "5分鐘"],
                tip: "大火快炒保持脆嫩！",
                requiredTools: ["平底鍋", "鍋鏟"]
            )
        ]
        
        // 根據偏好調整食譜
        var filteredRecipes = baseRecipes
        print("📊 基礎食譜庫: \(baseRecipes.count) 道")
        
        if selectedPreferences.contains("健康飲食") {
            let beforeCount = filteredRecipes.count
            filteredRecipes = filteredRecipes.filter { recipe in
                recipe.tags.contains { $0.contains("健康") || $0.contains("營養") }
            }
            print("🥗 健康飲食過濾: \(beforeCount) → \(filteredRecipes.count) 道")
        }
        
        if selectedPreferences.contains("快速省時") {
            let beforeCount = filteredRecipes.count
            filteredRecipes = filteredRecipes.filter { recipe in
                recipe.tags.contains { $0.contains("分鐘") && Int($0.replacingOccurrences(of: "分鐘", with: "")) ?? 0 <= 10 }
            }
            print("⚡ 快速省時過濾: \(beforeCount) → \(filteredRecipes.count) 道")
        }
        
        if selectedPreferences.contains("創意料理") {
            let beforeCount = filteredRecipes.count
            filteredRecipes = filteredRecipes.filter { recipe in
                recipe.tags.contains { $0.contains("創意") || $0.contains("經典") }
            }
            print("🎨 創意料理過濾: \(beforeCount) → \(filteredRecipes.count) 道")
        }
        
        // 根據可用食材過濾食譜
        let suitableRecipes = filteredRecipes.filter { recipe in
            recipe.ingredients.contains { ingredient in
                availableFoods.contains { food in
                    food.contains(ingredient) || ingredient.contains(food)
                }
            }
        }
        print("🍽️ 食材匹配過濾: \(filteredRecipes.count) → \(suitableRecipes.count) 道")
        
        // 確保返回 4 份食譜（如果不足則用其他食譜補足）
        let finalRecipes: [Recipe]
        if suitableRecipes.count >= 4 {
            finalRecipes = Array(suitableRecipes.prefix(4))
            print("✅ 直接返回匹配的食譜: \(finalRecipes.count) 道")
        } else {
            let remainingRecipes = baseRecipes.filter { !suitableRecipes.contains($0) }
            finalRecipes = suitableRecipes + Array(remainingRecipes.prefix(4 - suitableRecipes.count))
            print("🔄 補充食譜: 匹配 \(suitableRecipes.count) + 補充 \(finalRecipes.count - suitableRecipes.count) = \(finalRecipes.count) 道")
        }
        
        print("📋 最終選定的食譜:")
        for (index, recipe) in finalRecipes.enumerated() {
            print("  \(index + 1). \(recipe.title) - \(recipe.tags.joined(separator: ", "))")
        }
        
        return finalRecipes
    }

    // MARK: - 真的要接 API 時，可改用這個雛形
    struct OpenAIRequest: Encodable {
        let model: String
        let messages: [[String:String]]
        let temperature: Double
    }

    func generateViaOpenAI(from foods: [FoodItem], apiKey: String) async throws -> [Recipe] {
        let list = foods.map { "\($0.name)\u{FF08}\($0.quantity)\($0.unit)\u{FF09}" }.joined(separator: "、")
        let prompt =
        """
        依據食材：\(list)
        請產生2道家常料理食譜（JSON 回傳），格式：
        [
          {"title":"","ingredients":[],"steps":[],"tags":["從(快過期優先/健康飲食/創意料理/省時快速/家常料理)擇1-2"],"tip":""},
          ...
        ]
        僅輸出 JSON。
        """

        let request = OpenAIRequest(
            model: "gpt-4o-mini",
            messages: [
                ["role":"system","content":"你是善於用現有食材生食譜的小廚師。"],
                ["role":"user","content": prompt]
            ],
            temperature: 0.7
        )

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(request)

        let (data, _) = try await URLSession.shared.data(for: req)
        // 解析 completion 的 JSON（依你實際回傳結構調整）
        struct ChatResp: Decodable { let choices: [Choice]
            struct Choice: Decodable { let message: Msg
                struct Msg: Decodable { let content: String }
            }
        }
        let resp = try JSONDecoder().decode(ChatResp.self, from: data)
        guard let content = resp.choices.first?.message.content.data(using: .utf8) else {
            return []
        }
        return try JSONDecoder().decode([Recipe].self, from: content)
    }
}
