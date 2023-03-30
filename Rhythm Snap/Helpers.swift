//
//  Helpers.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-03-30.
//


import Foundation
import SwiftUI
import Vision

public class Time_Control:Thread{

    var wait_time:Double //In seconds
    public var can_send:Bool = true

    init(_ wait_time:Double) {
        self.wait_time = wait_time
    }

    public override func start() {
        super.start()

        self.can_send = false
        Thread.self.sleep(forTimeInterval: TimeInterval(self.wait_time))
        self.can_send = true
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
