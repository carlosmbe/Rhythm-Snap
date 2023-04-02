//
//  OnboardingView.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-04-01.
//

import SwiftUI

struct OnboardingView: View {
    @State private var selectedOption: Int? = nil
    
    

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to Rhythm Snap")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Choose your new way of practicing rhythm")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()

                NavigationLink(destination: ContentView(), tag: 1, selection: $selectedOption) {
                    VStack {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 60))
                        Text("Camera x Vision")
                            .font(.headline)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                }

                NavigationLink(destination: BPMView(showLogButton: true), tag: 2, selection: $selectedOption) {
                    VStack {
                        Image(systemName: "rectangle")
                            .font(.system(size: 60))
                        Text("Button")
                            .font(.headline)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                }

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
