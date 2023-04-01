//
//  Rhythm_SnapApp.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-03-17.
//

import SwiftUI

@main
struct Rhythm_SnapApp: App {
    
    @StateObject public var bpmTracker = BpmTracker()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bpmTracker)
        }
    }
}
