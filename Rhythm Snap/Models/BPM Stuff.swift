//
//  BPM Stuff.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-04-01.
//

import SwiftUI

class BpmTracker: ObservableObject {
    
    @Published var logged = false
    @Published var testName = "I was not changed"
    
    @Published var performance = ""
    @Published var perfColour = Color.purple
    
    @Published var timer = Timer.publish(every: 0.6316 * 2, on: .main, in: .common).autoconnect()

    
    @Published var startDate = Date()
    @Published var allAccurateBeats = [TimeInterval]()
    @Published var userBeats = [TimeInterval]()
    @Published var userLoggedTimes = [TimeInterval]()
    
    
    private let allowedTimeWindow: TimeInterval = 0.4
    
    func logBPM() {
        testName = "AAAAAAAaaaaa"
        
        let userTime = Date().timeIntervalSince(startDate)
        userLoggedTimes.append(userTime)
        
        let score = findNearestBeatScore(userTime)
        
        if score < allowedTimeWindow {
            perfColour = Color.green
            performance = "Good Timing Baby"
            
            let roundedFloat = Float(round(10000 * score) / 10000)
            print("Good Timing Baby with \n \(roundedFloat)")
        } else {
            perfColour = Color.red
            performance = "Not bad but not great"
            print("Not bad but not great with \n \(score)")
        }
        
        logged = true
        
        // Update the startDate to the next beat
        let interval = 0.6316 * 2
        let nextBeat = ceil(userTime / interval) * interval
        startDate = Date(timeIntervalSinceNow: nextBeat - userTime)
    }
    
    
    private func findNearestBeatScore(_ userTime: TimeInterval) -> TimeInterval {
        var minScore = TimeInterval.greatestFiniteMagnitude
        
        for accurateBeat in allAccurateBeats {
            let score = abs(userTime - accurateBeat)
            if score < minScore {
                minScore = score
            }
        }
        
        return minScore
    }
}


