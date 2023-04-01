//
//  ContentView.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-03-17.
//

import AVFoundation
import SwiftUI

struct ContentView: View {
    
    //MARK: Overlays work. Not using overlay array with chords right nnow. Mainly for debugging
    @State private var overlayPoints: [CGPoint] = []
    
    var CameraViewFinder : some View{
        CameraView {    overlayPoints = $0  }
            .overlay(FingersOverlay(with: overlayPoints)
                .foregroundColor(.green)
            )
            .ignoresSafeArea()
        
    }
    
    var body: some View {
       
        ZStack {
            CameraViewFinder.rotationEffect(.degrees(90))

            BPMView()
        }
    }
}

struct BPMView: View {
    
    @State private var logged = false
    
    @State private var performance = ""
    @State private var perfColour = Color.purple
    
    @State private var startDate = Date.now
    
    @State private var timeElapsed: Int = 0
    
    let timer = Timer.publish(every:  0.6316 * 2, on: .main, in: .common).autoconnect()
    
    @State private var allAccurateBeats = [TimeInterval]()
    
    @State private var userBeats = [TimeInterval]()
    
    @State private var userLoggedTimes = [TimeInterval]()
    
    func logBPM(){
        
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
    
    var body: some View {
        VStack {
            
            if logged{
                
                Circle()
                    .fill(perfColour)
                    .frame(width: 12, height: 12)
                    .modifier(ParticlesModifier())
                    .offset(x: -100, y : -50)
                
                    .onReceive(timer){ _ in
                        logged = false
                    }
                
            }
            
            
            Button("Log Time", action: logBPM)
                .buttonStyle(.borderedProminent)
                .padding()
            
            Text(performance)
                .foregroundColor(perfColour)
                .padding()
            
            Text("Counts: \(timeElapsed) sec")
                     // 2
                .onReceive(timer) { firedDate in
                    
                    AudioServicesPlaySystemSound(SystemSoundID(1057))
                    
                    let bpm =  0.6316 * 2//632MS is 1/4 at 95 BPM Tempo. That's what somber dreams is at
                    
                    let fullInterval = firedDate.timeIntervalSince(startDate)
                    allAccurateBeats.append(fullInterval)
                    
                 
                   // print(allAccurateBeats)
                 
                    if timeElapsed >= 2 {  timeElapsed = 1
                    }  else{ timeElapsed += 1    }
                    
                    
                    //Ok so the way we're doing this is that we're going to divide each time the user logs and then divide it by the number of seconds needed to perform a perfect bpm
                    
                    
                    //MARK: IDEA FROM INTERNET: just store the start date and then get the time interval since now. The only issue is that would always return negative result. Just swap the dates to get positive result Date().timeIntervalSince(startDate)
                    
                    //MARK: Idea to test time ratio have a second timer that fires a tick tock sound at the number we're dividing by
                }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct FingersOverlay: Shape {
    let points: [CGPoint]
    private let pointsPath = UIBezierPath()
    
    init(with points: [CGPoint]) {
        self.points = points
    }
    
    func path(in rect: CGRect) -> Path {
        for point in points {
            pointsPath.move(to: point)
            pointsPath.addArc(withCenter: point, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        }
        
        return Path(pointsPath.cgPath)
    }
}
