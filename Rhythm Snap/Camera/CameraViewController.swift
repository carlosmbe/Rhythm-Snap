//
//  CameraViewController.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-03-18.
//

import AVFoundation
import UIKit
import Vision

enum errors: Error{
    //TODO: Write actual error cases
    case TooLazyToWrite
}

final class CameraViewController : UIViewController{
    
    private var cameraFeedSession: AVCaptureSession?
    
    override func loadView() {
        view = CameraPreview()
    }
    
    private var cameraView: CameraPreview{ view as! CameraPreview}
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do{
            if cameraFeedSession == nil{
                try setupAVSession()
                cameraView.previewLayer.session = cameraFeedSession
                //MARK: Commented out cause it cropped
             //   cameraView.previewLayer.videoGravity = .resizeAspectFill
            }
            cameraFeedSession?.startRunning()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewDidDisappear(animated)
    }
    
    private let videoDataOutputQueue =
        DispatchQueue(label: "CameraFeedOutput", qos: .userInteractive)
    
    
    func setupAVSession() throws {
        //Start of setup
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw errors.TooLazyToWrite
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else{
            throw errors.TooLazyToWrite
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        guard session.canAddInput(deviceInput) else{
            throw errors.TooLazyToWrite
        }
        
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput){
            session.addOutput(dataOutput)
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        }else{
            throw errors.TooLazyToWrite
        }
        
        session.commitConfiguration()
        cameraFeedSession = session
    }
    
    
    //MARK: Vision Stuff Below
    
    private let handPoseRequest : VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        return request
    }()
    
 
    var pointsProcessorHandler: (([CGPoint]) -> Void)?

    func processPoints(_ fingerTips: [CGPoint]) {
      
      let convertedPoints = fingerTips.map {
        cameraView.previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
      }

      pointsProcessorHandler?(convertedPoints)
    }
    
}


extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    //Handler and Observation
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        var fingerTips: [CGPoint] = []
        defer {
          DispatchQueue.main.sync {
            self.processPoints(fingerTips)
          }
        }


        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer,   orientation: .up,   options: [:])
        
        do{
            try handler.perform([handPoseRequest])
            
            guard let results = handPoseRequest.results?.prefix(2),     !results.isEmpty  else{
                return
            }
            
            print(results)
            //Drawing results
            
            var recognizedPoints: [VNRecognizedPoint] = []
            
            try results.forEach { observation in
                
                let fingers = try observation.recognizedPoints(.all)
               // MagicWithHands(fingers: fingers)
                
                if let thumbTipPoint = fingers[.thumbTip] {
                    recognizedPoints.append(thumbTipPoint)
                    if thumbTipPoint.confidence > 0.9{
                        
                        let thumbCGPoint = getFingerCGPoint(thumbTipPoint)
                        
                        if fingers[.middleTip]?.confidence ?? 0.0 > 0.8 {
                            
                            let middle = fingers[.middleTip]!
                            
                            recognizedPoints.append(middle)
                            let middlefingerCG = getFingerCGPoint(middle)
                            
                            
                            let threshold: Double = 0.021
                            if thumbTipPoint.distance(middle) < threshold {
                                
                                playMajorChord()//G V
                                //  fingerReconsied(thumbTipCG: thumbCGPoint, otherFinger: littlefingerCG, fingerName: "Little")
                            }
                            
                        }
                    }
                }
                
                
                //MARK: The following code was moved into a different function(MagicWithHands) for readablity. I'm keeping it here for reference.
                
                
                /*
                if let thumbTipPoint = fingers[.thumbTip] {
                    recognizedPoints.append(thumbTipPoint)
                    if thumbTipPoint.confidence > 0.9{
                        
                        
                        
                        if fingers[.indexTip]?.confidence ?? 0.0 > 0.9{
                            recognizedPoints.append(fingers[.indexTip]!)
                            playMajorChord(finger: "Index")//Default c I
                        }else
                        
                        if fingers[.middleTip]?.confidence ?? 0.0 > 0.9 {
                            recognizedPoints.append(fingers[.middleTip]!)
                            playMajorChord(root: 65, finger: "Middle")//F IV
                        }else
                        
                        if fingers[.littleTip]?.confidence ?? 0.0 > 0.9 {
                            recognizedPoints.append(fingers[.littleTip]!)
                            playMajorChord(root: 67, finger: "Little")//G V
                        }
                        
                      /*  if let indexTipPoint = fingers[.indexTip]  {
                            if indexTipPoint.confidence > 0.9{
                                recognizedPoints.append(indexTipPoint)
                                playMajorChord()
                            }
                        }else
                        
                        if let middleTipPoint = fingers[.middleTip] {
                            recognizedPoints.append(middleTipPoint)
                        }else
                        if let ringTipPoint = fingers[.ringTip] {
                            recognizedPoints.append(ringTipPoint)
                        }else
                        if let littleTipPoint = fingers[.littleTip] {
                            recognizedPoints.append(littleTipPoint)
                        }
                       */
                    }
                }
                
                */
            }
            
            fingerTips = recognizedPoints.filter {
              $0.confidence > 0.9
            }
            .map {
              // Vision algorithms use a coordinate system with lower left origin and return normalized values relative to the pixel dimension of the input image. AVFoundation coordinates have an upper-left origin, so you convert the y-coordinate.
              CGPoint(x: $0.location.x, y: 1 - $0.location.y)
            }
            
            
        }catch{
            cameraFeedSession?.stopRunning()
        }
        
    }
    
}

