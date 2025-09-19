import Foundation

struct RecipeService {

    // TODO: 之後把這個替換成 OpenAI API 呼叫
    func mockRecipes(from foods: [FoodItem]) async throws -> [Recipe] {
        let dailyTips = [
            ("來點香蕉果昔", "5分鐘完成", "超簡單"),
            ("來個蒸蛋", "超營養", "10分鐘"),
            ("試試蛋炒飯", "經典美味", "15分鐘"),
            ("做個清爽沙拉", "超健康", "5分鐘"),
            ("來碗蔬菜湯", "暖胃又營養", "20分鐘"),
            ("煎個荷包蛋", "完美早餐", "5分鐘"),
            ("做個水果優格", "超清爽", "3分鐘"),
            ("來點炒青菜", "簡單美味", "8分鐘"),
            ("試試水煮蛋", "完美蛋白質", "12分鐘"),
            ("做個簡單炒飯", "一鍋搞定", "15分鐘"),
            ("來碗蛋花湯", "暖身又營養", "10分鐘"),
            ("試試涼拌菜", "清爽開胃", "5分鐘"),
            ("做個煎蛋餅", "香嫩可口", "8分鐘"),
            ("來點水果拼盤", "超新鮮", "3分鐘"),
            ("試試蒸蛋羹", "滑嫩美味", "15分鐘"),
            ("做個簡單湯麵", "暖胃飽足", "12分鐘")
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
    
    private func generateRecipesFromFoods(_ foods: [FoodItem]) -> [Recipe] {
        // 根據食材組合生成食譜
        let recipes = [
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
                tip: "用隔夜飯炒更香！"
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
                tip: "新鮮蔬菜最美味！"
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
                tip: "蒸蛋要小火慢蒸！"
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
                tip: "冰涼的優格最解膩！"
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
                tip: "番茄要炒出香味！"
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
                tip: "大火快炒保持脆嫩！"
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
