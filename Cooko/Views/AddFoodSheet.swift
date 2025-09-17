import SwiftUI

struct AddFoodSheet: View {
    @Environment(\.dismiss) var dismiss
    var onAdd: (FoodItem) -> Void

    @State private var name = ""
    @State private var emoji = ""
    @State private var quantity = 1
    @State private var unit = "顆"
    @State private var location: StorageLocation = .fridge
    @State private var expiry: Date? = nil
    @State private var hasExpiry = false

    let units = ["顆","盒","串","袋","份"]

    var body: some View {
        NavigationStack {
            Form {
                TextField("名稱（例如：雞蛋）", text: $name)
                TextField("Emoji（可留空）", text: $emoji)
                Picker("單位", selection: $unit) { ForEach(units, id: \.self, content: Text.init) }
                Stepper("數量：\(quantity)", value: $quantity, in: 0...99)
                Picker("存放位置", selection: $location) {
                    ForEach(StorageLocation.allCases, id: \.self) { Text($0.rawValue) }
                }
                Toggle("有到期日", isOn: $hasExpiry)
                if hasExpiry {
                    DatePicker("到期日", selection: Binding(get: {
                        expiry ?? Date().addingTimeInterval(60*60*24*3)
                    }, set: { expiry = $0 }), displayedComponents: .date)
                }
            }
            .navigationTitle("新增食材")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("加入") {
                        let item = FoodItem(
                            name: name.isEmpty ? "未命名食材" : name,
                            emoji: emoji.isEmpty ? nil : emoji,
                            quantity: quantity,
                            unit: unit,
                            location: location,
                            expiry: hasExpiry ? expiry : nil
                        )
                        onAdd(item); dismiss()
                    }
                    .disabled(name.isEmpty && emoji.isEmpty)
                }
            }
        }
    }
}
