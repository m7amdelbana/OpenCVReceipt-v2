//
//  Main+Motion.swift
//  OpenCVReceipt
//
//  Created by Mohamed Elbana on 3/24/20.
//  Copyright © 2020 Mohamed Elbana. All rights reserved.
//

import UIKit
import CoreMotion

extension MainController {
    
    func startDetectDeviceMotion() {
        motion.deviceMotionUpdateInterval = 0.5
        motion.startDeviceMotionUpdates(to: OperationQueue.current!) { (data, error) in
            if let data = data {
                self.yPosition = Double(data.attitude.roll).rounded(toPlaces: 3)
            }
        }
    }
    
    func stopDetectDeviceMotion() {
        motion.stopDeviceMotionUpdates()
        yPosition = 0.0
    }
}
