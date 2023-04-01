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
        var tipsColor: UIColor
     
        
        switch state {
            
        case .possiblePinch, .possibleApart:
            // We are in one of the "possible": states, meaning there is not enough evidence yet to determine
            // if we want to draw or not. For now, collect points in the evidence buffer, so we can add them
            // to a drawing path when required.
            evidenceBuffer.append(pointsPair)
            tipsColor = .orange
        
        case .pinched:
            /* We have enough evidence to draw. Draw the points collected in the evidence buffer, if any.
            for bufferedPoints in evidenceBuffer {
                updatePath(with: bufferedPoints, from: "Pinched")
            }*/
            // Clear the evidence buffer.
            evidenceBuffer.removeAll()
            // Finally, draw the current point.
            updatePath(with: pointsPair, from: "Pinched")
            tipsColor = .green
            
            
        case .apart, .unknown:
            // We have enough evidence to not draw. Discard any evidence buffer points.
            evidenceBuffer.removeAll()
            // And draw the last segment of our draw path.
         //   updatePath(with: pointsPair)
            tipsColor = .red
        }
     //MARK: COMMENTED OUT CAUSE IDK WHETHERE OR NOT TO KEEP   cameraView.showPoints([pointsPair.thumbTip, pointsPair.middleTip], color: tipsColor)
    }
    
    
    
    
    
    
    //TODO: MAke update path be a log BPM Button

    
    private func updatePath(with points: HandGestureProcessor.PointsPair, from source: String) {
        print("called")
        print("They're touching Update Path")
        bpmTracker!.logBPM()
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
                
                guard thumbTipPoint.confidence > 0.4 && middleTipPoint.confidence > 0.4 else{
                    return
                }
                
                thumbCGPoint = getFingerCGPoint(thumbTipPoint)
                middlefingerCG = getFingerCGPoint(middleTipPoint)
                
                fingerTips = recognizedPoints.filter {  $0.confidence > 0.5 }
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

