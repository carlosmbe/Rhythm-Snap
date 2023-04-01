//
//  PinchProccess.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-03-18.
//

import CoreGraphics
import Foundation

class HandGestureProcessor {
    enum State {
        case possibleTap
        case tapped
        case possibleApart
        case apart
        case unknown
    }
    
    //MARK: Type Alias is basically a refrence or shorthand. Whenever PointsPair appears (thumbTip: CGPoint, middleTip: CGPoint) is actaully written
  
    typealias PointsPair = (thumbTip: CGPoint, middleTip: CGPoint)
    
    private var state = State.unknown {
        didSet {
            didChangeStateClosure?(state)
        }
    }
    
    private var lastTapTimestamp: TimeInterval?
    private let tapMinDistance: CGFloat
    
    
    private var pinchEvidenceCounter = 0
    private var apartEvidenceCounter = 0
  //  private let pinchMaxDistance: CGFloat
    private let evidenceCounterStateTrigger: Int
    
    var didChangeStateClosure: ((State) -> Void)?
    
    private (set) var lastProcessedPointsPair = PointsPair(.zero, .zero)
    
    init(tapMinDistance: CGFloat = 40, evidenceCounterStateTrigger: Int = 3) {
        self.tapMinDistance = tapMinDistance
        self.evidenceCounterStateTrigger = evidenceCounterStateTrigger
    }
    func reset() {
        state = .unknown
        pinchEvidenceCounter = 0
        apartEvidenceCounter = 0
    }
    
    func processPointsPair(_ pointsPair: PointsPair) {
        lastProcessedPointsPair = pointsPair
        let distance = pointsPair.middleTip.distance(from: pointsPair.thumbTip)
        let currentTime = Date().timeIntervalSince1970

        if distance < tapMinDistance {
            if let lastTapTime = lastTapTimestamp, currentTime - lastTapTime < 0.3 {
                // If the time since the last tap is less than 0.3 seconds (or any desired threshold), it is considered a tap
                state = .tapped
                // Reset the last tap timestamp
                lastTapTimestamp = nil
            } else {
                // If the time since the last tap is greater than the threshold, store the current time as the last tap timestamp
                lastTapTimestamp = currentTime
                state = .possibleTap
            }
        } else {
            // Keep accumulating evidence for apart state.
            apartEvidenceCounter += 1
            // Set new state based on evidence amount.
            state = (apartEvidenceCounter >= evidenceCounterStateTrigger) ? .apart : .possibleApart
        }
    }
    
}
