//
//  CookoApp.swift
//  Cooko
//
//  Created by Chang Jill on 2025/9/17.
//

import SwiftUI

@main
struct CookoApp: App {
    @StateObject private var recipeVM = RecipeViewModel()
    
    var body: some Scene {
        WindowGroup {
            FridgeView()
                .environmentObject(recipeVM)
                .preferredColorScheme(.light)
        }
    }
}
