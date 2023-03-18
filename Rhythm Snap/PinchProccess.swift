//
//  PinchProccess.swift
//  Rhythm Snap
//
//  Created by Carlos Mbendera on 2023-03-18.
//

import CoreGraphics

class HandGestureProcessor {
    enum State {
        case possiblePinch
        case pinched
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
    
    private var pinchEvidenceCounter = 0
    private var apartEvidenceCounter = 0
    private let pinchMaxDistance: CGFloat
    private let evidenceCounterStateTrigger: Int
    
    var didChangeStateClosure: ((State) -> Void)?
    
    private (set) var lastProcessedPointsPair = PointsPair(.zero, .zero)
    
    init(pinchMaxDistance: CGFloat = 40, evidenceCounterStateTrigger: Int = 3) {
        self.pinchMaxDistance = pinchMaxDistance
        self.evidenceCounterStateTrigger = evidenceCounterStateTrigger
    }
    
    func reset() {
        state = .unknown
        pinchEvidenceCounter = 0
        apartEvidenceCounter = 0
    }
    
    func processPointsPair(_ pointsPair: PointsPair) {
        
        lastProcessedPointsPair = pointsPair
        //The CG Point extension is in MagicProcesses
        let distance = pointsPair.middleTip.distance(from: pointsPair.thumbTip)
        if distance < pinchMaxDistance {
            // Keep accumulating evidence for pinch state.
            pinchEvidenceCounter += 1
            apartEvidenceCounter = 0
            // Set new state based on evidence amount.
            state = (pinchEvidenceCounter >= evidenceCounterStateTrigger) ? .pinched : .possiblePinch
        } else {
            // Keep accumulating evidence for apart state.
            apartEvidenceCounter += 1
            pinchEvidenceCounter = 0
            // Set new state based on evidence amount.
            state = (apartEvidenceCounter >= evidenceCounterStateTrigger) ? .apart : .possibleApart
        }
    }
}
