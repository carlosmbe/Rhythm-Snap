//
//  BPM Stuff.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-04-01.
//

import AVFoundation
import SwiftUI

class BpmTracker: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    var audioPlayer: AVAudioPlayer?
    
    @Published var logged = false

    
    @Published var performance = ""
    @Published var perfColour = Color.purple
    
    @Published var timer = Timer.publish(every: 0.6316 * 2, on: .main, in: .common).autoconnect()

    
    @Published var startDate = Date()
    @Published var allAccurateBeats = [TimeInterval]()
    @Published var userBeats = [TimeInterval]()
    @Published var userLoggedTimes = [TimeInterval]()
    
    
    private let allowedTimeWindow: TimeInterval = 0.4
    
    func logBPM() {
        
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
    
    func setupAudioPlayer() {
        if let path = Bundle.main.path(forResource: "song", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.volume = 1.0
                audioPlayer?.prepareToPlay()
                audioPlayer?.delegate = self
            } catch {
                print("Error initializing audio player: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found")
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            //TODO: Add your performance review logic here
            print("Song finished playing")
        }
    }

    
    
}


