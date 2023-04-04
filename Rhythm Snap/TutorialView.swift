//
//  TutorialView.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-04-02.
//

import SwiftUI

struct TutorialView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("First Things First")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("To use the app, follow these steps:")
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("1.")
                        .fontWeight(.bold)
                    Text("Allow camera access. So it can detect your hand gestures.")
                }
                
                HStack {
                    Text("2.")
                        .fontWeight(.bold)
                    Text("Use your thumb and middle finger to tap along with the beat and metronome.")
                }
                
                HStack {
                    Text("3.")
                        .fontWeight(.bold)
                    Text("The app will analyze your tapping rhythm and provide feedback.")
                }
                
                HStack {
                    Text("4.")
                        .fontWeight(.bold)
                    Text("Press the rotate button if the Camera View Finder is in the wrong orientation.")
                }
                
                HStack {
                    Text("5.")
                        .fontWeight(.bold)
                    Text("Enable 'Show Tempo Button' if you prefer pressing a button rather than using the camera.")
                }
                
                
                
                HStack {
                    Text("Tips")
                        .font(.subheadline)
                        .padding()
                        .fontWeight(.heavy)
                }
                Group{
                    HStack {
                        Text("1.")
                            .fontWeight(.bold)
                        Text("Show the entirity of 1 Hand with the palm to the Camera.")
                    }
                    
                    HStack {
                        Text("2.")
                            .fontWeight(.bold)
                        Text("You can see which fingers the camera is using in 'Practice Vision' or if you wait for the song's end.")
                    }
                    
                    HStack {
                        Text("3.")
                            .fontWeight(.bold)
                        Text("Use the Button if tapping with Vision is too hard.")
                    }
                    
                    HStack {
                        Text("4.")
                            .fontWeight(.bold)
                        Text("Use the app in Land Scape and do not rotate too often.")
                    }
                    
                    HStack {
                        Text("5.")
                            .fontWeight(.bold)
                        Text("Most Importantly: Have Fun. It's just practice. :D")
                            .fontWeight(.bold)
                    }
                    
                    
                }
                
                
            }
            .padding(.leading, 10)
            
            Spacer()
            
            
            
            NavigationLink(destination: DemoView())  {
                Text("Get Started")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView()
    }
}
