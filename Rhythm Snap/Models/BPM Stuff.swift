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
    
    @Published var rotateAngle = Angle(degrees: -90)
    
    @Published var showButton = false
    
    @Published var logged = false
    @Published var songDone = false

    @Published var performance = "Ready?"
    @Published var perfColour = Color.purple
    
    @Published var timer = Timer.publish(every: 0.6316 * 2, on: .main, in: .common).autoconnect()

    
    @Published var startDate = Date()
    @Published var allAccurateBeats = [TimeInterval]()
    @Published var userBeats = [TimeInterval]()
    @Published var userLoggedTimes = [TimeInterval]()
    
    
    private let allowedTimeWindow: TimeInterval = 0.4
    private var badsInRow = 0
    
    func logBPM() {
        
        if songDone !=  true{
          
            let userTime = Date().timeIntervalSince(startDate)
            userLoggedTimes.append(userTime)
            
            let score = findNearestBeatScore(userTime)
            
            if score < allowedTimeWindow {
                
                withAnimation{
                    perfColour = Color.green
                    performance = "Good Timing"
                }
                
                badsInRow = 0
                
                let roundedFloat = Float(round(10000 * score) / 10000)
                print("Good Timing with \n \(roundedFloat)")
            } else {
                
                badsInRow += 1
                
                if badsInRow >= 1{
                    withAnimation{
                        perfColour = Color.orange
                        performance = "Needs some work"
                    }
                }
                
                print("Not bad but not great with \n \(score)")
                
            }
            
            logged = true
            
            // Update the startDate to the next beat
            let interval = 0.6316 * 2
            let nextBeat = ceil(userTime / interval) * interval
            startDate = Date(timeIntervalSinceNow: nextBeat - userTime)
        }
        
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
                //MARK: Changed the volume to zero cause of the wave form's audio
                audioPlayer?.volume = 0.0
                audioPlayer?.prepareToPlay()
                
                songDone = false
                
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
            withAnimation{
                performance = "We're Done Now.\nHope You had fun"
                perfColour = .indigo
            }
            timer.upstream.connect().cancel()
            songDone = true
            
        }
    }

    
    
}


