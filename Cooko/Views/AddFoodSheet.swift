import SwiftUI

struct AddFoodSheet: View {
    @ObservedObject var viewModel: FridgeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedCategory = FoodItem.FoodCategory.vegetables
    @State private var quantity = ""
    @State private var unit = ""
    @State private var expirationDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Food Details") {
                    TextField("Food name", text: $name)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(FoodItem.FoodCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    HStack {
                        TextField("Quantity", text: $quantity)
                            .keyboardType(.decimalPad)
                        
                        TextField("Unit", text: $unit)
                    }
                }
                
                Section("Expiration") {
                    DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveFoodItem()
                    }
                    .disabled(name.isEmpty || quantity.isEmpty || unit.isEmpty)
                }
            }
        }
    }
    
    private func saveFoodItem() {
        let newFoodItem = FoodItem(
            name: name,
            category: selectedCategory,
            expirationDate: expirationDate,
            quantity: quantity,
            unit: unit,
            addedDate: Date()
        )
        
        viewModel.addFoodItem(newFoodItem)
        dismiss()
    }
}

#Preview {
    AddFoodSheet(viewModel: FridgeViewModel())
}
