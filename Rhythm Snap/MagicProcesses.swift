//
//  MagicProcesses.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-03-18.
//

import Foundation
import Vision




func MagicWithHands(fingers:  [VNHumanHandPoseObservation.JointName : VNRecognizedPoint] ){
   
    //MARK: The other finger tips are commented out as at the moment I want to find a good THRESHOLD Distance and test it out
    
    var recognizedPoints: [VNRecognizedPoint] = []
    
    if let thumbTipPoint = fingers[.thumbTip], let middleTipPoint = fingers[.middleTip]{
        recognizedPoints.append(thumbTipPoint)
        recognizedPoints.append(middleTipPoint)
        
        if thumbTipPoint.confidence > 0.7 && middleTipPoint.confidence > 0.7{
            
            let thumbCGPoint = getFingerCGPoint(thumbTipPoint)
            let middlefingerCG = getFingerCGPoint(middleTipPoint)
                
            let threshold: Double = 0.1
                  
                if thumbTipPoint.distance(middleTipPoint) < threshold {
                        print("They're touching")
                        playMajorChord()//G V

                    }
            }
        }
    }
    
    

func getFingerCGPoint(_ finger: VNRecognizedPoint) -> CGPoint{
    CGPoint(x: finger.location.x,   y: 1 - finger.location.y)
}

func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
     (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
}

func fingerReconsied(thumbTipCG : CGPoint, otherFinger : CGPoint, fingerName : String){

    let distance =  CGPointDistanceSquared(from: thumbTipCG, to: otherFinger)
    print("Distance between points  is \(distance)")
    if distance < 0.01{
        print("Distance less than 0.01")
    }
}


extension CGPoint {

    static func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
    
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
    
}
