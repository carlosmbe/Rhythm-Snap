//
//  ContentView.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-03-17.
//

import AVFoundation
import SwiftUI


struct ContentView: View {
    
    @EnvironmentObject var bpmTracker: BpmTracker
    
    
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
            CameraViewFinder.rotationEffect(.degrees(-90))

            BPMView().environmentObject(bpmTracker)
            
        }
    }
}


struct BPMView: View {
    
    @EnvironmentObject var bpmTracker: BpmTracker

    var body: some View {
        VStack {
            
            if bpmTracker.logged{
                
                Circle()
                    .fill(bpmTracker.perfColour)
                    .frame(width: 12, height: 12)
                    .modifier(ParticlesModifier())
                    .offset(x: -100, y : -50)
                
                    .onReceive(bpmTracker.timer){ _ in
                        bpmTracker.logged = false
                    }
                
            }
            
            
            Button("Log Time", action: bpmTracker.logBPM)
                .buttonStyle(.borderedProminent)
                .padding()
            
            Text(bpmTracker.performance)
                .foregroundColor(bpmTracker.perfColour)
                .padding()
            
            Text(bpmTracker.testName).font(.title)
            
            Text("Counts: \(bpmTracker.timeElapsed) sec")
                     // 2
                .onReceive(bpmTracker.timer) { firedDate in
                    
                    AudioServicesPlaySystemSound(SystemSoundID(1057))
                    
                    let bpm =  0.6316 * 2//632MS is 1/4 at 95 BPM Tempo. That's what somber dreams is at
                    
                    let fullInterval = firedDate.timeIntervalSince(bpmTracker.startDate)
                    bpmTracker.allAccurateBeats.append(fullInterval)
                    
                 
                    if bpmTracker.timeElapsed >= 2 {  bpmTracker.timeElapsed = 1
                    }  else{ bpmTracker.timeElapsed += 1    }
                    
                    
                }
        }
        .padding()
    }
}

/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(bpmTracke)
    }
}
*/

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
