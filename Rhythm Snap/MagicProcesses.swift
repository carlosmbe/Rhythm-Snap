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
    
    if let thumbTipPoint = fingers[.thumbTip] {
        recognizedPoints.append(thumbTipPoint)
        if thumbTipPoint.confidence > 0.9{
            
            let thumbCGPoint = getFingerCGPoint(thumbTipPoint)
            
            if fingers[.middleTip]?.confidence ?? 0.0 > 0.8 {
                
                let middle = fingers[.middleTip]!
               
                recognizedPoints.append(middle)
                let middlefingerCG = getFingerCGPoint(middle)
                
                
                let threshold: Double = 0.1
                if thumbTipPoint.distance(middle) < threshold {
                    
                    playMajorChord()//G V
                  //  fingerReconsied(thumbTipCG: thumbCGPoint, otherFinger: littlefingerCG, fingerName: "Little")
                }
            
            }
            /*else
            
            if fingers[.middleTip]?.confidence ?? 0.0 > 0.9 {
                recognizedPoints.append(fingers[.middleTip]!)
                playMajorChord(root: 65, finger: "Middle")//F IV
            }else
            
            if fingers[.indexTip]?.confidence ?? 0.0 > 0.9{
                recognizedPoints.append(fingers[.indexTip]!)
                playMajorChord(finger: "Index")//Default c I
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
              */
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
        playMajorChord()//G V
    }
}

