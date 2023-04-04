//
//  OnboardingView.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-04-01.
//

import SwiftUI

struct OnboardingView: View {

    @EnvironmentObject var bpmTracker: BpmTracker
        
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to Rhythm Snap")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your new way of practicing rhythm")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                NavigationLink(destination: TutorialView()) {
                    VStack{
                        Image(systemName: "book")
                            .font(.system(size: 60))
                        
                        Text("Tutorial")
                            .font(.headline)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                }
                
                
                NavigationLink(destination: DemoView()) {
                    VStack {
                        Image(systemName: "livephoto.play")
                            .font(.system(size: 60))
                        Text("Practice Vision")
                            .font(.headline)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                }
                
                
                NavigationLink(destination: ContentView()) {
                    VStack {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 60))
                        Text("Camera x Vision")
                            .font(.headline)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                }
                
                
    
                Button("Rotate Camera View"){
                    withAnimation{
                        bpmTracker.rotateAngle += Angle(degrees: 90)
                    }
                }
                .buttonStyle(.borderedProminent)
                
                
      
                
                Toggle("Show Tempo Log Button", isOn: $bpmTracker.showButton)
                    .padding()
                
               
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}


struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
