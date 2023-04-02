//
//  WaveForm.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-04-01.
//

import AVFoundation
import Combine
import SwiftUI

struct WaveformView: View {
    @Binding var audioData: [Float]

    let gradient = Gradient(colors: [Color.blue, Color.purple])
    let lineWidth: CGFloat = 2

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<audioData.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: lineWidth)
                        .fill(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom))
                        .frame(width: geometry.size.width / CGFloat(audioData.count) - lineWidth, height: geometry.size.height / 2 * CGFloat(audioData[index]))
                        .offset(x: CGFloat(index) * geometry.size.width / CGFloat(audioData.count), y: geometry.size.height / 2 * (1 - CGFloat(audioData[index])))
                        .animation(.linear(duration: 0.1), value: audioData[index])
                }
            }
        }
    }
}


//VIEW ENDS HERE


class AudioAnalyzer: ObservableObject {
    private var audioEngine = AVAudioEngine()
    private var audioPlayer: AVAudioPlayerNode?
    
    @Published var audioData: [Float] = Array(repeating: 0.0, count: 50)

    func setupAudioPlayer() {
        let audioFileURL = Bundle.main.url(forResource: "song", withExtension: "mp3")!
        audioPlayer = AVAudioPlayerNode()
        audioEngine.attach(audioPlayer!)

        let audioFile = try! AVAudioFile(forReading: audioFileURL)
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))!
        try! audioFile.read(into: audioBuffer)

        
        audioEngine.connect(audioPlayer!, to: audioEngine.mainMixerNode, format: audioBuffer.format)
        
        audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: audioBuffer.format) { buffer, _ in
            DispatchQueue.main.async {
                self.updateAudioData(buffer: buffer)
            }
        }

        audioPlayer!.scheduleBuffer(audioBuffer, completionHandler: nil)

        try! audioEngine.start()
        audioPlayer!.play()
    }
    
    func updateAudioData(buffer: AVAudioPCMBuffer) {
        let channelData = buffer.floatChannelData![0]
        let channelDataCount = buffer.frameLength
        
        let stride = channelDataCount / UInt32(audioData.count)
        
        for i in 0..<audioData.count {
            let start = UInt32(i) * stride
            let end = start + stride
            var sum: Float = 0
            
            for j in start..<end {
                sum += abs(channelData[Int(j)])
            }
            
            audioData[i] = sum / Float(stride)
        }
    }
}

