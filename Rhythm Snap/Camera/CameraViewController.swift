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
    
    var bpmTracker: BpmTracker?
    private var lastUpdateTime: TimeInterval?

    
    private var gestureProcessor = HandGestureProcessor()
    private var evidenceBuffer = [HandGestureProcessor.PointsPair]()
    
    private var lastObservationTimestamp = Date()
    
    private var cameraFeedSession: AVCaptureSession?
    
    override func loadView() {
        view = CameraPreview()
    }
    
    private var cameraView: CameraPreview{ view as! CameraPreview}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add state change handler to hand gesture processor.
        gestureProcessor.didChangeStateClosure = { [weak self] state in
            self?.handleGestureStateChange(state: state)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do{
            
            if cameraFeedSession == nil{
                try setupAVSession()
                
                cameraView.previewLayer.session = cameraFeedSession
                //MARK: Commented out cause it cropped
             //   cameraView.previewLayer.videoGravity = .resizeAspectFill
            }
            
            //MARK: Surronded the code into a DispatchQueue Cause we were having crashes
            DispatchQueue.global(qos: .userInteractive).async {
                self.cameraFeedSession?.startRunning()
               }
            
            
            
          
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
    
    
    //MARK: Vision Functions and Init Below
    
    private let handPoseRequest : VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        return request
    }()
 
    var pointsProcessorHandler: (([CGPoint]) -> Void)?
    
    func snapProcessPoints(thumbTip: CGPoint?, middleTip: CGPoint?) {
        // Check that we have both points.
        
        guard let thumbPoint = thumbTip, let middlePoint = middleTip else {
            // If there were no observations for more than 2 seconds reset gesture processor.
            
            //MARK: Change the time interval to BPM Time in MS
            if Date().timeIntervalSince(lastObservationTimestamp) > (0.6316 ) {
                gestureProcessor.reset()
            }
           // cameraView.showPoints([], color: .clear)
            return
        }
        
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        let previewLayer = cameraView.previewLayer
        
        let thumbPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: thumbPoint)
        let middlePointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: middlePoint)
        
        // Process new points
        gestureProcessor.processPointsPair((thumbPointConverted, middlePointConverted))
    }
    
    private func handleGestureStateChange(state: HandGestureProcessor.State) {
        let pointsPair = gestureProcessor.lastProcessedPointsPair

        switch state {
        case .possibleTap, .possibleApart:
            evidenceBuffer.append(pointsPair)

        case .tapped:
            evidenceBuffer.removeAll()
            testBPMTap(with: pointsPair, from: "Tapped")

        case .apart, .unknown:
            evidenceBuffer.removeAll()
        }
      
    }
    
    //TODO: MAke update path be a log BPM Button

    
    private func testBPMTap(with points: HandGestureProcessor.PointsPair, from source: String) {
        
        let currentTime = Date().timeIntervalSince1970

        if let lastUpdate = lastUpdateTime, currentTime - lastUpdate < 0.8 {
            // If less than 0.8 seconds have passed since the last update, return without updating the path
            return
        }
        
        bpmTracker!.logBPM()
        lastUpdateTime = currentTime
        
        print("called from \(source)")
        print("They're touching Update Path")
     
    }
    
    
    func processPointsOverlays(_ fingerTips: [CGPoint]) {

       let convertedPoints = fingerTips.map {
         cameraView.previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
       }

       pointsProcessorHandler?(convertedPoints)
     }
    
}


extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    //MARK: Handler, Observation and General Output processing
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        var fingerTips: [CGPoint] = []
        
        var thumbCGPoint : CGPoint?
        var middlefingerCG : CGPoint?
        
        defer {
          DispatchQueue.main.sync {
              self.snapProcessPoints(thumbTip: thumbCGPoint, middleTip: middlefingerCG)
              
              if bpmTracker!.songDone == true{
                  //MARK: This line is responsible for displaying the overlays. I just don't want to constantly redraw the view during the song
                  self.processPointsOverlays(fingerTips)
              }
              
          }
        }

        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer,   orientation: .up,   options: [:])
        
        do{
            //MARK: Vision Processing starts here
            try handler.perform([handPoseRequest])
            
            guard let results = handPoseRequest.results?.prefix(2),  !results.isEmpty  else{
                return
            }
            
            var recognizedPoints: [VNRecognizedPoint] = []
            
            try results.forEach { observation in
                
                let fingers = try observation.recognizedPoints(.all)
                
                guard let thumbTipPoint = fingers[.thumbTip], let middleTipPoint = fingers[.middleTip] else{
                    return
                }
                
                recognizedPoints.append(thumbTipPoint)
                recognizedPoints.append(middleTipPoint)
                
                guard thumbTipPoint.confidence > 0.8 && middleTipPoint.confidence > 0.8 else{
                    return
                }
                
                thumbCGPoint = getFingerCGPoint(thumbTipPoint)
                middlefingerCG = getFingerCGPoint(middleTipPoint)
                
                fingerTips = recognizedPoints.filter {  $0.confidence > 0.8 }
                .map {
                    // Vision algorithms use a coordinate system with lower left origin and return normalized values relative to the pixel dimension of the input image. AVFoundation coordinates have an upper-left origin, so you convert the y-coordinate.
                    CGPoint(x: $0.location.x, y: 1 - $0.location.y)
                }
                
            }
        }
        catch{
            cameraFeedSession?.stopRunning()
        }
        
    }
    
}

