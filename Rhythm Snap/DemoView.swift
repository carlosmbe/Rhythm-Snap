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
        
        VStack{
            
            
            Text("This section illustrates how the camera is tracking your fingers")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            
            Text("There should be a purple dot on your thumb and middle finger\n Lighting and Environmental Factors may cause a less than ideal experience.\n Use the 'Tempo Button' toggle in such situations")
                .multilineTextAlignment(.center)
                .padding()
            
            
            CameraViewFinder
                .rotationEffect(bpmTracker.rotateAngle)
                .padding()
            
            Text("Press the Start Session Button when ready")
                .font(.title)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .multilineTextAlignment(.center)
               .padding([.bottom, .top], 20)
               .foregroundStyle(
                
                LinearGradient(
                    colors: [.red, .blue, .green, .yellow],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        
            
            
            
        }
    }
    


struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        DemoView()
    }
}
