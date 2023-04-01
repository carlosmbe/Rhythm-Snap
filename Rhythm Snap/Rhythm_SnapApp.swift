//
//  Rhythm_SnapApp.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-03-17.
//

import SwiftUI

@main
struct Rhythm_SnapApp: App {
    var body: some Scene {
        WindowGroup {
            //MARK: REMOVE
            let demoInstance = BpmTracker()
            ContentView(bpmTracker: demoInstance)
        }
    }
}
