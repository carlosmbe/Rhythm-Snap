//
//  BPM Stuff.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-04-01.
//

import SwiftUI

class BpmTracker : ObservableObject{
    
    @Published var logged = false
    
    @Published var testName = "I was not changed"
    
    @Published var performance = ""
    @Published var perfColour = Color.purple
    
    @Published var startDate = Date()
    
    @Published var timeElapsed: Int = 0
    
    let timer = Timer.publish(every: 0.6316 * 2, on: .main, in: .common).autoconnect()
    
    @Published var allAccurateBeats = [TimeInterval]()
    
    @Published var userBeats = [TimeInterval]()
    
    @Published var userLoggedTimes = [TimeInterval]()
    
    func logBPM(){
        
        testName = "AAAAAAAAAAa"

        
        let userTime = Date.now.timeIntervalSince(startDate)
        userLoggedTimes.append(userTime)
        
        let score = abs(userTime - (allAccurateBeats.last ?? 0))
        
        if score < 0.15{
            perfColour = Color.green
            performance = "Good Timing Baby"
            
            print("Good Timing Baby with \n \(score)")
        }else{
            perfColour = Color.red
            performance = "Not bad but not great"
            print("Not bad but not great with \n \(score)")
        }
        
        logged = true
        
        //It should be like if the difference is equal to from 0 - 0.15 good and 0.15 to 0.3 mid, > 0.3 then bad
        
    }
    
    
}
