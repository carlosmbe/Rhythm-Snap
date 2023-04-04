//
//  ContentView.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-03-17.
//

import AVFoundation
import SwiftUI


struct ContentView: View {
    
    @State private var currentOrientation = UIDevice.current.orientation
    
    @StateObject var audioAnalyzer = AudioAnalyzer()
    @State private var progress: CGFloat = 0.0
    
    @EnvironmentObject var bpmTracker: BpmTracker
    
    //MARK: Overlays work. Not using overlay array with chords right nnow. Mainly for debugging
    @State private var overlayPoints: [CGPoint] = []
    
    var TopTextView : some View{
        VStack{
            
            Text(bpmTracker.performance)
            
                .fontWeight(.bold)
                .font(.title)
                .foregroundColor(bpmTracker.perfColour)
                .padding()
            
            Text("Count: \(bpmTracker.allAccurateBeats.count % 2 + 1) Tap")
                .fontWeight(.bold)
            // Use bpmTracker.timer for the audio effect and beat count
                .onReceive(bpmTracker.timer) { _ in
                    
                    AudioServicesPlaySystemSound(SystemSoundID(1057))
                    
                    let currentTime = Date().timeIntervalSince(bpmTracker.startDate)
                    bpmTracker.allAccurateBeats.append(currentTime)
                }
        }
    }
    
    var CameraViewFinder : some View{
        CameraView {    overlayPoints = $0  }
            .overlay(FingersOverlay(with: overlayPoints)
                .foregroundColor(.green)
            )
            .ignoresSafeArea()
        
    }
    
    var body: some View {
        VStack{
            
            TopTextView
            
            ProgressBar(value: $progress)
                .frame(height: 4)
                .padding(8)
            
            ZStack {
            
                CameraViewFinder
                    .rotationEffect(bpmTracker.rotateAngle)
                 //   .scaleEffect(currentOrientation == .landscapeRight || currentOrientation == .landscapeLeft ? 1.8 : 1)
                    .padding()
                
                
                FireworkPerfBPMView()
                    .environmentObject(bpmTracker)
            }
            
            
            WaveformView(audioData: $audioAnalyzer.audioData)
                .frame(height: 100)
                .padding()
            
            if bpmTracker.showButton{
                Button("Log Tempo", action: bpmTracker.logBPM)
                    .buttonStyle(.borderedProminent)
                    .padding()
            }
            
            Spacer()
            
        }
        
        .onAppear{
            audioAnalyzer.setupAudioPlayer()
            startUpdatingProgressBar()

        }
        
        .onDisappear{
            bpmTracker.audioPlayer?.stop()
            audioAnalyzer.stopAudio()
            bpmTracker.timer.upstream.connect().cancel()
            bpmTracker.songDone = true
        }
        
    }
    

    
   private func startUpdatingProgressBar() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard let player = bpmTracker.audioPlayer else { return }
            
            if player.isPlaying {
                progress = CGFloat(player.currentTime / player.duration)
            } else {
                timer.invalidate()
            }
        }
    }
    
}


struct FireworkPerfBPMView: View {
    
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
            
            
        }
        .padding()
        .onAppear {
            bpmTracker.setupAudioPlayer()
            bpmTracker.audioPlayer?.play()
        }
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


struct ProgressBar: View {
    @Binding var value: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.purple)
                
                Rectangle().frame(width: geometry.size.width * value, height: geometry.size.height)
                    .foregroundColor(.red)
            }
        }
    }
}


