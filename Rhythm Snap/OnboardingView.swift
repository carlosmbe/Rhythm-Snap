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
                Text("Rhythm Snap")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .blue, .green, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("A new way of practicing ")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                
                Text("Pick an option to begin")
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
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 60))
                        Text("Test Vision")
                            .font(.headline)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                }
                
                
                NavigationLink(destination: ContentView()) {
                    VStack {
                        Image(systemName: "livephoto.play")
                            .font(.system(size: 60))
                        Text("Start Session")
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
