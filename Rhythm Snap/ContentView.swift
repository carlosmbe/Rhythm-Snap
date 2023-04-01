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

            BPMView()
                .environmentObject(bpmTracker)
        }
    }
}


struct BPMView: View {
    
    @EnvironmentObject var bpmTracker: BpmTracker
    
    var body: some View {
        VStack {
            
            if bpmTracker.logged {
                
                Circle()
                    .fill(bpmTracker.perfColour)
                    .frame(width: 12, height: 12)
                    .modifier(ParticlesModifier())
                    .offset(x: -100, y : -50)
                
                // Use Timer for the visual effect
                    .onReceive(bpmTracker.timer){ _ in
                    bpmTracker.logged = false
                }
                
            }
            
            Text(bpmTracker.performance)
                .foregroundColor(bpmTracker.perfColour)
                .padding()
            
            Text("Counts: \(bpmTracker.allAccurateBeats.count % 2 + 1) beats")
                // Use bpmTracker.timer for the audio effect and beat count
                .onReceive(bpmTracker.timer) { _ in
                    
                    AudioServicesPlaySystemSound(SystemSoundID(1057))
                    
                    let currentTime = Date().timeIntervalSince(bpmTracker.startDate)
                    bpmTracker.allAccurateBeats.append(currentTime)
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
