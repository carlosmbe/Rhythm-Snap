//
//  DemoView.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-04-03.
//

import SwiftUI

struct DemoView: View {
    
    @EnvironmentObject var bpmTracker: BpmTracker
    
    @State private var overlayPoints: [CGPoint] = []
    @State private var currentOrientation = UIDevice.current.orientation
    
    var CameraViewFinder : some View{
        CameraView {    overlayPoints = $0  }
            .overlay(FingersOverlay(with: overlayPoints)
                .foregroundColor(.purple)
            )
            .ignoresSafeArea()
        
    }
    
    var body: some View {
        
        Text("This section illustrates how the camera is tracking your fingers")
                           .font(.largeTitle)
                           .fontWeight(.bold)
        
        CameraViewFinder
            .rotationEffect(bpmTracker.rotateAngle)
            .padding()
            .onAppear{
                bpmTracker.songDone = true
            }
            .onDisappear{
                bpmTracker.songDone = false
            }
    }
    
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        DemoView()
    }
}
