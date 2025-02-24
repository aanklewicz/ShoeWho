//
//  ShoeWhoApp.swift
//  ShoeWho
//
//  Created by Adam Anklewicz on 2025-02-24.
//

import SwiftUI

@main
struct ShoeWhoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 900, minHeight: 700)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                EmptyView()
            }
        }
    }
}
