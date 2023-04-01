//
//  CameraView.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-03-18.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable{
    
    @EnvironmentObject var bpmTracker: BpmTracker
    
    var pointsProcessorHandler: (([CGPoint]) -> Void)?
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cvc = CameraViewController()
        cvc.pointsProcessorHandler = pointsProcessorHandler
        cvc.bpmTracker = bpmTracker
        return cvc
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        //Not needed for this app
    }
}
