import SwiftUI

struct FoodCard: View {
    let foodItem: FoodItem
    @State private var showingEditSheet = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(foodItem.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(foodItem.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Quantity: \(foodItem.quantity) \(foodItem.unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(expirationText)
                    .font(.caption)
                    .foregroundColor(expirationColor)
                
                Text("Added: \(foodItem.addedDate, style: .date)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.backgroundGray)
        .cornerRadius(Theme.cornerRadius)
        .onTapGesture {
            showingEditSheet = true
        }
        .sheet(isPresented: $showingEditSheet) {
            // TODO: Add EditFoodSheet
            Text("Edit Food Item")
        }
    }
    
    private var expirationText: String {
        if foodItem.isExpired {
            return "Expired"
        } else if foodItem.daysUntilExpiration == 0 {
            return "Expires today"
        } else if foodItem.daysUntilExpiration == 1 {
            return "Expires tomorrow"
        } else {
            return "Expires in \(foodItem.daysUntilExpiration) days"
        }
    }
    
    private var expirationColor: Color {
        if foodItem.isExpired {
            return .red
        } else if foodItem.daysUntilExpiration <= 2 {
            return .orange
        } else {
            return .green
        }
    }
}

#Preview {
    FoodCard(foodItem: FoodItem(
        name: "Fresh Tomatoes",
        category: .vegetables,
        expirationDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
        quantity: "5",
        unit: "pieces",
        addedDate: Date()
    ))
    .padding()
}
