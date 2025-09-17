//
//  CookoApp.swift
//  Cooko
//
//  Created by Chang Jill on 2025/9/17.
//

import SwiftUI

@main
struct CookoApp: App {
    var body: some Scene {
        WindowGroup {
            FridgeView()
                .preferredColorScheme(.light)
        }
    }
}
