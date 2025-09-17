import Foundation

struct RecipeService {

    // TODO: 之後把這個替換成 OpenAI API 呼叫
    func mockRecipes(from foods: [FoodItem]) async throws -> [Recipe] {
        let names = foods.map { $0.name }
        let tip = "可以試試香蕉奶昔，5 分鐘完成！"
        return [
            Recipe(title: "豆腐炒蛋",
                   ingredients: ["雞蛋", "豆腐", "蔥", "醬油"],
                   steps: ["打蛋拌勻", "豆腐切塊", "蔥爆香下蛋、豆腐", "調味盛盤"],
                   tags: ["快過期優先", "家常料理"],
                   tip: tip),
            Recipe(title: "葡萄優格碗",
                   ingredients: ["葡萄", "優格", "燕麥"],
                   steps: ["葡萄洗淨切半", "優格入碗", "撒上燕麥與葡萄"],
                   tags: ["健康飲食", "省時快速"],
                   tip: "當早餐或宵夜都很清爽！")
        ]
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
