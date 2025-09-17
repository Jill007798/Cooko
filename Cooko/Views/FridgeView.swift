import SwiftUI

struct FridgeView: View {
    @StateObject private var viewModel = FridgeViewModel()
    @State private var showingAddFoodSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading your fridge...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.foodItems.isEmpty {
                    EmptyFridgeView {
                        showingAddFoodSheet = true
                    }
                } else {
                    FoodItemsList(foodItems: viewModel.foodItems)
                }
            }
            .navigationTitle("My Fridge")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Food") {
                        showingAddFoodSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingAddFoodSheet) {
                AddFoodSheet(viewModel: viewModel)
            }
        }
    }
}

struct EmptyFridgeView: View {
    let onAddFood: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "refrigerator")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Your fridge is empty")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Add some food items to get started")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add Food") {
                onAddFood()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct FoodItemsList: View {
    let foodItems: [FoodItem]
    
    var body: some View {
        List(foodItems) { item in
            FoodCard(foodItem: item)
        }
    }
}

#Preview {
    FridgeView()
}
